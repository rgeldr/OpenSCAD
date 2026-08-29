/*
  Simple Parametric Knurled Knob with Spacer
*/

/* [Knob Settings] */
knob_diameter = 25.0;     // Overall diameter of the knob
knob_thickness = 8.0;     // Thickness of the knob

/* [Screw Configuration] */
shaft_diameter = 6.0;     // Diameter of the central screw shaft
head_diameter = 10.0;     // Distance across the flats of the hex head
head_depth = 4.5;         // How deep the hex hole goes into the knob

/* [Knurling Configuration] */
knurl_size = 1.5;         // Diameter of the grip ridges

/* [Spacer Configuration] */
spacer_thickness = 2.0;   // Height of the standoff spacer
spacer_diameter = 12.0;   // Diameter of the standoff spacer

/* [Hidden] */
$fn = 60;                 // Smoothness resolution for curves

// --- Generate Knob ---

difference() {
    
    // Step A: The main body, grip ridges, and spacer
    union() {
        // Main knob body
        cylinder(h = knob_thickness, d = knob_diameter);
        
        // Add the grip ridges mathematically evenly around the outside
        num_ridges = floor((PI * knob_diameter) / (knurl_size * 2));
        for(i = [0 : num_ridges - 1]) {
            rotate([0, 0, i * (360 / num_ridges)])
            translate([knob_diameter / 2, 0, 0])
            cylinder(h = knob_thickness, d = knurl_size, $fn = 12);
        }

        // Add the spacer/washer to the face where the shaft exits
        translate([0, 0, knob_thickness])
        cylinder(h = spacer_thickness, d = spacer_diameter);
    }

    // Step B: The central shaft hole (goes all the way through knob + spacer)
    translate([0, 0, -1])
    cylinder(h = knob_thickness + spacer_thickness + 2, d = shaft_diameter);

    // Step C: The press-fit hex hole 
    translate([0, 0, -0.1])
    cylinder(h = head_depth + 0.1, d = (head_diameter - 0.15) / cos(30), $fn = 6);
}