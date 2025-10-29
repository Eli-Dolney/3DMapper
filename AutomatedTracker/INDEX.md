# 🎬 Automated 3D Tracking & Drone Mapping Pipeline — Project Index

> **Last Updated:** October 26, 2025  
> **Platform:** macOS M4 (Sequoia)  
> **Status:** ✅ Ready to Use

---

## 📋 Quick Navigation

### Getting Started
1. **START HERE:** [`SETUP_COMPLETE.txt`](SETUP_COMPLETE.txt) — Completion summary with quick links
2. **FIRST TEST:** [`FIRST_RUN.md`](FIRST_RUN.md) — Step-by-step walkthrough for your first video
3. **FULL DOCS:** [`README.md`](README.md) — Complete documentation, config, troubleshooting

### Scripts
- **`05_scripts/run_all.sh`** — Main pipeline (frame extraction → COLMAP → dense mesh)
- **`05_scripts/test_setup.sh`** — Verify all dependencies are installed
- **`05_scripts/config.yaml`** — Configuration file (frame rate, resolution, GPU settings)

---

## 🚀 Quick Start (60 seconds)

```bash
# 1. Navigate to project
cd /Users/elidolney/Desktop/3d\ pipeline/AutomatedTracker

# 2. Add your video
# Drop any .mp4 or .mov file into: 02_videos/

# 3. Run the pipeline
./05_scripts/run_all.sh

# 4. Wait (2–10 minutes depending on video)

# 5. Import into Blender
# File → Import → COLMAP Model/Workspace
# Point to: 04_scenes/<video_name>/undistorted/
```

---

## 📁 Project Structure

```
AutomatedTracker/
├── 01_colmap/              # Empty (Homebrew installation)
├── 02_videos/              # ← DROP YOUR VIDEOS HERE
├── 03_ffmpeg/              # Empty (Homebrew installation)
├── 04_scenes/              # ← RESULTS APPEAR HERE (auto-created)
└── 05_scripts/
    ├── run_all.sh          # Main pipeline script
    ├── config.yaml         # Configuration (edit to customize)
    └── test_setup.sh       # Verification script

Documentation:
├── README.md               # Full project documentation
├── FIRST_RUN.md            # First-time user guide
├── SETUP_COMPLETE.txt      # Setup summary (this is what you just completed)
└── INDEX.md                # This file
```

---

## 🔧 Installed Components

| Component | Version | Location | Status |
|-----------|---------|----------|--------|
| **COLMAP** | 3.12.6 | `/opt/homebrew/bin/colmap` | ✅ Ready |
| **FFmpeg** | 8.0 | `/opt/homebrew/bin/ffmpeg` | ✅ Ready |
| **Bash** | 3.2.57 | `/bin/bash` | ✅ Ready |

**GPU Support:** Apple Metal (automatic)

---

## 📖 Documentation Files

### `README.md` — Main Documentation
- Project overview and goals
- Configuration reference
- Troubleshooting guide
- Blender import instructions
- Recommended capture settings
- Performance tuning tips

### `FIRST_RUN.md` — Beginner's Guide
- Pre-flight checklist
- Test video generation
- Step-by-step pipeline walkthrough
- Output verification
- Blender import walkthrough
- Common error fixes

### `SETUP_COMPLETE.txt` — Setup Summary
- Installation checklist (✅ all passed)
- Quick reference guide
- Project structure overview
- Next steps

---

## 🎯 Typical Workflow

1. **Record** video with good parallax, NO stabilization
2. **Place** video in `02_videos/`
3. **(Optional) Edit** `05_scripts/config.yaml` if needed
4. **Run** `./05_scripts/run_all.sh`
5. **Import** results into Blender (Photogrammetry Importer add-on)
6. **Animate** camera over point cloud
7. **Composite** effects or export camera path

---

## ⚡ Common Commands

### Run Full Pipeline
```bash
./05_scripts/run_all.sh
```

### Verify Setup
```bash
./05_scripts/test_setup.sh
```

### Test Single Video
```bash
# Extract frames only
ffmpeg -i 02_videos/myVideo.mp4 -vf "fps=12,scale=2048:-1:flags=lanczos" -qscale:v 2 04_scenes/test/images/frame_%06d.jpg

# Run COLMAP manually
colmap feature_extractor --ImageReader.single_camera 1 --ImageReader.camera_model OPENCV --SiftExtraction.use_gpu 1 --database_path 04_scenes/test/database.db --image_path 04_scenes/test/images
```

### Check Outputs
```bash
# Navigate to results
cd 04_scenes/<video_name>
ls -la

# Verify sparse reconstruction
ls -la sparse/0/

# Check dense mesh
ls -la dense/
```

---

## 🛠️ Configuration

Edit `05_scripts/config.yaml` to customize:

```yaml
# Frame extraction
frame_rate: 12              # Lower = faster, higher = more accurate
max_dim_px: 2048            # Resize images for speed (0 = no resize)
image_ext: jpg              # jpg or png

# COLMAP options
colmap:
  use_gpu: true             # Recommended on M4
  exhaustive_matcher: true  # Better for hard scenes (slower)
  dense_reconstruction: true # Mesh generation (very slow, optional)
```

**Quick Adjustments:**
- **Faster processing:** `frame_rate: 8`, `max_dim_px: 1024`, `dense_reconstruction: false`
- **Better accuracy:** `frame_rate: 24`, `max_dim_px: 4096`, `exhaustive_matcher: true`

---

## 📚 Resource Links

| Resource | URL |
|----------|-----|
| COLMAP Documentation | https://colmap.github.io/ |
| COLMAP GitHub | https://github.com/colmap/colmap |
| Photogrammetry Importer | https://github.com/SBCV/Blender-Addon-Photogrammetry-Importer |
| FFmpeg Docs | https://ffmpeg.org/ffmpeg.html |
| Blender 4.0+ | https://www.blender.org/download/ |

---

## 🎬 Pipeline Overview

```
Video Input (.mp4 / .mov)
           ↓
    [1] Frame Extraction (FFmpeg)
           ↓
    [2] Feature Detection (COLMAP SIFT)
           ↓
    [3] Feature Matching (COLMAP)
           ↓
    [4] Structure from Motion (Mapper)
           ↓
    [5] Dense Reconstruction (Patch Match + Poisson)
           ↓
Output: Cameras, Points3D, Dense Mesh (PLY)
           ↓
        Blender Import
           ↓
   Camera + Point Cloud + Effects ✨
```

---

## ✅ What's Included

- ✅ Fully automated COLMAP pipeline
- ✅ Frame extraction with FFmpeg
- ✅ GPU-accelerated feature detection
- ✅ Sparse 3D reconstruction
- ✅ Optional dense mesh generation
- ✅ Blender-ready export format
- ✅ Comprehensive documentation
- ✅ Setup verification script
- ✅ Configuration templates
- ✅ Troubleshooting guide

---

## 🐛 Need Help?

1. **Check FAQ:** See `README.md` → Troubleshooting section
2. **Verify setup:** Run `./05_scripts/test_setup.sh`
3. **Check logs:** Look in `04_scenes/<video>/` for error details
4. **Read guides:** Start with `FIRST_RUN.md`

---

## 🚀 Next Steps

1. ✅ Setup complete (you are here)
2. 📝 Read `FIRST_RUN.md` for a walkthrough
3. 🎥 Add a test video to `02_videos/`
4. ▶️ Run `./05_scripts/run_all.sh`
5. 🎬 Import into Blender and create!

---

**Happy tracking! 🎬✨**

Platform: macOS Sequoia (M4)  
Last Setup: October 26, 2025  
Ready: ✅ YES

