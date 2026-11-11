// Expected-failure checks. Pass -D fail_mode=N. Not part of the success echo run.
use <../RuggedBoxCustomeDividersV1.0.scad>

fail_mode = 0;
good_rows = [
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0]
];
narrow_rows = [
    [1, 1, 1, 1, 0, 0, 0, 0],
    [0.001, 1, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0]
];
shot = rb_row_layout([2, 3, 0, 0, 0, 0], [
    [62, 38, 0, 0, 0, 0, 0, 0],
    [74, 26, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0],
    [1, 0, 0, 0, 0, 0, 0, 0]
], 160, 60, 1.2);

result =
    fail_mode == 1 ? rb_row_layout([0, 2, 0, 0, 0, 0], good_rows, 160, 60, 1.2) :
    fail_mode == 2 ? rb_row_layout([1, 1, 1, 0, 0, 0], narrow_rows, 160, 60, 1.2) :
    fail_mode == 3 ? rb_row_layout([10, 10, 0.01, 0, 0, 0], good_rows, 160, 60, 1.2) :
    fail_mode == 4 ? rb_tool_slot_fits(1, 161.7, 2, 10, 20, 90, 1, 0.3, false, 12, 8, [0, 0, 99.2, 24], [], 1.2) :
    fail_mode == 5 ? rb_tool_depth_ok(1, 29, 0, 29.5, 1.2) :
    fail_mode == 6 ? rb_tool_depth_ok(1, 4, 1, 4, 1.2) :
    fail_mode == 7 ? rb_tool_plate_ok(40, 30, 0.5) :
    fail_mode == 8 ? rb_tool_file_ok(1, "tools/_blank.svg") :
    fail_mode == 9 ? rb_cell_rect(shot, 4, 1, 160, 60) :
    fail_mode == 10 ? rb_tool_slot_fits(2, 10, 10, 20, 20, 0, 1, 0, false, 12, 8, [0, 0, 160, 60], [["y", 24, 0, 160, 0, 60]], 1.2) :
    fail_mode == 11 ? rb_tool_clearance_ok(1, -0.2) :
    fail_mode == 12 ? rb_tool_slot_fits(1, 4, 6, 10, 20, 0, 1, 0, true, 200, 8, [0, 0, 160, 60], [], 1.2) :
    fail_mode == 13 ? rb_tool_size_ok(1, 0, 20) :
    fail_mode == 14 ? rb_row_layout([1, 1, 0, 0, 0, 0], [
        [1, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0],
        [1, 0, 0, 0, 0, 0, 0, 0],
        [1, 0, 0, 0, 0, 0, 0, 0],
        [1, 0, 0, 0, 0, 0, 0, 0],
        [1, 0, 0, 0, 0, 0, 0, 0]
    ], 160, 60, 1.2) :
    fail_mode == 15 ? rb_row_layout([1, 1, 0, 0, 0, 0], [
        [1, 0, 0, 0, 0, 0, 0, 0],
        [1, -1, 0, 0, 0, 0, 0, 0],
        [1, 0, 0, 0, 0, 0, 0, 0],
        [1, 0, 0, 0, 0, 0, 0, 0],
        [1, 0, 0, 0, 0, 0, 0, 0],
        [1, 0, 0, 0, 0, 0, 0, 0]
    ], 160, 60, 1.2) :
    true;
echo(result);
