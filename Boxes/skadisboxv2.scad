// --------------------------------------------------------------------------------
// Title:        SKÅDIS Box
// Version:      2.0
// Release Date: 2026-04-02
// Author:       Marco Henkes
// --------------------------------------------------------------------------------


 /*** User defined settings ***/
 
 $fn= $preview ? 32 : 128;

/*[Box dimensions]*/
// Width of the box. Will be overridden when calculate_size is defined.
width = 120;

// Depth of the box, excluding the hooks. Will be overridden when calculate_size is defined.
depth = 60;

// Height of the box, this includes the height of its bottom.
height = 80;

// Height of the front wall to create an angled front that slopes up to the full
// height at the back. Makes contents easier to see and grab.
// Set equal to height for no angle.
front_height = height;

// Thickness of the outer walls (minimum = 1).
outer_wall_thickness = 3;

// Thickness of the inner wall(s) (minimum = 1) when using compartments.
inner_wall_thickness = 1;

// Thickness of the bottom of the box (minimum = 1), will not affect the box height.
bottom_thickness = 2;

// Outer radius of the corners of the box (minimum = 1).
corner_outer_radius = 4;

// Chamfers the sharp top outer edge (clamped to outer_wall_thickness / 2), use 0 for a sharp edge.
shave_edge = 1.5;

// Inner radius of the inner corners of the box, will be determined automatically if the value < 0.
corner_inner_radius = -1;


/*[Box compartments]*/
// Define the inner compartments using helpers or the matrix format.
//
// Helpers:
//   single()         - one compartment (no dividers)
//   columns([2, 1])  - 2 vertical compartments, left is 2x wider than right
//   rows([2, 1])     - 2 horizontal compartments, front is 2x deeper than back
//   grid(3, 2)       - equal grid of 3 columns x 2 rows
//
// Matrix format: each row is a list of column width ratios.
// Use row_ratios to set relative depth per row (default = equal).
//   compartments = [[2, 1],       - 2 rows: front has 2 columns (2:1 ratio),
//                   [1, 1, 1]];     back has 3 equal columns
//   row_ratios = [2, 1];          - front row is 2x deeper than back
compartments = single();

// Relative depth of each row. Must match the number of rows in compartments.
// Leave empty for equal row depths.
row_ratios = [0];

// Radius of the corners of the box inner compartments.
compartment_corner_radius = 2;

// Radius of the bottom fillet (rounded transition from floor to walls).
// Clamped to compartment_corner_radius. Use 0 for sharp corners.
bottom_fillet_radius = 0;

// How high the compartment divider walls reach, measured from the bottom of the
// box. When equal to the box height, dividers extend to the top. When lower,
// a shared open space is created above the compartments.
// The actual inner depth of each compartment is compartment_wall_height - bottom_thickness.
compartment_wall_height = height;

// Override the inner height of individual compartments, specified as
// [row, column, height]. Omitted compartments use the full available height.
// Clamped to the maximum inner height (compartment_wall_height - bottom_thickness).
// Useful for mixed-height items: shorter compartments raise the bottom,
// making smaller items easier to grab from a tall box.
compartment_heights = [];
// Example: row 0 col 1 is 30mm tall, row 1 col 0 is 20mm tall:
//compartment_heights = [[0, 1, 30], [1, 0, 20]];

// Diameter of drain holes in the compartment floor. Use 0 for no holes.
drain_hole_diameter = 0;

// Center-to-center spacing between drain holes.
// Clamped to drain_hole_diameter + 1 to keep at least 1 mm between edges.
drain_hole_spacing = 10;

// Exclude specific compartments from drain holes, as [row, column] pairs.
no_drain_hole_compartments = [];

// Diameter of the finger scoop cutout at the front of each compartment.
// Clamped to fit the compartment width and wall height. Use 0 for no scoop.
finger_scoop_diameter = 0;

// Exclude specific compartments from the finger scoop, as [row, column] pairs.
no_finger_scoop_compartments = [];
// Example: exclude row 0 column 1 and row 1 column 0:
// no_finger_scoop_compartments = [[0, 1], [1, 0]];

// Auto-calculate box width and depth from the compartments grid and the desired
// size of the first (front-left) compartment. The other compartments scale
// according to their ratios. Not applicable to single(). Leave empty [] to use
// width and depth directly.
calculate_size = [];
// Example: first compartment is 15 x 20, box size is derived from the grid:
// calculate_size = [compartments, [15, 20]];


/*[Hooks]*/
// Auto-generate hooks based on box dimensions:
//   0 = use manual hooks and hook_margin below
//   1 = 2-row layout (top + bottom)
//   2 = 3-row layout (top + middle + bottom, if room)
//   3 = all even rows (0, 2, 4, ...)
//   4 = all odd rows (1, 3, 5, ...)
//   5 = all rows (even + odd)
auto_hooks = 1;

// Use alternate hook placement so adjacent boxes use different pegboard holes
// (auto_hooks only).
alternate_hooks = false;

// Manual hook definition, used when auto_hooks = 0.
// Array of [row, number_of_hooks]. Even rows (0, 2, 4, ...) are aligned,
// odd rows (1, 3, 5, ...) are offset by half a hole spacing (20mm).
hooks = [[0, 3], [2, 3]];
// Example: 3 rows with 3, 2, and 3 hooks:
// hooks = [[0, 3], [1, 2], [2, 3]];

// Manual hook margin, used when auto_hooks = 0.
// Horizontal and vertical margin for positioning the first hook on the back wall.
// The hooks are automatically placed at the back (depth) of the box.
hook_margin = [18, 18];

// Limit hooks to the edges of the box (per side). A value of 2 places 2 hooks
// on each side per row, leaving the center empty. Use 0 for no limit.
only_outer_hooks = 0;
 
/*** Render ***/
// Uncomment one example to render it, or call skadis_box() with the user defined settings above.
skadis_box();

