# 🚁 Automated 3D Tracking & Drone Mapping Pipeline

**Transform your drone footage into professional 3D models, point clouds, and camera tracks!**

Extract 3D geometry and animated camera paths from video using COLMAP photogrammetry. Perfect for VFX, 3D printing, virtual tours, and architectural visualization.

---

## ✨ Features

- ✅ **Automatic video frame extraction** with intelligent scaling
- ✅ **SIFT-based feature detection** (GPU-accelerated on CUDA systems)
- ✅ **Exhaustive feature matching** for robust reconstruction
- ✅ **Structure-from-Motion (SfM)** with dense bundle adjustment
- ✅ **Dense 3D reconstruction** (depth maps + point fusion)
- ✅ **Poisson surface meshing** for watertight models
- ✅ **Blender-ready output** with Photogrammetry Importer add-on
- ✅ **STL/PLY export** for 3D printing on Bambu Lab, Prusa, or any FDM printer

---

## 📋 System Requirements

### macOS (M-Series or Intel)

- **OS:** macOS 11+
- **CPU:** M1/M2/M3/M4 or Intel with 8+ cores
- **RAM:** 16GB minimum, 32GB+ recommended
- **Storage:** 50GB+ free (for video processing)
- **GPU:** Metal acceleration (automatic)

**Estimated Processing Time:**
- Small video (30 sec): 45-60 min
- Large video (2-3 min): 2-4 hours

### Windows 10/11

- **OS:** Windows 10/11 (22H2 or later)
- **CPU:** Intel/AMD with 8+ cores
- **RAM:** 16GB minimum, 32GB+ recommended  
- **GPU:** NVIDIA RTX 3000 series or newer (CUDA 11.8+)
- **Storage:** 50GB+ free

**Estimated Processing Time (with RTX 4080):**
- Small video (30 sec): 10-15 min
- Large video (2-3 min): 30-60 min

---

## 🚀 Quick Start

### macOS Setup

```bash
# 1. Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install COLMAP and FFmpeg
brew install colmap ffmpeg

# 3. Clone this repository
git clone https://github.com/yourusername/automated-3d-tracker.git
cd automated-3d-tracker/AutomatedTracker

# 4. Make scripts executable
chmod +x 05_scripts/run_all.sh
chmod +x 05_scripts/run_phone_video.sh
chmod +x 05_scripts/test_setup.sh

# 5. Test your setup
./05_scripts/test_setup.sh

# 6. Add your video
cp /path/to/your/video.mp4 02_videos/

# 7. Run the pipeline
./05_scripts/run_all.sh
```

### Windows Setup

See [WINDOWS_SETUP.md](WINDOWS_SETUP.md) for detailed GPU-accelerated COLMAP installation.

---

## 📁 Project Structure

```
AutomatedTracker/
├── 02_videos/              # Drop your videos here
├── 03_documentation/       # Setup guides & troubleshooting
├── 04_scenes/             # Output (auto-created per video)
│   └── video_name/
│       ├── images/        # Extracted frames
│       ├── sparse/        # Point cloud & camera poses
│       ├── undistorted/   # Undistorted frames (Blender-ready)
│       └── dense/         # Depth maps & mesh
├── 05_scripts/
│   ├── run_all.sh         # Main pipeline (drone footage)
│   ├── run_phone_video.sh # Optimized for phone videos
│   ├── config.yaml        # Tunable parameters
│   └── test_setup.sh      # Verify installation
└── README.md              # This file
```

---

## 🎬 Usage

### Process Drone Footage

```bash
cd AutomatedTracker
cp ~/videos/my_drone_footage.mp4 02_videos/
./05_scripts/run_all.sh
```

**Pipeline Steps:**
1. Frame extraction (FFmpeg)
2. SIFT feature detection
3. Exhaustive feature matching
4. Structure-from-Motion (SfM)
5. Dense reconstruction & meshing

### Process Phone/Handheld Video

```bash
./05_scripts/run_phone_video.sh
```

Optimized for close-range objects with sequential frame matching.

---

## 🎨 Blender Integration

### Import COLMAP Model

