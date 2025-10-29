# 🚀 Deployment Guide — Push to GitHub & Test on RTX 4080

This guide walks you through:
1. Preparing your code for GitHub
2. Pushing to your repository
3. Cloning and testing on your Windows RTX 4080 PC
4. Preparing specific outputs for Google Drive/Blender testing

---

## 📋 Part 1: Prepare Repository Locally (macOS)

### Step 1a: Clean Up Old Outputs

Run this to remove all large generated files while keeping the project structure:

```bash
cd "/Users/elidolney/Desktop/3d pipeline"

# Remove all scene outputs (images, sparse, dense data)
rm -rf AutomatedTracker/04_scenes/*/images
rm -rf AutomatedTracker/04_scenes/*/database.db
rm -rf AutomatedTracker/04_scenes/*/sparse
rm -rf AutomatedTracker/04_scenes/*/undistorted/images
rm -rf AutomatedTracker/04_scenes/*/undistorted/stereo
rm -rf AutomatedTracker/04_scenes/*/dense

# Remove logs
rm -f AutomatedTracker/*.log
rm -f "/Users/elidolney/Desktop/3d pipeline"/*.log

# Remove test videos (keep only sample/reference if needed)
# Optional: rm AutomatedTracker/02_videos/*.mp4 AutomatedTracker/02_videos/*.mov
```

### Step 1b: Initialize Git Repository

```bash
cd "/Users/elidolney/Desktop/3d pipeline"

# Initialize git (if not already done)
git init

# Configure git
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Add all tracked files (respecting .gitignore)
git add .

# Check what will be committed
git status

# Commit initial version
git commit -m "Initial commit: Clean 3D pipeline code for RTX 4080 deployment"
```

### Step 1c: Create `.gitkeep` Files for Directory Structure

These empty marker files ensure empty directories are tracked by git:

```bash
cd "/Users/elidolney/Desktop/3d pipeline/AutomatedTracker"

# Keep directory structure even if empty
touch 02_videos/.gitkeep
touch 04_scenes/.gitkeep
touch 01_colmap/.gitkeep
touch 03_ffmpeg/.gitkeep

# Add these to git
git add .gitkeep

# Commit
git commit -m "Add directory structure markers"
```

---

## 📊 Part 2: Push to GitHub

### Step 2a: Add Remote Repository

```bash
cd "/Users/elidolney/Desktop/3d pipeline"

# Add your GitHub repository as origin
git remote add origin https://github.com/Eli-Dolney/3DMapper.git

# Verify remote
git remote -v
```

### Step 2b: Push to GitHub

```bash
# Set upstream and push (first time)
git branch -M main
git push -u origin main

# Future pushes (just use):
# git push
```

**Expected output:**
```
Counting objects: 47, done.
Delta compression using up to 8 threads.
Compressing objects: 100% (42/42), done.
Writing objects: 100% (47/47), 2.4 MiB | 1.2 MiB/s, done.
...
To github.com:Eli-Dolney/3DMapper.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

---

## 🖥️ Part 3: Clone & Setup on Windows RTX 4080

### Step 3a: On Your Windows PC

Open PowerShell or Command Prompt:

```powershell
# Navigate to your projects folder
cd D:\projects  # or wherever you prefer

# Clone the repository
git clone https://github.com/Eli-Dolney/3DMapper.git
cd 3DMapper\AutomatedTracker
```

### Step 3b: Verify Setup (Windows)

```powershell
# Check COLMAP with GPU support
colmap -h

# Check FFmpeg
ffmpeg -version

# Test directory structure
dir 02_videos
dir 04_scenes
```

### Step 3c: Run Test Pipeline

```powershell
# Navigate to project
cd D:\projects\3DMapper\AutomatedTracker

# Run test setup (verifies all dependencies)
bash .\05_scripts\test_setup.sh

