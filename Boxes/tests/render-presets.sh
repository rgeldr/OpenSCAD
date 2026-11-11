#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
mkdir -p out
SCAD="${OPENSCAD:-openscad}"
PYTHON="${PYTHON:-python3}"
LOG="out/openscad-last.log"
declare -a SUMMARY=()

run_scad() {
  local label=$1
  shift
  set +e
  "$SCAD" -q --hardwarnings "$@" >"$LOG" 2>&1
  local rc=$?
  set -e
  if [[ $rc -ne 0 ]]; then
    echo "OpenSCAD failed ($label): exit $rc" >&2
    cat "$LOG" >&2
    exit 1
  fi
  if grep -qE '(ERROR|WARNING):' "$LOG"; then
    echo "OpenSCAD reported ERROR/WARNING ($label)" >&2
    grep -E '(ERROR|WARNING):' "$LOG" >&2 || true
    exit 1
  fi
  local stl=""
  local prev=""
  for arg in "$@"; do
    if [[ "$prev" == "-o" ]]; then
      stl="$arg"
    fi
    prev="$arg"
  done
  if [[ -n "$stl" && "$stl" == *.stl ]]; then
    local tris
    tris=$("$PYTHON" -c "import sys; sys.path.insert(0,'Boxes/tests'); from check_overhangs import load_triangles; print(len(load_triangles('$stl')))" 2>/dev/null || echo "?")
    SUMMARY+=("OK $label ($stl, $tris triangles)")
  else
    SUMMARY+=("OK $label")
  fi
  echo "  $label ... ok"
}

echo "render-presets: OpenSCAD=$SCAD"

OFF="-D generateGasket=false -D generateFeetIfSetInSettings=false"

# -q suppresses ECHO output to .echo files; keep assert run verbose.
set +e
"$SCAD" --hardwarnings -o out/custom-dividers-test.echo Boxes/tests/rugged-box-custom-dividers-test.scad >"$LOG" 2>&1
rc=$?
set -e
[[ $rc -ne 0 ]] && { cat "$LOG" >&2; exit 1; }
grep -qE '(ERROR|WARNING):' "$LOG" && { grep -E '(ERROR|WARNING):' "$LOG" >&2; exit 1; } || true
echo "  assert echo ... ok"
grep -q "custom-dividers-tests ok" out/custom-dividers-test.echo
"$PYTHON" Boxes/tests/check_tool_files.py
if [[ -z "${RENDER_PRESETS_SKIP_UNITTEST:-}" ]]; then
  "$PYTHON" -m unittest discover -s Boxes/tests -p 'test_*.py'
fi

EMPTY=(-D 'dividerRowHeights=[0,0,0,0,0,0]')
GRID=(
  -D 'dividerRowHeights=[1,1,1,0,0,0]'
  -D 'dividerRow1Widths=[1,1,1,1,0,0,0,0]'
  -D 'dividerRow2Widths=[1,1,1,1,0,0,0,0]'
  -D 'dividerRow3Widths=[1,1,1,1,0,0,0,0]'
)

run_scad "bottom empty" -o out/bottom-empty.stl \
  "${EMPTY[@]}" \
  -D generateBoxTop=false -D generateLatches=false -D generateHandle=false \
  $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad
"$PYTHON" Boxes/tests/check_rugged_overhangs.py --report-only out/bottom-empty.stl

run_scad "bottom screenshot" -o out/bottom-screenshot.stl \
  -D generateBoxTop=false -D generateLatches=false -D generateHandle=false \
  $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad
"$PYTHON" Boxes/tests/check_rugged_overhangs.py --report-only out/bottom-screenshot.stl

run_scad "bottom 3x4" -o out/bottom-grid-3x4.stl \
  "${GRID[@]}" \
  -D generateBoxTop=false -D generateLatches=false -D generateHandle=false \
  $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad
"$PYTHON" Boxes/tests/check_rugged_overhangs.py --report-only out/bottom-grid-3x4.stl

run_scad "lid empty" -o out/lid-empty.stl \
  "${EMPTY[@]}" \
  -D generateBoxBottom=false -D generateBoxTop=true \
  -D generateLatches=false -D generateHandle=false \
  $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad
"$PYTHON" Boxes/tests/check_rugged_overhangs.py --report-only out/lid-empty.stl

