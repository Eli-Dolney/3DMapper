# ⚡ Quick Start (5 Minutes)

Get your first 3D model in less than 5 minutes!

---

## 🚀 For macOS Users

### 1. Install Dependencies (2 min)

```bash
# Install Homebrew (if needed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install COLMAP & FFmpeg
brew install colmap ffmpeg

# Verify
colmap -h
ffmpeg -version
```

### 2. Clone & Setup (1 min)

```bash
git clone https://github.com/yourusername/automated-3d-tracker.git
cd automated-3d-tracker/AutomatedTracker
chmod +x 05_scripts/*.sh
```

### 3. Add Your Video (30 sec)

```bash
cp ~/Videos/my_video.mp4 02_videos/
```

### 4. Run Pipeline (ongoing, ~45 min for short video)

```bash
./05_scripts/run_all.sh
```

**Done!** Your 3D model is in `04_scenes/video_name/undistorted/`

---

## 🪟 For Windows Users

### 1. Install Dependencies (5 min)

See [WINDOWS_SETUP.md](WINDOWS_SETUP.md) for:
- NVIDIA drivers + CUDA
- Git
- FFmpeg
- COLMAP (with CUDA)

### 2. Clone & Setup (1 min)

```powershell
git clone https://github.com/yourusername/automated-3d-tracker.git
cd automated-3d-tracker\AutomatedTracker
```

### 3. Add Your Video (30 sec)

```powershell
copy "C:\Users\YourName\Videos\my_video.mp4" "02_videos\"
```

### 4. Run Pipeline (ongoing, ~15 min with RTX 4080)

```powershell
bash ./05_scripts/run_all.sh
```

---

## 🎨 Import to Blender

1. Open **Blender 4.0+**
2. **Add-ons** → Install "Photogrammetry Importer"
3. **File** → **Import** → **COLMAP Model/Workspace**
4. Select: `04_scenes/video_name/undistorted/`
5. **Import COLMAP Model**

✅ You now have:
- 🎥 Animated camera path
- ☁️ 3D point cloud
- 📏 Perfect tracking data!

---

## 🖨️ Export for 3D Printing

1. Select point cloud
2. **Object** → **Convert to Mesh**
3. **Modifier** → Add **Remesh** (Smooth, voxel 0.01)
4. **File** → **Export As** → **STL**
5. Upload to Shapeways / load into Bambu Studio

---

## 🎯 Best Practices

✅ **DO:**
- Orbit around subject (good parallax)
- 30-60 second videos (best quality)
- Good lighting (overcast ideal)
- Distinctive features (not blank walls)

❌ **DON'T:**
- Enable in-camera stabilization
- Spin in place (no parallax)
- Point at featureless sky
- Move too fast (motion blur)

---

## 📞 Need Help?

- **macOS issues?** See [README.md](../README.md) Troubleshooting
- **Windows issues?** See [WINDOWS_SETUP.md](WINDOWS_SETUP.md)
- **Blender issues?** See [BLENDER_GUIDE.md](BLENDER_GUIDE.md)

---

**Next:** Process your footage! 🚁✨
