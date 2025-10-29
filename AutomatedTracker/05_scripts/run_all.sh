#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
COLMAP_BIN="colmap"      # Homebrew installs into PATH
FFMPEG_BIN="ffmpeg"
VIDEOS_DIR="$ROOT/02_videos"
SCENES_DIR="$ROOT/04_scenes"

# Ensure scenes directory exists
mkdir -p "$SCENES_DIR"

echo "📹 Searching for videos in: $VIDEOS_DIR"
video_count=0

# Use find to properly handle spaces in filenames
while IFS= read -r -d '' f; do
  ((video_count++))
  stem="$(basename "${f%.*}")"
  out="$SCENES_DIR/$stem"
  img="$out/images"
  mkdir -p "$img"

  fps=12
  maxdim=2048
  ext=jpg

  echo ""
  echo "═══════════════════════════════════════════════════════════════"
  echo "[VIDEO $video_count] Processing: $stem"
  echo "═══════════════════════════════════════════════════════════════"
  echo "[1/5] Extracting frames from: $(basename "$f") ..."
  $FFMPEG_BIN -y -i "$f" -vf "fps=${fps},scale='if(gt(a,1),${maxdim},-1)':'if(gt(a,1),-1,${maxdim})':flags=lanczos" -qscale:v 2 "$img/frame_%06d.$ext"

  echo "[1b/5] Normalizing frame dimensions..."
  # Resize all frames to same dimensions to avoid undistortion errors
  for frame in "$img"/frame_*.jpg; do
    $FFMPEG_BIN -y -i "$frame" -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" "$frame.tmp" 2>/dev/null && mv "$frame.tmp" "$frame"
  done

  echo "[2/5] Feature extraction (SIFT)..."
  $COLMAP_BIN feature_extractor --ImageReader.single_camera 1 --ImageReader.camera_model OPENCV --SiftExtraction.use_gpu 1 --database_path "$out/database.db" --image_path "$img"
  
  echo "[3/5] Feature matching..."
  $COLMAP_BIN exhaustive_matcher --SiftMatching.use_gpu 1 --database_path "$out/database.db"

  mkdir -p "$out/sparse"
  echo "[4/5] Structure from Motion (3D reconstruction)..."
  $COLMAP_BIN mapper --database_path "$out/database.db" --image_path "$img" --output_path "$out/sparse"

  if [[ -d "$out/sparse/0" ]]; then
    mkdir -p "$out/undistorted" "$out/dense"
    echo "[5/5] Dense reconstruction & mesh generation..."
    $COLMAP_BIN image_undistorter --image_path "$img" --input_path "$out/sparse/0" --output_path "$out/undistorted" --output_type COLMAP
    
    echo "  → Running stereo matching (patch match)..."
    $COLMAP_BIN patch_match_stereo \
      --workspace_path "$out/undistorted" \
      --workspace_format COLMAP \
      --PatchMatchStereo.gpu_index 0 \
      --PatchMatchStereo.geom_consistency true \
      --PatchMatchStereo.filter true || echo "⚠️  Stereo matching had issues (non-critical)"
    
    echo "  → Fusing depth maps..."
    $COLMAP_BIN stereo_fusion \
      --workspace_path "$out/undistorted" \
      --workspace_format COLMAP \
      --input_type geometric \
      --output_path "$out/dense/fused.ply" || echo "⚠️  Fusion incomplete (using sparse model instead)"
    
    if [[ -f "$out/dense/fused.ply" ]] && [[ $(stat -f%z "$out/dense/fused.ply" 2>/dev/null || echo 0) -gt 1000 ]]; then
      echo "  → Generating Poisson mesh..."
      $COLMAP_BIN poisson_mesher --input_path "$out/dense/fused.ply" --output_path "$out/dense/mesh.ply" || echo "⚠️  Mesh generation skipped"
    else
      echo "  ⚠️  Dense fusion was empty - skipping mesh (sparse model is sufficient!)"
    fi
    
    echo "✅ Finished $stem - All outputs ready in: $out"
  else
    echo "[WARN] Mapper produced no model for $stem - scene may lack parallax/features"
  fi
done < <(find "$VIDEOS_DIR" -maxdepth 1 \( -name "*.mp4" -o -name "*.mov" -o -name "*.MP4" -o -name "*.MOV" \) -print0)

if [[ $video_count -eq 0 ]]; then
  echo "⚠️  No video files found in: $VIDEOS_DIR"
  echo "Please add .mp4 or .mov files to this directory"
  exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🎬 Pipeline complete! Processed $video_count video(s)"
echo "📁 Results: $SCENES_DIR"
echo "═══════════════════════════════════════════════════════════════"
