# ⚡ Windows RTX 4080 Quick Start (15 mins)

**Your 3D pipeline is ready!** Follow these 4 steps to start processing videos on your RTX 4080.

---

## 1️⃣ Clone Repository (2 min)

```powershell
# Open PowerShell and run:
cd D:\projects
git clone https://github.com/Eli-Dolney/3DMapper.git
cd 3DMapper\AutomatedTracker
```

---

## 2️⃣ Install Dependencies (5-10 min)

**See the full setup guide:** `03_documentation/WINDOWS_SETUP.md`

Quick checklist:
- [ ] NVIDIA Driver → https://nvidia.com/Download
- [ ] CUDA 11.8 → https://developer.nvidia.com/cuda-11-8-0-download-archive
- [ ] cuDNN → Copy to CUDA folder (see WINDOWS_SETUP.md)
- [ ] FFmpeg → https://ffmpeg.org/download.html (add to PATH)
- [ ] COLMAP → https://github.com/colmap/colmap/releases (CUDA build, add to PATH)

**Verify everything:**
```powershell
nvidia-smi          # Should show RTX 4080
nvcc --version      # Should show CUDA 11.8
ffmpeg -version     # Should show ffmpeg
colmap -h           # Should show help
```

---

## 3️⃣ Add Your Video (1 min)

```powershell
# Copy your video to 02_videos/
copy "C:\Users\YourName\Videos\my_drone.mp4" "02_videos\"

# Or use GUI: Copy/paste into 02_videos\ folder
```

**Supported formats:** .mp4, .mov, .avi, .mkv, .flv

---

## 4️⃣ Run Pipeline (8-60 min depending on video)

```powershell
# Navigate to project
cd 3DMapper\AutomatedTracker

# Run pipeline
bash .\05_scripts\run_all.sh

# Results: 04_scenes\my_drone\
```

**Typical Processing Times (RTX 4080):**
| Video Length | Processing Time |
|---|---|
| 10 seconds | 5 min |
| 30 seconds | 8-15 min |
| 1 minute | 20-30 min |
| 2 minutes | 40-60 min |

---

## ✅ View Results

After processing completes:

```
04_scenes\my_drone\
├── images\              (extracted frames)
├── sparse\              (3D points + cameras)
├── undistorted\         ← USE THIS IN BLENDER
│   ├── images\
│   └── sparse\
└── dense\
    └── mesh.ply         (for 3D printing)
```

---

## 🎬 Import in Blender

1. Open Blender 4.0+
2. **File → Import → COLMAP Model**
3. Navigate to: `04_scenes\my_drone\undistorted\`
4. Enable:
   - ✓ Suppress distortion warnings
   - ✓ Import points as mesh
5. Click **Import COLMAP Model**
6. 🎉 See your point cloud and camera path!

---

## 📤 Send Results to Google Drive

```powershell
# Create compressed archive
cd 04_scenes\my_drone
tar -czf results.tar.gz undistorted\

# Upload results.tar.gz to Google Drive
# Download on any machine with Blender
```

---

## 🔧 Adjust Settings

Edit `05_scripts/config.yaml` before running:

```yaml
frame_rate: 12          # Lower = fewer images = faster (try 8-10)
max_dim_px: 2048        # Lower = smaller = faster (try 1024 for speed)
colmap:
  use_gpu: true         # Keep enabled for RTX 4080
  exhaustive_matcher: true  # Set false for speed, true for quality
  dense_reconstruction: true # Set false to skip dense (faster)
```

---

## 🆘 Troubleshooting

| Problem | Solution |
|---------|----------|
| `colmap: command not found` | Add COLMAP to PATH (see WINDOWS_SETUP.md) |
| `ffmpeg: command not found` | Add FFmpeg to PATH |
| `GPU not detected` | Run `nvidia-smi`; verify CUDA installed |
| `No frames extracted` | Check video format; try smaller file |
| `Mapper produced no model` | Video lacks features/parallax; try different video |
| `Dense reconstruction failed` | Lower max_dim_px to 1024; use sparse model from Blender |

---

## 📊 Expected Output

✅ **On Success:**
- 100+ extracted frames in `images/`
- Camera poses in `sparse/0/`
- Point cloud in `undistorted/`
- Dense mesh in `dense/mesh.ply`

❌ **If "Mapper produced no model":**
- Sparse model still works in Blender
- Try different video (more texture/movement)
- Increase frame_rate in config.yaml

---

## 🚀 Common Workflows

### Drone Footage
```powershell
# Default settings work great
bash .\05_scripts\run_all.sh
```

### Phone/Handheld Video
```powershell
# Use phone-optimized script
bash .\05_scripts\run_phone_video.sh
```

### Fast Processing
```yaml
# Edit config.yaml:
frame_rate: 8
max_dim_px: 1024
exhaustive_matcher: false
dense_reconstruction: false
```

### High Quality
```yaml
# Edit config.yaml:
frame_rate: 15
max_dim_px: 2048
exhaustive_matcher: true
dense_reconstruction: true
```

---

## 📚 Full Documentation

- **Full Setup:** `/03_documentation/WINDOWS_SETUP.md`
- **Detailed Guide:** `/DEPLOYMENT.md`
- **Project Info:** `/README.md`

---

## 💡 Tips

- **Parallax is Key:** Move camera/subject for better tracking
- **Lighting Matters:** Well-lit scenes track better
- **Video Quality:** Use 1080p+ for best results
- **Monitor Progress:** Open Task Manager → GPU to see RTX 4080 working
- **Blender Playback:** Disable viewport effects for smooth timeline scrubbing

---

**You're ready! 🚁 Start with a 30-second test video.**

Questions? See the full documentation or run:
```powershell
bash .\05_scripts\test_setup.sh
```

---

**Repository:** https://github.com/Eli-Dolney/3DMapper