1. Open Blender
2. **File → Import → COLMAP Model/Workspace**
3. Navigate to: `04_scenes/video_name/undistorted/`
4. Click **Import COLMAP Model**

You'll get:
- ☁️ Point cloud (colored by depth)
- 🎥 Animated camera path
- 📏 All 850+ camera positions

### Export for 3D Printing

1. Select point cloud
2. **Object → Convert to Mesh**
3. **Modifier → Add "Remesh"** (Smooth mode, voxel size 0.01)
4. **File → Export As → STL**
5. Import into Bambu Studio / PrusaSlicer / Cura

---

## 📊 Configuration

Edit `05_scripts/config.yaml` to customize:

```yaml
frame_rate: 12              # FPS to extract (lower = fewer images)
max_dim_px: 2048            # Resize long edge (0 = native)
colmap:
  use_gpu: true             # CUDA/Metal acceleration
  exhaustive_matcher: true  # Robust but slower
  dense_reconstruction: true
```

---

## 🐛 Troubleshooting

### "Command not found: colmap"

**macOS:**
```bash
brew install colmap
```

**Windows:** See [WINDOWS_SETUP.md](WINDOWS_SETUP.md)

### "No video files found"

- Ensure videos are in `02_videos/` directory
- Supported formats: `.mp4`, `.mov`, `.avi`, `.flv`, `.mkv`

### "Mapper produced no model"

- Increase `frame_rate` in `config.yaml` (more images = better tracking)
- Ensure video has good parallax (camera/subject movement)
- Avoid overly reflective or featureless scenes

### "Dense reconstruction failed"

- Sparse reconstruction succeeded! Use `undistorted/` folder in Blender
- Dense reconstruction requires GPU; skip with `colmap:dense_reconstruction: false`

---

## 🖨️ 3D Printing

### File Locations

- **For printing:** `04_scenes/video_name/dense/mesh.ply` (if successful)
- **Fallback:** Export point cloud from Blender as STL

### Recommended Settings

| Setting | Value |
|---------|-------|
| Nozzle | 0.4mm |
| Layer Height | 0.15mm |
| Infill | 20% |
| Support | Tree supports |
| Material | PLA / PETG |

### Services

- **Shapeways:** Professional 3D printing (various materials)
- **Local makerspaces:** DIY 3D printing community
- **Personal 3D printer:** Bambu Lab A1, Prusa i3, etc.

---

## 📈 Performance Tips

| Factor | Impact | Optimization |
|--------|--------|---------------|
| **Video Length** | 2-4x per minute | Trim to 30-60 sec |
| **Resolution** | 2x per 1920→2560 | Set `max_dim_px: 1536` |
| **Frame Rate** | 2x per 10fps added | Start with `frame_rate: 12` |
| **GPU Available** | 10-50x speedup | Use Windows + RTX 4080 |

---

## 🔗 Applications

- 🏠 **Real Estate:** Virtual tours with actual camera tracking
- 🎬 **VFX/Motion Graphics:** Camera-matched 3D effects
- 🎮 **Game Development:** Level design reference geometry
- 🖨️ **3D Printing:** Physical models of scanned scenes
- 📐 **Architecture:** Site documentation & analysis
- 🎓 **Education:** Photogrammetry learning tool

---

## 🤝 Contributing

Found a bug? Have a feature idea?

1. Fork the repository
2. Create a branch: `git checkout -b feature/your-feature`
3. Commit: `git commit -m "Add feature"`
4. Push: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

MIT License - See LICENSE file

---

## 🙏 Acknowledgments

- **COLMAP** - Bergman et al. (3D reconstruction engine)
- **FFmpeg** - Video frame extraction
- **Blender Photogrammetry Importer** - COLMAP import support
- **Poisson Surface Reconstruction** - Kazhdan et al.

---

## 📚 Resources

- [COLMAP Documentation](https://colmap.github.io/)
- [Structure-from-Motion Guide](https://colmap.github.io/index.html)
- [Blender Manual](https://docs.blender.org/)
- [3D Printing Tips](https://www.printables.com/)

---

**Questions?** See the troubleshooting section or check `/03_documentation/`

**Ready to scan?** 🚁 See [QUICK_START.md](03_documentation/QUICK_START.md)