//example_mixed_compartments();
//example_simple_tray();
//example_two_column_organizer();
//example_stacked_rows();
//example_grid_box();
//example_sized_compartments();
//example_wide_shelf();
//example_hardware_bin();
//example_angled_scoop_box();
//example_complex_layout();
//example_open_top_dividers();

// Mixed compartments with varying row depths and a raised floor.
// Creates a 120mm x 60mm x 80mm box with 5 compartments.
// The front row has 2 compartments, the left is twice as wide as the right.
// The left compartment has a depth of 20mm.
// The back row has 3 equal sized compartments.
// The front row is twice as deep as the back row.
// Two of these boxes will fit next to each other on a SKÅDIS pegboard
// without having a space between them. To have a 20mm space between them
// use alternate_hooks = true for the second box. Set auto_hooks = 2 if
// you need an additional row of hooks in the center.
module example_mixed_compartments() {
    skadis_box(compartments = [[2, 1],
                               [1, 1, 1]],
               row_ratios = [2, 1],
               compartment_heights = [[0, 0, 20]]);
}

// A simple open tray with no dividers, thick rounded walls and a bottom fillet.
// Good for collecting small items like paperclips or coins.
module example_simple_tray() {
    skadis_box(width = 80,
               depth = 50,
               height = 30,
               outer_wall_thickness = 4,
               corner_outer_radius = 8,
               bottom_fillet_radius = 2);
}

// Two vertical compartments with finger scoops and drain holes.
// The left compartment is wider than the right, useful for sorting
// markers and pens by size.
module example_two_column_organizer() {
    skadis_box(width = 80,
               depth = 40,
               height = 60,
               compartments = columns([2, 1]),
               finger_scoop_diameter = 20,
               drain_hole_diameter = 4,
               drain_hole_spacing = 8);
}

// Three horizontal rows of equal depth.
// Useful for separating items front-to-back, like different grades
// of sandpaper or labels.
module example_stacked_rows() {
    skadis_box(width = 80,
               depth = 80,
               height = 50,
               compartments = rows([1, 1, 1]),
               bottom_fillet_radius = 2);
}

// A 3x2 grid with an angled front for easy access.
// Good for small hardware like screws, nuts and washers.
module example_grid_box() {
    skadis_box(width = 120,
               depth = 80,
               height = 60,
               front_height = 30,
               compartments = grid(3, 2),
               finger_scoop_diameter = 15,
               bottom_fillet_radius = 1);
}

// Uses calculate_size to derive the box dimensions from the desired
// compartment size. The first (front-left) compartment will be exactly
// 25mm x 30mm. The other compartments scale according to their ratios.
module example_sized_compartments() {
    skadis_box(compartments = columns([1, 2]),
               calculate_size = [columns([1, 2]), [25, 30]],
               finger_scoop_diameter = 15,
               bottom_fillet_radius = 1);
}

// A wide, shallow shelf using a single compartment.
// Uses thick walls, a low profile and hooks on all rows for stability.
module example_wide_shelf() {
    skadis_box(width = 200,
               depth = 60,
               height = 30,
               outer_wall_thickness = 4,
               corner_outer_radius = 6,
               auto_hooks = 5);
}

// A tall hardware bin with drain holes and manual hook configuration.
// Uses only_outer_hooks to leave the center of the back wall clear,
// providing more hooks at the edges for a sturdy hold.
module example_hardware_bin() {
    skadis_box(width = 120,
               depth = 60,
               height = 100,
               front_height = 100,
               compartments = grid(2, 2),
               compartment_wall_height = 100,
               drain_hole_diameter = 3,
               drain_hole_spacing = 8,
               auto_hooks = 5,
               only_outer_hooks = 1);
}

// A box with an angled front, finger scoops, bottom fillet and
// drain holes. All three new features combined in a single box.
module example_angled_scoop_box() {
    skadis_box(width = 120,
               depth = 60,
               height = 80,
               front_height = 40,
               compartments = columns([1, 1, 1]),
               finger_scoop_diameter = 25,
               drain_hole_diameter = 4,
               drain_hole_spacing = 10,
               bottom_fillet_radius = 2,
               auto_hooks = 2);
}

// A complex layout with different column counts per row.
// 3 rows: front has 1 wide compartment, middle has 3 equal columns,
// back has 2 columns (left twice as wide as right).
// Each row has a different depth (3:1:2 ratio).
// Several compartments have raised floors, the large front compartment
// has no drain holes, and the back-right compartment has no finger scoop.
// Uses manual hooks with 3 rows of 4, 3 and 4 hooks and an margin of 18 from the side and 9 mm from the bottom.
module example_complex_layout() {
    skadis_box(width = 160,
               depth = 100,
               height = 70,
               compartments = [[1],
                               [1, 1, 1],
                               [2, 1]],
               row_ratios = [3, 1, 2],
               compartment_heights = [[0, 0, 40],
                                      [1, 0, 25],
                                      [1, 2, 25]],
               finger_scoop_diameter = 20,
               no_finger_scoop_compartments = [[2, 1]],
               drain_hole_diameter = 3,
               drain_hole_spacing = 8,
               no_drain_hole_compartments = [[0, 0]],
               bottom_fillet_radius = 2,
               auto_hooks = 0,
               hooks = [[0, 4], [1, 3], [2, 4]],
               hook_margin = [18, 9]);
}

// A tall box where the divider walls stop at 40mm, leaving shared
// open space above the compartments. Useful when items need to be
// sorted at the bottom but can overlap above, like cables or fabric.
module example_open_top_dividers() {
    skadis_box(width = 120,
               depth = 60,
               height = 80,
               compartments = grid(3, 1),
               compartment_wall_height = 40,
               finger_scoop_diameter = 20,
               bottom_fillet_radius = 1);
}


/*** Code ***/

// Skådis pegboard specifications
skadis_hole_spacing  = 40;
skadis_hook_width    = 4.8;
skadis_hook_depth    = 5.4;
skadis_hook_lower_height = 9;
skadis_hook_upper_height = 14.4;
skadis_hook_shave    = 0.6;