# Process test video (if included) or add your own
# Copy your video to 02_videos/
copy "C:\Users\YourName\Videos\my_drone.mp4" "02_videos\"

# Run the pipeline
bash .\05_scripts\run_all.sh
```

**Expected timing with RTX 4080:**
- 30-second video: 8-15 minutes
- 2-minute video: 40-60 minutes

---

## 📤 Part 4: Export Results to Google Drive for Blender

### Step 4a: After Pipeline Completes

Your outputs will be in: `04_scenes\video_name\`

**Files to upload to Google Drive:**

```
04_scenes/video_name/
├── undistorted/                    ← USE THIS for Blender import
│   ├── images/ (undistorted frames)
│   └── sparse/ (camera data)
├── dense/mesh.ply                 ← USE THIS for 3D printing
└── sparse/0/ (fallback if needed)
```

### Step 4b: Export to Google Drive

**Option 1: Manual Upload**

1. Zip the folder: `04_scenes\video_name\undistorted\`
2. Upload to Google Drive
3. Download on Mac/PC with Blender

**Option 2: Local Testing First (Recommended)**

1. Open Blender on your Windows PC
2. File → Import → COLMAP Model
3. Navigate to: `04_scenes\video_name\undistorted\`
4. Verify it imports correctly
5. Then upload to Google Drive

### Step 4c: Import in Blender

```
File → Import → COLMAP Model/Workspace
    ↓
Navigate to undistorted/ folder
    ↓
Enable:
  ✓ Suppress distortion warnings
  ✓ Import points as mesh
    ↓
Click "Import COLMAP Model"
```

---

## ✅ Checklist

### Before First Push:
- [ ] `.gitignore` created and working
- [ ] All large output files removed
- [ ] `.gitkeep` files added to empty directories
- [ ] First commit made locally
- [ ] Remote added: `git remote -v` shows `origin`

### After Push to GitHub:
- [ ] `git push` completes without errors
- [ ] GitHub shows your repository with code files visible
- [ ] No large .ply, .bin, or image files in repository

### After Clone on Windows:
- [ ] Directory structure intact: `02_videos\`, `04_scenes\`, `05_scripts\`
- [ ] Scripts present: `run_all.sh`, `config.yaml`
- [ ] COLMAP, FFmpeg, and CUDA ready
- [ ] Test video processes successfully

### After Blender Import:
- [ ] Point cloud visible
- [ ] Camera path animates in timeline
- [ ] Can render and export

---

## 🔧 Troubleshooting

### "Can't clone repository"
```powershell
# Verify git is installed
git --version

# If not working, reinstall from: https://git-scm.com/download/win
```

### ".gitignore not working?"
```bash
# Remove cached files and reapply gitignore
git rm -r --cached .
git add .
git commit -m "Remove cached files and apply gitignore"
```

### "Script won't run on Windows"
```powershell
# Use bash explicitly
bash .\05_scripts\run_all.sh

# Or convert to PowerShell (advanced)
# PowerShell -ExecutionPolicy Bypass -File .\script.ps1
```

### "GPU not detected"
```cmd
# Verify CUDA installation
nvidia-smi

# Check COLMAP GPU support
colmap feature_extractor --help | findstr gpu
```

---

## 📝 Quick Command Reference

**On macOS (push code):**
```bash
cd "/Users/elidolney/Desktop/3d pipeline"
git status
git add .
git commit -m "Your message"
git push
```

**On Windows (test code):**
```powershell
cd D:\projects\3DMapper\AutomatedTracker
bash .\05_scripts\run_all.sh
```

**Export to Google Drive:**
```powershell
# After processing video_name:
tar -czf video_name_results.tar.gz 04_scenes\video_name\undistorted
# Upload video_name_results.tar.gz to Google Drive
```

---

**Questions?** Check [README.md](AutomatedTracker/README.md) or [WINDOWS_SETUP.md](AutomatedTracker/03_documentation/WINDOWS_SETUP.md)
