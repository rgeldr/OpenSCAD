Status: plan only, not started

# Divider layout as Customizer controls

**Goal:** Replace the stlbuddy string `y32(x62(.,.),x74(.,.))` and the preset dropdown in `Boxes/RuggedBoxCustomeDividersV1.0.scad` with Customizer controls Jason can read without learning a grammar. Design B (share vectors) is the approved layout. The tool-outline section below is also approved as the plan for non-rectangular tool pockets. Nothing in this file is implemented yet.

**Do not do while the status line says plan only:** change any product `.scad`, test, fixture, or render script. Do not modify `Boxes/RuggedBoxV1.3.scad`. There is no overhang rule.

The product file stays free of `include` and `use`. The divider tree, lid mirror, wall fusion, and the 1.1 mm closed gap stay. Layout entry changes to share vectors. Tool pockets are subtracted from a block in the bottom only.

---

## What OpenSCAD's Customizer can actually edit

This file already uses that panel (`/*[Divider layout]*/` and the groups above it). A setting appears only when it is a top-level assignment of a literal. The comment on the line above is the label. The comment after the semicolon picks the widget.

| Widget | How it is written | What Jason sees |
|--------|-------------------|-----------------|
| Slider | `n = 3; // [0:6]` | One slider, integer steps |
| Spinbox | `n = 1.2; // [1:0.1:4]` | One number with a step |
| Dropdown | `n = 0; // [0:None, 1:Even]` | A fixed list of choices |
| Checkbox | `flag = true;` | On or off |
| Text | `s = "4,4,4";` | One text field |
| Vector | `v = [1, 1, 0];` | One spinbox per number already in the literal |

Hard limits, from the Customizer (OpenSCAD 2021.01 and current builds):

- The panel is fixed by the source file. A slider cannot show or hide other sliders. Choosing "3 rows" does not remove row 4 from the panel. Extra rows stay visible and the builder ignores them.
- A vector's length is the length of the literal in the file. The panel cannot add a fifth spinbox to a four-number vector. Growing the cap means editing the `.scad` once.
- There is no table, no repeating group, and no vector-of-vectors widget. Each row's widths are their own assignment. A hidden expression may then pack those vectors into a list for the builder.
- A string is the only variable-length control. That is the thing this change is moving away from, so it is only design C below.

Recommended cap, large enough for the cases below and still a finite panel: **6 rows and 8 column slots per row.** Trailing `0` means "not used."

---

## The three cases

Interior coordinates below are millimeters from the inner corner. On the mesh the shell adds `boxWallWidthMm` (default 2), which is why today's preset 2 tips are at y=26, x=101.2, and x=120.4 on a 160 × 60 interior.

1. **Even grid.** 3 rows along Y, 4 equal columns along X in every row.
2. **Uneven column counts.** Row 1 has 4 columns, row 2 has 2, row 3 is one open cell (no column wall).
3. **Screenshot layout.** One cross wall at 40% of the length, then a column at 62% of the width in the first band and 74% of the width in the second. That is today's `rb_screenshot_tree`, and on a 100 × 80 interior it is the old string `y32(x62(.,.),x74(.,.))`. On the default 160 × 60 interior the same fractions are y=24 (mesh y=26), x=99.2 (mesh x=101.2), and x=118.4 (mesh x=120.4).

---

## Design A — row count and a column count per row

Even columns only. Each used row is split into N equal columns across the full interior width. Row bands are equal slices of the interior length.

```text
Dividers
  Rows along the length (0 = no dividers)     [ 3 ]
  Columns in row 1 (Y = 0, the front)         [ 4 ]
  Columns in row 2                            [ 4 ]
  Columns in row 3                            [ 4 ]
  Columns in row 4   (ignored while Rows < 4) [ 1 ]
  Columns in row 5                            [ 1 ]
  Columns in row 6                            [ 1 ]
  Divider wall thickness (mm)                 [ 1.2 ]
  Gap at the lid opening, each half (mm)      [ 0.5 ]
```

Source shape:

```openscad
/*[Dividers]*/
// Rows along the length (Y). 0 removes every divider.
dividerRowCount = 3; // [0:6]
// Equal columns along the width (X). Ignored when this row is past dividerRowCount.
dividerRow1Columns = 4; // [1:8]
dividerRow2Columns = 4; // [1:8]
dividerRow3Columns = 4; // [1:8]
dividerRow4Columns = 1; // [1:8]
dividerRow5Columns = 1; // [1:8]
dividerRow6Columns = 1; // [1:8]
```

| Case | How Jason sets it |
|------|-------------------|
| 3 × 4 even | Rows = 3. Row 1, 2, and 3 columns = 4. |
| 4, then 2, then 1 column | Rows = 3. Columns = 4, 2, 1. |
| Screenshot (62% / 74%) | Cannot. Each row is equal columns only. The closest is 2 rows and 1 column, which is one cross wall and no column walls. |

**Pros.** Seven controls. The labels say "row" and "columns." Changing the interior width or length keeps the same counts and respaces the walls. A 3 × 4 grid is obvious.

**Cons.** The screenshot layout is not expressible. Column walls in one row cannot sit at a different X from another row unless the column *count* differs, and even then the walls are evenly spaced.

---

## Design B — share vectors (recommended)

