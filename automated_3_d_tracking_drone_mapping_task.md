# Automated 3D Tracking & Drone Mapping — **task.md**

A hands‑off pipeline for turning **any video** (especially drone footage) into a **3D‑tracked camera**, point cloud, and optional dense mesh—using **free, open‑source** tools: **FFmpeg + COLMAP + Blender**.

> Goal: Drop videos into a folder → run one command → get a Blender scene with a rock‑solid tracked camera + point cloud (and optionally a dense mesh), ready for VFX or mapping.

---

## 0) Quick Start (TL;DR)

1) **Install**
   - Windows (RTX 4080): download **COLMAP (CUDA)** and **FFmpeg**.
   - macOS (M‑series): install via Homebrew: `brew install colmap ffmpeg`.
2) **Folder scaffold**: run the scaffold script below (creates `01_colmap/ 02_videos/ 03_ffmpeg/ 04_scenes/ 05_scripts/`).
3) **Drop footage** into `02_videos/`.
4) **Run** `run_all.bat` (Windows) or `run_all.sh` (macOS/Linux).
5) **Open Blender** → **File ▸ Import ▸ Photogrammetry (COLMAP Model/Workspace)** → point to the scene folder inside `04_scenes/<video_name>/`.
6) (Optional) In Blender’s Movie Clip Editor, build **proxies** (50% or 25%) for smooth playback.

You’re done. 🎬➡️🟦➡️🟩

---

## 1) Why this pipeline?
- **Fully automated**: no manual trackers or lens/focal metadata required.
- **Robust**: handles shaky/handheld and many real‑world scenes.
- **Open‑source**: FFmpeg, COLMAP, Blender add‑on.
- **Drone‑friendly**: captures long paths; optional GPS hints; scalable for mapping.

> Important: **Turn off image stabilization** in camera settings before recording (optical/digital). For phones, use the **Blackmagic Camera** app with stabilization **Off** and lens correction **On**.

---

## 2) Dependencies

### Windows (recommended for RTX GPUs)
- **COLMAP (CUDA)**: download latest CUDA build; unzip into `01_colmap/`.
- **FFmpeg** (static build): unzip into `03_ffmpeg/`.
- **Blender** ≥ 4.0 (OpenGL backend).
- **Photogrammetry Importer** Blender add‑on (from sbcv) — install the zip in Blender.

### macOS (Apple Silicon)
```bash
brew install colmap ffmpeg
```
- Blender ≥ 4.0 (use **OpenGL**, not Vulkan).
- Photogrammetry Importer add‑on.

---

## 3) Project Structure

```
AutomatedTracker/
├─ 01_colmap/          # COLMAP binaries (Windows) or just leave empty on macOS if using Homebrew
├─ 02_videos/          # Drop *.mp4 / *.mov here
├─ 03_ffmpeg/          # FFmpeg binaries (Windows) or empty on macOS
├─ 04_scenes/          # Output (auto‑created per video)
└─ 05_scripts/         # Pipeline scripts, config
```

> Each processed video creates `04_scenes/<video_stem>/` with: `images/`, `database.db`, `sparse/` (and optionally `dense/`).

---

## 4) Config (edit me)
Create `05_scripts/config.yaml`:
```yaml
# Frame extraction
frame_rate: 12              # frames per second to extract from video
max_dim_px: 2048            # long edge resize for images; set 0 to keep native
image_ext: jpg              # jpg|png
jpg_quality: 95             # if jpg

# COLMAP options (safe defaults)
colmap:
  use_gpu: true             # set false on CPU‑only machines
  feature_type: SIFT        # SIFT recommended
  sift_max_num_features: 12000
  exhaustive_matcher: false # set true for tough clips; slower
  vocab_tree_matcher: true  # use if you have vocab tree file, else false
  mapper_min_model_size: 20
  mapper_min_tri_angle: 1.5
  mapper_multiple_models: false
  undistort: true
  dense_reconstruction: true # set false if you only want the tracked camera + sparse cloud
  stereo_max_image_size: 2048

# Advanced (optional)
prior:
  use_gps: false            # true if you prepare GPS priors (see §9)
  gps_sigma: 5.0            # meters

# Blender import hints (docs only)
blender:
  suppress_distortion_warnings: true
  import_points_as_mesh: true
```

