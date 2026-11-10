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
if [[ -z "${RENDER_PRESETS_SKIP_UNITTEST:-}" ]]; then
  "$PYTHON" -m unittest discover -s Boxes/tests -p 'test_*.py'
fi

for p in 0 1 2 3; do
  run_scad "bottom preset $p" -o "out/bottom-preset-$p.stl" \
    -D dividerLayoutPreset="$p" \
    -D generateBoxTop=false -D generateLatches=false -D generateHandle=false \
    $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad
  "$PYTHON" Boxes/tests/check_rugged_overhangs.py "out/bottom-preset-$p.stl"
done

for p in 0 1 2 3; do
  run_scad "lid preset $p" -o "out/lid-preset-$p.stl" \
    -D dividerLayoutPreset="$p" \
    -D generateBoxBottom=false -D generateBoxTop=true \
    -D generateLatches=false -D generateHandle=false \
    $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad
  "$PYTHON" Boxes/tests/check_rugged_overhangs.py "out/lid-preset-$p.stl"
done

run_scad "latch" -o out/latch.stl \
  -D generateBoxBottom=false -D generateBoxTop=false \
  -D generateLatches=true -D generateHandle=false \
  $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad
"$PYTHON" Boxes/tests/check_overhangs.py out/latch.stl

run_scad "handle" -o out/handle.stl \
  -D generateBoxBottom=false -D generateBoxTop=false \
  -D generateLatches=false -D generateHandle=true -D numberOfLatches=2 \
  $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad
"$PYTHON" Boxes/tests/check_overhangs.py out/handle.stl

run_scad "closed preset 2" -o out/closed-preset-2.stl \
  -D viewBoxClosed=true -D dividerLayoutPreset=2 \
  -D generateLatches=false -D generateHandle=false \
  $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad

"$PYTHON" Boxes/tests/check_layout.py out/bottom-preset-0.stl out/bottom-preset-2.stl out/closed-preset-2.stl
"$PYTHON" Boxes/tests/check_geometry.py out/bottom-preset-0.stl out/bottom-preset-2.stl \
  out/lid-preset-0.stl out/lid-preset-2.stl out/latch.stl out/handle.stl out/closed-preset-2.stl
geom_rc=$?
if [[ $geom_rc -ne 0 ]]; then
  exit "$geom_rc"
fi

if command -v xvfb-run >/dev/null; then
  echo "  PNG previews ..."
  xvfb-run -a "$SCAD" -q --hardwarnings --autocenter --viewall --imgsize 800,600 \
    -D viewBoxClosed=true -D dividerLayoutPreset=2 \
    -D generateLatches=false -D generateHandle=false $OFF \
    -o out/closed-preview.png Boxes/RuggedBoxCustomeDividersV1.0.scad 2>"$LOG" || { cat "$LOG"; exit 1; }
  grep -qE '(ERROR|WARNING):' "$LOG" && { cat "$LOG"; exit 1; } || true
  for p in 0 1 2 3; do
    xvfb-run -a "$SCAD" -q --hardwarnings --autocenter --viewall --imgsize 800,600 \
      -D viewBoxClosed=false -D dividerLayoutPreset="$p" \
      -D generateLatches=false -D generateHandle=false -D generateBoxTop=false \
      $OFF -o "out/bottom-preset-$p.png" Boxes/RuggedBoxCustomeDividersV1.0.scad 2>"$LOG" || exit 1
    xvfb-run -a "$SCAD" -q --hardwarnings --autocenter --viewall --imgsize 800,600 \
      -D viewBoxClosed=false -D dividerLayoutPreset="$p" \
      -D generateBoxBottom=false -D generateLatches=false -D generateHandle=false \
      $OFF -o "out/lid-preset-$p.png" Boxes/RuggedBoxCustomeDividersV1.0.scad 2>"$LOG" || exit 1
  done
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