Each used row has a height share and up to eight width shares. `0` ends the list. Shares are normalized, so `[2, 3]` is 40% / 60% and `[1, 1, 1]` is three equal parts. The interior size is applied after that, so resizing the box keeps the same proportions.

```text
Dividers
  Row height shares, front to back. 0 ends the list.
    [ 2 ] [ 3 ] [ 0 ] [ 0 ] [ 0 ] [ 0 ]

  Row 1 column width shares. 0 ends the list.
    [ 62 ] [ 38 ] [ 0 ] [ 0 ] [ 0 ] [ 0 ] [ 0 ] [ 0 ]
  Row 2 column width shares.
    [ 74 ] [ 26 ] [ 0 ] [ 0 ] [ 0 ] [ 0 ] [ 0 ] [ 0 ]
  Row 3 column width shares.   (ignored while its height is 0)
    [ 1 ] [ 0 ] [ 0 ] [ 0 ] [ 0 ] [ 0 ] [ 0 ] [ 0 ]
  ... rows 4–6, same pattern, left at a single 1 and the rest 0 ...

  Divider wall thickness (mm)               [ 1.2 ]
  Gap at the lid opening, each half (mm)    [ 0.5 ]
```

Source shape (rows 4–6 omitted here; they follow the same pattern):

```openscad
/*[Dividers]*/
// Height shares along Y, front (Y=0) to back. Trailing 0s are unused. [2, 3] is 40% then 60%.
dividerRowHeights = [2, 3, 0, 0, 0, 0];
// Width shares along X for that row. One positive number means the row has no column wall.
dividerRow1Widths = [62, 38, 0, 0, 0, 0, 0, 0];
dividerRow2Widths = [74, 26, 0, 0, 0, 0, 0, 0];
dividerRow3Widths = [1, 0, 0, 0, 0, 0, 0, 0];
```

The file default is the screenshot, so opening the model matches today's preset 2.

| Case | Heights | Each row's widths |
|------|---------|-------------------|
| 3 × 4 even | `[1, 1, 1, 0, 0, 0]` | `[1, 1, 1, 1, 0, 0, 0, 0]` on rows 1–3 |
| 4, then 2, then one open cell | `[1, 1, 1, 0, 0, 0]` | row 1 `[1, 1, 1, 1, 0, 0, 0, 0]`, row 2 `[1, 1, 0, 0, 0, 0, 0, 0]`, row 3 `[1, 0, 0, 0, 0, 0, 0, 0]` |
| Screenshot | `[2, 3, 0, 0, 0, 0]` | row 1 `[62, 38, 0, 0, 0, 0, 0, 0]`, row 2 `[74, 26, 0, 0, 0, 0, 0, 0]` |

On a 100 × 80 interior the screenshot numbers come back as millimeters: the cross wall at 32 mm, columns at 62 mm and 74 mm. On a 160 × 60 interior they come back as 24 mm, 99.2 mm, and 118.4 mm (mesh 26, 101.2, 120.4), which is the check already in `Boxes/tests/check_layout.py`.

**Pros.** All three cases are numbers Jason can point at. Equal grids are a run of `1`s. The screenshot is the same 62 and 74 he already uses, written as shares instead of a nested string. Changing `internalBoxWidthXMm` or `internalboxLengthYMm` rescales every wall. No preset dropdown and no grammar.

**Cons.** The panel is long: 6 height boxes plus 6 × 8 width boxes. Unused rows stay on screen. A spinbox is not labeled "column 3"; the description on the vector has to say that trailing zeros are unused. A `0` before the end of a list is an error, not a hole in the middle (see validation).

---

## Design C — one readable text field

Still a string, but one row per band and commas for column widths. No parentheses and no `x` / `y` / `.`.

```text
Dividers
  One row per band, front to back. Commas are column widths.
  0 rows (empty text) means no dividers.
  [ 62,38 / 74,26                                              ]
  Divider wall thickness (mm)            [ 1.2 ]
  Gap at the lid opening, each half (mm) [ 0.5 ]
```

| Case | Text |
|------|------|
| 3 × 4 even | `1,1,1,1 / 1,1,1,1 / 1,1,1,1` |
| 4, then 2, then one open cell | `1,1,1,1 / 1,1 / 1` |
| Screenshot | `62,38 / 74,26` |

Row heights in this form are equal. A second optional text field `dividerRowHeightShares = "2,3"` covers the screenshot's 40/60 split. If that field is empty, rows are equal.

**Pros.** One or two text fields, no cap, and the screenshot is a short line. Shares still scale with the box.

**Cons.** It is still a string Jason has to type correctly. A typo is an assert instead of a spinbox that cannot be malformed. This is the design to pick only if the vector panel in B is too long.

---

## Recommendation

**Approved: design B.** It is the layout to build. It uses spinboxes, covers an even grid, covers rows with different column counts, and covers the screenshot's 62 / 74 split, and it still follows a box-size change. Design A stays documented as the shorter panel that cannot place uneven widths. Design C stays documented as the one-text-field alternative. Neither is the implementation.

File defaults are the screenshot shares (`[2, 3, ...]`, `[62, 38, ...]`, `[74, 26, ...]`), so the model opens on the layout preset 2 uses today.

---

## Validation and the messages

