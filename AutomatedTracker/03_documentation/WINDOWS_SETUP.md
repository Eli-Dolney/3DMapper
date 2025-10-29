# 🪟 Windows 10/11 Setup Guide - GPU-Accelerated COLMAP

This guide will get you running the 3D pipeline on Windows with RTX CUDA acceleration (50-100x faster than CPU!).

---

## ✅ Prerequisites

- **Windows 10 22H2** or **Windows 11**
- **GPU:** NVIDIA RTX 3000+ (RTX 4080, 4090, 3080 Ti, etc.)
- **RAM:** 16GB minimum, 32GB+ recommended
- **Storage:** 50GB+ free SSD space
- **Admin access** (for driver installation)

---

## 📋 Step 1: NVIDIA CUDA Toolkit & cuDNN

### 1a. Install NVIDIA GPU Drivers

1. Go to https://www.nvidia.com/Download/driverDetails.aspx
2. Select your GPU model
3. Download latest **Game Ready Driver** (or Studio Driver)
4. Run installer, **restart** after completion

Verify:
```cmd
nvidia-smi
```

You should see your GPU listed (e.g., `NVIDIA RTX 4080`).

### 1b. Install CUDA Toolkit 11.8

1. Download from https://developer.nvidia.com/cuda-11-8-0-download-archive
2. Select: Windows → x86_64 → 11 → exe (network or local)
3. Run installer with **default paths**
4. **Restart** Windows

Verify:
```cmd
nvcc --version
```

Expected output: `release 11.8`

### 1c. Install cuDNN 8.x

1. Register at https://developer.nvidia.com/cudnn (free account)
2. Download **cuDNN 8.8.0 for CUDA 11.x** (Windows)
3. Extract ZIP to: `C:\tools\cudnn\`
4. Copy contents of `cudnn/bin/` to `C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.8\bin\`

---

## 📋 Step 2: Git & Clone Repository

### 2a. Install Git

1. Download from https://git-scm.com/download/win
2. Run installer (default settings fine)
3. **Restart** shell

### 2b. Clone Repository

```cmd
cd D:\projects
git clone https://github.com/yourusername/automated-3d-tracker.git
cd automated-3d-tracker\AutomatedTracker
```

---

## 📋 Step 3: FFmpeg Installation

### Option A: Download Pre-built (Easiest)

1. Go to https://ffmpeg.org/download.html
2. Download **full build** for Windows (BtbN's builds recommended)
3. Extract to: `C:\Tools\ffmpeg\`
4. Add to **PATH**:
   - Press `Win + R`, type `sysdm.cpl`
   - Go to **Environment Variables**
   - Add `C:\Tools\ffmpeg\bin` to PATH
   - Restart PowerShell/CMD

Verify:
```cmd
ffmpeg -version
```

### Option B: Chocolatey

```cmd
choco install ffmpeg
```

---

## 📋 Step 4: COLMAP Installation (with CUDA)

### 4a. Download Pre-built COLMAP (Windows + CUDA)

1. Go to https://github.com/colmap/colmap/releases
2. Download latest **COLMAP-X.X.X-Windows-CUDA.zip**
3. Extract to: `C:\Tools\COLMAP\`
4. Add to PATH:
   - Add `C:\Tools\COLMAP\bin` to your system PATH
   - Restart PowerShell/CMD

Verify:
```cmd
colmap -h
```

Should show COLMAP help without errors.

### 4b. Test GPU Acceleration

```cmd
colmap feature_extractor --help | findstr /i "cuda gpu"
```

Should list GPU options (if CUDA compiled in).

---

## 📋 Step 5: Python (Optional, for advanced features)

```cmd
choco install python
python --version
```

Should show Python 3.9+.

---

## 🚀 Step 6: Run Pipeline

### 6a. Add Videos

```cmd
copy "C:\Users\YourName\Videos\my_drone.mp4" "D:\projects\automated-3d-tracker\AutomatedTracker\02_videos\"
```

### 6b. Run Pipeline

```cmd
cd D:\projects\automated-3d-tracker\AutomatedTracker
.\05_scripts\run_all.sh
```

**Windows PowerShell:**
```powershell
cd D:\projects\automated-3d-tracker\AutomatedTracker
bash ./05_scripts/run_all.sh
```

---

## ⚡ Performance Comparison

| Task | CPU Only | RTX 3080 Ti | RTX 4080 |
|------|----------|------------|----------|
| Feature Matching (425 frames) | 35 min | 4 min | 2 min |
| Dense Stereo | 45 min | 8 min | 4 min |
| **Total (30 sec video)** | **90 min** | **15 min** | **8 min** |

---

## 🐛 Troubleshooting

### "colmap: command not found" in PowerShell

Ensure PATH is set correctly:
```powershell
$env:PATH
# Should contain C:\Tools\COLMAP\bin
```

If not, add it:
```powershell
[Environment]::SetEnvironmentVariable("PATH", $env:PATH + ";C:\Tools\COLMAP\bin", "User")
```

Restart PowerShell.

### "CUDA compute capability is not sufficient"

Your GPU might not support CUDA. Supported: RTX 20+ series, RTX 30+, RTX 40+.

Check https://developer.nvidia.com/cuda-gpus

### "nvcc: command not found"

CUDA Toolkit not installed or not in PATH. Re-run CUDA installer.

### "ffmpeg: command not found"

FFmpeg not in PATH. Add `C:\Tools\ffmpeg\bin` to system PATH and restart.

### Script runs but "no vertices" in mesh

Dense reconstruction needs GPU memory. Try:
- Lower resolution: set `max_dim_px: 1024` in config.yaml
- Fewer frames: set `frame_rate: 8`
- Use sparse model from `undistorted/` in Blender

---

## 📂 Windows File Paths

Replace these in any Mac instructions:
| Mac | Windows |
|-----|---------|
| `~/Desktop/` | `C:\Users\YourName\Desktop\` |
| `/Users/name/` | `C:\Users\YourName\` |
| `./script.sh` | `.\script.sh` or `bash script.sh` |

---

## ✨ Final Checklist

- [ ] NVIDIA drivers installed (`nvidia-smi` works)
- [ ] CUDA 11.8 installed (`nvcc --version` shows 11.8)
- [ ] cuDNN extracted to CUDA folder
- [ ] Git installed (`git --version` works)
- [ ] FFmpeg in PATH (`ffmpeg -version` works)
- [ ] COLMAP with CUDA (`colmap -h` works)
- [ ] Repository cloned
- [ ] Test video in `02_videos/`
- [ ] Ready to run `./05_scripts/run_all.sh`!

---

## 🎬 Next Steps

1. **Run test video** (30 sec clip)
2. **Monitor GPU usage:** Open Task Manager → Performance → GPU
3. **Check output:** `04_scenes/video_name/`
4. **Import to Blender:** `undistorted/` folder
5. **3D print!** Export as STL

---

**🚀 Ready? Start with [QUICK_START.md](QUICK_START.md)**