module skadis_box(
    width = width,
    depth = depth,
    height = height,
    front_height = front_height,
    outer_wall_thickness = outer_wall_thickness,
    inner_wall_thickness = inner_wall_thickness,
    bottom_thickness = bottom_thickness,
    corner_outer_radius = corner_outer_radius,
    corner_inner_radius = corner_inner_radius,
    shave_edge = shave_edge,
    compartments = compartments,
    row_ratios = row_ratios,
    compartment_corner_radius = compartment_corner_radius,
    bottom_fillet_radius = bottom_fillet_radius,
    compartment_wall_height = compartment_wall_height,
    compartment_heights = compartment_heights,
    drain_hole_diameter = drain_hole_diameter,
    drain_hole_spacing = drain_hole_spacing,
    no_drain_hole_compartments = no_drain_hole_compartments,
    finger_scoop_diameter = finger_scoop_diameter,
    no_finger_scoop_compartments = no_finger_scoop_compartments,
    calculate_size = calculate_size,
    auto_hooks = auto_hooks,
    alternate_hooks = alternate_hooks,
    hooks = hooks,
    hook_offset = [],
    hook_margin = hook_margin,
    only_outer_hooks = only_outer_hooks) {

    // Auto-detect matrix format and convert to internal format
    compartments = is_list(compartments.x)
        ? make_compartments(compartments, row_ratios)
        : compartments;

    outer_wall_thickness = max(outer_wall_thickness, 1);
    inner_wall_thickness = max(inner_wall_thickness, 1);
    bottom_thickness = max(bottom_thickness, 1);
    shave_edge = min(max(0, shave_edge), outer_wall_thickness / 2);

    // Calculate the width and depth on basis of calculate_size
    has_pair = len(calculate_size) == 2;
    has_grid = has_pair && is_list(calculate_size.x) && is_num(calculate_size.x.x) && is_list(calculate_size.x.y);
    has_size = has_pair && is_list(calculate_size.y) && len(calculate_size.y) == 2;
    valid_calculate_size = has_grid && has_size;
    calculate_compartments = calculate_size.x;
    first_compartment_size = calculate_size.y;
    valid_first_compartment_size = valid_calculate_size && first_compartment_size.x > 0 && first_compartment_size.y > 0;
    first_row = valid_first_compartment_size ? grid_width_ratios(calculate_compartments).x : [];
    first_column = valid_first_compartment_size ? grid_depth_ratios(calculate_compartments) : [];
    assert(!valid_first_compartment_size || first_row.x > 0, "First column ratio must be > 0 for calculate_size");
    assert(!valid_first_compartment_size || first_column.x > 0, "First row ratio must be > 0 for calculate_size");
    width = valid_first_compartment_size ? 2 * outer_wall_thickness + first_compartment_size.x / (first_row.x / sum(first_row)) + (len(first_row) - 1) * inner_wall_thickness : width;
    depth = valid_first_compartment_size ? 2 * outer_wall_thickness + first_compartment_size.y / (first_column.x / sum(first_column)) + (len(first_column) - 1) * inner_wall_thickness : depth;

    // Auto-generate hooks (if auto_hooks > 0) and apply row offset
    _hooks = auto_hooks > 0
        ? auto_hook_layout(auto_hooks, width, height, corner_outer_radius)
        : hooks;
    hooks = auto_hooks > 0 && alternate_hooks
        ? offset_hook_rows(_hooks, 1, width, height, corner_outer_radius)
        : _hooks;

    hook_offset = auto_hooks > 0
        ? auto_hook_offset(hooks, width, height, depth, corner_outer_radius)
        : len(hook_margin) == 2
            ? [hook_margin.x, depth, hook_margin.y]
            : hook_offset;

    for (h = hooks) echo(str("hooks: row ", h[0], ": ", h[1], " hooks"));
    echo(str("hook_offset = [", r2(hook_offset[0]), ", ", r2(hook_offset[1]), ", ", r2(hook_offset[2]), "]"));

    assert(width > 2 * outer_wall_thickness, "width too small for wall thickness");
    assert(depth > 2 * outer_wall_thickness, "depth too small for wall thickness");
    assert(height > bottom_thickness, "height must exceed bottom_thickness");
    // Clamp front_height and compartment_wall_height to valid ranges.
    front_height = min(max(front_height, bottom_thickness + 1), height);
    compartment_wall_height = min(max(bottom_thickness, compartment_wall_height), height);

    echo(str("outer box size = [", r2(width), ", ", r2(depth), ", ", r2(height), "]"));

    union() {
        hooks(hooks = hooks, hook_offset = hook_offset, only_outer_hooks = only_outer_hooks);
        difference() {
            comparted_box(width = width,
                          depth = depth,
                          height = height,
                          front_height = front_height,
                          outer_wall_thickness = outer_wall_thickness,
                          inner_wall_thickness = inner_wall_thickness,
                          bottom_thickness = bottom_thickness,
                          corner_outer_radius = corner_outer_radius,
                          corner_inner_radius = corner_inner_radius,
                          shave_edge = shave_edge,
                          compartments = compartments,
                          compartment_corner_radius = compartment_corner_radius,
                          bottom_fillet_radius = bottom_fillet_radius,
                          compartment_wall_height = compartment_wall_height,
                          compartment_heights = compartment_heights,
                          drain_hole_diameter = drain_hole_diameter,
                          drain_hole_spacing = drain_hole_spacing,
                          no_drain_hole_compartments = no_drain_hole_compartments,
                          finger_scoop_diameter = finger_scoop_diameter,
                          no_finger_scoop_compartments = no_finger_scoop_compartments);

            if (compartment_wall_height < height) {
                translate([outer_wall_thickness, outer_wall_thickness, compartment_wall_height])
                    rounded_box(width = width - 2 * outer_wall_thickness,
                                depth = depth - 2 * outer_wall_thickness,
                                height = height,
                                corner_radius = corner_inner_radius >= 0 ? corner_inner_radius : estimated_inner_radius(corner_outer_radius, outer_wall_thickness));
            }
        }
    }
}