`rb_validate` stays the backstop (thickness ≥ 1 mm, clearance > 0, embed < wall width, clearance + embed fits both interior heights, each split at least `dividerWallThickness` from its cell edges, at most 32 walls). The new builder asserts first, with the row and column in the text, so the Customizer console names the field Jason just edited.

| Check | Message shape |
|-------|----------------|
| A `0` with a later positive number | `dividerRowHeights: a 0 must be trailing, found 0 before 2` |
| Negative share | `dividerRow2Widths[1] is -1; shares must be 0 or positive` |
| A used row whose widths are all 0 | `divider row 2 has a height share but no column widths` |
| Widths set on a row whose height is trailing 0 | Ignored, not an error |
| After normalizing, a compartment narrower than `dividerWallThickness` | `divider row 2 column 1 is 0.8 mm; minimum is dividerWallThickness (1.2 mm)` |
| Same check for a row band | `divider row 3 height is 0.4 mm; minimum is dividerWallThickness (1.2 mm)` |
| More than 32 walls | The existing `rb_validate: too many walls` assert |

Normalization: drop trailing zeros, divide by the sum of the remaining positives, multiply by `internalboxLengthYMm` or `internalBoxWidthXMm`. Positions stored in the tree are millimeters from the cell origin, which is what `rb_walls` and `rb_mirror_y` already expect.

One positive width means "this row is a single cell." No column wall is emitted.

---

## Lid mirror, the 1.1 mm gap, thickness, box size

These stay as they are.

- One layout builds the bottom tree. `rb_lid_tree` / `rb_mirror_y` still mirrors it across the interior length measured from `boxWallWidthMm`, inside the lid's existing 180° shell frame. Do not add a second copy of the row and width vectors for the lid. The only new lid control is the plain-lid dropdown in the tool-outline section.
- `dividerTopClearance` stays 0.5 mm on each half. `rb_divider_tip_z(0.5)` stays `-0.5`. `rb_closed_divider_gap(0.5, 0.1)` stays `1.1` (`2 * clearance + openingTolerance`). Tips on a closed default render stay at z=31.5 and z=32.6.
- `dividerWallThickness` stays a Customizer number in the Dividers group (default 1.2, minimum 1.0). `rb_embed` stays 0.2 and moves under `/* [Hidden] */` so the panel is not carrying an overlap constant. The embed assert stays.
- Because shares are normalized, editing `internalBoxWidthXMm` or `internalboxLengthYMm` moves the walls. It does not require retyping 62 and 74. A value that scales to a sliver fails the assert above instead of emitting a wall that breaks the thickness rule.

---

## What is removed, and what the builder becomes

Remove from the Dividers group:

- `dividerLayoutPreset` (None / UniformGrid / Screenshot / CustomString)
- `uniformGridCols`, `uniformGridRows`
- `dividerLayoutString`

Remove the functions that only exist to feed those controls:

- `rb_preset_tree`, `rb_uniform`, `_rb_uniform_x`, `_rb_uniform_y`, `rb_screenshot_tree`
- `rb_parse` and the string helpers (`_rb_ws_chars` through `_rb_expect_char`)

Keep, unchanged in behavior:

- The tree shape `["x" or "y", pos_mm, child_lo, child_hi]` and the leaf `[]`
- `rb_walls`, `rb_mirror_y`, `rb_lid_tree`, `rb_validate`, `rb_fused_divider_solids`
- `rb_divider_tip_z`, `rb_closed_divider_gap`, `dividerTopClearance`, `openingTolerance`

New hidden builder, called from the existing `_bottom_divider_tree` assignment:

```openscad
function rb_row_layout(heights, width_rows, interior_w, interior_l) = ...
```

`width_rows` is a list of the six vectors, assembled in a hidden expression. The function:

1. Asserts the share rules above.
2. Turns height shares into Y positions (cumulative millimeters).
3. For each band, turns that row's width shares into X positions.
4. Returns one Y chain. Each side of a Y split is either a leaf or an X chain. An X chain is the same shape `_rb_uniform_x` builds today, with explicit positions instead of `w / cols`.

No preset index remains. `-D dividerLayoutPreset=2` goes away. Overrides pass vectors, for example `-D dividerRowHeights=[1,1,1,0,0,0]`. Each `-D` is its own argument, and the value is quoted so PowerShell 5.1 does not split on commas or brackets.

---

## Tests

Windows-safe: no `&&`, no bash required for the PowerShell path. `render-presets.ps1` already avoids both. New `-D` values go through that script's existing argument quoting.

Update:

| File | Change |
|------|--------|
| `Boxes/tests/rugged-box-custom-dividers-test.scad` | Delete the `rb_parse`, `rb_uniform`, and `rb_screenshot_tree` asserts. Assert `rb_row_layout` for the three cases on both 100×80 and 160×60. Keep mirror-twice, `rb_lid_tree`, `rb_divider_tip_z(0.5) == -0.5`, `rb_closed_divider_gap(0.5, 0.1) == 1.1`, and a `rb_validate` smoke assert. Add asserts that a middle `0` and a too-narrow compartment assert (OpenSCAD assert tests that are expected to fail belong in a separate tiny file invoked on purpose, or they are checked by rendering and requiring a non-zero exit plus the message text). |
| `Boxes/tests/check_layout.py` | Keep the mesh numbers (empty interior has no tip at y=26; screenshot tips at y=26, x=101.2, x=120.4, z=31.5; closed gap 1.1 and the lid meets those X walls). Rename the helpers off "preset 0" / "preset 2" so the names match empty vs screenshot. |
| `Boxes/tests/render-presets.sh` and `render-presets.ps1` | Stop sweeping `dividerLayoutPreset` 0–3. Render the default (screenshot shares) and one empty override (`dividerRowHeights=[0,0,0,0,0,0]`) for bottom and lid. Point `check_layout.py` at those two bottoms plus the closed default. |
| `Boxes/tests/check_geometry.py` | Retarget filenames. Default bottom/lid triangle floors stay at today's preset 2 floors (bottom 4744-class, lid 3198-class) because the default layout is the screenshot. The empty export stays at today's preset 0 floors. |
| `Boxes/tests/test_cgal_exports.py` | Drop `-D dividerLayoutPreset=0` or replace it with the empty height vector if that test should stay divider-free. |

Add:

- A Python test that does not need OpenSCAD: given the screenshot shares and a 160 × 60 interior, the positions are 24, 99.2, and 118.4 before the wall offset. This can live next to `check_layout.py` as a pure function if the builder is duplicated in Python, or it can be an assert inside the `.scad` echo test only. Prefer the `.scad` assert so there is one implementation.
- An OpenSCAD echo test for "3 × 4 on 160 × 60" → Y positions 20 and 40, X positions 40, 80, 120 in each band.
- Render one 3 × 4 bottom with `-D` vector overrides and assert those tip locations the same way `check_layout.py` asserts the screenshot. That is the test that the Customizer numbers, not a leftover preset, drive the mesh.

`check_overhangs.py` stays informational (`--report-only`). Do not add a pass/fail overhang check.

Tool-outline tests, fixtures, and the extra PowerShell steps are specified in the tool-outline section. Default renders keep `toolInsertEnabled` false, so the triangle floors in this table do not change when pockets are added.

---

## PowerShell verification

From `D:\GitHub\OpenSCAD` after the implementation exists. PowerShell 5.1 and 7. No `&&`.

```powershell
$env:OPENSCAD = "C:\Program Files\OpenSCAD\openscad.com"
Set-Location D:\GitHub\OpenSCAD

& $env:OPENSCAD --hardwarnings -o out\divider-ui-test.echo Boxes\tests\rugged-box-custom-dividers-test.scad
if ($LASTEXITCODE -ne 0) { throw "echo test failed: $LASTEXITCODE" }
$echo = Get-Content -LiteralPath out\divider-ui-test.echo -Raw
if ($echo -notmatch "custom-dividers-tests ok") { throw "divider asserts did not pass" }

.\Boxes\tests\render-presets.ps1
```

Then the tool-outline commands in the section below.

`render-presets.ps1` must exit 0, print no OpenSCAD `ERROR:` or `WARNING:`, and print `layout checks ok`. The default STL is the screenshot layout. The empty override STL has no divider tips. With the tool insert left off, those STLs gain no pockets.

A manual Customizer check, once, in the OpenSCAD GUI: open the Dividers tab, set height shares to `1,1,1,0,0,0` and the first three width rows to `1,1,1,1,0,0,0,0`, and confirm three row bands and four equal columns. Set the first height to `0` and a later one to `1` and confirm the assert names `dividerRowHeights`.

---

## Tool outline cutouts

Jason wants non-rectangular spaces shaped for specific tools, on top of the approved share-vector dividers. The pockets are cut out of a solid block in the **bottom**. The lid does not get tool pockets. `Boxes/RuggedBoxV1.3.scad` stays untouched. There is no overhang rule.

Checked against OpenSCAD 2021.01, which is the language this file has to keep working on. Jason's Windows build is newer; the rules below are the ones that already hold on 2021.01, so a newer build is not required.

### 1. How an outline gets in

`import()` is a module. It reads SVG and DXF into a 2D shape. The product file calls it directly. No `include` and no `use` of V1.3.

**Folder.** Outlines live in `Boxes/tools/`, next to `RuggedBoxCustomeDividersV1.0.scad`. OpenSCAD resolves `import()` relative to the `.scad` file, not the shell's current directory (confirmed: the same relative path loads when the process is started from the repo root, from `Boxes/`, or from elsewhere). Customizer strings and `-D` overrides use that same relative form, with forward slashes, which PowerShell and `openscad.com` both accept:

```text
Boxes/tools/_blank.svg          default for every unused slot
Boxes/tools/wrench.svg          an outline Jason adds
Boxes/tests/fixtures/...        test shapes only, not real tools
```

The committed default `Boxes/tools/_blank.svg` is a real file: a filled 1 mm × 1 mm square at the origin, `width` and `height` in mm. Unused slots point at it so a fresh open of the model never asks OpenSCAD to read a path that is not there.

**SVG units.** Two different files behave differently, measured on 2021.01:

| File | What `import` produced |
|------|------------------------|
| `width="10mm" height="20mm"` (viewBox either `0 0 10 20` or a CSS-pixel viewBox covering the same rectangle) | 10 mm × 20 mm, at both `dpi=96` and `dpi=25.4`. Declared millimeters win and **dpi is ignored**. |
| Unitless `width="10" height="20"` at `dpi=96` | 2.6458 mm × 5.2917 mm, because 1 user unit is `25.4/96` mm. |
| That same unitless file at `dpi=25.4` | 10 mm × 20 mm. One user unit is one millimeter. |

Customizer fallback, one number for every slot:

```openscad
// Used only when the SVG width/height are not in mm. 25.4 means 1 user unit = 1 mm.
toolSvgDpi = 25.4; // [1:0.1:96]
```

A file that already says `mm` is unchanged by this knob. A unitless file whose numbers are already millimeters (some exports) comes in 1:1 at 25.4. Do not use `import(..., scale=...)`. On 2021.01 that argument is ignored (a 10-unit file stayed 2.6458 mm with `scale=2`). A separate nudge exists for a trace that is a few percent off true size:

```openscad
// Multiplier applied with scale() after import. 1 leaves the file's size alone.
toolOutlineScale = 1; // [0.5:0.01:2]
```

**SVG drawing rules** that match what 2021.01 actually imports:

- Filled closed paths only. Stroke width is ignored. A stroked rectangle imported as the path's own rectangle, not as a band of stroke thickness.
- OpenSCAD flips SVG Y inside the viewBox. A rectangle at SVG y = 7..11 on a page 40 units tall landed at OpenSCAD y = 29..33. Resize the Inkscape page to the drawing so the shape sits on the page origin. After the flip, that origin is the bottom-left of the shape, which is the point the Customizer x/y moves.
- One compound path. Holes must be holes in that path, not a second object sitting on top. No text, images, filters, clones, or nested `<svg>`.

**DXF.** 2021.01 imports coordinates as millimeters and ignores `$INSUNITS`. A closed polyline tagged as inches still came in as 10 mm × 20 mm. Draw the DXF in millimeters. The entity has to be a closed `LWPOLYLINE` (group 70 = 1). An old-style `POLYLINE` / `VERTEX` file failed with `WARNING: Unsupported DXF Entity 'POLYLINE'` and an empty object. Put the outline on layer `0`. `import(file, layer="0")` works. A wrong layer name produces an empty object and a failed render, which the preflight below treats as a bad file only when the layer is missing entirely; a wrong layer still has to be avoided by exporting layer `0`.

### 2. Customizer settings

The panel cannot grow a list and cannot hide a slot. The cap is **4 outline slots**, the same idea as the 6-row cap. A fifth tool means duplicating one slot block in the `.scad`. All four slots are always visible. Slot checkboxes default off, and the master switch defaults off, so opening the file still shows only the dividers.

```text
Tool outlines
  Print a shaped insert in the bottom                         [ ] off
  Block fills                                                 [ Whole bottom | One compartment ]
  Row of that compartment (ignored for whole bottom)          [ 1 ]
  Column of that compartment                                  [ 1 ]
  Dividers                                                    [ Keep | Replace in the block ]
  Block height                                                [ Solid insert | Pocket floor ]
  Pocket plate thickness, pocket-floor mode only (mm)         [ 4 ]
  Minimum material left under a pocket (mm)                   [ 1.2 ]
  Lid                                                         [ Mirror dividers | Plain lid ]
  SVG dpi fallback (ignored when the file says mm)            [ 25.4 ]
  Scale nudge for every outline                               [ 1.00 ]

  Slot 1
    Use this slot                                             [ ] off
    File, relative to the .scad                               [ tools/_blank.svg ]
    Width of the drawing (mm)                                 [ 0 ]
    Height of the drawing (mm)                                [ 0 ]
    X from the interior's left (mm)                           [ 0 ]
    Y from the interior's front (mm)                          [ 0 ]
    Rotation around that origin (degrees)                     [ 0 ]
    Pocket depth from the top of the block (mm)               [ 8 ]
    Extra clearance around the outline (mm)                   [ 0.3 ]
    Finger notch on the front edge                            [ ] off
  Slot 2..4   same fields, left off, file tools/_blank.svg
  Finger notch width (mm)                                     [ 12 ]
  Finger notch depth toward the back (mm)                     [ 8 ]
```

`toolInsertTarget`, `toolBlockMode`, `toolDividers`, and `toolLid` are labeled dropdowns (`// [0:Whole bottom, 1:One compartment]` and the same pattern for the others). Width, height, position, rotation, depth, and clearance are spinboxes. The file is a string. OpenSCAD has no file-picker widget.

Width and height are not read from the file. `import()` does not return a size, and 2021.01 has no way to measure a module. The fit assert uses these two numbers. The how-to says to copy W and H from Inkscape after resizing the page to the drawing. The Python preflight compares them to the file's declared size and warns when they disagree by more than 0.5 mm.

Position is the drawing origin (bottom-left after the page is resized to the drawing), in interior millimeters. Interior origin is the inner front-left corner, the same origin as the divider tree, before `boxWallWidthMm` is added. Rotation is degrees counterclockwise around that origin. Clearance is an `offset(delta=...)` applied to the 2D outline before it is extruded. Positive clearance makes the pocket larger. The default 0.3 mm is a drop-in fit, not a press fit.

