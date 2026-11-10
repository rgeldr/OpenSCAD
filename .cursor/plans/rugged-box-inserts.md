Status: plan only, not started

# Rugged Box — Recursive Divider Inserts

**Goal:** A new OpenSCAD entry point that builds STLBuddy-style nested dividers for the V1.3 rugged box. `Boxes/RuggedBoxV1.3.scad` stays unchanged.

**Architecture:** One library of pure layout functions, plus a verbatim copy of V1.3's cavity boolean (not a new rounded-rect). One entry file for the Customizer and the tray mesh. One assert test. Two render scripts (PowerShell 5.1 and bash).

**Tech stack:** OpenSCAD 2021.01 or newer (`assert`, `.echo` export, `--hardwarnings`). No BOSL2.

**Reference:** [STLBuddy Hinged Box Maker](https://stlbuddy.com/hinged-box-maker). The attached screenshot is a top view of a 100 mm × 80 mm interior: one full-width cross-divider, then a column in each of the two bands at different X positions (the lower column is the orange selected wall, near 74 mm). That is a depth-2 tree, not a uniform grid. The same tree can nest further (a column only in one band, or a band split into three).

---

## Global constraints

- Do not modify `Boxes/RuggedBoxV1.3.scad`.
- Do not fork hinges, latches, the handle, feet, or the seal.
- Smallest design that can express the screenshot. No string dialect besides the one grammar below. No finger scoops in this build.
- Implementation starts only when Jason says run/build.
- Commands must run in Windows PowerShell 5.1 (Windows 11 default) and in bash. PowerShell 5.1 has no `&&`.

### Hard rule — 3D printer friendly (Jason, PR #1)

Every part this plan **produces** must print **without support** in its intended orientation:

- **Downward-facing** triangle normals (air above the face, solid below when printed) may not be shallower than **60° from the build plate** — equivalently, the angle between the face and **vertical (+Z)** must be **≤ 30°**.
- **Upward-facing** surfaces and the **build-plate contact** (`z ≈ 0`) are unrestricted.
- No horizontal ceilings/bridges, no lips or chamfers on **undersides**, no fillet geometry copied from the cavity profile onto sloped tray faces.

**Intended print orientation (all tray outputs):**

| Part | Orientation on the bed |
|------|-------------------------|
| **Bottom drop-in tray** (`dividerTarget = "bottom"`) | Tray **floor outer face** on `z = 0`. Walls and dividers grow **+Z**. Compartments open upward. |
| **Lid drop-in tray** (Phase 3, `dividerTarget = "lid"`) | **Same** — floor on the plate, walls up. The tray is a separate print; Jason drops it into the lid cavity after printing. Do **not** flip the mesh to match the installed lid pose. |
| **Walls-only** (`dividerFloorThickness = 0`) | Bottom of each divider wall segment on `z = 0` (no floor slab). |

Design geometry so compliance is **obvious from construction** (vertical `linear_extrude` only). Do not rely on the checker to excuse modeled overhangs.

---

## 1. What V1.3 actually is

### 1.1 Files

| File | Role |
|------|------|
| `Boxes/RuggedBoxV1.3.scad` | Hinged box. Target. Unchanged. |
| `Boxes/RuggedBoxV1.3.json` | GUI Customizer presets. CLI does not load this unless `-p`/`-P` are passed. |
| `Boxes/RuggedBoxV1.2.scad`, `RuggedGridfinityBoxV1.0.scad` | Same divider idea (rows with a column count). Not the code we extend. |
| Other files under `Boxes/` | Unrelated. |

Nothing in `Boxes/` uses `include` or `use`. Each box file is a monolith. There is no repo style guide beyond that SCAD style.

### 1.2 How the file is structured

- Lines 1–251: Customizer assignments (view flags, `BoxPolygonStyle` → `polyLvl`, internal size, wall, chamfer, seal, rim, the legacy grid, hinges, latches, handle, feet).
- Lines 256–263: outside size and section height.
- Lines 281–383: **top-level geometry** (gasket coupon, `BoxBottom`, `BoxTop`, latches, handle, feet, `CreateBoxInserts`, gasket). It is not inside a module. `include` of this file always renders a box.

Outside size (lines 256–263):

```openscad
boxWidthXMm  = internalBoxWidthXMm + (2*boxWallWidthMm);
boxLengthYMm = internalboxLengthYMm + (2*boxWallWidthMm);
boxBottomHeightZMm = internalboxBottomHeightZMm + boxWallWidthMm;
boxTopHeightZMm    = internalBoxTopHeightZMm + boxWallWidthMm;
```

File defaults: internal 160 × 60 mm, bottom interior height 30 mm, lid interior 15 mm, wall 2 mm, chamfer 1 mm. The screenshot's 100 × 80 mm is a preset we will set in the new file, not a V1.3 default.

### 1.3 Interior cavity (verified, not a rounded rect of `boxChamferRadiusMm`)

**Plan rectangle the existing dividers use** (`BoxLengthXSeparators`, lines 878–893):

- Origin `(boxWallWidthMm, boxWallWidthMm)`.
- Size `internalBoxWidthXMm` × `internalboxLengthYMm`.
- Straight walls span that full rectangle. The straights are not shortened by a corner radius.

**Vertical extent** (lines 895–898, 940–943): a divider cube runs from `z = -(height - boxWallWidthMm)` to `z = 0`. For the bottom, `height` is `boxBottomHeightZMm`, so the cube height is `internalboxBottomHeightZMm`. The divider modules treat `z = 0` as the top of the cavity (the parting plane) and the bottom of that cube as the floor top. Dividers sit on the floor and touch the parting plane.

**Corners are not `circle(r = boxChamferRadiusMm)`.** `BoxShellBase` (lines 951–963) sweeps `Wall2D` with `rotate_extrude` at the four corners. `Wall2D` (lines 1024–1091) is a vertical wall profile:

- `floorChamferRadius = sqrt(boxChamferRadiusMm^2 + boxChamferRadiusMm^2)` (line 1026), i.e. `boxChamferRadiusMm * sqrt(2)`.
- The inner fillet circle has radius `floorChamferRadius - boxWallWidthMm` (line 1074).
- Extra corner trim runs only when `wallThickness <= boxChamferRadiusMm` (line 1076).

The comments on lines 64 and 67 disagree (`>` vs `>=`) about when the inside corner is square. The code is the authority: the extra trim is applied when wall thickness is less than or equal to the chamfer radius. File defaults (wall 2, chamfer 1) skip that trim. Several JSON presets do too. A tray clipped to a rounded rect of radius `boxChamferRadiusMm` would be wrong for those boxes, and wrong for the filleted ones as well.

The void cut in `BoxBottom` (lines 453–457) is the cavity solid:

```openscad
difference() {
    translate([0,0,-(boxBottomHeightZMm-boxWallWidthMm-.01)])
        cube([boxWidthXMm, boxLengthYMm, boxBottomHeightZMm-boxWallWidthMm-.02]);
    BoxShellBase(boxBottomHeightZMm, boxChamferRadiusMm);
}
```

`BoxTop` uses the same cut with `boxChamferRadiusMm*2` (lines 417–422). Side ribs (lines 966–977) are outside the inner face. They do not change the cavity.

**Do not copy `CreateBoxInserts` (lines 517–537).** That difference is then `resize()`d to the interior minus `insertTolerance`, which scales the fillet. It is not a true offset.

**Lid mirror** (`BoxTop` lines 424–428 and `BoxLengthXSeparators` lines 884–893): the lid geometry is `rotate([180,0,0]) translate([0,-boxLengthYMm,...])`, which maps `(x, y)` to `(x, boxLengthYMm - y)`. `isReversed` only flips which row's column count is used. X is not mirrored. A tree mirror for the lid is a Y mirror only: complement Y positions and swap the two Y children. Doing both is a double mirror. Do not mirror X.

### 1.4 Legacy dividers, and why they cannot do the screenshot

- `BoxWidthYSeparators` (lines 924–936): full-width walls across X, one per row boundary. `numBoxLengthYSectionsToSkip` drops some of those walls.
- `BoxLengthXSeparators` (lines 878–922): each row has `columnsPerRow[row]` equal columns. An X wall spans only that row.

`columnsPerRow` is either "N columns in every row" or a flat list like `[1, 2, 4]` (lines 102–132). That is a ragged grid: every X wall in a row spans the whole row. It cannot put a column in the lower band at 74 mm and a different column in the upper band, and it cannot split only one side of a wall. The screenshot needs a tree.

### 1.5 Reuse decision

| Approach | Why it loses |
|----------|----------------|
| `include <RuggedBoxV1.3.scad>` | Pastes the file. Its assignments overwrite ours. Top-level code from line 281 renders the whole box. |
| `use <RuggedBoxV1.3.scad>` | Imports modules only. Those modules read V1.3's own assignments, not this file's Customizer values. `-D` on the main file does not retarget them. The divider modules are also hard-wired to `columnsPerRow`. |
| Copy the whole box | A second hinge/latch codebase. |

**Use this:** new file, same variable names for the few cavity inputs. Copy three pieces **verbatim** into the library and delete nothing else from V1.3:

1. `Wall2D` (lines 1024–1091).
2. `BoxShellBase` **without** the rib loop (lines 951–963 only).
3. The cavity `difference` (lines 453–457), called with the bottom height.

Clearance is that same solid built with `Wall2D(boxWallWidthMm + insertTrayTolerance, ...)`, which subtracts a thicker wall and shrinks the void. Do not `resize()` it the way `CreateBoxInserts` does.

The printed tray is not the 3D void itself. In `Wall2D` the inner fillet sits at the floor and the inner boundary moves into the cavity there (center x of that circle is `floorChamferRadius`, which is past the vertical inner face at `wallThickness`). The void is tighter at the floor than higher up. A solid equal to the void is wider at the top than at the base, so it overhangs when printed floor-down. Take the plan with `projection(cut=true)` 0.01 mm above the floor top and extrude the floor and the walls vertically from that plan. `projection()` without `cut=true` is the shadow of the wider upper outline and collides with the fillet.

Copied modules keep reading `boxChamferRadiusMm`, `boxWallWidthMm`, `rimWidthMm`, `rimHeightMm`, and `polyLvl`. The entry file defines those names. Do not rewrite the fillet.

---

## 2. Files to add

| File | Responsibility |
|------|----------------|
| `Boxes/lib/rugged-box-divider-lib.scad` | Layout functions, the copied cavity pieces, tray module. No top-level geometry. |
| `Boxes/RuggedBoxV1.4-Inserts.scad` | Customizer, presets, calls the tray. |
| `Boxes/tests/rugged-box-divider-lib-test.scad` | Calls every helper and `assert`s. Echoes one success line. No mesh. |
| `Boxes/tests/render-presets.ps1` | Windows PowerShell 5.1 render + overhang check. |
| `Boxes/tests/render-presets.sh` | bash render + overhang check. |
| `Boxes/tests/check_overhangs.py` | STL overhang audit (stdlib only). |
| `Boxes/tests/test_check_overhangs.py` | Synthetic-STL unit tests for the checker. |

No `RuggedBoxV1.4-Inserts.json`. A sibling JSON is loaded by the GUI and, with `-p`/`-P`, overrides `-D`. Presets live in the `.scad` file so CLI `-D dividerLayoutPreset=N` is the value that renders.

`V1.4-Inserts` is an insert for the V1.3 box, not a replacement box.

---

## 3. Layout model

### 3.1 Tree

A leaf is `[]`. A split is `["x" or "y", pos_mm, child_lo, child_hi]`.

- `"x"` is a **Column** (the "+ Column" button): a wall of constant X across the parent cell's Y span. `pos_mm` is millimeters from the cell's `xmin`.
- `"y"` is a **Cross-divider**: a wall of constant Y across the parent cell's X span. `pos_mm` is millimeters from the cell's `ymin`.
- `child_lo` is the side toward the smaller coordinate.

Positions are millimeters in the parent cell. Presets compute those millimeters from the current cavity size, so changing the box size keeps the picture. The customizer string is also millimeters (the screenshot slider is millimeters; it reads 73.92).

Screenshot preset (100 mm wide, 80 mm deep; numbers are the picture, not a caliper reading):

```openscad
// one cross-divider, then a column in EACH band at a different X
["y", 32,
  ["x", 62, [], []],
  ["x", 74, [], []]
]
```

A column in only one band, which the same model must also accept:

```openscad
["y", 32, ["x", 50, [], []], []]
```

A deeper split (not the screenshot, covered by an assert so nesting stays honest):

```openscad
["y", 32, [], ["x", 40, [], ["x", 70, [], []]]]
```

`rb_uniform(cols, rows, w, l)` builds the equal-spacing case of the V1.3 grid. Do not port `numBoxLengthYSectionsToSkip`; omitting a split is the same thing.

### 3.2 Customizer (what the panel can actually edit)

The Customizer edits numbers, bools, strings, and flat numeric vectors. It does not edit a nested list. V1.3 already hides computed lists behind `/* [Hidden] */` (lines 125–132). Do the same for the tree.

```openscad
/*[Divider layout]*/
dividerLayoutPreset = 2; // [0:None, 1:UniformGrid, 2:Screenshot, 3:CustomString]
uniformGridCols = 2;     // [1:8]
uniformGridRows = 2;     // [1:8]
dividerLayoutString = "y32(x62(.,.),x74(.,.))";
```

- Presets 0–2 ignore the string.
- Preset 3 parses the string. Grammar, one line, no second dialect:

```text
node = "." | ("x" | "y") number "(" node "," node ")"
```

Screenshot string: `y32(x62(.,.),x74(.,.))`. Spaces are allowed. No fractions, no `|`, no `;`. A fraction mode would make `32` mean either 32 mm or 32% depending on a hidden flag. Millimeters only.

Parsing uses `search()` / `chr()` (no regex in OpenSCAD 2021.01). Invalid strings `assert` with the string in the message.

There is no in-file "custom tree" preset. The string is the editable nested layout. Adding a second representation is how the earlier draft of this plan grew a grammar it could not parse (`y@0.4|x@0.5;...`).

### 3.3 Helpers and the assert that locks each one

| Function | Assert |
|----------|--------|
| `rb_parse(s)` | screenshot string → the screenshot tree; `"y32(x50(.,.),.)"` → column on one side only; `"y32(.,x40(.,x70(.,.)))"` → depth 3. |
| `rb_uniform(cols, rows, w, l)` | 2×2 on a 100×80 cavity → one Y wall at 40 and one X wall at 50 in each band. |
| `rb_walls(node, xmin, ymin, xmax, ymax)` | screenshot tree → 3 walls; the Y wall spans the full width; each X wall spans only its band. |
| `rb_mirror_y(node, ymin, ymax)` | screenshot tree, mirrored twice, equals the original. X positions unchanged. |
| `rb_wall_z(interior_h, floor_t, top_clear)` | see §5. `rb_wall_z(30, 1.2, 1) == 27.8`. |
| `rb_inside_corner_trimmed(wall, chamfer)` | `false` for `(2, 1)` (file default); `true` for `(2, 6)`. This is the line 1076 predicate, not a new radius. |

`rb_validate(node, xmin, ymin, xmax, ymax, thickness)` asserts each `pos_mm` leaves at least `thickness` of parent on both sides, and that the wall count is ≤ 32.

---

## 4. Output

**Default: a drop-in tray** (floor + walls) for the bottom cavity. The screenshot shows walls that are part of the box. We cannot union into `BoxBottom` without editing V1.3 or copying it. A tray that occupies the real cavity is the printable result that does not fork the box. V1.3's own grid dividers should be off (`numberOfRows = 1`, one column) when this tray is used, or the walls collide. Say that in the entry-file header comment.

| Parameter | Default | Role |
|-----------|---------|------|
| `dividerLayoutPreset` | `2` | Screenshot tree. |
| `dividerWallThickness` | `1.2` | Same as V1.3 `boxSectionSeparatorWidth`. |
| `dividerFloorThickness` | `1.2` | `0` turns the floor off (walls only). |
| `insertTrayTolerance` | `0.1` | Same as V1.3 `insertTolerance`. Added to the cavity wall thickness so the void shrinks. |
| `dividerTopClearance` | `1.0` | Gap from the top of the walls to the parting plane. |
| `dividerBottomClearance` | `0` | Tray sits on the floor. |
| `dividerTarget` | `"bottom"` | `"lid"` uses the lid interior height and `rb_mirror_y`. |

Cavity inputs, same names as V1.3 so values can be copied across: `internalBoxWidthXMm`, `internalboxLengthYMm`, `internalboxBottomHeightZMm`, `internalBoxTopHeightZMm`, `boxWallWidthMm`, `boxChamferRadiusMm`, `BoxPolygonStyle`, `rimWidthMm`, `rimHeightMm`. Screenshot preset sets internal size to 100 × 80.

Not parameters: finger scoops, a fused `BoxBottom`, gasket/hinge/latch flags.

---

## 5. Clip and height

**Clip:** build the cavity void from §1.3 with wall thickness `boxWallWidthMm + insertTrayTolerance`. `projection(cut=true)` 0.01 mm above the floor top gives the tight plan. If that projection is empty, the cut plane missed the solid; fix the z before exporting. Extrude the tray floor and each wall vertically from the intersection of that plan with the wall's rectangle. Walls stay vertical. This replaces `BoxInsert`'s end cuts (lines 944–945) for the tray and does not copy the fillet onto the tray as an overhang.

**Height.** Interior height of the bottom is `internalboxBottomHeightZMm` (floor top to parting plane). The lid's interior is above the seam; do not subtract it from the bottom tray. `openingTolerance` (0.1 mm) is the gap between the two shells and is already outside both interiors; do not subtract it either.

```text
tray_h = interior_h - dividerBottomClearance - dividerTopClearance
wall_h = tray_h - dividerFloorThickness
```

`rb_wall_z(30, 1.2, 1)` with bottom clearance 0 returns `30 - 1 - 1.2 = 27.8`. The earlier formula used `interior - clearances` as the wall height and then added the floor, so the tray was `dividerFloorThickness` too tall and crossed the parting plane.

OpenSCAD module origin uses V1.3's cavity `z` (floor top near `z = -(height - boxWallWidthMm)`). Before export, **`translate([0, 0, +tray_h])`** (or equivalent) moves the tray so the **bed contact is at `z = 0`**. All overhang checks assume that export transform.

Lid target: same formula with `internalBoxTopHeightZMm`, after `rb_mirror_y`. Same bed orientation and same export translate.

---

## 6. Printability (30° rule audit)

### 6.1 Construction rules (implementation)

- **Floor:** one `linear_extrude(dividerFloorThickness)` of the tray floor polygon (intersection of cavity plan with compartment layout). Top face is +Z (up); bottom is bed — **compliant**.
- **Dividers:** one `linear_extrude(wall_h)` per wall rectangle, axis **Z** only. No `rotate_extrude`, no `hull()` that adds sloped faces, no `minkowski()` with a sphere.
- **Clip:** floor plan from `projection(cut=true)`; **vertical** extrusion only. The V1.3 `Wall2D` fillet is used to **define the void** for that projection, not swept onto the tray solid (see §1.3). **Compliant.**
- **Forbidden on tray solids:** underside chamfers, draft angles &lt; 60° from horizontal, radius rounds on the **bottom** edge, pockets with horizontal roofs, bridge spans between dividers, lightening grids.
- If a **top edge** feature is ever needed (e.g. a pull tab), chamfer the **outer top** only (up-facing mold); never the underside.

### 6.2 Feature-by-feature compliance

| Feature | Complies? | Notes |
|---------|-----------|--------|
| Tray floor (solid) | Yes | Plate at `z=0`; thickness extruded +Z. |
| Divider walls (vertical) | Yes | Side normals horizontal (`n_z = 0`), not downward. |
| Divider wall **tops** | Yes | Horizontal face normal **+Z** (upward), not a downward ceiling. |
| Divider–divider T joints | Yes | 90° vertical intersections only; no fillet wedges on undersides. |
| Divider–perimeter (cavity clip) | Yes | Walls truncated by vertical floor outline; no sloped cavity fillet on tray. |
| Floor outline corners (plan) | Yes | Vertical extrusion → vertical exterior corners; no 45° bottom chamfer. |
| `dividerFloorThickness = 0` (walls-only) | Yes | Walls rest on bed; no bridging between wall bases. |
| Uniform grid / nested tree layouts | Yes | Topology only; does not add slopes. |
| Lid tray (Phase 3) | Yes | Same mesh rules; `rb_mirror_y` is layout-only, then same Z-up export. |
| Finger scoops (out of scope) | N/A | Would violate (concave undercuts); remain excluded. |
| STLBuddy “remove section” / `["open"]` (future) | **Redesign required** | Removing a cell floor exposes the **underside** of neighboring floors (downward horizontal). Future spec: either no open cells, or **per-cell floors** with vertical walls (no shared horizontal shelf), or printable only with support (reject in checker). |
| Integrated / fused V1.3 bottom (out of scope) | N/A | Not produced by this plan. |

### 6.3 V1.3 geometry (unchanged — information only)

This plan does **not** change `RuggedBoxV1.3.scad`. Jason may print the box as today. Overhangs in V1.3 are **not** fixed here; noted for context:

- **`Wall2D` floor fillet** (lines 1071–1080): inner corner is a circular fillet; when dividers use **`BoxInsert`** chamfer booleans (lines 944–945), end cuts match wall profile — relevant to **built-in** V1.3 dividers, not the drop-in tray.
- **`BoxShellBase` / hinge / latch / handle**: many slopes and overhangs; standard rugged-box print orientation is outside this insert project.
- **`CreateBoxInserts`**: blank TPU inserts use the same cavity shell; printing them is separate from the divider tray.

### 6.4 Other FDM defaults

- Default wall 1.2 mm (three 0.4 mm perimeters). `rb_validate` rejects thickness &lt; 1.0 mm.
- A split closer than the wall thickness to a cell edge is a validation error.
- Side clearance default 0.1 mm. Note in the header that FDM may want 0.2–0.4 mm.

---

## 7. Verification

Pass/fail is the process exit code plus `--hardwarnings`. Do not grep the log for `ERROR`: a no-match `grep` returns 1, so the old snippet failed the run when OpenSCAD succeeded. `-q` is omitted so the `.echo` export still contains the success line.

**Do not** `-o /dev/null` or `-o NUL`. Assert-only runs export `.echo` ([manual](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_OpenSCAD_in_a_command_line_environment)). On Windows call `openscad.com`, not `openscad.exe`. PNG preview may need `xvfb-run -a` on headless Linux. `--imgsize` takes `width,height` as one argument.

### 7.0 Per-part checklist (manual, before merge)

For each exported STL (`preset-0` … `preset-3`, lid preset when present):

- [ ] Printed orientation documented: floor / wall bases on bed, +Z up.
- [ ] No `rotate`/`hull`/`minkowski` used for tray/d divider solids (code review).
- [ ] No underside chamfer or lip in the SCAD for that export.
- [ ] `python3 Boxes/tests/check_overhangs.py <file.stl>` exits 0.
- [ ] Slicer preview (optional): no support generated with default settings.

### 7.1 Bash (`Boxes/tests/render-presets.sh`)

```bash
#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/../.."
mkdir -p out
SCAD="${OPENSCAD:-openscad}"

"$SCAD" --hardwarnings -o out/divider-lib-test.echo \
  Boxes/tests/rugged-box-divider-lib-test.scad
grep -q "divider-lib-tests ok" out/divider-lib-test.echo

PYTHON="${PYTHON:-python3}"
"$PYTHON" -m unittest discover -s Boxes/tests -p 'test_check_overhangs.py'

for p in 0 1 2 3; do
  "$SCAD" --hardwarnings -o "out/preset-$p.stl" \
    -D dividerLayoutPreset="$p" \
    Boxes/RuggedBoxV1.4-Inserts.scad
  "$PYTHON" Boxes/tests/check_overhangs.py "out/preset-$p.stl"
done

# xvfb-run execs a program. It does not see a shell function, so the
# openscad arguments are repeated here rather than wrapped in png().
if command -v xvfb-run >/dev/null; then
  xvfb-run -a "$SCAD" --hardwarnings --autocenter --viewall --imgsize 800,600 \
    -D dividerLayoutPreset=2 \
    -o out/nested_demo.png Boxes/RuggedBoxV1.4-Inserts.scad
else
  "$SCAD" --hardwarnings --autocenter --viewall --imgsize 800,600 \
    -D dividerLayoutPreset=2 \
    -o out/nested_demo.png Boxes/RuggedBoxV1.4-Inserts.scad
fi
```

Preset 3 is the screenshot string left at its default, so the parser is on the render path too.

### 7.2 Windows PowerShell 5.1 (`Boxes/tests/render-presets.ps1`)

`$ErrorActionPreference = "Stop"` is wrong here: PowerShell 5.1 turns native stderr into an error record and aborts even when OpenSCAD exits 0. Call `openscad.com` with the call operator so each argument is a separate argv token (no `cmd /c` quoting). `$LASTEXITCODE` is the pass/fail signal. Do not grep a log for `ERROR`.

```powershell
$ErrorActionPreference = "Continue"
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $repo
New-Item -ItemType Directory -Force -Path (Join-Path $repo "out") | Out-Null
$scad = if ($env:OPENSCAD) { $env:OPENSCAD } else { "openscad.com" }

function Invoke-OpenSCAD([string[]]$ScadArgs) {
    & $scad @ScadArgs
    if ($LASTEXITCODE -ne 0) { throw "openscad exited $LASTEXITCODE" }
}

Invoke-OpenSCAD @(
    "--hardwarnings", "-o", "out\divider-lib-test.echo",
    "Boxes\tests\rugged-box-divider-lib-test.scad"
)
$echo = Get-Content "out\divider-lib-test.echo" -Raw
if ($echo -notmatch "divider-lib-tests ok") { throw "assert run did not report success" }

$py = if (Get-Command python -ErrorAction SilentlyContinue) { "python" } else { "py" }
& $py -m unittest discover -s Boxes/tests -p 'test_check_overhangs.py'
if ($LASTEXITCODE -ne 0) { throw "check_overhangs unit tests failed" }

foreach ($p in 0, 1, 2, 3) {
    Invoke-OpenSCAD @(
        "--hardwarnings", "-o", "out\preset-$p.stl",
        "-D", "dividerLayoutPreset=$p",
        "Boxes\RuggedBoxV1.4-Inserts.scad"
    )
    & $py Boxes\tests\check_overhangs.py "out\preset-$p.stl"
    if ($LASTEXITCODE -ne 0) { throw "overhang check failed for preset $p" }
}
Invoke-OpenSCAD @(
    "--hardwarnings", "--autocenter", "--viewall", "--imgsize", "800,600",
    "-D", "dividerLayoutPreset=2",
    "-o", "out\nested_demo.png",
    "Boxes\RuggedBoxV1.4-Inserts.scad"
)
```

The test file ends with `echo("divider-lib-tests ok");` after the asserts. A failed `assert` is a non-zero exit and never reaches that echo.

PNG on a Windows box with a desktop session does not need Xvfb. Attach `out/nested_demo.png` and name the STL paths in the implementation PR.

### 7.3 Overhang checker (automated)

**Math (unit outward normal `n`, bed at `z = 0`, build direction +Z):**

- A triangle **violates** the 30°-from-vertical rule if it is **downward-facing** and too shallow:
  - **`n_z < -sin(30°) = -0.5`** (more than 30° from vertical toward the bed).
- **Excluded:** triangles whose three vertices all have **`z ≤ z_bed_eps`** (default `z_bed_eps = 0.05` mm) — build-plate contact.
- Upward faces (`n_z ≥ 0`) never violate.

Report each violation: triangle index, `n`, centroid, `max_z`.

**CLI:**

```text
python3 Boxes/tests/check_overhangs.py [--z-bed-eps 0.05] [--min-angle-deg 30] file.stl ...
```

Exit **0** if none; **1** if any; **2** on parse error. Python **3.8+**, stdlib only (ASCII/binary STL).

**Unit tests** (`Boxes/tests/test_check_overhangs.py`, `unittest`):

| Case | Expect |
|------|--------|
| Synthetic box 10×10×5 mm on bed | pass |
| Box + triangle normal `(0,0,-1)` at `z = 2` | fail |
| Normal `(0,0,-1)` at `z = 0.01` | pass (bed band) |
| `n_z = -0.4` at `z = 2` | pass (≤ 30° from vertical) |
| `n_z = -0.6` at `z = 2` | fail |

From repo root: `python3 -m unittest discover -s Boxes/tests -p 'test_check_overhangs.py'` (Windows: `python` / `py -3`).

**Integration:** §7.1 and §7.2 run this checker on every exported STL after Phase 2.

**Horizontal holes (future):** teardrop or diamond profile; add golden STL to unit tests. None in Phases 1–3.

---

## 8. Phases

### Phase 0 — this plan

- [x] Review against `RuggedBoxV1.3.scad` and correct the cavity, the tree, and the CLI commands.
- [x] Add Jason's 30°-from-vertical overhang rule, audit, and verification plan.
- **Done when:** Jason says to build. No `.scad` in this phase.

### Phase 1 — functions + overhang checker

- [ ] Add the library functions in §3.3. No mesh, no copied `Wall2D` yet.
- [ ] Add the OpenSCAD test file. Every function in the table has its assert.
- [ ] Add `check_overhangs.py` and `test_check_overhangs.py` (synthetic STLs only).
- **Done when:** `.echo` step exits 0; `unittest discover … test_check_overhangs.py` exits 0 on Windows and Linux. STL/overhang-on-export waits for Phase 2.

### Phase 2 — bottom tray

- [ ] Copy `Wall2D`, rib-free `BoxShellBase`, and the cavity difference. Extrude the tray from the floor-level `projection(cut=true)`; **translate so bed is `z = 0`**.
- [ ] Entry file, presets 0–3, screenshot size 100 × 80. Geometry per §6.1 only.
- [ ] Wire full render scripts (STL, PNG, overhang check per preset).
- **Done when:** four STLs exit 0 under `--hardwarnings`; **`check_overhangs.py` exits 0 on each**; preset 0 is floor-only; `out/nested_demo.png` shows one cross-divider plus a column in each band; §7.0 checklist signed off.

### Phase 3 — lid tray

- [ ] `dividerTarget = "lid"` uses lid height and `rb_mirror_y`. Same Z-up bed orientation as bottom tray.
- **Done when:** lid STL exits 0 under `--hardwarnings`; **`check_overhangs.py` exits 0**; Y-mirror assert passes; §7.0 checklist for lid STL.

---

## Open questions

| Question | Recommended default |
|----------|---------------------|
| Tray vs. dividers fused into the V1.3 shell? | **Tray.** Fusing means editing V1.3 or copying `BoxBottom`. Out of this build. |
| Where does the nested layout get edited? | **Preset dropdown, plus one millimeter string** for preset 3. Nested lists stay off the Customizer. |
| Fractions in the string? | **No.** Millimeters, matching the 73.92 mm slider. Presets recompute mm from the cavity size. |
| STLBuddy "remove section"? | **Not in this build.** A future `["open"]` leaf must not leave a shared horizontal shelf under neighbors (would fail the 30° rule); use per-cell floors or reject in the checker. |
| Finger scoops? | **Not in this build.** |
| Lid tray? | **Phase 3**, Y-mirror only, default target stays the bottom. |
| Should V1.3 later call this library? | **Separate decision.** Not part of building the tray. |