// Outer shell with slope and chamfer on all top edges.
// When front_height < height, creates an angled front with 45-degree bevels.
// When no slope, delegates to rounded_box with its built-in shave_edge.
module chamfered_shell(width, depth, height, front_height, corner_radius, shave_edge) {
    clamped_shave = max(0, shave_edge);
    has_slope = front_height < height;

    // Helper: box with angle cut, no chamfer
    module cut_shell(cut_width, cut_depth, cut_height, cut_front_height, cut_radius) {
        difference() {
            rounded_box(cut_width, cut_depth, cut_height, cut_radius);
            if (cut_front_height < cut_height)
                front_angle_cut(cut_width, cut_depth, cut_front_height, cut_height);
        }
    }

    if (clamped_shave > 0 && has_slope) {
        // Chamfer all top/slope edges via intersection:
        // hull of (shorter box) + (X-inset box) creates 45-degree bevels.
        // - shorter: shave lower everywhere (front/back bevels + Z offset)
        // - X-inset: shave narrower in X only (side slope bevels, parallel)
        intersection() {
            cut_shell(width, depth, height, front_height, corner_radius);
            hull() {
                cut_shell(width, depth, height - clamped_shave, front_height - clamped_shave, corner_radius);
                translate([clamped_shave, 0, 0])
                    cut_shell(width - 2 * clamped_shave, depth, height, front_height, max(corner_radius - clamped_shave, 1));
            }
        }
    } else if (has_slope) {
        // Slope without chamfer
        cut_shell(width, depth, height, front_height, corner_radius);
    } else {
        // Flat top: use rounded_box's built-in shave_edge
        rounded_box(width, depth, height, corner_radius, clamped_shave);
    }
}

// Wedge shape for the angled front cut.
module front_angle_cut(width, depth, front_height, height) {
    epsilon = 0.1;
    hull() {
        translate([-epsilon, -epsilon, front_height])
            cube([width + 2*epsilon, epsilon, height - front_height + epsilon]);
        translate([-epsilon, depth, height])
            cube([width + 2*epsilon, epsilon, epsilon]);
    }
}

// Rounded box with shave_edge chamfer on the top outer edge.
module rounded_box(width, depth, height, corner_radius, shave_edge = 0) {
    corner_radius = max(1, corner_radius);
    width = width - 2 * corner_radius;
    depth = depth - 2 * corner_radius;

    corners = [[0, 0, 0], [width, 0, 0], [0, depth, 0], [width, depth, 0]];
    translate([corner_radius, corner_radius, 0])
        hull() {
            for (corner = corners) {
                translate(corner)
                    if (shave_edge > 0) {
                        hull() {
                            cylinder(r = corner_radius, h = height - shave_edge);
                            cylinder(r = corner_radius - shave_edge, h = height);
                        }
                    } else {
                        cylinder(r = corner_radius, h = height);
                    }
            }
        }
}

module comparted_box(
    width,
    depth,
    height,
    front_height,
    outer_wall_thickness,
    inner_wall_thickness,
    bottom_thickness,
    corner_outer_radius,
    corner_inner_radius,
    shave_edge,
    compartments,
    compartment_corner_radius,
    compartment_wall_height,
    compartment_heights,
    drain_hole_diameter = 0,
    drain_hole_spacing = 10,
    no_drain_hole_compartments = [],
    finger_scoop_diameter = 0,
    no_finger_scoop_compartments = [],
    bottom_fillet_radius = 0) {
    depth_ratios = grid_depth_ratios(compartments);
    width_ratios = grid_width_ratios(compartments);
    assert(len(depth_ratios) == len(width_ratios), "Invalid compartments grid, define a row ratios per column ratios. See examples in comments of [Box compartments] section.");

    corner_inner_radius = corner_inner_radius >= 0 ? corner_inner_radius : estimated_inner_radius(corner_outer_radius, outer_wall_thickness);

    column_depth = sum(depth_ratios);
    total_compartment_depth = depth - 2 * outer_wall_thickness - (len(depth_ratios) - 1) * inner_wall_thickness;

    difference() {
        union() {
            difference() {
                // Outer box with slope and chamfer
                chamfered_shell(width, depth, height, front_height, corner_outer_radius, shave_edge);

                // Compartment cutouts, clipped to the inner boundary to enforce
                // correct corner radius where compartments meet the outer wall
                intersection() {
                    translate([outer_wall_thickness, outer_wall_thickness, bottom_thickness])
                        rounded_box(width = width - 2 * outer_wall_thickness,
                                    depth = depth - 2 * outer_wall_thickness,
                                    height = height,
                                    corner_radius = corner_inner_radius);

                    union() {
                        for (row = [0 : len(depth_ratios) - 1]) {
                            row_depth_ratio = depth_ratios[row];
                            compartment_depth = row_depth_ratio / column_depth * total_compartment_depth;
                            compartment_depth_offset_ratio = row > 0 ? sum(sublist(depth_ratios, to = row - 1)) / column_depth : 0;
                            compartment_depth_offset = compartment_depth_offset_ratio * total_compartment_depth;

                            column_width_ratios = width_ratios[row];
                            column_width = sum(column_width_ratios);
                            total_compartment_width = width - 2 * outer_wall_thickness - ((len(column_width_ratios) - 1) * inner_wall_thickness);

                            for (column = [0 : len(column_width_ratios) - 1]) {
                                column_width_ratio = column_width_ratios[column];
                                compartment_width = column_width_ratio / column_width * total_compartment_width;
                                compartment_width_offset_ratio = column > 0 ? sum(sublist(column_width_ratios, to = column - 1)) / column_width : 0;
                                compartment_width_offset = compartment_width_offset_ratio * total_compartment_width;

                                max_inner_height = compartment_wall_height - bottom_thickness;
                                inner_height = get_compartment_height(compartment_heights, row, column, max_inner_height);
                                bottom_raise = max_inner_height - inner_height;

                                echo(str("row ", row, ", column ", column, ": inner compartment size = [", r2(compartment_width), ", ", r2(compartment_depth), ", ", r2(inner_height), "]"));
                                translate([outer_wall_thickness + column * inner_wall_thickness + compartment_width_offset,
                                           outer_wall_thickness + row * inner_wall_thickness + compartment_depth_offset,
                                           bottom_thickness + bottom_raise])
                                    rounded_box(width = compartment_width, depth = compartment_depth, height = height, corner_radius = compartment_corner_radius);
                            }
                        }
                    }
                }
            }

            compartment_fillets(
                compartments, width, depth,
                outer_wall_thickness, inner_wall_thickness, bottom_thickness,
                compartment_wall_height, compartment_heights, compartment_corner_radius,
                bottom_fillet_radius);
        }

        finger_scoop_cutouts(
            compartments, width, depth, height, front_height,
            outer_wall_thickness, inner_wall_thickness, bottom_thickness,
            compartment_wall_height, compartment_heights, compartment_corner_radius,
            finger_scoop_diameter, no_finger_scoop_compartments);

        drain_hole_cutouts(
            compartments, width, depth,
            outer_wall_thickness, inner_wall_thickness, bottom_thickness,
            compartment_wall_height, compartment_heights, compartment_corner_radius,
            bottom_fillet_radius,
            drain_hole_diameter, drain_hole_spacing, no_drain_hole_compartments);
    }
}

