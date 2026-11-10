// Rugged box custom divider helpers (function/module block only; no includes)

rb_embed = 0.2;

function rb_divider_tip_z(clearance) = -clearance;
function rb_closed_divider_gap(clearance, opening_tol) = 2 * clearance + opening_tol;
function rb_inside_corner_trimmed(wall, chamfer) = wall <= chamfer;

// --- Layout tree (leaf = []; split = [axis, pos_mm, child_lo, child_hi]) ---

function rb_is_leaf(node) = len(node) == 0;

function _rb_uniform_x(cols, w) =
    cols <= 1 ? [] :
    ["x", w / cols, [], _rb_uniform_x(cols - 1, w - w / cols)];

function _rb_uniform_y(rows, l, w, cols) =
    rows <= 1 ? _rb_uniform_x(cols, w) :
    let(step = l / rows)
    ["y", step, _rb_uniform_x(cols, w), _rb_uniform_y(rows - 1, l - step, w, cols)];

function rb_uniform(cols, rows, w, l) = _rb_uniform_y(rows, l, w, cols);

function rb_walls(node, xmin, ymin, xmax, ymax) =
    rb_is_leaf(node) ? [] :
    let(axis = node[0], pos_rel = node[1], lo = node[2], hi = node[3])
    axis == "y" ?
        let(pos = ymin + pos_rel)
        concat(
            [["y", pos, xmin, xmax, ymin, ymax]],
            rb_walls(lo, xmin, ymin, xmax, pos),
            rb_walls(hi, xmin, pos, xmax, ymax)
        ) :
        let(pos = xmin + pos_rel)
        concat(
            [["x", pos, xmin, xmax, ymin, ymax]],
            rb_walls(lo, xmin, ymin, pos, ymax),
            rb_walls(hi, pos, ymin, xmax, ymax)
        );

function rb_mirror_y(node, ymin, ymax) =
    rb_is_leaf(node) ? [] :
    let(axis = node[0], pos_rel = node[1], lo = node[2], hi = node[3])
    let(span = ymax - ymin, pos_abs = ymin + pos_rel)
    axis == "y" ?
        ["y", span - pos_rel,
            rb_mirror_y(hi, ymin, pos_abs),
            rb_mirror_y(lo, pos_abs, ymax)
        ] :
        ["x", pos_rel,
            rb_mirror_y(lo, ymin, ymax),
            rb_mirror_y(hi, ymin, ymax)
        ];

function rb_lid_tree(bottom_tree, ymin, ymax) = rb_mirror_y(bottom_tree, ymin, ymax);

function rb_screenshot_tree(w, l) =
    ["y", 0.40 * l,
        ["x", 0.62 * w, [], []],
        ["x", 0.74 * w, [], []]
    ];

function rb_preset_tree(preset, w, l, layout_string) =
    preset == 0 ? [] :
    preset == 1 ? rb_uniform(uniformGridCols, uniformGridRows, w, l) :
    preset == 2 ? rb_screenshot_tree(w, l) :
    preset == 3 ? rb_parse(layout_string) :
    assert(false, str("rb_preset_tree: invalid preset ", preset));

// --- String parser (OpenSCAD 2021.01: search / chr, no regex) ---

function _rb_ws_chars() = " \t\n\r";
function _rb_digit_chars() = "0123456789.";

function _rb_is_ws(c) = len(search(c, _rb_ws_chars(), 1)) > 0;
function _rb_is_digit_or_dot(c) = len(search(c, _rb_digit_chars(), 1)) > 0;

function _rb_skip_ws(s, i) =
    (i >= len(s) || !_rb_is_ws(s[i])) ? i : _rb_skip_ws(s, i + 1);

function _rb_parse_number(s, i, acc) =
    _rb_skip_ws(s, i) >= len(s) ? [acc, i] :
    let(c = s[_rb_skip_ws(s, i)], j = _rb_skip_ws(s, i))
    !_rb_is_digit_or_dot(c) ? [acc, j] :
    _rb_parse_number(s, j + 1, str(acc, c));

function _rb_digit_val(c) = search(c, "0123456789", 1)[0];

function _rb_atof_int(s, i, end, acc) =
    i >= end ? acc :
    _rb_atof_int(s, i + 1, end, acc * 10 + _rb_digit_val(s[i]));

function _rb_atof_frac(s, i, acc, place) =
    i >= len(s) ? acc :
    _rb_atof_frac(s, i + 1, acc + _rb_digit_val(s[i]) * place, place / 10);

function _rb_atof(num_str) =
    let(dot = search(".", num_str))
    len(dot) > 0 ?
        _rb_atof_int(num_str, 0, dot[0], 0) + _rb_atof_frac(num_str, dot[0] + 1, 0, 0.1) :
        _rb_atof_int(num_str, 0, len(num_str), 0);

function _rb_expect_char(s, i, c, msg) =
    let(j = _rb_skip_ws(s, i))
    assert(j < len(s) && s[j] == c, str(msg, " at ", j, " in ", s))
    j + 1;

