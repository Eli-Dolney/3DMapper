# 🧪 First Run — Test Your Setup

This guide walks you through your first pipeline run step-by-step.

---

## ✅ Pre-Flight Checklist

Run this to verify everything is installed:

```bash
colmap -h          # Should show: "COLMAP 3.12.6"
ffmpeg -version    # Should show: "ffmpeg version 8.0"
which ffmpeg       # Should show: /opt/homebrew/bin/ffmpeg
which colmap       # Should show: /opt/homebrew/bin/colmap
```

If any command fails, run:
```bash
brew install colmap ffmpeg
```

---

## 📹 Step 1: Get a Test Video

**Option A: Use an existing video**
- Copy a `.mp4` or `.mov` file (10–30 seconds recommended)
- Place it in `02_videos/`

**Option B: Generate a simple test video** (if you don't have one)
```bash
# Create a 15-second test video of a rotating pattern
ffmpeg -f lavfi -i testsrc=duration=15:size=1280x720:rate=30 \
        -f lavfi -i sine=frequency=1000:duration=15 \
        -pix_fmt yuv420p \
        -c:v libx264 -preset fast \
        -c:a aac \
        02_videos/test.mp4
```

---

## ▶️ Step 2: Run the Pipeline

```bash
cd /Users/elidolney/Desktop/3d\ pipeline/AutomatedTracker
./05_scripts/run_all.sh
```

You should see output like:
```
[INFO] Processing video: test
[1/5] Extracting frames...
[2/5] Feature extraction...
[3/5] Feature matching...
[4/5] Structure from Motion (3D reconstruction)...
[5/5] Dense reconstruction & mesh generation...
✅ Finished test - All outputs ready in: /path/to/04_scenes/test
```

**Expected timing:**
- 10–30 sec video → 2–5 minutes total
- 1+ minute video → 10+ minutes total
- Dense mesh generation is the slowest step

---

## 📂 Step 3: Check Outputs

```bash
# Navigate to your results
cd 04_scenes/test

# See what was generated
ls -lh

# You should see:
# - images/           (100+ JPG frames)
# - database.db       (COLMAP database)
# - sparse/0/         (cameras, 3D points)
# - undistorted/      (undistorted images for dense recon)
# - dense/            (fused point cloud + mesh)
#   └── mesh.ply      (watertight mesh)
```

---

## 🎬 Step 4: Import into Blender

1. **Open Blender 4.0+**
   - Go to **Preferences** → **System** → Ensure **OpenGL** is selected (not Vulkan)

2. **Install Photogrammetry Importer Add-on**
   - Download from: https://github.com/SBCV/Blender-Addon-Photogrammetry-Importer
   - **Edit** → **Preferences** → **Add-ons** → **Install from File**
   - Select the downloaded `.zip` file

3. **Import the Model**
   - **File** → **Import** → **COLMAP Model/Workspace**
   - Navigate to: `04_scenes/test/undistorted/` (preferred) or `sparse/0/`
   - Enable:
     - ✓ Suppress distortion warnings
     - ✓ Import points as mesh
   - Click **Import COLMAP Model**

4. **View the Result**
   - You should see a **point cloud** and **camera path**
   - Press **Numpad 0** to see from the camera's viewpoint
   - Play timeline to see the camera moving (⏯)

---

## 🐛 Troubleshooting First Run

### "No frames extracted" or FFMPEG error
```bash
# Test FFmpeg manually
ffmpeg -i 02_videos/test.mp4 -vf "fps=12,scale=2048:-1:flags=lanczos" -qscale:v 2 /tmp/test_%06d.jpg

# If this fails, check video format
ffprobe 02_videos/test.mp4
```

### "Mapper produced no model"
- Your video may lack distinctive features (repeating patterns, featureless walls)
- Try:
  1. Reduce `frame_rate` to 8 in `config.yaml`
  2. Use a **different video** with more texture/parallax
  3. Enable `exhaustive_matcher: true` in `config.yaml`

### COLMAP fails with GPU error
- Edit `05_scripts/config.yaml`: change `use_gpu: true` → `use_gpu: false`
- COLMAP will use CPU (slower but more stable)

### Blender import shows nothing
- Verify path points to `undistorted/` folder (not `sparse/`)
- Switch to **Shading** workspace, enable viewport shading (bottom right)
- Check box: **Display Point Cloud** if available

---

## ✅ Success Criteria

Your first run is successful if you see:

1. ✅ Frames extracted to `04_scenes/test/images/frame_000001.jpg` etc.
2. ✅ COLMAP database created: `database.db`
3. ✅ Sparse reconstruction: `sparse/0/cameras.bin`, `sparse/0/images.bin`, `sparse/0/points3D.bin`
4. ✅ Dense outputs: `undistorted/sparse/cameras.bin` + `dense/mesh.ply`
5. ✅ Blender imports and shows point cloud

---

## 🎯 Next Steps

Once your first test is done:

1. **Try a real video** (drone footage, handshake, etc.)
2. **Adjust settings** in `config.yaml`:
   - Lower `frame_rate` for faster processing
   - Increase `frame_rate` for higher accuracy
   - Change `exhaustive_matcher` based on video difficulty

3. **Experiment with Blender**:
   - Build proxies for smooth playback (Movie Clip Editor)
   - Composite effects over the point cloud
   - Export camera to other software

---

## 💡 Tips

- **Fast iteration**: Edit your video to 10–15 seconds before processing
- **Check frames**: Review `04_scenes/<name>/images/` to ensure extraction worked
- **GPU speed**: COLMAP on Apple Silicon uses Metal acceleration automatically
- **Dense mesh**: Takes the longest; disable in `config.yaml` if you only need sparse + camera

---

**You're ready! 🚀**

Let me know if you hit any snags. Refer to the troubleshooting section or the main `README.md`.
