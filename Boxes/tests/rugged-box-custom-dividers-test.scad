// Assert-only tests for divider helpers in RuggedBoxCustomeDividersV1.0.scad
use <../RuggedBoxCustomeDividersV1.0.scad>

iw = 100;
il = 80;

// rb_parse
assert(rb_parse("y32(x62(.,.),x74(.,.))") == ["y", 32, ["x", 62, [], []], ["x", 74, [], []]]);
assert(rb_parse("y32(x50(.,.),.)") == ["y", 32, ["x", 50, [], []], []]);
assert(rb_parse("y32(.,x40(.,x70(.,.)))") == ["y", 32, [], ["x", 40, [], ["x", 70, [], []]]]);

// rb_uniform 2x2 on 100x80
u = rb_uniform(2, 2, 100, 80);
assert(u[0] == "y" && abs(u[1] - 40) < 0.001);
assert(u[2][0] == "x" && abs(u[2][1] - 50) < 0.001);
assert(u[3][0] == "x" && abs(u[3][1] - 50) < 0.001);

// rb_walls screenshot
shot = rb_screenshot_tree(100, 80);
walls = rb_walls(shot, 0, 0, 100, 80);
assert(len(walls) == 3);

// rb_mirror_y
m1 = rb_mirror_y(shot, 0, 80);
m2 = rb_mirror_y(m1, 0, 80);
assert(m2 == shot);

// rb_lid_tree
assert(rb_lid_tree(shot, 0, 80) == m1);

// tip / gap
assert(rb_divider_tip_z(0.5) == -0.5);
assert(rb_closed_divider_gap(0.5, 0.1) == 1.1);

// trim predicate
assert(!rb_inside_corner_trimmed(2, 1));
assert(rb_inside_corner_trimmed(2, 6));

// validate smoke
assert(rb_validate([], iw, il, 1.2, 0.5, 30, 15, 0.2, 2));

echo("custom-dividers-tests ok");