---

## 5) Scripts

### 5.1 Windows — `05_scripts/run_all.bat`
```bat
@echo off
setlocal enabledelayedexpansion

REM Root is the script folder’s parent
pushd %~dp0
cd ..
set ROOT=%cd%

set COLMAP_DIR=%ROOT%\01_colmap
set FFMPEG_DIR=%ROOT%\03_ffmpeg
set VIDEOS_DIR=%ROOT%\02_videos
set SCENES_DIR=%ROOT%\04_scenes
set CONFIG=%ROOT%\05_scripts\config.yaml

REM Add local bins to PATH (Windows portable)
set PATH=%COLMAP_DIR%;%COLMAP_DIR%\bin;%FFMPEG_DIR%;%FFMPEG_DIR%\bin;%PATH%

for %%F in (%VIDEOS_DIR%\*.mp4 %VIDEOS_DIR%\*.mov) do (
  if exist "%%F" (
    call :PROCESS "%%~fF"
  )
)

echo Done.
popd
exit /b 0

:PROCESS
set VIDEO=%~1
for %%I in ("%VIDEO%") do set STEM=%%~nI
set OUT=%SCENES_DIR%\%STEM%
set IMG=%OUT%\images
if not exist "%OUT%" mkdir "%OUT%"
if not exist "%IMG%" mkdir "%IMG%"

REM Read config (minimal; for full YAML parsing, use Python version)
REM Defaults if not using Python helper
set FPS=12
set MAXDIM=2048
set EXT=jpg
set Q=2

REM Extract frames
ffmpeg -y -i "%VIDEO%" -vf "fps=%FPS%,scale='if(gt(a,1),%MAXDIM%,-1)':'if(gt(a,1),-1,%MAXDIM%)':flags=lanczos" -qscale:v %Q% "%IMG%\frame_%06d.%EXT%"

REM Initialize COLMAP database/paths
colmap feature_extractor --ImageReader.single_camera 1 --ImageReader.camera_model OPENCV --SiftExtraction.gpu_index 0 --SiftExtraction.use_gpu 1 --database_path "%OUT%\database.db" --image_path "%IMG%"
colmap exhaustive_matcher --SiftMatching.gpu_index 0 --SiftMatching.use_gpu 1 --database_path "%OUT%\database.db"

mkdir "%OUT%\sparse"
colmap mapper --database_path "%OUT%\database.db" --image_path "%IMG%" --output_path "%OUT%\sparse"

if exist "%OUT%\sparse\0" (
  if not exist "%OUT%\undistorted" mkdir "%OUT%\undistorted"
  colmap image_undistorter --image_path "%IMG%" --input_path "%OUT%\sparse\0" --output_path "%OUT%\undistorted" --output_type COLMAP
  mkdir "%OUT%\dense"
  colmap patch_match_stereo --workspace_path "%OUT%\undistorted" --workspace_format COLMAP --PatchMatchStereo.gpu_index 0
  colmap stereo_fusion --workspace_path "%OUT%\undistorted" --workspace_format COLMAP --input_type geometric --output_path "%OUT%\dense\fused.ply"
  colmap poisson_mesher --input_path "%OUT%\dense\fused.ply" --output_path "%OUT%\dense\mesh.ply"
) else (
  echo [WARN] Mapper produced no model for %STEM%.
)

echo Finished %STEM%.
exit /b 0
```

