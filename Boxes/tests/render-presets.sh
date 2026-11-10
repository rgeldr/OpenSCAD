#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."
mkdir -p out
SCAD="${OPENSCAD:-openscad}"
PYTHON="${PYTHON:-python3}"
LOG="out/openscad-last.log"

run_scad() {
  local label=$1
  shift
  set +e
  "$SCAD" --hardwarnings "$@" >"$LOG" 2>&1
  local rc=$?
  set -e
  if [[ $rc -ne 0 ]]; then
    echo "OpenSCAD failed ($label): exit $rc" >&2
    cat "$LOG" >&2
    exit 1
  fi
  if grep -qE '^(ERROR|WARNING):' "$LOG"; then
    echo "OpenSCAD reported ERROR/WARNING ($label)" >&2
    cat "$LOG" >&2
    exit 1
  fi
}

OFF="-D generateGasket=false -D generateFeetIfSetInSettings=false"

run_scad "assert echo" -o out/custom-dividers-test.echo Boxes/tests/rugged-box-custom-dividers-test.scad
grep -q "custom-dividers-tests ok" out/custom-dividers-test.echo
"$PYTHON" -m unittest discover -s Boxes/tests -p 'test_*.py'

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

if command -v xvfb-run >/dev/null; then
  xvfb-run -a "$SCAD" --hardwarnings --autocenter --viewall --imgsize 800,600 \
    -D viewBoxClosed=true -D dividerLayoutPreset=2 \
    -D generateLatches=false -D generateHandle=false $OFF \
    -o out/closed-preview.png Boxes/RuggedBoxCustomeDividersV1.0.scad
  for p in 0 1 2 3; do
    xvfb-run -a "$SCAD" --hardwarnings --autocenter --viewall --imgsize 800,600 \
      -D viewBoxClosed=false -D dividerLayoutPreset="$p" \
      -D generateLatches=false -D generateHandle=false -D generateBoxTop=false \
      $OFF -o "out/bottom-preset-$p.png" Boxes/RuggedBoxCustomeDividersV1.0.scad
    xvfb-run -a "$SCAD" --hardwarnings --autocenter --viewall --imgsize 800,600 \
      -D viewBoxClosed=false -D dividerLayoutPreset="$p" \
      -D generateBoxBottom=false -D generateLatches=false -D generateHandle=false \
      $OFF -o "out/lid-preset-$p.png" Boxes/RuggedBoxCustomeDividersV1.0.scad
  done
else
  run_scad "closed preview png" --autocenter --viewall --imgsize 800,600 \
    -D viewBoxClosed=true -D dividerLayoutPreset=2 \
    -D generateLatches=false -D generateHandle=false $OFF \
    -o out/closed-preview.png Boxes/RuggedBoxCustomeDividersV1.0.scad
fi

echo "render-presets ok"
