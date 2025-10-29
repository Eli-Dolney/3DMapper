# ⚡ Quick Push to GitHub (5 minutes)

**TL;DR** — Copy & paste these commands to push your code to GitHub:

---

## 🚀 Step 1: Navigate to Project

```bash
cd "/Users/elidolney/Desktop/3d pipeline"
```

---

## 🚀 Step 2: Initialize Git (First Time Only)

```bash
git init
git config user.name "Eli Dolney"
git config user.email "your.email@gmail.com"
```

---

## 🚀 Step 3: Add & Commit

```bash
# Add all files (respecting .gitignore)
git add .

# Check what's being committed
git status

# Commit
git commit -m "Initial commit: 3D pipeline for RTX 4080"
```

---

## 🚀 Step 4: Add Remote & Push

```bash
# Add GitHub repository
git remote add origin https://github.com/Eli-Dolney/3DMapper.git

# Verify it was added
git remote -v

# Set main branch and push
git branch -M main
git push -u origin main
```

---

## ✅ Done!

Your code is now on GitHub. You can:

1. **Clone on Windows:**
   ```powershell
   git clone https://github.com/Eli-Dolney/3DMapper.git
   cd 3DMapper\AutomatedTracker
   bash .\05_scripts\run_all.sh
   ```

2. **Upload results to Google Drive:**
   ```powershell
   # After processing, zip the results
   tar -czf results.tar.gz 04_scenes\video_name\undistorted
   # Upload results.tar.gz to Google Drive
   ```

---

## 🔄 Next Pushes (After You Make Changes)

```bash
cd "/Users/elidolney/Desktop/3d pipeline"
git add .
git commit -m "Your message here"
git push
```

---

**Need more details?** See [DEPLOYMENT.md](DEPLOYMENT.md)
