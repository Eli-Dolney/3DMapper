# 🗿 Statue Scanning & 3D Printing Guide

## Quick Start for Scanning Statues

### What You Need:
- Your DJI drone
- Good lighting (ideally outdoor, overcast day)
- 5-10 minutes

### How to Capture:
1. **Start high** - Fly 20+ feet up
2. **Orbit the statue** - Fly in slow circles around it
3. **Different heights** - Repeat at mid-level and ground level
4. **Get all angles** - North, South, East, West views
5. **Close-ups** - Details of face, hands, etc.

**Tip:** Shoot at 30fps, then extract at 12fps for processing

### Processing:
```bash
# 1. Copy your video to:
#    AutomatedTracker/02_videos/

# 2. Run the pipeline:
cd /Users/elidolney/Desktop/3d\ pipeline/AutomatedTracker
./05_scripts/run_all.sh

# 3. Wait for processing (15-30 min depending on video length)

# 4. Results in:
#    04_scenes/YOUR_VIDEO_NAME/
```

### Import to Blender:
```
File → Import → COLMAP Model/Workspace
→ Select: 04_scenes/YOUR_VIDEO_NAME/undistorted/
```

### Prep for 3D Printing:
```
1. In Blender, select the point cloud
2. Modifiers → Add Modifier → Remesh (Smooth)
3. File → Export As → STL
4. Upload to Shapeways or local print service
```

### Pro Tips:
- ✅ MORE frames = better detail (100+ is ideal)
- ✅ Consistent lighting = better reconstruction
- ✅ Stationary subject = easiest to process
- ❌ Avoid fast movements
- ❌ Avoid reflective surfaces (very shiny statues)
- ❌ Avoid backlighting (harsh shadows)

### Results You Can Expect:
- **Good:** Clean point cloud, visible details
- **Great:** Watertight mesh ready to print
- **Amazing:** Textured mesh from video frames

Happy scanning! 🚀
