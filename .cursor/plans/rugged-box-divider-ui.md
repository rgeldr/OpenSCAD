Status: plan only, not started

# Divider layout as Customizer controls

**Goal:** Replace the stlbuddy string `y32(x62(.,.),x74(.,.))` and the preset dropdown in `Boxes/RuggedBoxCustomeDividersV1.0.scad` with Customizer controls Jason can read without learning a grammar.

**Do not do in this plan:** change any `.scad`, test, or render script. Do not modify `Boxes/RuggedBoxV1.3.scad`. There is no overhang rule.

The product file stays free of `include` and `use`. The divider tree, lid mirror, wall fusion, and the 1.1 mm closed gap stay. Only the way a layout is entered changes.

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

Build **design B**. It is the only option that uses spinboxes, covers an even grid, covers rows with different column counts, and covers the screenshot's 62 / 74 split, and it still follows a box-size change. Design A is easier to look at and should be the fallback only if Jason decides uneven widths are unnecessary. Design C stays a documented alternative, not the implementation.

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

- One layout builds the bottom tree. `rb_lid_tree` / `rb_mirror_y` still mirrors it across the interior length measured from `boxWallWidthMm`, inside the lid's existing 180° shell frame. Do not add a second set of Customizer fields for the lid.
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

`render-presets.ps1` must exit 0, print no OpenSCAD `ERROR:` or `WARNING:`, and print `layout checks ok`. The default STL is the screenshot layout. The empty override STL has no divider tips.

A manual Customizer check, once, in the OpenSCAD GUI: open the Dividers tab, set height shares to `1,1,1,0,0,0` and the first three width rows to `1,1,1,1,0,0,0,0`, and confirm three row bands and four equal columns. Set the first height to `0` and a later one to `1` and confirm the assert names `dividerRowHeights`.