// Places bottom_fillet material at the floor of each compartment.
module compartment_fillets(
    compartments, width, depth,
    outer_wall_thickness, inner_wall_thickness, bottom_thickness,
    compartment_wall_height, compartment_heights, compartment_corner_radius,
    bottom_fillet_radius) {

    if (bottom_fillet_radius > 0) {
        depth_ratios = grid_depth_ratios(compartments);
        width_ratios = grid_width_ratios(compartments);
        column_depth = sum(depth_ratios);
        total_compartment_depth = depth - 2 * outer_wall_thickness - (len(depth_ratios) - 1) * inner_wall_thickness;

        for (row = [0 : len(depth_ratios) - 1]) {
            row_depth_ratio = depth_ratios[row];
            compartment_depth = row_depth_ratio / column_depth * total_compartment_depth;
            compartment_depth_offset_ratio = row > 0 ? sum(sublist(depth_ratios, to = row - 1)) / column_depth : 0;
            compartment_depth_offset = compartment_depth_offset_ratio * total_compartment_depth;

            column_width_ratios = width_ratios[row];
            column_width = sum(column_width_ratios);
            total_compartment_width = width - 2 * outer_wall_thickness - ((len(column_width_ratios) - 1) * inner_wall_thickness);

            for (column = [0 : len(column_width_ratios) - 1]) {
                column_width_ratio = column_width_ratios[column];
                compartment_width = column_width_ratio / column_width * total_compartment_width;
                compartment_width_offset_ratio = column > 0 ? sum(sublist(column_width_ratios, to = column - 1)) / column_width : 0;
                compartment_width_offset = compartment_width_offset_ratio * total_compartment_width;

                max_inner_height = compartment_wall_height - bottom_thickness;
                inner_height = get_compartment_height(compartment_heights, row, column, max_inner_height);
                bottom_raise = max_inner_height - inner_height;

                clamped_radius = min(bottom_fillet_radius, compartment_corner_radius, compartment_width / 2, compartment_depth / 2);
                if (clamped_radius > 0) {
                    translate([outer_wall_thickness + column * inner_wall_thickness + compartment_width_offset,
                               outer_wall_thickness + row * inner_wall_thickness + compartment_depth_offset,
                               bottom_thickness + bottom_raise])
                        bottom_fillet(compartment_width, compartment_depth, clamped_radius, compartment_corner_radius);
                }
            }
        }
    }
}

// Cuts a semicircular scoop into the front wall of each compartment.
module finger_scoop_cutouts(
    compartments, width, depth, height, front_height,
    outer_wall_thickness, inner_wall_thickness, bottom_thickness,
    compartment_wall_height, compartment_heights, compartment_corner_radius,
    finger_scoop_diameter, no_finger_scoop_compartments) {

    if (finger_scoop_diameter > 0) {
        depth_ratios = grid_depth_ratios(compartments);
        width_ratios = grid_width_ratios(compartments);
        column_depth = sum(depth_ratios);
        total_compartment_depth = depth - 2 * outer_wall_thickness - (len(depth_ratios) - 1) * inner_wall_thickness;

        for (row = [0 : len(depth_ratios) - 1]) {
            compartment_depth_offset_ratio = row > 0 ? sum(sublist(depth_ratios, to = row - 1)) / column_depth : 0;
            compartment_depth_offset = compartment_depth_offset_ratio * total_compartment_depth;

            // Y of the wall's front face (where the scoop exits)
            wall_front_y = row == 0
                ? 0
                : outer_wall_thickness + (row - 1) * inner_wall_thickness + compartment_depth_offset;
            // Effective wall top at that Y, accounting for slope
            slope_height = front_height + (height - front_height) * wall_front_y / depth;
            // Divider walls are cut at compartment_wall_height + bottom_thickness
            wall_top = row == 0
                ? slope_height
                : min(compartment_wall_height + bottom_thickness, slope_height);

            column_width_ratios = width_ratios[row];
            column_width = sum(column_width_ratios);
            total_compartment_width = width - 2 * outer_wall_thickness - ((len(column_width_ratios) - 1) * inner_wall_thickness);

            for (column = [0 : len(column_width_ratios) - 1]) {
                if (!is_excluded(no_finger_scoop_compartments, row, column)) {
                    column_width_ratio = column_width_ratios[column];
                    compartment_width = column_width_ratio / column_width * total_compartment_width;
                    compartment_width_offset_ratio = column > 0 ? sum(sublist(column_width_ratios, to = column - 1)) / column_width : 0;
                    compartment_width_offset = compartment_width_offset_ratio * total_compartment_width;

                    max_inner_height = compartment_wall_height - bottom_thickness;
                    inner_height = get_compartment_height(compartment_heights, row, column, max_inner_height);
                    bottom_raise = max_inner_height - inner_height;

                    available_height = 2 * (wall_top - bottom_thickness - bottom_raise);
                    max_scoop_width = compartment_width - 2 * compartment_corner_radius;
                    clamped_diameter = min(finger_scoop_diameter, max_scoop_width, available_height);

                    if (clamped_diameter > 0) {
                        scoop_radius = clamped_diameter / 2;
                        center_x = outer_wall_thickness + column * inner_wall_thickness + compartment_width_offset + compartment_width / 2;
                        compartment_front_y = outer_wall_thickness + row * inner_wall_thickness + compartment_depth_offset;
                        translate([center_x, compartment_front_y + 1, wall_top])
                            rotate([90, 0, 0])
                                cylinder(r = scoop_radius, h = outer_wall_thickness + 2);
                    }
                }
            }
        }
    }
}