**Solid insert.** The block fills the target from the interior floor up to `dividerTopClearance` below the opening. With the defaults that is 30 − 0.5 = 29.5 mm tall, so the top of the block is at the same height as the divider tips. Each slot cuts down from that top by its own depth. Material left under the pocket is `29.5 - depth`, and it must be at least `toolMinPocketFloor` (1.2 mm). The box shell floor (`boxWallWidthMm`, default 2 mm) is not part of the block and is never subtracted.

**Pocket floor.** The block is only `toolPocketPlateMm` thick (default 4 mm), sitting on the interior floor. The space above the plate stays empty so a tall tool can stand in a shallow recess. Cut depth cannot exceed the plate minus the same 1.2 mm minimum floor. The plate top is far below the opening, so it cannot close the 1.1 mm lid gap.

The block overlaps the interior floor by `rb_embed` (0.2 mm) so it fuses to the shell instead of leaving a zero-thickness joint. It is inset from divider walls by zero and overlaps those walls by `rb_embed` as well when dividers are kept, so the union stays one solid. Pockets are extruded from the top of the block downward and extended 0.02 mm past the top face so the mouth is open and CGAL does not seal a void.

### 3. Dividers and the lid

The share-vector tree is built first. The block is then fitted to one rectangle:

| Target | Rectangle | Dividers set to Keep | Dividers set to Replace |
|--------|-----------|----------------------|-------------------------|
| Whole bottom | The full interior, `internalBoxWidthXMm` by `internalboxLengthYMm` | Walls stay. Every outline must sit in the interior and must not cross a wall (the wall's thickness counts). | The bottom tree becomes `[]`. The block is the only insert. |
| One compartment | The cell addressed by row and column, 1-based. Row 1 is the front band (low Y). Column 1 is the left band (low X). `rb_cell_rect` walks the tree and returns that cell. | Walls stay, including walls inside that cell. The outline must fit the cell. Use this when the tool sits in one existing opening. | `rb_clear_cell` replaces that cell's subtree with a leaf. Walls that bound the cell stay. Walls that used to cut through it go away. Use this when the tool needs the whole cell and a divider would pass through the pocket. |

A tool that should occupy two of today's columns is not done by cutting across a wall. Jason gives that region one width share so it is already one cell, then points the insert at that cell and chooses Replace. All four slots share one block. Two tools in two different cells use Whole bottom with Keep, and each outline's rectangle is checked against the walls.

The lid never imports an outline and never subtracts a pocket.

- **Mirror dividers** (default) runs the same `rb_lid_tree` / `rb_mirror_y` as today, including a cell that Replace turned into a leaf. That cell is empty on the lid too.
- **Plain lid** forces the lid tree to `[]`. The bottom dividers are unchanged.

Divider tips stay at `rb_divider_tip_z(0.5) = -0.5` in the bottom's local frame (mesh z = 31.5 after the print shift). The solid-insert top is that same plane, so the closed gap to the lid tips stays `rb_closed_divider_gap(0.5, 0.1) = 1.1`. A pocket-floor plate is shorter and does not approach the lid. Nothing in this section raises a tip or the insert into that gap.

### 4. Validation

Number checks are `assert`s, and the message names the slot. They run before any `import()`.

| Check | Message shape |
|-------|----------------|
| Master on, slot on, file still `tools/_blank.svg` | `tool slot 1 is on but still set to tools/_blank.svg` |
| Slot on and width or height is 0 | `tool slot 1 width and height must be the Inkscape page size in mm` |
| Clearance < 0 | `tool slot 1 clearance is -0.2 mm; use 0 or a positive gap` |
| Row or column outside the current layout | `tool insert row 4 does not exist; this layout has 2 rows` |
| Rotated width/height rectangle, grown by clearance, sticks out of the target | `tool slot 1 extends past the compartment: right edge 162 mm, compartment ends at 99.2 mm` |
| That rectangle crosses a kept divider | `tool slot 2 crosses the divider at x=99.2` |
| Finger notch on, and the notch rectangle (shared width and depth, centered on the outline's low-Y edge) leaves the target | `tool slot 1 finger notch extends past the compartment` |
| Solid insert, depth leaves less than 1.2 mm | `tool slot 1 cut depth 29 mm leaves 0.5 mm of floor; minimum is 1.2 mm (block height 29.5 mm)` |
| Pocket floor, depth deeper than the plate allows | `tool slot 1 cut depth 4 mm is deeper than the 4 mm plate allows; minimum floor is 1.2 mm` |
| Plate thicker than the interior minus `dividerTopClearance` | `tool pocket plate 40 mm is taller than the interior allows (29.5 mm)` |

The rotated rectangle uses the width and height Jason typed, times `toolOutlineScale`, then `offset` clearance on every side. Rotation is around the drawing origin, so the checked box is the axis-aligned bounds of that rotated rectangle, not a guess at the true curve. A curve that bulges outside its own width/height rectangle is a wrong width/height, which the preflight flags.

**Missing files.** OpenSCAD has no `file_exists` and `assert` cannot see the disk. Confirmed on 2021.01:

- `import("missing.svg")` prints `ERROR: Can't open file 'missing.svg', import() at line N`, exits 1, and does not run a later `assert`.
- `if (false) import("missing.svg")` does not open the file. A slot whose checkbox is off is safe even when the path is stale.
- A `for` loop that imports a list containing one bad path still printed `ERROR: Can't open file` and, in that build, exited 0 because another iteration produced geometry. Do not import from a loop. Write four separate `if (toolNEnabled && toolInsertEnabled) import(toolNFile, dpi=toolSvgDpi);` calls so an off slot is not opened and a bad path fails the render.

The clear message is a Python preflight, `Boxes/tests/check_tool_files.py`, run before OpenSCAD. It takes the four path strings (defaults, or the same `-D` values the render is about to use). For each slot that the arguments say is enabled it checks the path relative to `Boxes/`. Missing path:

```text
tool slot 2: file not found: tools/wrench.svg
```

Exit code 2. It does not invoke OpenSCAD. SVG size check: read `width` / `height` (honor `mm`) or the unitless viewBox times `25.4/dpi`, compare to the slot's width and height, and if they differ by more than 0.5 mm print `tool slot 2: file is 80.0 x 20.0 mm, Customizer says 10.0 x 20.0 mm` and exit 2. DXF check: the file contains a closed `LWPOLYLINE` and does not contain a bare `POLYLINE` entity; extents come from the LWPOLYLINE coordinates, which are already millimeters. Someone who skips the preflight and renders a bad path still gets `ERROR: Can't open file`, and the render scripts already fail the run on that text. The preflight is the message that names the slot.

### 5. Render performance

A photo trace can be tens of thousands of line segments. `offset()` and the CGAL `difference()` that cuts the pocket both get slow and can fail on a self-crossing path. F5 preview is usable long before F6 is.

- After tracing, Inkscape Path → Simplify until the status bar shows a few hundred nodes, not tens of thousands. One filled compound path, no islands.
- The default model imports nothing (`toolInsertEnabled` false, and an off slot does not call `import`). Divider renders stay at today's triangle counts.
- Tests import the 4-vertex fixture only. Do not commit a traced photo as a test.
- `linear_extrude(..., convexity=8)` so a concave tool previews correctly. Convexity does not speed up F6.
- The preflight prints `tool slot 1: 18432 path segments, simplify in Inkscape` as a warning above 2000 segments and still exits 0 for that warning alone. It exits 2 only for a missing file, a bad DXF entity, or a size mismatch.

### 6. How to trace a tool

1. Photograph the tool on a ruler, or measure its length and width.
2. In Inkscape, File → Document Properties → Display units and Units = mm.
3. File → Import the photo. Select it, lock the aspect ratio, and set the width to the real width in millimeters.
4. Path → Trace Bitmap. One scan, brightness cutoff, is enough for a silhouette. Delete the photo. Path → Break Apart only if a hole filled in, then Path → Combine so holes stay holes. Remove specks.
5. Path → Simplify until the outline is smooth and the node count is a few hundred.
6. Set fill to a solid color and stroke to none.
7. Object → Align and Distribute, or Edit → Resize Page to Selection, so the page is exactly the outline. Copy the page width and height from the toolbar. Those two numbers are the slot's width and height.
8. File → Save As → Plain SVG, into `D:\GitHub\OpenSCAD\Boxes\tools\`, for example `wrench.svg`. DXF is the alternative: Save As → Desktop Cutting Plotter (AutoCAD DXF R14), mm, LWPOLYLINE, layer 0. Do not export inches.
9. In OpenSCAD's Tool outlines group, turn the insert on, choose Whole bottom or the compartment, leave Keep or pick Replace, pick Solid insert or Pocket floor, turn on slot 1, set the file to `tools/wrench.svg`, paste width and height, and set X, Y, rotation, depth, and clearance. The finger-notch checkbox adds the shared notch on the front edge of that outline.
10. F5. If the pocket is the wrong size, fix the page units first. Use the scale nudge only for a small correction. If the assert names an edge, move X/Y or rotate. If it names the floor, reduce the cut depth.

### 7. Tests and PowerShell

Windows-safe: no `&&`, forward slashes in every `-D` path, each `-D` as its own argument. `render-presets.ps1` keeps treating native stderr as non-terminating. No overhang pass/fail.

**Fixtures the implementation adds** (not added by this plan):

- `Boxes/tools/_blank.svg` — 1 mm × 1 mm filled square, `width`/`height` in mm.
- `Boxes/tests/fixtures/tool-rect-10x20.svg` — filled rectangle `x=0 y=0 width=10 height=20`, page `width="10mm" height="20mm" viewBox="0 0 10 20"`.
- `Boxes/tests/fixtures/tool-rect-10x20.dxf` — one closed LWPOLYLINE, layer 0, vertices (0,0), (10,0), (10,20), (0,20). No POLYLINE/VERTEX entities. A `$INSUNITS` value other than millimeters may be present so the test proves those coordinates still import as 10 × 20 mm.

**Assert file** `Boxes/tests/rugged-box-custom-dividers-test.scad` gains number checks that do not import:

- A 10 × 20 rectangle at (4, 6), rotation 0, clearance 0.3, scale 1, inside a 160 × 60 interior, passes.
- The same rectangle rotated 90° has axis-aligned bounds 20 × 10 grown by clearance, and a position that shoves the rotated right edge past a 99.2 mm cell wall fails with the "extends past the compartment" text. Expected-failure asserts live in a second tiny file that the runner invokes on purpose and checks for that message and a non-zero exit.
- Solid-insert depth 29 mm on a 29.5 mm block fails with the floor message. Depth 8 mm passes. Pocket-floor depth 4 mm on a 4 mm plate fails. Depth 2 mm passes.
- `rb_cell_rect` on the screenshot tree returns the front band y = 0..24 and the back band y = 24..60 on a 160 × 60 interior, and the front band's column split at x = 99.2.
- `rb_clear_cell` on that front cell removes the x = 99.2 wall and leaves the y = 24 wall.
- Lid mirror and `rb_closed_divider_gap(0.5, 0.1) == 1.1` stay. Plain-lid mode asserts the lid tree is `[]` while the bottom tree is not.

**Python, no OpenSCAD:** `check_tool_files.py` on the fixture SVG reports 10 × 20 mm and exit 0 when the slot says 10 × 20. The same call with width 11 prints the mismatch and exits 2. A missing path prints `tool slot 1: file not found` and exits 2. The DXF fixture reports 10 × 20 mm. A copied DXF with `POLYLINE` instead of `LWPOLYLINE` exits 2. These tests run under `python -m unittest` and do not care about the host path separator because the script joins paths with `pathlib`.

**Mesh, one extra render, not the default sweep.** Bottom only, screenshot layout, master insert on, slot 1 on, SVG fixture, whole bottom, keep dividers, solid insert, x=20, y=10, rotation 0, depth 5, clearance 0. The other slots off. Expect:

- Interior floor of the shell still closed: no opening through z = 0..2.
- Pocket mouth at the insert top, mesh z = 31.5, and the pocket floor 5 mm below that (z = 26.5), covering x = 22..32 and y = 12..32 after the 2 mm wall offset (the 0.3 mm clearance is visible as a slightly larger opening; the test allows 0.5 mm).
- Divider tips still at y = 26, x = 101.2, x = 120.4, z = 31.5.
- A second render with the DXF fixture at the same numbers matches the SVG pocket within 0.5 mm.
- A lid render with plain lid has no divider tips and no pocket. A lid render with mirror dividers still has the y = 26 tip and no pocket.
- A closed render of the solid-insert bottom plus the mirrored lid still measures a 1.1 mm gap at the divider tips, and the insert top is on the bottom side of that gap (z = 31.5), not in it.
- Master off, slot 1 file set to `tools/does-not-exist.svg`, still renders and does not print `Can't open file`. Slot 1 on with that same file, preflight exits 2 before OpenSCAD. Invoking OpenSCAD directly prints `Can't open file` and exits non-zero. That direct call is its own test, not part of `render-presets.ps1`.

`check_overhangs.py` is not a gate on these STLs.

**PowerShell**, after the divider commands above. PowerShell 5.1 and 7. No `&&`.

```powershell
$env:OPENSCAD = "C:\Program Files\OpenSCAD\openscad.com"
Set-Location D:\GitHub\OpenSCAD

python -m unittest discover -s Boxes\tests -p "test_*.py"
if ($LASTEXITCODE -ne 0) { throw "python tests failed: $LASTEXITCODE" }

python Boxes\tests\check_tool_files.py --slot 1 --enabled --file tests/fixtures/tool-rect-10x20.svg --width 10 --height 20 --dpi 25.4
if ($LASTEXITCODE -ne 0) { throw "fixture preflight failed: $LASTEXITCODE" }

$tool = @(
    "-D", "toolInsertEnabled=true",
    "-D", "tool1Enabled=true",
    "-D", "tool1File=""tests/fixtures/tool-rect-10x20.svg""",
    "-D", "tool1WidthMm=10",
    "-D", "tool1HeightMm=20",
    "-D", "tool1XMm=20",
    "-D", "tool1YMm=10",
    "-D", "tool1CutDepthMm=5",
    "-D", "tool1ClearanceMm=0",
    "-D", "generateGasket=false",
    "-D", "generateFeetIfSetInSettings=false",
    "-D", "generateBoxTop=false"
)
& $env:OPENSCAD --hardwarnings -o out\bottom-tool-svg.stl @tool Boxes\RuggedBoxCustomeDividersV1.0.scad
if ($LASTEXITCODE -ne 0) { throw "tool svg render failed: $LASTEXITCODE" }

$log = & $env:OPENSCAD --hardwarnings -o out\bottom-tool-missing.stl -D "toolInsertEnabled=true" -D "tool1Enabled=true" -D "tool1File=""tools/does-not-exist.svg""" -D "generateGasket=false" -D "generateFeetIfSetInSettings=false" -D "generateBoxTop=false" Boxes\RuggedBoxCustomeDividersV1.0.scad 2>&1
if ($LASTEXITCODE -eq 0) { throw "missing outline was supposed to fail" }
if (($log | Out-String) -notmatch "Can't open file") { throw "missing outline did not name the file" }
```

Quote the file value so PowerShell 5.1 does not split it. The render script's existing argument list is the place those `-D` flags land for the checked-in run; the block above is the manual re-run. `render-presets.ps1` calls `check_tool_files.py` for any enabled slot before it calls OpenSCAD, and it does not enable the insert on the default bottom, lid, or closed STLs.
