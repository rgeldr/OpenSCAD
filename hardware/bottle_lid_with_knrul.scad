// --- [1. User Measurement Input] ---
measured_neck_diameter = 30.0; // Measured max diameter of the bottle neck (including threads)
measured_neck_height = 12.0;   // Measured height of the bottle neck
clearance = 0.3;               // Fitting clearance (added to the inner diameter)

// --- [2. Thread Specification] ---
thread_pitch = 3.0;            // Vertical distance between thread peaks
thread_depth =1;            // How far the thread extends inward

// --- [3. Structure & Knurling Settings] ---
shell_thickness = 2.0;         // Uniform thickness for walls and top lid
knurl_size = 1.5;              // Diameter of each external embossed rib

// --- [Internal Calculated Variables] ---
lid_inner_d = measured_neck_diameter + clearance; 
lid_outer_d = lid_inner_d + (shell_thickness * 2);
lid_total_h = measured_neck_height + shell_thickness;
thread_turns = (measured_neck_height - 2) / thread_pitch;

// Calculate number of knurls to maintain a 1:1 ratio between rib and flat space
knurl_count = round((PI * lid_outer_d) / (knurl_size * 2));

$fn = 60; // Resolution for cylinders

// --- [Main Modeling] ---
union() {
    // 1. Main Lid Body
    difference() {
        cylinder(h = lid_total_h, d = lid_outer_d); 
        translate([0, 0, shell_thickness])
            cylinder(h = lid_total_h + 1, d = lid_inner_d);
    }

    // 2. Internal Helical Threads
    translate([0, 0, shell_thickness + 1])
    for (i = [0 : 6 : 360 * thread_turns]) {
        hull() {
            thread_profile(i);
            thread_profile(i + 6);
        }
    }

    // 3. External Embossed Knurling (Ribs only)
    for (i = [0 : knurl_count - 1]) {
        rotate([0, 0, i * (360 / knurl_count)])
        translate([lid_outer_d / 2, 0, 0])
        cylinder(h = lid_total_h, d = knurl_size, $fn = 20);
    }
}

// Module for generating the thread cross-section
module thread_profile(angle) {
    z_pos = angle * (thread_pitch / 360);
    rotate([0, 0, angle])
    translate([lid_inner_d / 2, 0, z_pos])
    rotate([0, -90, 0])
    // Sharp triangular profile pointing inward
    cylinder(h = thread_depth, r1 = thread_pitch / 2.2, r2 = 0, $fn = 4);
}