// Cuts a centered grid of drain holes through the floor of each compartment.
module drain_hole_cutouts(
    compartments, width, depth,
    outer_wall_thickness, inner_wall_thickness, bottom_thickness,
    compartment_wall_height, compartment_heights, compartment_corner_radius,
    bottom_fillet_radius,
    drain_hole_diameter, drain_hole_spacing, no_drain_hole_compartments) {

    if (drain_hole_diameter > 0 && drain_hole_spacing > 0) {
        epsilon = 0.01;
        drain_hole_spacing = max(drain_hole_spacing, drain_hole_diameter + 1);
        depth_ratios = grid_depth_ratios(compartments);
        width_ratios = grid_width_ratios(compartments);
        column_depth = sum(depth_ratios);
        total_compartment_depth = depth - 2 * outer_wall_thickness - (len(depth_ratios) - 1) * inner_wall_thickness;

        for (row = [0 : len(depth_ratios) - 1]) {
            row_depth_ratio = depth_ratios[row];
            compartment_depth = row_depth_ratio / column_depth * total_compartment_depth;
            compartment_depth_offset_ratio = row > 0 ? sum(sublist(depth_ratios, to = row - 1)) / column_depth : 0;
            compartment_depth_offset = compartment_depth_offset_ratio * total_compartment_depth;

            column_width_ratios = width_ratios[row];
            column_width = sum(column_width_ratios);
            total_compartment_width = width - 2 * outer_wall_thickness - ((len(column_width_ratios) - 1) * inner_wall_thickness);

            for (column = [0 : len(column_width_ratios) - 1]) {
                if (!is_excluded(no_drain_hole_compartments, row, column)) {
                    column_width_ratio = column_width_ratios[column];
                    compartment_width = column_width_ratio / column_width * total_compartment_width;
                    compartment_width_offset_ratio = column > 0 ? sum(sublist(column_width_ratios, to = column - 1)) / column_width : 0;
                    compartment_width_offset = compartment_width_offset_ratio * total_compartment_width;

                    max_inner_height = compartment_wall_height - bottom_thickness;
                    inner_height = get_compartment_height(compartment_heights, row, column, max_inner_height);
                    bottom_raise = max_inner_height - inner_height;

                    margin = max(drain_hole_diameter, bottom_fillet_radius + drain_hole_diameter / 2);
                    grid_width = compartment_width - 2 * margin;
                    grid_depth = compartment_depth - 2 * margin;

                    if (grid_width >= 0 && grid_depth >= 0) {
                        hole_cols = grid_width > 0 ? floor(grid_width / drain_hole_spacing) + 1 : 1;
                        hole_rows = grid_depth > 0 ? floor(grid_depth / drain_hole_spacing) + 1 : 1;
                        actual_width = (hole_cols - 1) * drain_hole_spacing;
                        actual_depth = (hole_rows - 1) * drain_hole_spacing;
                        origin_x = outer_wall_thickness + column * inner_wall_thickness + compartment_width_offset + (compartment_width - actual_width) / 2;
                        origin_y = outer_wall_thickness + row * inner_wall_thickness + compartment_depth_offset + (compartment_depth - actual_depth) / 2;

                        for (hole_col = [0 : hole_cols - 1]) {
                            for (hole_row = [0 : hole_rows - 1]) {
                                translate([origin_x + hole_col * drain_hole_spacing,
                                           origin_y + hole_row * drain_hole_spacing,
                                           -epsilon])
                                    cylinder(d = drain_hole_diameter, h = bottom_thickness + bottom_raise + 2 * epsilon);
                            }
                        }
                    }
                }
            }
        }
    }
}

// Concave fillet at the bottom of a compartment where floor meets walls.
// Adds material along all 4 edges and 4 rounded corners.
// All pieces extend by epsilon into the surrounding walls and floor
// to guarantee manifold overlap when unioned with the box.
module bottom_fillet(width, depth, fillet_radius, corner_radius) {
    epsilon = 0.01;
    edge_width = width - 2 * corner_radius;
    edge_depth = depth - 2 * corner_radius;

    // 2D fillet cross-section for rotate_extrude (radial, height).
    // Extended by epsilon into wall (radial) and floor (height).
    module fillet_profile() {
        translate([corner_radius - fillet_radius, -epsilon])
            difference() {
                square([fillet_radius + epsilon, fillet_radius + epsilon]);
                translate([0, fillet_radius + epsilon]) circle(r = fillet_radius);
            }
    }