run_scad "lid screenshot" -o out/lid-screenshot.stl \
  -D generateBoxBottom=false -D generateBoxTop=true \
  -D generateLatches=false -D generateHandle=false \
  $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad
"$PYTHON" Boxes/tests/check_rugged_overhangs.py --report-only out/lid-screenshot.stl

run_scad "latch" -o out/latch.stl \
  -D generateBoxBottom=false -D generateBoxTop=false \
  -D generateLatches=true -D generateHandle=false \
  $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad
"$PYTHON" Boxes/tests/check_overhangs.py --report-only out/latch.stl

run_scad "handle" -o out/handle.stl \
  -D generateBoxBottom=false -D generateBoxTop=false \
  -D generateLatches=false -D generateHandle=true -D numberOfLatches=2 \
  $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad
"$PYTHON" Boxes/tests/check_overhangs.py --report-only out/handle.stl

run_scad "closed screenshot" -o out/closed-screenshot.stl \
  -D viewBoxClosed=true \
  -D generateLatches=false -D generateHandle=false \
  $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad

"$PYTHON" Boxes/tests/check_layout.py out/bottom-empty.stl out/bottom-screenshot.stl \
  out/closed-screenshot.stl out/bottom-grid-3x4.stl
"$PYTHON" Boxes/tests/check_geometry.py out/bottom-empty.stl out/bottom-screenshot.stl \
  out/lid-empty.stl out/lid-screenshot.stl out/latch.stl out/handle.stl out/closed-screenshot.stl
geom_rc=$?
if [[ $geom_rc -ne 0 ]]; then
  exit "$geom_rc"
fi

if command -v xvfb-run >/dev/null; then
  echo "  PNG previews ..."
  xvfb-run -a "$SCAD" -q --hardwarnings --autocenter --viewall --imgsize 800,600 \
    -D viewBoxClosed=true \
    -D generateLatches=false -D generateHandle=false $OFF \
    -o out/closed-preview.png Boxes/RuggedBoxCustomeDividersV1.0.scad 2>"$LOG" || { cat "$LOG"; exit 1; }
  grep -qE '(ERROR|WARNING):' "$LOG" && { cat "$LOG"; exit 1; } || true
  xvfb-run -a "$SCAD" -q --hardwarnings --autocenter --viewall --imgsize 800,600 \
    -D viewBoxClosed=false \
    -D generateLatches=false -D generateHandle=false -D generateBoxTop=false \
    $OFF -o out/bottom-screenshot.png Boxes/RuggedBoxCustomeDividersV1.0.scad 2>"$LOG" || exit 1
  grep -qE '(ERROR|WARNING):' "$LOG" && { cat "$LOG"; exit 1; } || true
  xvfb-run -a "$SCAD" -q --hardwarnings --autocenter --viewall --imgsize 800,600 \
    -D viewBoxClosed=false "${GRID[@]}" \
    -D generateLatches=false -D generateHandle=false -D generateBoxTop=false \
    $OFF -o out/bottom-grid-3x4.png Boxes/RuggedBoxCustomeDividersV1.0.scad 2>"$LOG" || exit 1
  grep -qE '(ERROR|WARNING):' "$LOG" && { cat "$LOG"; exit 1; } || true
  SUMMARY+=("OK PNG previews (out/*.png)")
  for mount in bottom lid; do
    xvfb-run -a "$SCAD" -q --hardwarnings --autocenter --viewall --imgsize 1200,900 \
      -D previewHingeLatchMounts=true -D previewHingeLatchPart="$mount" \
      -D generateBoxBottom=false -D generateBoxTop=false \
      -D generateLatches=false -D generateHandle=false -D generateGasket=false \
      -D generateFeetIfSetInSettings=false \
      -o "out/hinge-latch-${mount}-after.png" Boxes/RuggedBoxCustomeDividersV1.0.scad 2>"$LOG" || exit 1
    grep -qE '(ERROR|WARNING):' "$LOG" && { cat "$LOG"; exit 1; } || true
  done
  SUMMARY+=("OK hinge/latch close-up PNGs (out/hinge-latch-*-after.png)")
fi

echo ""
echo "Summary:"
for line in "${SUMMARY[@]}"; do
  echo "  $line"
done
echo "layout checks ok"
echo "geometry checks ok"
echo "render-presets ok"
