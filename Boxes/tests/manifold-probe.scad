// Isolated operands used to prove rim / seal / floor profiles are closed solids.
use <../RuggedBoxCustomeDividersV1.0.scad>

part = "corner";

if (part == "corner")
    rotate_extrude(angle = 90, $fn = 8) Wall2D(2, 0, 32, true, true);
else if (part == "side")
    rotate([90, 0, 90]) linear_extrude(30) Wall2D(2, 0, 32, true, false);
else if (part == "seal")
    rotate_extrude(angle = 90, $fn = 8) translate([2, 0]) rb_groove_profile(1.1);
else if (part == "bead")
    rotate_extrude(angle = 90, $fn = 8) translate([2, 0]) rb_bead_profile(1.1, $fn = 32);
