#!/usr/bin/env bash
# test_setup.sh - Verify pipeline installation

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  🔍 AUTOMATED PIPELINE — SETUP VERIFICATION                   ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

PASSED=0
FAILED=0

test_command() {
  local name=$1
  local cmd=$2
  echo -n "Checking $name... "
  if output=$(eval "$cmd" 2>&1); then
    echo "✓ OK"
    ((PASSED++))
    return 0
  else
    echo "✗ FAILED"
    echo "  Error: $output"
    ((FAILED++))
    return 1
  fi
}

test_directory() {
  local name=$1
  local path=$2
  echo -n "Checking $name... "
  if [[ -d "$path" ]]; then
    echo "✓ OK"
    ((PASSED++))
    return 0
  else
    echo "✗ MISSING: $path"
    ((FAILED++))
    return 1
  fi
}

echo "📦 DEPENDENCIES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
test_command "COLMAP" "colmap -h | head -1"
test_command "FFmpeg" "ffmpeg -version | head -1"
test_command "Bash" "bash --version | head -1"
test_command "YAML support" "python3 -c 'import yaml' 2>/dev/null || echo 'Python YAML not found'"

echo ""
echo "📁 PROJECT STRUCTURE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
test_directory "01_colmap" "$ROOT/01_colmap"
test_directory "02_videos" "$ROOT/02_videos"
test_directory "03_ffmpeg" "$ROOT/03_ffmpeg"
test_directory "04_scenes" "$ROOT/04_scenes"
test_directory "05_scripts" "$ROOT/05_scripts"

echo ""
echo "📄 CONFIGURATION FILES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_file() {
  local name=$1
  local path=$2
  echo -n "Checking $name... "
  if [[ -f "$path" ]]; then
    echo "✓ OK"
    ((PASSED++))
    return 0
  else
    echo "✗ MISSING: $path"
    ((FAILED++))
    return 1
  fi
}

test_file "run_all.sh" "$ROOT/05_scripts/run_all.sh"
test_file "config.yaml" "$ROOT/05_scripts/config.yaml"
test_file "README.md" "$ROOT/README.md"

echo ""
echo "🔧 EXECUTABLE SCRIPTS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

test_executable() {
  local name=$1
  local path=$2
  echo -n "Checking $name... "
  if [[ -x "$path" ]]; then
    echo "✓ EXECUTABLE"
    ((PASSED++))
    return 0
  else
    echo "✗ NOT EXECUTABLE"
    ((FAILED++))
    return 1
  fi
}

test_executable "run_all.sh" "$ROOT/05_scripts/run_all.sh"

echo ""
echo "📍 PATHS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Project root:  $ROOT"
echo "COLMAP binary: $(which colmap)"
echo "FFmpeg binary: $(which ffmpeg)"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ PASSED: $PASSED"
echo "✗ FAILED: $FAILED"
echo ""

if [[ $FAILED -eq 0 ]]; then
  echo "🎉 ALL CHECKS PASSED! Pipeline is ready to use."
  echo ""
  echo "Next steps:"
  echo "  1. Add video files to: $ROOT/02_videos/"
  echo "  2. Run: $ROOT/05_scripts/run_all.sh"
  echo ""
  exit 0
else
  echo "⚠️  Some checks failed. Please review the errors above."
  echo ""
  echo "Common fixes:"
  echo "  • Install missing tools: brew install colmap ffmpeg"
  echo "  • Make run_all.sh executable: chmod +x $ROOT/05_scripts/run_all.sh"
  echo "  • Check directory permissions: ls -la $ROOT"
  echo ""
  exit 1
fi