function _rb_parse_node(s, i) =
    let(j0 = _rb_skip_ws(s, i))
    assert(j0 < len(s), str("rb_parse: unexpected end in ", s))
    let(c0 = s[j0])
    c0 == "." ? [[], j0 + 1] :
    c0 == "x" || c0 == "y" ?
        let(axis = c0)
        let(np = _rb_parse_number(s, j0 + 1, ""))
        let(num_str = np[0], j1 = np[1])
        assert(len(num_str) > 0, str("rb_parse: missing number after ", axis, " in ", s))
        let(pos = _rb_atof(num_str))
        let(j2 = _rb_expect_char(s, j1, "(", "rb_parse: expected '('"))
        let(lo_p = _rb_parse_node(s, j2))
        let(j3 = _rb_expect_char(s, lo_p[1], ",", "rb_parse: expected ','"))
        let(hi_p = _rb_parse_node(s, j3))
        let(j4 = _rb_expect_char(s, hi_p[1], ")", "rb_parse: expected ')'"))
        [[axis, pos, lo_p[0], hi_p[0]], j4] :
    assert(false, str("rb_parse: bad input '", c0, "' in ", s));

function rb_parse(s) =
    let(p = _rb_parse_node(s, 0))
    let(j = _rb_skip_ws(s, p[1]))
    assert(j == len(s), str("rb_parse: trailing input at ", j, " in ", s))
    p[0];

// --- Validation ---

function _rb_count_walls(node) =
    rb_is_leaf(node) ? 0 : 1 + _rb_count_walls(node[2]) + _rb_count_walls(node[3]);

function _rb_validate_node(node, xmin, ymin, xmax, ymax, wall_thick, n_walls) =
    rb_is_leaf(node) ? n_walls :
    let(axis = node[0], pos_rel = node[1], lo = node[2], hi = node[3])
  axis == "y" ?
    let(span = ymax - ymin)
    let(pos_lo = pos_rel)
    let(pos_hi = span - pos_rel)
    assert(pos_lo >= wall_thick, "rb_validate: Y split too close to ymin")
    assert(pos_hi >= wall_thick, "rb_validate: Y split too close to ymax")
    let(pos = ymin + pos_rel)
    _rb_validate_node(hi, xmin, pos, xmax, ymax, wall_thick,
        _rb_validate_node(lo, xmin, ymin, xmax, pos, wall_thick, n_walls + 1)) :
    let(span = xmax - xmin)
    let(pos_lo = pos_rel)
    let(pos_hi = span - pos_rel)
    assert(pos_lo >= wall_thick, "rb_validate: X split too close to xmin")
    assert(pos_hi >= wall_thick, "rb_validate: X split too close to xmax")
    let(pos = xmin + pos_rel)
    _rb_validate_node(hi, pos, ymin, xmax, ymax, wall_thick,
        _rb_validate_node(lo, xmin, ymin, pos, ymax, wall_thick, n_walls + 1));

function rb_validate(node, w, l, wall_thick, clearance, clearance_bottom, clearance_top, embed, wall_width) =
    assert(wall_thick >= 1.0, "rb_validate: dividerWallThickness must be >= 1.0")
    assert(clearance > 0, "rb_validate: dividerTopClearance must be > 0")
    assert(embed < wall_width, "rb_validate: rb_embed must be < boxWallWidthMm")
    assert(clearance + embed < clearance_bottom, "rb_validate: clearance + embed vs bottom height")
    assert(clearance + embed < clearance_top, "rb_validate: clearance + embed vs lid height")
    let(n = _rb_validate_node(node, 0, 0, w, l, wall_thick, 0))
    assert(n <= 32, str("rb_validate: too many walls (", n, ", max 32)"))
    true;

// --- Printable teardrop / tongue profiles (60° from horizontal on critical faces) ---

// Junction of upper semicircle with 60° lower flats: (±r*sqrt(3)/2, r/2), tip at (0, -r)
function _rb_teardrop_down_points(r, n_arc) =
    let(jx = r * sqrt(3) / 2)
    let(jy = r / 2)
    let(angles = [for (a = [n_arc : n_arc : 180 - n_arc]) a])
    concat(
        [[0, -r]],
        [[jx, jy]],
        [for (a = angles) [r * cos(a), r * sin(a)]],
        [[-jx, jy]]
    );

module rb_printable_teardrop_2d(r) {
    polygon(_rb_teardrop_down_points(r, 6));
}

module rb_printable_teardrop_hole_2d(r) {
    mirror([0, 1, 0])
        polygon(_rb_teardrop_down_points(r, 6));
}

module rb_teardrop_cylinder_x(length, r) {
  rotate([0, 90, 0])
    linear_extrude(height = length, center = true)
      rb_printable_teardrop_2d(r);
}

// 60° tongue/groove cross-section (polygon approximation of circle with printable slopes)
function _rb_tongue_groove_points(r, fn) =
    let(steps = max(12, fn))
    let(jx = r * cos(30))
    let(jy = r * sin(30))
    let(arc = [for (i = [0 : steps - 1]) let(a = 30 + (120 / steps) * i) [r * cos(a), r * sin(a)]])
    concat([[0, -r]], [[jx, jy]], arc, [[-jx, jy]]);

module rb_tongue_groove_circle(r, $fn = 24) {
    polygon(_rb_tongue_groove_points(r, $fn));
}
