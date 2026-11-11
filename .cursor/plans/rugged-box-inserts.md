Status: implementation complete (Phases 1–3)

# Rugged Box — standalone custom dividers (V1.0)

**Goal:** One new OpenSCAD file, `Boxes/RuggedBoxCustomeDividersV1.0.scad`, that prints a complete rugged box (bottom, lid, hinges, latches) and fuses a nested divider tree into **both** the bottom and the lid. `Boxes/RuggedBoxV1.3.scad` is not modified and is not `include`d or `use`d.

**Look and parameters:** The new file is based on V1.3. It should look like V1.3 (shell profile, ribs, rim, hinge and latch shape) and it should keep V1.3's parameter names and source defaults wherever that still makes sense. It is a separate file, not a wrapper.

**Reference:** [STLBuddy Hinged Box Maker](https://stlbuddy.com/hinged-box-maker). The screenshot is a top view of a 100 mm × 80 mm interior: one full-width cross-divider, then a column in each band at a different X (the lower column is the orange wall, near 74 mm).

---

## Global constraints

- Do not modify `Boxes/RuggedBoxV1.3.scad`.
- `Boxes/RuggedBoxCustomeDividersV1.0.scad` is the product. It has no `include` and no `use`. Not of V1.3, and not of any other file. Helpers live in that same file.
- The only other `.scad` is `Boxes/tests/rugged-box-custom-dividers-test.scad`. It `use`s the product file and nothing else. `use` brings in the functions and does not draw the box. The product file stays runnable on its own.
- Copy V1.3 behavior by copying the modules into the new file and editing them there. Do not fork a second hinge/latch design.
- Implementation starts only when Jason says run/build.
- Commands must run in Windows PowerShell 5.1 and in bash. PowerShell 5.1 has no `&&`.

### Print orientation (V1.3 layout)

| Part | On the bed |
|------|------------|
| Bottom, dividers fused in | Outer floor on `z = 0`. Opening and divider tops toward +Z. |
| Lid, dividers fused in | **Outer top skin** on `z = 0`. Inner opening and divider free ends toward +Z. Same bed pose as V1.3's lid print layout, not flipped into the installed pose. |
| Latch bodies | `linear_extrude` in +Z, back face on `z = 0`. |
| Handle (two copies) | Flat base on `z = 0`, grip toward +Z. |
| Gasket, only if `boxSealType = 2` | Flat on `z = 0`. |
| Feet, only if `isFeetAdded` | Flat base on `z = 0`. |

There is no printed hinge pin. V1.3 uses a screw. The knuckles and screw holes are part of the bottom and the lid.

**Overhang rule (dropped, Nov 2025):** An earlier build enforced a 30°-from-vertical limit on downward faces. That produced weak, odd hinge and latch shapes. The product file now copies V1.3 shell, hinge, latch, rim, seal, and handle geometry as-is. `Boxes/tests/check_overhangs.py` may still be run with `--report-only` for diagnostics; it is not a merge gate.

---

## 1. What V1.3 is, and what the new file keeps

### 1.1 V1.3, read from the file

`Boxes/RuggedBoxV1.3.scad` is one monolith. Lines 1–251 are Customizer assignments. Lines 256–263 derive the outside size. Lines 281–383 place geometry at the top level, so `include` of that file always draws a box. Nothing under `Boxes/` uses `include` or `use` today.

Outside size:

```openscad
boxWidthXMm  = internalBoxWidthXMm + (2*boxWallWidthMm);
boxLengthYMm = internalboxLengthYMm + (2*boxWallWidthMm);
boxBottomHeightZMm = internalboxBottomHeightZMm + boxWallWidthMm;
boxTopHeightZMm    = internalBoxTopHeightZMm + boxWallWidthMm;
```

Source defaults: interior 160 × 60 mm, bottom interior height 30 mm, lid interior 15 mm, wall 2 mm, chamfer 1 mm. The screenshot's 100 × 80 mm is not a V1.3 default. The new file keeps the source defaults. Preset 2 scales the screenshot fractions to whatever the interior is.

Print layout when `viewBoxClosed` is false: the bottom is translated by `boxBottomHeightZMm` so the floor sits on the bed and the opening faces up (lines 311–317). The lid is moved beside it and rotated so it also sits on the bed (lines 326–328). Latches are extruded beside the box (lines 633–637). Handles sit in front (lines 356–361). The new file uses that same arrangement.

`requestedLatchCenterOffsetMm` is assigned twice (line 165 as 30, line 214 as 5). OpenSCAD uses the last one, so the effective default is 5. The new file has a single assignment, default 5.

The legacy dividers (`gridMode`, `columnsPerRow`, lines 102–132 and 878–947) are a ragged grid. They cannot put a column in one band only, and they cannot put the two columns of the screenshot at different X positions. The new file does not copy that grid.

### 1.2 Features reproduced

Same names, same source defaults, same look for shell, rim, hinges, latches, seal, and handle (copied from V1.3).

| Feature | Where it is in V1.3 | In V1.0 file |
|---------|---------------------|---------|
| Bottom shell and lid shell | `BoxShellBase`, `Wall2D`, `BoxBottom`, `BoxTop` | Yes. Inner floor fillet kept. |
| Side ribs | `BoxShellBase` lines 966–977 | Yes. |
| Rim | `Wall2D` lines 1046–1063 | Yes. Same 45° underside as V1.3. |
| Hinges, screw holes, count, offsets | `BotomStandardHinge`, `TopStandardHinge` | Yes. Same cylinders, ribs, and 45° braces as V1.3. |
| Latch mounts and latch bodies | `LatchMount`, `StandardLatch` | Yes. Same as V1.3. |
| Handle | `CaseHandle`, default on | Yes. V1.3 `hull()` shape and circular screw holes. |
| Circular seal and gasket seal | `boxSealType`, seal modules | Yes. V1.3 circular bead/groove. Gasket slot kept. |
| Feet | `isFeetAdded` default false | Yes, optional. **`isFeetAdded` stays false** by default (Jason). |
| Closed-box preview | `viewBoxClosed` | Yes. CLI exports use the print layout (`false`). |
| Poly level | `BoxPolygonStyle` → `polyLvl` | Yes. |

### 1.3 Features dropped

| Dropped | Why |
|---------|-----|
| Legacy `gridMode` / `columnsPerRow` dividers | Replaced by the split tree, fused into the bottom. |
| `generateEmptyBottomBoxTPUInsert`, `generateEmptyTopBoxTPUInsert`, `CreateBoxInserts` | A blank TPU insert is a different part. `resize()` also scales the fillet. |
| `generateGasketTestObjects` coupon | A printer-tuning offcut, not the box. |
| The second copy of the latch Customizer block | It only overrides one default. |
| Drop-in tray, tray floor, `insertTrayTolerance`, `dividerFloorThickness`, `dividerBottomClearance` | Jason wants the dividers fused into the box. |

### 1.4 Cavity the dividers fuse into

The divider modules in V1.3 span the rectangle from `(boxWallWidthMm, boxWallWidthMm)` by `internalBoxWidthXMm` × `internalboxLengthYMm` (lines 878–893). That rectangle is the vertical inner face. The corners are not a `circle` of radius `boxChamferRadiusMm`.

`Wall2D` (lines 1024–1091), swept by `BoxShellBase`:

- `floorChamferRadius = boxChamferRadiusMm * sqrt(2)` (line 1026).
- The inner fillet is the circle of radius `floorChamferRadius - wallThickness` (line 1074).
- The extra corner trim runs only when `wallThickness <= boxChamferRadiusMm` (line 1076). File defaults (wall 2, chamfer 1) skip it, so those inside corners are square. Other presets are not.

The void is the `difference` at lines 453–457: a cube minus `BoxShellBase(..., boxChamferRadiusMm)`. The lid uses `boxChamferRadiusMm * 2` (lines 417–422). Ribs sit outside the inner face.

Divider cubes in V1.3 run from the floor top up to the parting plane (`z = 0` in module space, lines 895–898). The new file stops bottom and lid divider tips **0.5 mm** short of that plane so the lid closes (§5).

---

## 2. Files

| File | Responsibility |
|------|----------------|
| `Boxes/RuggedBoxCustomeDividersV1.0.scad` | The whole box, the divider tree, the Customizer. No `include`, no `use`. |
| `Boxes/tests/rugged-box-custom-dividers-test.scad` | `use <../RuggedBoxCustomeDividersV1.0.scad>`, then `assert`s. Echoes `custom-dividers-tests ok`. No mesh. |
| `Boxes/tests/render-presets.ps1` | PowerShell 5.1 renders; optional `--report-only` overhang report. |
| `Boxes/tests/render-presets.sh` | bash renders; optional `--report-only` overhang report. |
| `Boxes/tests/check_overhangs.py` | STL normal report (`--report-only` for render scripts). |
| `Boxes/tests/test_check_overhangs.py` | Synthetic-STL tests for the checker logic. |

No sibling Customizer JSON. Presets live in the `.scad` file. Helpers take arguments so the test does not depend on Customizer values in the `use`d file.

---

## 3. Layout model

### 3.1 Tree

A leaf is `[]`. A split is `["x" or "y", pos_mm, child_lo, child_hi]`.

- `"x"` is a **Column**: a wall of constant X across the parent cell's Y span. `pos_mm` is millimeters from the cell's `xmin`.
- `"y"` is a **Cross-divider**: a wall of constant Y across the parent cell's X span. `pos_mm` is millimeters from the cell's `ymin`.
- `child_lo` is the side toward the smaller coordinate.

Screenshot shape, as fractions of whatever the interior is (preset 2 computes the millimeters):

```openscad
// one cross-divider, then a column in EACH band at a different X
["y", 0.40 * length,
  ["x", 0.62 * width, [], []],
  ["x", 0.74 * width, [], []]
]
```

The same tree can leave one side empty (`["y", pos, ["x", pos2, [], []], []]`) or nest deeper. `rb_uniform(cols, rows, w, l)` builds the equal-spacing grid. Do not port `numBoxLengthYSectionsToSkip`; omitting a split is the same thing.

### 3.2 Customizer

The Customizer edits numbers, bools, strings, and flat numeric vectors. It does not edit a nested list. V1.3 already hides computed lists behind `/* [Hidden] */` (lines 125–132). The new file does the same for the tree.

**Bottom and lid share one layout.** There is no second preset or second string for the lid. When the lid is built, the resolved bottom tree is passed through `rb_mirror_y(...)` so compartments line up when the box is closed. That matches V1.3's habit of reversing row order on the lid (`BoxLengthXSeparators(..., isReversed=true)`, lines 424–428) instead of adding a second editor.

```openscad
/*[Objects To Generate]*/
generateBoxBottom = true;
generateBoxTop = true;
generateLatches = false;
generateHandle = true;
generateGasket = true;       // still only if boxSealType == 2
generateFeetIfSetInSettings = true;

/*[Divider layout]*/
dividerLayoutPreset = 2; // [0:None, 1:UniformGrid, 2:Screenshot, 3:CustomString]
uniformGridCols = 2;     // [1:8]
uniformGridRows = 2;     // [1:8]
dividerWallThickness = 1.2;
dividerTopClearance = 0.5;
dividerLayoutString = "y32(x62(.,.),x74(.,.))";
```

Box, hinge, latch, handle, seal, rib, and feet parameters keep V1.3's names and source defaults (`internalBoxWidthXMm`, `internalboxLengthYMm`, `internalboxBottomHeightZMm`, `internalBoxTopHeightZMm`, `boxWallWidthMm`, `boxChamferRadiusMm`, `BoxPolygonStyle`, `rimWidthMm`, `rimHeightMm`, `openingTolerance`, and the rest of those groups).

- Presets 0–2 ignore the string. Preset 2 scales the screenshot fractions to the current interior.
- Preset 3 parses the string. Millimeters in the current interior. It does not scale if the box size changes.

```text
node = "." | ("x" | "y") number "(" node "," node ")"
```

`y32(x62(.,.),x74(.,.))` is the screenshot on a 100 × 80 mm interior. Spaces are allowed. No fractions, no `|`, no `;`. Parsing uses `search()` / `chr()` (OpenSCAD 2021.01 has no regex). A bad string `assert`s with the string in the message.

### 3.3 Helpers and the assert on each

| Function | Assert |
|----------|--------|
| `rb_parse(s)` | screenshot string → that tree; `"y32(x50(.,.),.)"` → column on one side; `"y32(.,x40(.,x70(.,.)))"` → depth 3. |
| `rb_uniform(cols, rows, w, l)` | 2×2 on 100×80 → one Y wall at 40 and one X wall at 50 in each band. |
| `rb_walls(node, xmin, ymin, xmax, ymax)` | screenshot tree → 3 walls; the Y wall spans the full width; each X wall spans only its band. |
| `rb_mirror_y(node, ymin, ymax)` | mirrored twice equals the original; X unchanged; Y split positions map to `length - pos`. |
| `rb_lid_tree(bottom_tree, length)` | equals `rb_mirror_y(bottom_tree, 0, length)`. |
| `rb_divider_tip_z(clearance)` | shell-frame tip is `-clearance` (0.5 → `-0.5`). Same formula for bottom and lid. |
| `rb_closed_divider_gap(clearance, opening_tol)` | `2*clearance + opening_tol`. Defaults → `1.1`. |
| `rb_inside_corner_trimmed(wall, chamfer)` | `false` for `(2, 1)`; `true` for `(2, 6)`. This is the line 1076 predicate. |

`rb_validate` asserts each `pos_mm` leaves at least `dividerWallThickness` of parent on both sides, thickness ≥ 1.0, clearance > 0, and wall count ≤ 32.

---

## 4. Output

One solid bottom: shell ∪ bottom dividers. One solid lid: shell ∪ lid dividers (Y-mirrored tree). Latch bodies, handles, gasket, and feet are the same separate pieces V1.3 already splits off for printing.

CLI renders set one `generate*` flag at a time so each STL is one part. `dividerLayoutPreset` is swept on **both** bottom and lid exports (0–3).

---

## 5. How the dividers fuse

Shared constants: `rb_embed = 0.2` (mm overlap into shell or sibling divider), `dividerTopClearance = 0.5` (mm gap at the parting plane on **each** half).

### 5.1 Bottom (`BoxBottom` cavity)

Each wall is a vertical cube in bottom module space:

- Plan span is the parent cell, extended **`rb_embed`** into any side that meets the shell or another divider.
- Bottom end is **`rb_embed`** below the cavity floor's top face (buried in the floor slab).
- Top end is **`dividerTopClearance`** below the parting plane (`z = 0` in `BoxBottom` space, before the print translate).

Then `union()` with the shell. No `intersection()` with the cavity void.

### 5.2 Lid — same shell frame as V1.3's lid dividers

`BoxTop` (lines 390–429) does **not** build the lid in the same Z frame as `BoxBottom`. The shell and the existing dividers are both inside:

```openscad
rotate([180,0,0]) translate([0,-boxLengthYMm,-openingTolerance])
```

Call that the **shell frame**. In it, `z = 0` is the opening and the inner ceiling is `z = -internalBoxTopHeightZMm`. V1.3's lid dividers are cubes in that frame from the ceiling up to `z = 0` (lines 424–428, `BoxLengthXSeparators` at lines 895–898).

Build the new lid walls in that **same** wrapper, not in `BoxTop` coordinates after the rotate:

- Tree is `rb_mirror_y` of the bottom tree across the **interior** length `internalboxLengthYMm` (positions measured from the inner corner `boxWallWidthMm`, not from the outside). Mirror once, here. The `rotate([180,0,0])` then maps shell Y to closed-box Y (`y → boxLengthYMm - y`), so a wall at interior position `pos` on the bottom meets the lid wall at `interior - pos`. Mirroring again after the rotate would undo that and the compartments would miss.
- Z is the bottom rule, in this same frame: root buried `rb_embed` past the inner ceiling (`z = -internalBoxTopHeightZMm - rb_embed`), tip at `z = -dividerTopClearance`. Default lid interior is 15 mm (`internalBoxTopHeightZMm`, Customizer min 15), so a 0.5 mm tip clearance still leaves a wall.
- `union` with the shell. The lid void cut uses `boxChamferRadiusMm*2` (line 421) only as the subtracted corner solid. Do not clip the divider to that solid.

`rb_validate` also asserts `dividerTopClearance + rb_embed < internalBoxTopHeightZMm` and `< internalboxBottomHeightZMm`, and `rb_embed < boxWallWidthMm` so the root stays inside the skin.

### 5.3 Why not clip to the fillet

The fillet makes the void tighter at the floor than higher up. Embedding a vertical wall with **`rb_embed`** keeps the divider root inside the skin. The fillet stays on the shell only.

### 5.4 Closing clearance

Both tips are `dividerTopClearance` short of **their own** shell opening (`z = 0` in that shell frame). That is the 0.5 mm Jason asked for on each half.

They are not 1.0 mm apart in the closed box. `BoxTop`'s shell is shifted by `-openingTolerance` before the 180° rotate (line 393), so the lid opening sits `openingTolerance` (default 0.1 mm) above the bottom opening. Closed gap between divider tips:

```text
rb_closed_divider_gap = 2*dividerTopClearance + openingTolerance
```

Defaults: `1.0 + 0.1 = 1.1` mm. The two sets cannot meet. Do not also subtract `openingTolerance` from the 0.5 mm.

### 5.5 Print orientation of the lid dividers

The print layout (lines 326–328) is `translate([0, …, boxTopHeightZMm]) translate([0, …, openingTolerance]) rotate([-180,0,0]) BoxTop()`. Combined with the shell's own 180° rotate, the **outer lid skin lands on `z = 0`** and the opening faces +Z.

In that pose the buried root is the low end (inside the skin, near `z = boxWallWidthMm`) and the free tip is the high end (`z = boxTopHeightZMm - dividerTopClearance`). Side faces stay vertical (`n_z = 0`). The tip face points +Z. Nothing on the divider faces down. Same rule as the bottom.

---

## 6. Shell and mount geometry

V1.3 is unchanged on disk. `LatchMount`, `BotomStandardHinge`, `TopStandardHinge`, `Wall2D`, `BoxCircularSealExtrude`, and `CaseHandle` are copied verbatim into the product file (no `include` / `use` of V1.3). Fused dividers (§5) are the main new geometry. Overhang-driven teardrop knuckles, 60° rim/seal rewrites, and corner facet shaves were removed.

---

## 7. Verification

Pass/fail is the process exit code plus `--hardwarnings`. Do not grep the log for `ERROR`: a no-match `grep` returns 1, so that fails a successful run. Do not use `-o /dev/null` or `-o NUL`. The export format is the file extension. Assert runs export `.echo`.

On Windows call `openscad.com`, not `openscad.exe`. The `.exe` is a GUI binary and drops stdout. Override with `$env:OPENSCAD` / `$OPENSCAD` when it is not on `PATH`.

`--hardwarnings` makes an STL export return non-zero on 2021.01. The same flag's non-zero exit for `.echo` and `.png` is the April 2021 fix, after the 2021.01 tag. Prefer a current build. Any non-zero exit fails the script.

PNG preview needs OpenGL. Headless Linux uses `xvfb-run -a` on the `openscad` binary, not on a shell function. Camera is `--autocenter --viewall`. `--imgsize` takes `width,height` as one argument.

### 7.0 Checklist before merge

For every STL in §7.1:

- [ ] Bed orientation matches the table in the global constraints.
- [ ] The part is one of: bottom or lid (per preset 0–3), latch, handle. Feet and gasket only when those flags are on.
- [ ] Hinge and latch modules match V1.3 (cylindrical knuckles, circular screw holes, 45° wall braces).
- [ ] OpenSCAD log has no `ERROR:` or `WARNING:` (`--hardwarnings`).
- [ ] Optional: `check_overhangs.py --report-only` (informational only).

### 7.1 What gets rendered

Every render also passes `-D generateGasket=false` and `-D generateFeetIfSetInSettings=false`, and leaves `viewBoxClosed` at its default `false`.

Bottoms use V1.3's default 160 × 60 interior. Preset 3's default string (`y32`, `x62`, `x74`) fits that interior. Preset 2 is the one that scales the screenshot proportions. The handle render also passes `-D numberOfLatches=2`, because V1.3 skips the handle when there are fewer than two latches and an empty export is an error.

Latch mounts are part of the bottom and the lid, so `bottom-preset-*.stl` and `lid.stl` cover them. `latch.stl` is only the loose latch bodies.

| STL | Flags |
|-----|-------|
| `out/bottom-preset-<n>.stl` | bottom only, `dividerLayoutPreset=n` |
| `out/lid-preset-<n>.stl` | lid only, same preset n |
| `out/latch.stl` | latches only |
| `out/handle.stl` | handle only |

`generateGasket=false` and `generateFeetIfSetInSettings=false` on every CLI render (`isFeetAdded` default stays false in the file).

### 7.2 Bash

```bash
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
else
  "$SCAD" --hardwarnings --autocenter --viewall --imgsize 800,600 \
    -D viewBoxClosed=true -D dividerLayoutPreset=2 \
    -D generateLatches=false -D generateHandle=false $OFF \
    -o out/closed-preview.png Boxes/RuggedBoxCustomeDividersV1.0.scad
fi
```

### 7.3 PowerShell 5.1

`$ErrorActionPreference = "Stop"` aborts a native program that writes to stderr even when the exit code is 0. Leave it at `Continue` and use `$LASTEXITCODE`. Call `openscad.com` with the call operator so each argument is one argv token.

```powershell
$ErrorActionPreference = "Continue"
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $repo
New-Item -ItemType Directory -Force -Path (Join-Path $repo "out") | Out-Null
$scad = if ($env:OPENSCAD) { $env:OPENSCAD } else { "openscad.com" }
$py = if (Get-Command python -ErrorAction SilentlyContinue) { "python" } else { "py" }

function Invoke-OpenSCAD([string[]]$ScadArgs) {
    & $scad @ScadArgs
    if ($LASTEXITCODE -ne 0) { throw "openscad exited $LASTEXITCODE" }
}
function Invoke-Check([string]$Stl) {
    & $py Boxes\tests\check_overhangs.py $Stl
    if ($LASTEXITCODE -ne 0) { throw "overhang check failed: $Stl" }
}

Invoke-OpenSCAD @("--hardwarnings","-o","out\custom-dividers-test.echo","Boxes\tests\rugged-box-custom-dividers-test.scad")
$echo = Get-Content "out\custom-dividers-test.echo" -Raw
if ($echo -notmatch "custom-dividers-tests ok") { throw "assert run did not report success" }
& $py -m unittest discover -s Boxes/tests -p 'test_check_overhangs.py'
if ($LASTEXITCODE -ne 0) { throw "overhang unit tests failed" }

foreach ($p in 0, 1, 2, 3) {
    Invoke-OpenSCAD @(
        "--hardwarnings","-o","out\bottom-preset-$p.stl",
        "-D","dividerLayoutPreset=$p",
        "-D","generateBoxTop=false","-D","generateLatches=false","-D","generateHandle=false",
        "-D","generateGasket=false","-D","generateFeetIfSetInSettings=false",
        "Boxes\RuggedBoxCustomeDividersV1.0.scad")
    Invoke-Check "out\bottom-preset-$p.stl"
}
foreach ($p in 0, 1, 2, 3) {
    Invoke-OpenSCAD @(
        "--hardwarnings","-o","out\lid-preset-$p.stl",
        "-D","dividerLayoutPreset=$p",
        "-D","generateBoxBottom=false","-D","generateBoxTop=true",
        "-D","generateLatches=false","-D","generateHandle=false",
        "-D","generateGasket=false","-D","generateFeetIfSetInSettings=false",
        "Boxes\RuggedBoxCustomeDividersV1.0.scad")
    Invoke-Check "out\lid-preset-$p.stl"
}
Invoke-OpenSCAD @(
    "--hardwarnings","-o","out\latch.stl",
    "-D","generateBoxBottom=false","-D","generateBoxTop=false",
    "-D","generateLatches=true","-D","generateHandle=false",
    "-D","generateGasket=false","-D","generateFeetIfSetInSettings=false",
    "Boxes\RuggedBoxCustomeDividersV1.0.scad")
Invoke-Check "out\latch.stl"
Invoke-OpenSCAD @(
    "--hardwarnings","-o","out\handle.stl",
    "-D","generateBoxBottom=false","-D","generateBoxTop=false",
    "-D","generateLatches=false","-D","generateHandle=true","-D","numberOfLatches=2",
    "-D","generateGasket=false","-D","generateFeetIfSetInSettings=false",
    "Boxes\RuggedBoxCustomeDividersV1.0.scad")
Invoke-Check "out\handle.stl"
```

### 7.4 Overhang checker

Recompute the normal from the vertices. Do not trust the normal stored in the STL; a flipped winding would hide every overhang.

```text
n = normalize( (v1 - v0) × (v2 - v0) )
```

If the mesh volume is negative, flip every `n` before testing. Skip a triangle whose area is under `1e-12`.

A triangle **fails** when its unit normal has `n_z < -0.5`.

**Bed contact, the only exclusion:** centroid `z ≤ 0.05` and `n_z < -0.99`. That is the flat bottom on the plate. Do not skip every triangle that merely has a vertex near `z = 0`. A chamfer that leaves the bed at 45° has `n_z ≈ -0.707` and must fail even if one edge touches `z = 0`.

Upward faces (`n_z ≥ 0`) pass. A vertical wall (`n_z = 0`) passes.

ASCII vs binary: if the first 2 KB contains `facet normal`, parse ASCII. Otherwise parse binary. A binary header may start with the letters `solid`, so that word is not the test.

```text
python3 Boxes/tests/check_overhangs.py [--z-bed-eps 0.05] file.stl ...
```

Exit 0 if none fail, 1 if any fail, 2 if the file cannot be parsed. Python 3.8+, stdlib only. Windows: `python` or `py`. Linux: `python3`.

Unit tests, written as small STL buffers in memory (no checked-in binary):

| Case | Expect |
|------|--------|
| Box 10×10×5 on the bed, outward normals | pass |
| Same box with all windings reversed (negative volume) | pass, after the flip |
| Extra triangle, `n_z = -1`, centroid `z = 2` | fail |
| Extra triangle, `n_z = -1`, centroid `z = 0` | pass (bed) |
| Extra triangle, `n_z = -0.7`, one edge at `z = 0`, centroid `z = 0.2` | fail (not bed; 45° class) |
| `n_z = -0.4` at `z = 2` | pass (about 66° from horizontal) |
| `n_z = -0.5` at `z = 2` | pass (exactly 60°) |
| `n_z = -0.6` at `z = 2` | fail |
| `n_z = +1` at `z = 5` | pass |

From the repo root: `python3 -m unittest discover -s Boxes/tests -p 'test_check_overhangs.py'`.

---

## 8. Phases

### Phase 0 — this plan

- [x] Standalone file, fused dividers on bottom and lid, overhang audit, Jason's decisions recorded.
- **Done when:** Jason says to build. No `.scad` in this phase.

### Phase 1 — helpers and the checker

- [x] Divider functions in §3.3 (including `rb_mirror_y` / `rb_lid_tree`) in `RuggedBoxCustomeDividersV1.0.scad`.
- [x] `rugged-box-custom-dividers-test.scad` with one assert per function; echo `custom-dividers-tests ok`.
- [x] `check_overhangs.py` and `test_check_overhangs.py`.
- **Done when:** `.echo` and unittest exit 0 on Windows and Linux. No box STL yet.

### Phase 2 — shell, lid shell, hinges, latches, handle (no dividers)

- [x] Copy V1.3 modules in §1.2 into the product file. `dividerLayoutPreset=0`.
- [x] Parameter names and defaults match §3.2 and the decisions table.
- **Done when:** `bottom-preset-0.stl`, `lid-preset-0.stl`, `latch.stl`, and `handle.stl` each pass `--hardwarnings` with zero CGAL errors/warnings.

### Phase 3 — fused dividers (bottom and lid)

- [x] Bottom: §5.1. Lid: §5.2 with `rb_mirror_y` tree. Presets 0–3 on both.
- [x] Assert `rb_divider_tip_z(0.5) == -0.5` and `rb_closed_divider_gap(0.5, 0.1) == 1.1`.
- **Done when:** all eight STLs pass `--hardwarnings` with zero CGAL errors/warnings. Preset 2 on the lid is the Y-mirror of the bottom. `closed-preview.png` uses `viewBoxClosed=true`. §7.0 checked off.

---

## Decisions (Jason)

| Topic | Decision |
|-------|----------|
| File name | `Boxes/RuggedBoxCustomeDividersV1.0.scad` (exact spelling) |
| Include V1.3? | **No.** Copy modules in. No `include`, no `use`. |
| Tray or fused? | **Fused into the bottom** (and lid). No tray parameters. |
| Lid dividers? | **Yes.** Same preset/string as bottom, Y-mirrored via `rb_mirror_y`. Each half stops **0.5 mm** from the parting plane. |
| Nested layout editing | Preset dropdown; preset 3 = one millimeter string, same grammar. |
| Fractions in string? | **No.** Millimeters only. Preset 2 uses fractions in code × current interior. |
| Outer bottom corner | **V1.3** arc (no overhang-driven rewrite). |
| Hinge and latch rounds | **V1.3** cylinders, circular screw holes, 45° wall braces. |
| Circular seal | **V1.3** circular bead/groove; gasket slot stays rectangular. |
| Handle and feet | **V1.3** handle; **`isFeetAdded` false** by default. Overhang checker not a gate. |
| Open cells, finger scoops | **Not in this build.** |
| V1.3 later calls this file? | **No.** Separate files. |

---

## Open questions

| Question | Recommended default |
|----------|---------------------|
| `generateHandle` when `numberOfLatches < 2`? | Keep V1.3's behavior (no handle). `handle.stl` is rendered with `-D numberOfLatches=2`. |
| Gasket and feet in the render scripts? | **Off**, matching `boxSealType` 1 and `isFeetAdded` false. Turn them on by hand when those options are enabled. |