### 5.2 macOS/Linux — `05_scripts/run_all.sh`
```bash
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
COLMAP_BIN="colmap"      # Homebrew installs into PATH
FFMPEG_BIN="ffmpeg"
VIDEOS_DIR="$ROOT/02_videos"
SCENES_DIR="$ROOT/04_scenes"

shopt -s nullglob
for f in "$VIDEOS_DIR"/*.mp4 "$VIDEOS_DIR"/*.mov; do
  stem="$(basename "${f%.*}")"
  out="$SCENES_DIR/$stem"
  img="$out/images"
  mkdir -p "$img"

  fps=12
  maxdim=2048
  ext=jpg

  $FFMPEG_BIN -y -i "$f" -vf "fps=${fps},scale='if(gt(a,1),${maxdim},-1)':'if(gt(a,1),-1,${maxdim})':flags=lanczos" -qscale:v 2 "$img/frame_%06d.$ext"

  $COLMAP_BIN feature_extractor --ImageReader.single_camera 1 --ImageReader.camera_model OPENCV --SiftExtraction.use_gpu 1 --database_path "$out/database.db" --image_path "$img"
  $COLMAP_BIN exhaustive_matcher --SiftMatching.use_gpu 1 --database_path "$out/database.db"

  mkdir -p "$out/sparse"
  $COLMAP_BIN mapper --database_path "$out/database.db" --image_path "$img" --output_path "$out/sparse"

  if [[ -d "$out/sparse/0" ]]; then
    mkdir -p "$out/undistorted" "$out/dense"
    $COLMAP_BIN image_undistorter --image_path "$img" --input_path "$out/sparse/0" --output_path "$out/undistorted" --output_type COLMAP
    $COLMAP_BIN patch_match_stereo --workspace_path "$out/undistorted" --workspace_format COLMAP --PatchMatchStereo.gpu_index 0 || true
    $COLMAP_BIN stereo_fusion --workspace_path "$out/undistorted" --workspace_format COLMAP --input_type geometric --output_path "$out/dense/fused.ply"
    $COLMAP_BIN poisson_mesher --input_path "$out/dense/fused.ply" --output_path "$out/dense/mesh.ply"
  else
    echo "[WARN] Mapper produced no model for $stem"
  fi
  echo "Finished $stem"
done
```

> Notes
> - These scripts use **exhaustive matching** (reliable, slower). For long clips you can swap to **sequential matcher** for speed.
> - The Windows BAT reads minimal config; for full YAML control, use the Python helper (§5.3) or adapt to PowerShell.

### 5.3 Optional Python helper — single clip runner (cross‑platform)
Create `05_scripts/colmap_auto.py` if you prefer a Python‑first flow (easier config parsing & logging). Pseudocode outline:
```python
# 1) Parse config.yaml
# 2) For each video in 02_videos/:
#    - Extract frames with ffmpeg (subprocess)
#    - Run COLMAP subcommands in order
#    - Write a JSON report with timings, counts, and failure reasons
# 3) Emit a .blend import tip file into 04_scenes/<stem>/README.md
```

---

## 6) Blender Import
- **Add‑on**: Install Photogrammetry Importer (zip) in Preferences ▸ Add‑ons.
- **Backend**: Preferences ▸ System ▸ **OpenGL**.
- **Import**: File ▸ Import ▸ **COLMAP Model/Workspace**
  - Point to `04_scenes/<video_stem>/undistorted/` (or `sparse/0/`), enable **Suppress distortion warnings**, and (optional) **Import points as mesh**.
- **Camera**: Hide still cameras; select the **animated** camera. View ▸ Cameras ▸ Set Active.
- **Proxies** (smoother playback): Movie Clip Editor ▸ set **Proxy/Timecode** (50% or 25%) ▸ **Build Proxy** → In Camera Background Images: set Proxy size to match.

---

## 7) Recommended capture settings (drone & handheld)
- **Turn OFF stabilization** (optical/digital).
- **Frame rate**: 24–30 fps is fine; extraction at **8–12 fps** usually sufficient.
- **Shutter**: avoid excessive motion blur (180° rule or faster).
- **Texture**: prefer textured surfaces; avoid feature‑less water/sky.
- **Parallax**: orbit/translate rather than pure yaw.
- **Lighting**: overcast is great; avoid large speculars.

---

