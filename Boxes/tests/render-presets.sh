#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/../.."
mkdir -p out
SCAD="${OPENSCAD:-openscad}"
PYTHON="${PYTHON:-python3}"

"$SCAD" --hardwarnings -o out/custom-dividers-test.echo Boxes/tests/rugged-box-custom-dividers-test.scad
grep -q "custom-dividers-tests ok" out/custom-dividers-test.echo
"$PYTHON" -m unittest discover -s Boxes/tests -p 'test_check_overhangs.py'

OFF="-D generateGasket=false -D generateFeetIfSetInSettings=false"

for p in 0 1 2 3; do
  "$SCAD" --hardwarnings -o "out/bottom-preset-$p.stl" \
    -D dividerLayoutPreset="$p" \
    -D generateBoxTop=false -D generateLatches=false -D generateHandle=false \
    $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad
  "$PYTHON" Boxes/tests/check_overhangs.py "out/bottom-preset-$p.stl"
done

for p in 0 1 2 3; do
  "$SCAD" --hardwarnings -o "out/lid-preset-$p.stl" \
    -D dividerLayoutPreset="$p" \
    -D generateBoxBottom=false -D generateBoxTop=true \
    -D generateLatches=false -D generateHandle=false \
    $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad
  "$PYTHON" Boxes/tests/check_overhangs.py "out/lid-preset-$p.stl"
done

"$SCAD" --hardwarnings -o out/latch.stl \
  -D generateBoxBottom=false -D generateBoxTop=false \
  -D generateLatches=true -D generateHandle=false \
  $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad
"$PYTHON" Boxes/tests/check_overhangs.py out/latch.stl

"$SCAD" --hardwarnings -o out/handle.stl \
  -D generateBoxBottom=false -D generateBoxTop=false \
  -D generateLatches=false -D generateHandle=true -D numberOfLatches=2 \
  $OFF Boxes/RuggedBoxCustomeDividersV1.0.scad
"$PYTHON" Boxes/tests/check_overhangs.py out/handle.stl

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
  "$SCAD" --hardwarnings --autocenter --viewall --imgsize 800,600 \
    -D viewBoxClosed=true -D dividerLayoutPreset=2 \
    -D generateLatches=false -D generateHandle=false $OFF \
    -o out/closed-preview.png Boxes/RuggedBoxCustomeDividersV1.0.scad
fi
