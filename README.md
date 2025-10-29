# 🚁 3D Photogrammetry Pipeline

**Transform your drone footage into stunning 3D models, point clouds, and animated camera tracks.**

Extract professional 3D geometry from video using COLMAP Structure-from-Motion. Perfect for VFX, 3D printing, virtual tours, and architectural visualization.

---

## ✨ What Makes This Cool

### 🎬 **From Video to 3D in Minutes**
Take a 30-second drone video and get:
- **Point clouds** with 100K+ 3D points
- **Animated camera path** showing exact camera position at every frame
- **Dense depth maps** for 3D printing
- **Photogrammetric mesh** - ready for Blender

### 🚀 **GPU-Accelerated (50-100x faster)**
- **RTX 4080:** 30-second video = **8-15 minutes**
- **RTX 3080:** 30-second video = **15-20 minutes**
- **CPU only:** 30-second video = **90+ minutes**

### 🎮 **Professional-Grade Output**
- COLMAP point clouds + camera poses
- Blender-ready imports with camera animation
- STL/PLY exports for 3D printing
- No manual camera tracking needed

### 📐 **Fully Automated**
- One command processes entire video
- Automatic frame extraction with intelligent scaling
- SIFT feature detection and exhaustive matching
- Structure-from-Motion reconstruction
- Dense depth fusion and Poisson meshing

---

## 🎯 Real-World Applications

| Use Case | Result |
|----------|--------|
| 🏠 **Real Estate** | Virtual tours with actual camera motion |
| 🎬 **VFX/Motion Graphics** | Camera-matched 3D effects and overlays |
| 🎮 **Game Development** | Level design reference geometry |
| 🖨️ **3D Printing** | Physical models of scanned objects |
| 📐 **Architecture** | Site documentation & analysis |
| 🎓 **Education** | Learn photogrammetry hands-on |

---

## 🚀 Quick Start

### **On macOS**

```bash
# Install dependencies
brew install colmap ffmpeg

# Clone repository
git clone https://github.com/Eli-Dolney/3DMapper.git
cd 3DMapper/AutomatedTracker

# Add your video
cp ~/Videos/my_drone_footage.mp4 02_videos/

# Run pipeline
./05_scripts/run_all.sh

# Results in: 04_scenes/my_drone_footage/
```

### **On Windows (RTX 4080)**

See **[WINDOWS_RTX4080_QUICK_START.md](WINDOWS_RTX4080_QUICK_START.md)** for full GPU setup

Quick version:
```powershell
# Clone and navigate
git clone https://github.com/Eli-Dolney/3DMapper.git
cd 3DMapper\AutomatedTracker

# Copy video to 02_videos\

# Run pipeline
bash .\05_scripts\run_all.sh
```

---

## 📂 What You Get

After processing, you'll have:

```
04_scenes/video_name/
├── images/              # 100+ extracted frames
├── sparse/              # 3D point cloud + cameras (raw)
├── undistorted/         # ← USE THIS IN BLENDER
│   ├── images/          # Undistorted frames
│   └── sparse/          # Camera poses (corrected)
└── dense/
    ├── fused.ply        # Dense point cloud
    └── mesh.ply         # Watertight mesh (3D printing)
```

---

## 🎬 Import into Blender

Once processing completes:

1. **Open Blender 4.0+**
2. **File → Import → COLMAP Model**
3. **Navigate to:** `04_scenes/video_name/undistorted/`
4. **Enable:**
   - ✓ Suppress distortion warnings
   - ✓ Import points as mesh
5. **Click Import**
6. 🎉 **See your point cloud + camera animation!**

**In Blender you can:**
- Play timeline to see camera motion
- Render from camera perspective
- Composite effects over point cloud
- Export camera path to other software
- Convert point cloud to mesh for modeling

---

## 📤 Share Results

### Via Google Drive
```bash
# After processing completes
cd 04_scenes/video_name
tar -czf results.tar.gz undistorted/
# Upload results.tar.gz to Google Drive
# Download anywhere, import in Blender
```

### For 3D Printing
```
Use: 04_scenes/video_name/dense/mesh.ply
Import to: Bambu Studio, PrusaSlicer, or Cura
Recommended: 0.4mm nozzle, 20% infill, tree supports
```

---

## ⚙️ Adjust Settings

Edit `05_scripts/config.yaml` to customize processing:

```yaml
frame_rate: 12              # Lower = faster, fewer images
max_dim_px: 2048            # Lower = faster, lower quality
colmap:
  use_gpu: true             # GPU acceleration (recommended)
  exhaustive_matcher: true  # Better quality, slower
  dense_reconstruction: true # Creates mesh (slow, optional)
```

**Presets:**
- **Fast:** frame_rate: 8, max_dim_px: 1024, exhaustive_matcher: false
- **Balanced:** frame_rate: 12, max_dim_px: 2048 (default)
- **Quality:** frame_rate: 15, max_dim_px: 4096, exhaustive_matcher: true

---

## 📊 Performance

| Metric | Value (RTX 4080) |
|--------|-----------------|
| 10-second video | ~5 min |
| 30-second video | 8-15 min |
| 1-minute video | 20-30 min |
| 2-minute video | 40-60 min |

**Breakdown:**
- Frame extraction: ~1 min
- SIFT feature detection: 2-5 min
- Feature matching: 2-5 min
- Structure-from-Motion: 2-10 min
- Dense reconstruction: 3-30 min (optional)

---

## 🛠️ System Requirements

### macOS
- **OS:** macOS 11+
- **CPU:** M1/M2/M3/M4 or Intel with 8+ cores
- **RAM:** 16GB minimum, 32GB+ recommended
- **Storage:** 50GB+ free
- **GPU:** Metal acceleration (automatic)

### Windows
- **OS:** Windows 10/11 (22H2+)
- **CPU:** Intel/AMD with 8+ cores
- **RAM:** 16GB minimum, 32GB+ recommended
- **GPU:** NVIDIA RTX 3000+ series (CUDA 11.8+)
- **Storage:** 50GB+ free

---

## 🆘 Troubleshooting

### "Mapper produced no model"
- Video lacks distinctive features or parallax
- Try: Different video with more texture and movement
- Try: Increase `frame_rate` in config.yaml
- Try: Enable `exhaustive_matcher: true`

### "Dense reconstruction failed"
- GPU memory insufficient
- Try: Lower `max_dim_px` to 1024
- Try: Set `dense_reconstruction: false` in config.yaml
- Note: Sparse model still works in Blender!

### "colmap: command not found" (Windows)
- COLMAP not in PATH
- See: WINDOWS_RTX4080_QUICK_START.md section 2

### "No frames extracted"
- Video format not supported
- Try: Convert to .mp4 first
- Try: Check video is valid with: `ffprobe video.mp4`

---

## 🎓 How It Works (Technical Overview)

1. **Frame Extraction** → Extract frames at specified FPS with intelligent scaling
2. **Feature Detection** → SIFT keypoints on each frame (GPU accelerated)
3. **Feature Matching** → Match keypoints across frames (exhaustive or vocabulary tree)
4. **Structure-from-Motion** → COLMAP mapper reconstructs 3D structure and camera poses
5. **Image Undistortion** → Correct lens distortion based on camera model
6. **Dense Stereo** → Patch match stereo for depth maps
7. **Depth Fusion** → Combine depth maps into single point cloud
8. **Poisson Meshing** → Generate watertight surface mesh

---

## 📚 Learn More

- **COLMAP Documentation:** https://colmap.github.io/
- **Structure-from-Motion:** https://en.wikipedia.org/wiki/Structure_from_motion
- **Blender COLMAP Import:** Photogrammetry Importer add-on
- **3D Printing:** https://www.printables.com/

---

## 🤝 Contributing

Found a bug? Have an improvement?

1. Fork the repository
2. Create a feature branch
3. Test thoroughly
4. Submit a pull request

---

## 📝 License

MIT License - Use freely for personal and commercial projects

---

## 🙏 Acknowledgments

Built on:
- **COLMAP** - Bergman et al. Structure-from-Motion engine
- **FFmpeg** - Video processing
- **Blender Photogrammetry Importer** - COLMAP integration
- **Poisson Surface Reconstruction** - Kazhdan et al.

---

## 🚀 Ready to Scan?

**macOS Users:** Start with the commands above  
**Windows Users:** See [WINDOWS_RTX4080_QUICK_START.md](WINDOWS_RTX4080_QUICK_START.md)

Questions? Check the troubleshooting section or the script logs in your output directory.

**Transform your videos into stunning 3D models today!** 🎯
