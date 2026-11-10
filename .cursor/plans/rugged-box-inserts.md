Status: plan only, not started

# Rugged Box — Recursive Divider Inserts (STLBuddy-style)

**Goal:** Add a new OpenSCAD entry point that keeps `Boxes/RuggedBoxV1.3.scad` unchanged while supporting nested compartment layouts (recursive split tree), clipped to the rounded interior cavity, with STLBuddy-like presets and headless CLI verification.

**Reference UI:** [STLBuddy Hinged Box Maker](https://stlbuddy.com/hinged-box-maker) — Dividers panel: select a compartment, add Column (split along X) or Cross-divider (split along Y), drag position in mm, remove/restore sections independently, layout clipped to rounded outline. Nested example: one full-width cross-divider, then columns only in one child region (not a uniform grid).

**Screenshot (Jason):** `uploads/stlbuddy-dividers.png` — nested layout on ~100×80 mm interior.

---

## 1. RuggedBoxV1.3 — structure, cavity, dividers, reuse strategy

### 1.1 Repo context (`Boxes/`)

| File | Role |
|------|------|
| `RuggedBoxV1.3.scad` | Current rugged hinged box (Jason’s target). |
| `RuggedBoxV1.3.json` | OpenSCAD Customizer preset sets. |
| `RuggedBoxV1.2.scad` | Older revision (row/column dividers; fewer features). |
| `RuggedGridfinityBoxV1.0.scad` | Gridfinity variant; same divider pattern as V1.3. |
| Others | Unrelated box generators (`junction-box`, `skadisboxv2`, etc.). |

The repo does **not** today use `use`/`include` for rugged boxes (only BOSL2 in unrelated projects). Each box file is a self-contained monolith.

### 1.2 `RuggedBoxV1.3.scad` architecture (read-only baseline)

**Top (lines ~1–374):** Customizer parameter groups and **immediate-mode assembly** (`if` / `translate` / `union`) — not guarded by `module main()`. Any `include` of this file would execute the full box render.

**Customizer groups (summary):**

- **View / generate flags:** `viewBoxClosed`, `generateBoxBottom`, `generateBoxTop`, latches, gasket test pieces, feet, empty TPU inserts.
- **Poly:** `BoxPolygonStyle` → `polyLvl` ($fn for chamfers).
- **Main box:** Internal size `internalBoxWidthXMm`, `internalboxLengthYMm`, `internalBoxTopHeightZMm`, `internalboxBottomHeightZMm`; `boxWallWidthMm`, `boxChamferRadiusMm`; seal, rim, ribs, `openingTolerance`.
- **Dividers (legacy grid):** `gridMode` uniform vs `customColumnsPerRow`; `numberOfRows` / `columnsInEveryRow`; `numBoxLengthYSectionsToSkip`; `boxSectionSeparatorWidth`.
- **Hinge / latch / handle / feet / TPU insert:** Large secondary surface; inserts use `insertTolerance`.

**Derived exterior / section heights (representative):**

```openscad
boxWidthXMm  = internalBoxWidthXMm  + (2*boxWallWidthMm);
boxLengthYMm = internalboxLengthYMm + (2*boxWallWidthMm);
boxBottomHeightZMm = internalboxBottomHeightZMm + boxWallWidthMm;
boxTopHeightZMm    = internalBoxTopHeightZMm    + boxWallWidthMm;
```

**Interior usable cavity (for dividers):**

- **Plan area (XY):** Rectangle from `(boxWallWidthMm, boxWallWidthMm)` to `(boxWidthXMm - boxWallWidthMm, boxLengthYMm - boxWallWidthMm)`, with **rounded inner corners** at radius `boxChamferRadiusMm` (straight segments shrink accordingly — same model as `BoxShellBase` floor plate).
- **Bottom Z:** Divider walls run from floor up to ~`height - boxWallWidthMm` (see `BoxInsert` / `BoxLengthXSeparators`).
- **Top:** Lid mirrors base row order via `isReversed` on `BoxLengthXSeparators`.

**Legacy divider model (not recursive):**

- **Y (length) splits:** `BoxWidthYSeparators` — full-width walls spanning internal X, using `BoxInsert` with chamfer end cutouts.
- **X splits per row:** `BoxLengthXSeparators` — each row has `columnsPerRow[row]` columns; vertical walls only span that row’s Y band (supports ragged grids like `[1,2,4]`, not arbitrary nesting).

**Cavity / shell primitives to reuse conceptually:**

- `BoxShellBase(height, additionalShellThickness)` — chamfered shell + ribs.
- `BoxInsert(width, height, separatorWidth)` — single divider slab with corner chamfer booleans.
- `Wall2D(...)` — chamfer profile for clipping.
- `CreateBoxInserts(...)` — **drop-in TPU blank**: inner volume via `difference(cube, BoxShellBase)` + `resize(..., insertTolerance)`.

### 1.3 Constraint: V1.3 must stay unchanged

We cannot add `include` guards or extract modules inside `RuggedBoxV1.3.scad` in this effort.

### 1.4 Recommended reuse approach (and why)

| Approach | Verdict |
|----------|---------|
| `include <RuggedBoxV1.3.scad>` | **Reject** — runs all top-level geometry; duplicates box when combined with inserts. |
| `use <RuggedBoxV1.3.scad>` | **Reject for parametric workflow** — imports modules only; modules close over **V1.3’s** global defaults, not Customizer values from a new file; divider modules are hard-wired to `columnsPerRow` grid, not a tree. |
| Copy entire V1.3 into V1.4 | **Reject** — unmaintainable fork. |
| **New parameterized library `.scad` + thin entry file** | **Recommend** — copy *patterns* (chamfer clip, inner rounded rect) into `Boxes/lib/rugged-box-divider-lib.scad` as functions/modules with explicit arguments; **no edit to V1.3**; V1.4 entry file holds Customizer + `ECHO`/`assert` tests. Optional later PR: refactor V1.3 to call same lib (Jason-approved). |

**Smallest path:** One library file (layout + 2D rects + wall mesh + clip), one entry SCAD, one test SCAD, optional shell script. Do **not** duplicate hinge/latch/box assembly in phase 1.

---

## 2. Proposed new files

| File | Purpose |
|------|---------|
| **`Boxes/RuggedBoxV1.4-Inserts.scad`** | **Primary entry** — Customizer, presets, output mode, calls lib. |
| **`Boxes/lib/rugged-box-divider-lib.scad`** | Tree layout, wall segment generation, cavity clip, height math (parameterized). |
| **`Boxes/tests/rugged-box-divider-lib-test.scad`** | `assert()` unit tests (no mesh export). |
| **`Boxes/tests/render-presets.ps1`** | Windows PowerShell CI-style render script. |
| **`Boxes/tests/render-presets.sh`** | Linux/macOS equivalent. |
| **`Boxes/RuggedBoxV1.4-Inserts.json`** | Optional Customizer presets mirroring test cases. |

**Name note:** `V1.4-Inserts` signals “insert/divider extension” without replacing V1.3. A future `RuggedBoxV1.4.scad` full box could compose V1.3 assembly + lib once shared extraction is allowed.

---

## 3. Layout data model (recursive split tree)

### 3.1 Semantic mapping (match STLBuddy / screenshot)

- **Cross-divider:** split along **Y** (wall is a plane of constant Y, runs full width of the *current* region’s X extent).
- **Column:** split along **X** (wall at constant X, runs full depth of current region’s Y extent).
- **Position:** distance from the **minimum** edge along that axis (`ymin` for Y-split, `xmin` for X-split).
- **Children:** `[before, after]` relative to split plane (lower coordinate = “before”).
- **Leaves:** empty list `[]` = undivided compartment (no further splits).

This is a **binary tree**; depth is unbounded in code, practically limited by printability and Customizer editability.

### 3.2 In-memory representation (OpenSCAD lists)

```openscad
// Leaf
RB_LEAF = [];

// Split node: [AXIS, POS, CHILD_NEG, CHILD_POS]
// AXIS: "x" | "y"
// POS:  number (mm or fraction — see positionMode)
RB_SPLIT_Y(pos, a, b) = ["y", pos, a, b];
RB_SPLIT_X(pos, a, b) = ["x", pos, a, b];
```

**Example (screenshot-style, fractions):**

```openscad
layout_tree = RB_SPLIT_Y(0.40,
  RB_SPLIT_X(0.50, RB_LEAF, RB_LEAF),  // front half: 2 cells
  RB_SPLIT_X(0.33,
    RB_LEAF,
    RB_SPLIT_X(0.50, RB_LEAF, RB_LEAF)  // back half: 3 cells
  )
);
```

### 3.3 Position modes

| `dividerPositionMode` | Meaning |
|-----------------------|---------|
| `0` — **Fraction** (default) | `pos` ∈ (0,1) of parent span; stable when resizing box in Customizer. |
| `1` — **Millimeters** | Absolute mm from parent min edge; matches STLBuddy slider. |

Lib function: `rb_resolve_position(parent_min, parent_max, pos, mode)`.

### 3.4 Customizer limits and editing UX

OpenSCAD Customizer **cannot** edit nested lists interactively.

**Expose:**

```openscad
/*[Divider layout]*/
dividerLayoutPreset = 2; // [0:None, 1:UniformGrid_NxM, 2:NestedDemo, 3:CustomString, 4:CustomTreeInFile]
uniformGridCols = 2;
uniformGridRows = 2;
dividerLayoutString = "y@0.4|x@0.5;x@0.33|x@0.5"; // used when preset=3
```

**Editing workflows:**

1. **Preset dropdown** — covers none, uniform grid (compat with V1.3 grid), nested demo, tests.
2. **Custom string** — compact DSL, parsed to tree (depth-first with `|` = sibling at same level only via explicit parentheses later; phase 1 use **preset 4**: edit `layout_tree` constant in file for complex nests — document in header comment).
3. **String DSL (phase 2 parser):** tokens `x@0.5` / `y@40mm`; nested via `(...)` e.g. `y@0.4(x@0.5, x@0.33(x@0.5,leaf))` — keep parser & tests small.

**Uniform grid preset:** Expand to equivalent tree (repeat Y-splits then X per band) so one code path renders all layouts.

### 3.5 Layout validation (`assert`)

- Split position strictly inside parent (min gap ≥ half wall thickness).
- Max depth / max wall count sanity cap (e.g. ≤ 32 segments).
- Unknown node shapes fail fast.

---

## 4. Output modes and parameters

### 4.1 Recommended default: **drop-in insert tray**

Matches existing `CreateBoxInserts` intent (`insertTolerance`), lets Jason tune V1.3 and inserts independently, avoids duplicating the full box assembly while V1.3 is frozen.

```openscad
dividerOutputMode = 1; // [1:DropInTray, 2:WallsOnly, 3:IntegratedBottom, 4:IntegratedTop, 5:BothIntegrated]
generateDropInTrayFloor = true;
```

| Mode | Output |
|------|--------|
| **DropInTray (default)** | Floor + dividers, outer silhouette = inner cavity minus `insertTrayTolerance`, height ≤ bottom internal height − clearance. |
| **WallsOnly** | Divider walls without floor (glue into blank TPU insert or custom pocket). |
| **IntegratedBottom / Top** | **Phase 3** — divider union intended to merge with box print; without V1.3 edits, ship as **separate STL** aligned to origin + README alignment notes, or optional localized `BoxBottom_with_dividers()` copy inside V1.4 only (not maintaining full hinge/latch). |
| **BothIntegrated** | Bottom + lid divider sets (lid mirrored Y-order like V1.3 `isReversed`). |

### 4.2 Key parameters (Customizer)

| Parameter | Default | Notes |
|-----------|---------|-------|
| `insertTrayTolerance` | `0.1` | Match `insertTolerance` in V1.3. |
| `dividerWallThickness` | `1.2` | Match `boxSectionSeparatorWidth`. |
| `dividerFloorThickness` | `1.2` | Tray floor; 0 in WallsOnly. |
| `dividerBottomClearance` | `0.5` | Gap below tray bottom to box floor (finger pick / print variance). |
| `dividerTopClearance` | `1.0` | Below lid close plane / content gap. |
| `dividerHeightMode` | `0` | `[0:AutoFromBoxHeight, 1:ManualMm]` |
| `dividerHeightManualMm` | `25` | When manual. |
| `clipToCavityOutline` | `true` | Intersect walls with inner rounded-rect prism. |
| `fingerScoopEnable` | `false` | Optional spherical/cylindrical scoop on selected walls (phase 4). |
| `mirrorLidLayout` | `true` | For top tray / integrated top. |
| `polyLvl` / chamfer | Import from same `BoxPolygonStyle` pattern as V1.3 for clip fidelity. |

**Dimension source:** Duplicate **only** the Main Box Settings block needed for cavity math in V1.4 (internal W/L/Z, wall, chamfer, opening tolerance) — same names as V1.3 so Jason can copy values from one Customizer to the other.

**Disable legacy grid in V1.4 entry:** Document that divider inserts supersede V1.3 `gridMode` when printing trays; do not enable both for the same physical box.

---

## 5. Clipping, height, lid respect

### 5.1 Cavity outline (2D clip)

1. Build `rb_inner_rounded_rect(w, l, chamfer)` matching V1.3 straight segment + quarter-circle corners (same insets as `BoxShellBase` floor).
2. Each wall segment → extrude as axis-aligned slab in its compartment bounds.
3. `intersection()` with `linear_extrude(h) rb_inner_rounded_rect(...)` when `clipToCavityOutline`.

**End caps:** Reuse `BoxInsert`-style chamfer cuts on walls that touch the outer cavity boundary (detect when wall span equals parent region touch at global min/max X or Y).

### 5.2 Height

```text
auto_bottom_divider_z =
  internalboxBottomHeightZMm - dividerBottomClearance - dividerTopClearance;

auto_lid_divider_z =
  internalBoxTopHeightZMm - dividerTopClearance - openingTolerance;  // lid internal
```

Tray total height = `dividerFloorThickness + auto_bottom_divider_z` (clamped ≥ dividerWallThickness).

Walls sit on tray floor (or box floor in integrated mode).

### 5.3 Lid mirroring

When generating top dividers, traverse tree with **Y splits reversed** (swap before/after child assignment or mirror positions `pos → 1-pos` on Y only) — mirror V1.3 `BoxLengthXSeparators(..., isReversed=true)` behavior.

---

## 6. Printability

| Rule | Implementation |
|------|----------------|
| No unsupported overhangs | Vertical walls; chamfer only on **outer** cavity-facing ends (existing 45° floor join in `Wall2D` logic). |
| Min wall thickness | Default 1.2 mm; `assert(dividerWallThickness >= 1.0)`. |
| Min feature | Gap between parallel walls ≥ `dividerWallThickness + 0.4` mm default tolerance lane. |
| Bridging | Tray floor optional lightened pattern — **off** by default (YAGNI). |
| Tolerances | `insertTrayTolerance` 0.1; document ±0.2 mm for FDM fit tuning. |

---

## 7. Verification (CLI + asserts)

Treat **`assert()` in test SCAD** as unit tests; **STL/PNG exports** as integration tests.

### 7.1 Prerequisites

- OpenSCAD ≥ 2021.01 (`openscad` on PATH).
- Repo paths: Windows `D:\GitHub\OpenSCAD`, Linux `/workspace` (adjust scripts via `$RepoRoot`).

### 7.2 Unit tests — `Boxes/tests/rugged-box-divider-lib-test.scad`

```openscad
include <../lib/rugged-box-divider-lib.scad>
// assert bbox of leaves, split counts, position resolution, grid→tree expansion
```

Run (no output file — fails on assert):

```bash
openscad -q Boxes/tests/rugged-box-divider-lib-test.scad -o /dev/null
```

PowerShell:

```powershell
openscad -q Boxes/tests/rugged-box-divider-lib-test.scad -o NUL
```

### 7.3 Integration renders — presets

From repo root, for each preset `P` in `{none, grid_2x2, nested_demo, tray_default}`:

```bash
openscad -q Boxes/RuggedBoxV1.4-Inserts.scad \
  -D 'dividerLayoutPreset=…' -D 'generateGasketTestObjects=false' \
  -o "out/rugged-inserts-${P}.stl" 2> "out/${P}.log"
grep -iE 'ERROR|CGAL error|Top level object is empty' "out/${P}.log" && exit 1
```

PNG preview (PR artifact):

```bash
openscad -q --preview -D 'dividerLayoutPreset=2' \
  --imgsize=800,600 --camera=0,0,0,55,0,25,500 \
  -o out/nested_demo.png Boxes/RuggedBoxV1.4-Inserts.scad
```

**PowerShell** (`Boxes/tests/render-presets.ps1`):

```powershell
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path "$RepoRoot/out" | Out-Null
$presets = @(0, 1, 2)
foreach ($p in $presets) {
  $log = "$RepoRoot/out/preset-$p.log"
  & openscad -q "$RepoRoot/Boxes/RuggedBoxV1.4-Inserts.scad" `
    -D "dividerLayoutPreset=$p" -o "$RepoRoot/out/preset-$p.stl" 2> $log
  if (Select-String -Path $log -Pattern 'ERROR|CGAL error' -Quiet) { throw "OpenSCAD failed preset $p" }
}
```

**Policy:** Every new helper in `rugged-box-divider-lib.scad` gets at least one `assert()` in the test file before merge.

### 7.4 CI (optional follow-up)

GitHub Action `ubuntu-latest`, `apt install openscad`, run `render-presets.sh` + test scad on PRs touching `Boxes/`.

---

## 8. Implementation phases (small PRs)

### Phase 0 — Plan (this PR)

- [x] Document architecture and decisions.
- **Success:** Jason approves plan; no `.scad` implementation.

### Phase 1 — Layout library + tests (no STL UX)

- [ ] Add `rugged-box-divider-lib.scad`: tree types, bbox propagation, wall segment list, grid→tree.
- [ ] Add `rugged-box-divider-lib-test.scad`; all asserts green via CLI.
- **Success:** `openscad …-test.scad -o /dev/null` exit 0 on Win + Linux.

### Phase 2 — Drop-in tray MVP

- [ ] Add `RuggedBoxV1.4-Inserts.scad` with duplicated cavity params + preset dropdown.
- [ ] Render `DropInTray` STL for presets 0, 1, 2; PNG for nested demo.
- **Success:** STLs non-empty; no CGAL errors; tray fits logical dimensions (assert bbox).

### Phase 3 — Walls-only + clip + chamfer caps

- [ ] `clipToCavityOutline`, `BoxInsert`-style end chamfers on outer-span walls.
- [ ] `WallsOnly` output mode.
- **Success:** Visual PNG matches screenshot topology (1 Y + partial X splits).

### Phase 4 — Lid tray + optional integrated exports

- [ ] `mirrorLidLayout`, top height math, `IntegratedBottom/Top` as **separate aligned STLs** + doc.
- [ ] Optional `dividerLayoutString` parser with tests.
- **Success:** Top+bottom trays render; README snippet for aligning with V1.3 parts.

### Phase 5 — Optional V1.3 convergence (Jason opt-in)

- [ ] Refactor V1.3 to call shared lib OR replace legacy grid with tree preset — **only if Jason wants single file**.

---

## Open questions (recommended defaults)

| Question | Recommendation |
|----------|----------------|
| Single file vs lib split? | **Lib + V1.4-Inserts entry** (V1.3 untouched). |
| Default output mode? | **DropInTray** with floor. |
| Position mode default? | **Fraction** in Customizer; mm in string DSL for STLBuddy parity. |
| Replace V1.3 grid dividers? | **No** — inserts are separate; note in README. |
| Integrated dividers without editing V1.3? | Phase 4: **separate STL** + origin alignment; full one-piece bottom deferred to Phase 5. |
| String DSL complexity? | Phase 1: edit `layout_tree` in file; Phase 4: optional parser. |
| Finger scoops? | Default **off**; one wall index param if enabled later. |
| BOSL2 dependency? | **No** — keep deps zero, match existing Boxes style. |
| Customizer JSON? | Ship **optional** `RuggedBoxV1.4-Inserts.json` with 3 regression presets. |

---

## Global constraints (implementation)

- **Do not modify** `Boxes/RuggedBoxV1.3.scad`.
- Smallest reasonable design; prefer parameterized lib over copying hinge/latch assembly.
- Karpathy/repo rules: minimal scope, no speculative features, match V1.3 naming and comment style in new files.
- Implementation starts only when Jason says run/build.

---

## Appendix — Legacy grid vs tree (behavioral)

| Capability | V1.3 `columnsPerRow` | New tree |
|------------|----------------------|----------|
| Nested split in one sub-region | No | Yes |
| Partial-height X walls | Per-row only | Per-region |
| Full-width Y wall | Yes | Yes, scoped to parent X span |
| Lid mirror | Row reverse | Y-mirror on tree |

Uniform `NxM` preset should approximate V1.3 uniform mode for regression comparison.