    // Straight edge fillets
    if (edge_width > 0) {
        // Front edge (along X at y=0)
        translate([corner_radius, 0, 0])
            difference() {
                translate([-epsilon, -epsilon, -epsilon])
                    cube([edge_width + 2 * epsilon, fillet_radius + epsilon, fillet_radius + epsilon]);
                translate([-2 * epsilon, fillet_radius, fillet_radius])
                    rotate([0, 90, 0])
                        cylinder(r = fillet_radius, h = edge_width + 4 * epsilon);
            }
        // Back edge (along X at y=depth)
        translate([corner_radius, depth - fillet_radius, 0])
            difference() {
                translate([-epsilon, 0, -epsilon])
                    cube([edge_width + 2 * epsilon, fillet_radius + epsilon, fillet_radius + epsilon]);
                translate([-2 * epsilon, 0, fillet_radius])
                    rotate([0, 90, 0])
                        cylinder(r = fillet_radius, h = edge_width + 4 * epsilon);
            }
    }
    if (edge_depth > 0) {
        // Left edge (along Y at x=0)
        translate([0, corner_radius, 0])
            difference() {
                translate([-epsilon, -epsilon, -epsilon])
                    cube([fillet_radius + epsilon, edge_depth + 2 * epsilon, fillet_radius + epsilon]);
                translate([fillet_radius, -2 * epsilon, fillet_radius])
                    rotate([-90, 0, 0])
                        cylinder(r = fillet_radius, h = edge_depth + 4 * epsilon);
            }
        // Right edge (along Y at x=width)
        translate([width - fillet_radius, corner_radius, 0])
            difference() {
                translate([0, -epsilon, -epsilon])
                    cube([fillet_radius + epsilon, edge_depth + 2 * epsilon, fillet_radius + epsilon]);
                translate([0, -2 * epsilon, fillet_radius])
                    rotate([-90, 0, 0])
                        cylinder(r = fillet_radius, h = edge_depth + 4 * epsilon);
            }
    }

    // Corner fillets (sweep fillet profile around compartment corner radius)
    if (corner_radius >= fillet_radius) {
        // Front-left
        translate([corner_radius, corner_radius, 0])
            rotate([0, 0, 180])
                rotate_extrude(angle = 90)
                    fillet_profile();
        // Front-right
        translate([width - corner_radius, corner_radius, 0])
            rotate([0, 0, 270])
                rotate_extrude(angle = 90)
                    fillet_profile();
        // Back-left
        translate([corner_radius, depth - corner_radius, 0])
            rotate([0, 0, 90])
                rotate_extrude(angle = 90)
                    fillet_profile();
        // Back-right
        translate([width - corner_radius, depth - corner_radius, 0])
            rotate_extrude(angle = 90)
                fillet_profile();
    }
}

module skadis_hook() {
    union() {
        translate([0, skadis_hook_depth, 0])
            rotate([90, 0, 0])
                rounded_box(width = skadis_hook_width, depth = skadis_hook_lower_height, height = skadis_hook_depth, corner_radius = 2);

        translate([0, skadis_hook_depth, skadis_hook_lower_height])
            rotate([-90, 0, 0])
                rounded_box(width = skadis_hook_width, depth = skadis_hook_upper_height, height = skadis_hook_depth, corner_radius = 2, shave_edge = skadis_hook_shave);
    }
}

module hooks(hooks, hook_offset, only_outer_hooks) {
    for (hook_row = [0 : len(hooks) - 1]) {
        hook_max_index = hooks[hook_row].y - 1;
        for (hook_index = [0 : hook_max_index]) {
            add_hook = only_outer_hooks > 0 ? only_outer_hooks - hook_index > 0 || hook_max_index - hook_index < only_outer_hooks : true;
            if (add_hook) {
                translate([(hook_index + (hooks[hook_row].x % 2 == 0 ? 0 : 0.5)) * skadis_hole_spacing + hook_offset.x, hook_offset.y, hooks[hook_row].x * 0.5 * skadis_hole_spacing + hook_offset.z])
                    skadis_hook();
            }
        }
    }
}


// Sum via dot product: builds a ones-vector the same length as values, then multiplies.
function sum(values) = len(values) == 0 ? 0 : [for(p=values) 1]*values;

function r2(value) = round(value * 100) / 100;

function sublist(list, from=0, to) =
    let( end = (to==undef ? len(list)-1 : to) )
    [ for(index=[from:end]) list[index] ];


// Converts matrix format [[col_ratios], ...] to internal interleaved format.
// row_ratios sets relative depth per row (default = equal).
function make_compartments(col_ratios_per_row, row_ratios = []) =
    let(ratios = len(row_ratios) == len(col_ratios_per_row) ? row_ratios : [for(index = [0 : len(col_ratios_per_row) - 1]) 1])
    [for(index = [0 : len(col_ratios_per_row) - 1]) each [ratios[index], col_ratios_per_row[index]]];

// Shorthand helpers
function single() = [1, [1]];
function columns(col_ratios) = [1, col_ratios];
function rows(row_ratios) =
    [ for(index = [0 : len(row_ratios) * 2 - 1]) index % 2 == 0 ? row_ratios[floor(index / 2)] : [1] ];
function grid(cols, rows) =
    [ for(index = [0 : rows * 2 - 1]) index % 2 == 0 ? 1 : [for(col = [0 : cols - 1]) 1] ];


function estimated_inner_radius(corner_outer_radius, outer_wall_thickness) =
    max((1 - (outer_wall_thickness / corner_outer_radius)) * 1.1, 0.3) * corner_outer_radius;

function grid_width_ratios(grid) = [ for(index = [0 : len(grid) - 1]) if (is_list(grid[index])) grid[index] ];

function grid_depth_ratios(grid) = [ for(index = [0 : len(grid) - 1]) if (is_num(grid[index])) grid[index] ];

// Check if a compartment [row, column] is in the exclusion list.
function is_excluded(exclusions, row, column) =
    len([for (e = exclusions) if (e.x == row && e.y == column) true]) > 0;

