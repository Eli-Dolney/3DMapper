#!/usr/bin/env bash
# Optimized for phone/handheld video scanning
set -euo pipefail

ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
COLMAP_BIN="colmap"
FFMPEG_BIN="ffmpeg"
VIDEOS_DIR="$ROOT/02_videos"
SCENES_DIR="$ROOT/04_scenes"

mkdir -p "$SCENES_DIR"

echo "📱 Phone Video Scanning Pipeline"
echo "═══════════════════════════════════════════════════════════════"
echo "Best for: Object scanning with handheld phone camera"
echo ""

video_count=0

while IFS= read -r -d '' f; do
  ((video_count++))
  stem="$(basename "${f%.*}")"
  out="$SCENES_DIR/$stem"
  img="$out/images"
  mkdir -p "$img"

  # Phone video settings (optimized for close-range objects)
  fps=15                    # More frames for better coverage
  maxdim=1536              # Smaller = faster, still good quality
  ext=jpg

  echo ""
  echo "📱 Processing: $stem"
  echo "───────────────────────────────────────────────────────────────"
  
  echo "[1/5] Extracting frames at ${fps}fps..."
  $FFMPEG_BIN -y -i "$f" \
    -vf "fps=${fps},scale='if(gt(a,1),${maxdim},-1)':'if(gt(a,1),-1,${maxdim})':flags=lanczos" \
    -qscale:v 2 "$img/frame_%06d.$ext"

  frame_count=$(ls "$img" | wc -l)
  echo "   ✅ Extracted $frame_count frames"

  echo "[2/5] Feature extraction (SIFT)..."
  $COLMAP_BIN feature_extractor \
    --ImageReader.single_camera 1 \
    --ImageReader.camera_model OPENCV \
    --SiftExtraction.use_gpu 1 \
    --SiftExtraction.max_num_features 8000 \
    --database_path "$out/database.db" \
    --image_path "$img" 2>&1 | tail -3

  echo "[3/5] Feature matching (sequential matcher for close objects)..."
  $COLMAP_BIN sequential_matcher \
    --SiftMatching.use_gpu 1 \
    --SiftMatching.max_num_matches 32768 \
    --database_path "$out/database.db" 2>&1 | tail -2

  mkdir -p "$out/sparse"
  echo "[4/5] Structure from Motion..."
  $COLMAP_BIN mapper \
    --database_path "$out/database.db" \
    --image_path "$img" \
    --output_path "$out/sparse" \
    --Mapper.min_model_size 3 \
    --Mapper.init_min_tri_angle 1.5 2>&1 | tail -5

  if [[ -d "$out/sparse/0" ]]; then
    mkdir -p "$out/undistorted" "$out/dense"
    echo "[5/5] Dense reconstruction..."
    
    $COLMAP_BIN image_undistorter \
      --image_path "$img" \
      --input_path "$out/sparse/0" \
      --output_path "$out/undistorted" \
      --output_type COLMAP 2>&1 | tail -2

    echo "   → Stereo matching..."
    $COLMAP_BIN patch_match_stereo \
      --workspace_path "$out/undistorted" \
      --workspace_format COLMAP \
      --PatchMatchStereo.gpu_index 0 \
      --PatchMatchStereo.geom_consistency true \
      --PatchMatchStereo.filter true \
      --PatchMatchStereo.min_triangulation_angle 1.5 \
      2>&1 | tail -2 || echo "   ⚠️  Stereo had issues (continuing)"

    echo "   → Fusing depth..."
    $COLMAP_BIN stereo_fusion \
      --workspace_path "$out/undistorted" \
      --workspace_format COLMAP \
      --input_type geometric \
      --output_path "$out/dense/fused.ply" 2>&1 | tail -2 || echo "   ⚠️  Fusion incomplete"

    if [[ -f "$out/dense/fused.ply" ]] && [[ $(stat -f%z "$out/dense/fused.ply" 2>/dev/null || echo 0) -gt 5000 ]]; then
      echo "   → Poisson meshing..."
      $COLMAP_BIN poisson_mesher \
        --input_path "$out/dense/fused.ply" \
        --output_path "$out/dense/mesh.ply" 2>&1 | tail -2 || echo "   ⚠️  Mesh gen skipped"
      echo "   ✅ Dense mesh generated!"
    else
      echo "   ℹ️  Dense fusion insufficient - sparse model is still great!"
    fi

    echo ""
    echo "✅ DONE! Your 3D model is ready:"
    echo "   📍 Location: $out"
    echo "   📊 Cameras: $frame_count frames"
    echo "   📦 Import to Blender: File → Import → COLMAP Model/Workspace"
    echo "   📂 Point to: $out/undistorted/"
    echo ""

  else
    echo "❌ Mapper failed - reconstruction unsuccessful"
    echo "   Try: Better lighting, more/slower movements, or less reflective objects"
  fi

done < <(find "$VIDEOS_DIR" -maxdepth 1 \( -name "*.mp4" -o -name "*.mov" -o -name "*.MP4" -o -name "*.MOV" \) -print0)

if [[ $video_count -eq 0 ]]; then
  echo "⚠️  No videos found in: $VIDEOS_DIR"
  exit 1
fi

echo "═══════════════════════════════════════════════════════════════"
echo "🎉 Pipeline complete! Processed $video_count video(s)"
echo "═══════════════════════════════════════════════════════════════"
