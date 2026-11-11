// Assert-only tests for divider helpers in RuggedBoxCustomeDividersV1.0.scad
use <../RuggedBoxCustomeDividersV1.0.scad>

function _near(a, b) = abs(a - b) < 0.001;
function _wall_at(walls, axis, pos, i = 0) =
    i >= len(walls) ? false :
    (walls[i][0] == axis && _near(walls[i][1], pos)) ? true :
    _wall_at(walls, axis, pos, i + 1);

function _rows() = [
    [1, 1, 1, 1, 0, 0, 0, 0],
    [1, 1, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0]
];
function _shot_rows() = [
    [62, 38, 0, 0, 0, 0, 0, 0],
    [74, 26, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0]
];
function _grid_rows() = [
    [1, 1, 1, 1, 0, 0, 0, 0],
    [1, 1, 1, 1, 0, 0, 0, 0],
    [1, 1, 1, 1, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0]
];

// Screenshot shares on 100x80 are the old y32 / x62 / x74 millimeter layout.
shot80 = rb_row_layout([2, 3, 0, 0, 0, 0], _shot_rows(), 100, 80, 1.2);
w80 = rb_walls(shot80, 0, 0, 100, 80);
assert(_wall_at(w80, "y", 32));
assert(_wall_at(w80, "x", 62));
assert(_wall_at(w80, "x", 74));
assert(len(w80) == 3);

// Same shares on the default 160x60 interior.
shot = rb_row_layout([2, 3, 0, 0, 0, 0], _shot_rows(), 160, 60, 1.2);
walls = rb_walls(shot, 0, 0, 160, 60);
assert(_wall_at(walls, "y", 24));
assert(_wall_at(walls, "x", 99.2));
assert(_wall_at(walls, "x", 118.4));

front = rb_cell_rect(shot, 1, 1, 160, 60);
assert(_near(front[0], 0) && _near(front[1], 0) && _near(front[2], 99.2) && _near(front[3], 24));
back = rb_cell_rect(shot, 2, 2, 160, 60);
assert(_near(back[0], 118.4) && _near(back[1], 24) && _near(back[2], 160) && _near(back[3], 60));

cleared = rb_clear_cell(shot, 1, 1);
cw = rb_walls(cleared, 0, 0, 160, 60);
assert(!_wall_at(cw, "x", 99.2));
assert(_wall_at(cw, "y", 24));
assert(_wall_at(cw, "x", 118.4));

// 3 rows x 4 even columns.
grid = rb_row_layout([1, 1, 1, 0, 0, 0], _grid_rows(), 160, 60, 1.2);
gw = rb_walls(grid, 0, 0, 160, 60);
assert(_wall_at(gw, "y", 20) && _wall_at(gw, "y", 40));
assert(_wall_at(gw, "x", 40) && _wall_at(gw, "x", 80) && _wall_at(gw, "x", 120));
assert(len(gw) == 2 + 3 * 3);

// Different column counts: 4, then 2, then one open cell.
mixed = rb_row_layout([1, 1, 1, 0, 0, 0], _rows(), 160, 60, 1.2);
assert(rb_col_count(_rb_band_node(mixed, 1)) == 4);
assert(rb_col_count(_rb_band_node(mixed, 2)) == 2);
assert(rb_col_count(_rb_band_node(mixed, 3)) == 1);

// A negative share on an unused row is ignored.
unused = rb_row_layout([1, 0, 0, 0, 0, 0], [
    [1, 0, 0, 0, 0, 0, 0, 0],
    [-1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0]
], 100, 80, 1.2);
assert(rb_is_leaf(unused));

// No heights means no dividers.
assert(rb_is_leaf(rb_row_layout([0, 0, 0, 0, 0, 0], _rows(), 160, 60, 1.2)));

// Mirror twice is the identity. Plain lid is an empty tree.
m1 = rb_mirror_y(shot, 0, 80);
m2 = rb_mirror_y(m1, 0, 80);
assert(m2 == shot);
assert(rb_lid_tree(shot, 0, 80) == m1);
assert(rb_is_leaf(rb_lid_mode(shot, 1, 0, 80)));
assert(rb_lid_mode(shot, 0, 0, 80) == m1);

assert(rb_divider_tip_z(0.5) == -0.5);
assert(rb_closed_divider_gap(0.5, 0.1) == 1.1);
assert(!rb_inside_corner_trimmed(2, 1));
assert(rb_inside_corner_trimmed(2, 6));
assert(rb_validate([], 100, 80, 1.2, 0.5, 30, 15, 0.2, 2));

box = rb_outline_aabb(4, 6, 10, 20, 0, 1, 0.3);
assert(_near(box[0], 3.7) && _near(box[1], 5.7) && _near(box[2], 14.3) && _near(box[3], 26.3));
box90 = rb_outline_aabb(0, 0, 10, 20, 90, 1, 0.3);
assert(_near(box90[0], -20.3) && _near(box90[1], -0.3) && _near(box90[2], 0.3) && _near(box90[3], 10.3));
assert(rb_tool_slot_fits(1, 4, 6, 10, 20, 0, 1, 0.3, false, 12, 8, [0, 0, 160, 60], [], 1.2));
assert(rb_tool_slot_fits(1, 20, 2, 10, 20, 0, 1, 0, false, 12, 8, [0, 0, 160, 60], walls, 1.2));
assert(rb_tool_depth_ok(1, 8, 0, 29.5, 1.2));
assert(rb_tool_depth_ok(1, 2, 1, 4, 1.2));
assert(rb_tool_plate_ok(4, 30, 0.5));

echo("custom-dividers-tests ok");