// Look up the inner height override for a specific compartment.
// Returns default_height when no override is defined for the given row/column.
function get_compartment_height(heights, row, column, default_height) =
    let(matches = [for (h = heights) if (h.x == row && h.y == column) h.z])
    len(matches) > 0 ? min(matches.x, default_height) : default_height;

// Auto-generate hook layout based on box dimensions.
// mode: 1=top+bottom, 2=top+middle+bottom, 3=all even, 4=all odd, 5=all rows
// Uses corner_radius as minimum margin to keep hooks away from rounded corners.
function auto_hook_layout(mode, width, height, corner_radius) =
    let(
        min_margin = skadis_hole_spacing / 2,
        // Hooks per even row (full spacing)
        even_hooks = max(1, floor((width - 2 * min_margin) / skadis_hole_spacing) + 1),
        // Hooks per odd row (offset by half spacing)
        odd_hooks = max(1, floor((width - 2 * min_margin - skadis_hole_spacing / 2) / skadis_hole_spacing) + 1),
        // Maximum row index that fits (each row is 20mm apart from row 0)
        max_row = max(0, floor((height - 2 * min_margin) / (skadis_hole_spacing / 2))),
        // Last even/odd rows
        last_even = max_row - (max_row % 2),
        last_odd = max_row >= 1 ? max_row - (1 - max_row % 2) : -1,
        // Row closest to the top
        top_row = max_row,
        // Row closest to center
        center_row = round(max_row / 2),
        // Hook count for a given row
        hooks_for_row = function(row) row % 2 == 0 ? even_hooks : odd_hooks
    )
    mode == 1 ? (
        // Top + bottom: bottom is always row 0, top is the highest row that fits
        top_row > 0
            ? [[0, hooks_for_row(0)], [top_row, hooks_for_row(top_row)]]
            : [[0, hooks_for_row(0)]]
    ) :
    mode == 2 ? (
        // Top + middle + bottom
        top_row >= 2 && center_row > 0 && center_row < top_row
            ? [[0, hooks_for_row(0)], [center_row, hooks_for_row(center_row)], [top_row, hooks_for_row(top_row)]]
            : top_row > 0
                ? [[0, hooks_for_row(0)], [top_row, hooks_for_row(top_row)]]
                : [[0, hooks_for_row(0)]]
    ) :
    mode == 3 ? (
        // All even rows
        [for (row = [0 : 2 : last_even]) [row, even_hooks]]
    ) :
    mode == 4 ? (
        // All odd rows (falls back to row 0 if box is too short for odd rows)
        last_odd >= 1
            ? [for (row = [1 : 2 : last_odd]) [row, odd_hooks]]
            : let(_w = echo("WARNING: auto_hooks mode 4 (odd rows) - box too short for odd rows, falling back to row 0"))
              [[0, even_hooks]]
    ) :
    mode == 5 ? (
        // All rows (even + odd)
        [for (row = [0 : max_row]) [row, hooks_for_row(row)]]
    ) :
    [];

// Compute centered hook_offset from the generated hooks layout.
// Accounts for hook physical dimensions so hooks appear visually centered.
function auto_hook_offset(hooks, width, height, depth, corner_radius) =
    let(
        min_margin = corner_radius * 2,
        hook_total_height = skadis_hook_lower_height + skadis_hook_upper_height,
        // Find extents for even and odd rows separately
        even_row_hooks = [for (hook = hooks) if (hook.x % 2 == 0) hook.y],
        odd_row_hooks = [for (hook = hooks) if (hook.x % 2 != 0) hook.y],
        max_even = len(even_row_hooks) > 0 ? max(even_row_hooks) : 0,
        max_odd = len(odd_row_hooks) > 0 ? max(odd_row_hooks) : 0,
        // Compute actual hook span: leftmost to rightmost + hook width
        // Even hooks start at 0 from margin_x, odd hooks start at 20
        left_offset = max_even > 0 ? 0 : skadis_hole_spacing / 2,
        even_right = max_even > 0 ? (max_even - 1) * skadis_hole_spacing : 0,
        odd_right = max_odd > 0 ? (max_odd - 1) * skadis_hole_spacing + skadis_hole_spacing / 2 : 0,
        right_extent = max(even_right, odd_right) + skadis_hook_width,
        total_span = right_extent - left_offset,
        margin_x = max(min_margin, (width - total_span) / 2 - left_offset),
        // Center hooks vertically based on actual row positions.
        // margin_z + row * 20 gives each row's Z position, so center the
        // midpoint of min and max row positions at height/2.
        row_indices = [for (hook = hooks) hook.x],
        min_row = min(row_indices),
        max_row = max(row_indices),
        margin_z = max(0, height / 2 - (min_row + max_row) * skadis_hole_spacing / 4)
    )
    [margin_x, depth, margin_z];

// Shift all hook row indices by an offset and recalculate hook counts.
// Even rows become odd (and vice versa), so hook counts adjust for the
// 20mm offset on odd rows. Enables alternate pegboard placement.
function offset_hook_rows(hooks, offset, width, height, corner_radius) =
    let(
        // Use smaller margin for max_row so shifted rows still fit,
        // but keep larger margin for hook counts to prevent overflow.
        max_row = floor((height - 2 * corner_radius * 2) / (skadis_hole_spacing / 2)),
        count_margin = skadis_hole_spacing / 2,
        even_hooks = max(1, floor((width - 2 * count_margin) / skadis_hole_spacing) + 1),
        odd_hooks = max(1, floor((width - 2 * count_margin - skadis_hole_spacing / 2) / skadis_hole_spacing) + 1),
        hooks_for_row = function(row) row % 2 == 0 ? even_hooks : odd_hooks
    )
    [for (hook = hooks)
        let(new_row = hook.x + offset)
        if (new_row >= 0 && new_row <= max_row)
            [new_row, hooks_for_row(new_row)]];