## 8) Scaling to real‑world units
COLMAP outputs an **arbitrary scale**. Pick one:
1) **Known distance**: In Blender, place a reference edge; scale scene so two points match a measured distance on the ground.
2) **GPS priors** (advanced): provide image GPS EXIF or DJI SRT track → import as COLMAP priors (see §9). This aligns approximately to meters.

---

## 9) (Advanced) GPS priors from DJI footage
- Many DJI drones write a **.SRT subtitle** with lat/lon/alt/heading per frame.
- Extract SRT → build a `images.txt`/`positions.txt` prior for COLMAP (`--ImageReader.single_camera 0`, `--Mapper.ba_global_function_tolerance 1e-12`, etc.).
- Rough recipe:
  1) Extract frames at `N` fps and make an index ↔ timestamp table.
  2) Parse SRT rows → interpolate to frame timestamps.
  3) Write a COLMAP `images.txt` prior or use `--ImageReader.camera_params_prior` via database updates.
- GPS priors **don’t need to be perfect**; they help long, repetitive paths.

> Future improvement: add `05_scripts/gps_priors.py` that reads `<video>.srt` and emits a `priors.csv` to seed COLMAP.

---

## 10) Performance knobs
- **Frame stride**: lower `frame_rate` to reduce images.
- **Resize**: clamp `max_dim_px` to 1600–2048 for speed.
- **Matcher**: sequential matcher for long paths; exhaustive for short clips.
- **GPU**: ensure COLMAP sees your CUDA device (`--SiftExtraction.use_gpu 1`).
- **Dense**: disable dense reconstruction when you only need camera + sparse points.

---

## 11) Troubleshooting
- **No model produced**: scene lacks parallax/features; reduce frame rate; try `exhaustive_matcher: true`; shoot again with more lateral motion.
- **Jello/rolling‑shutter artifacts**: reduce shutter angle; avoid rapid pans.
- **Blender shows nothing**: switch backend to **OpenGL**; enable **display point cloud**; check you imported from `sparse/0` or `undistorted`.
- **Playback stutters**: build proxies; use SSD; hide point cloud while previewing.
- **Weird orientation**: rotate root collection; set navigation to **Trackball**.

---

## 12) Roadmap (nice‑to‑haves)
- [ ] Python pipeline with rich logs & YAML config
- [ ] GPS priors from DJI SRT/EXIF
- [ ] Auto‑export
  - [ ] Blender .blend template with compositor & proxy setup
  - [ ] Alembic/FBX camera export for Unreal/Nuke/AE
- [ ] Web preview of point clouds (PLY → Potree/Three.js)
- [ ] Batch datasets; nightly runs

---

## 13) Legal & safety
- Fly within **Part 107/recreational** rules; respect **no‑fly zones**.
- For cold weather: warm batteries; avoid icing; keep within manufacturer temp limits.
- Blur PII (faces/plates) in deliverables when needed.

---

## 14) Command Cheatsheet
- **Windows**: double‑click `05_scripts/run_all.bat`.
- **macOS/Linux**: `chmod +x 05_scripts/run_all.sh && ./05_scripts/run_all.sh`.
- **One‑off ffmpeg**:
  ```bash
  ffmpeg -i input.mp4 -vf "fps=12,scale=2048:-1:flags=lanczos" -qscale:v 2 images/frame_%06d.jpg
  ```
- **Import to Blender**: File ▸ Import ▸ *Photogrammetry (COLMAP Model/Workspace)* → pick `04_scenes/<clip>/undistorted/` (or `sparse/0/`).

---

## 15) To‑Do Today (Eli)
- [ ] Create `AutomatedTracker/` scaffold.
- [ ] Download **COLMAP (CUDA)** + **FFmpeg** on the 4080 PC; Homebrew setup on Mac.
- [ ] Paste scripts into `05_scripts/` and run a short **Mini 3** test clip.
- [ ] Import into Blender; build 50% proxies; sanity‑check path.
- [ ] Commit project to GitHub (readme + sample clip results).

**Ship it.** 🚀

