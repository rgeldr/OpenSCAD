/* [Parameters] */

// Determines the distance between the two screw holes.
Length = 120;

// Determines the size of the 45-degree chamfer on the edges.
Chamfer_size = 1.5; 

// Determines the passthrough hole diameter for the two screws.
Skrew_diameter = 6;

// Determines handle width
Width = 20;

// Determines handle height / finger clearance.
Finger_clearance = 25;

// Determines thickness of handle.
Thickness = 15;

// Determines Bend Radius
Bend_Radius = 0;

/* [Hidden] */
$fn = 64; // Smoothness resolution for curves

// --- 2D Cross Section Profile ---
// This generates a 2D rectangle with 45-degree chamfered corners
module chamfered_profile(t, w, c) {
    polygon([
        [-t/2, -w/2 + c],
        [-t/2 + c, -w/2],
        [t/2 - c, -w/2],
        [t/2, -w/2 + c],
        [t/2, w/2 - c],
        [t/2 - c, w/2],
        [-t/2 + c, w/2],
        [-t/2, w/2 - c]
    ]);
}

module Parametric_Handle() {
    
    // Auto-calculate bend alignments
    Bend_Radius = Thickness  + Bend_Radius; 
    C_Z = Finger_clearance - (Thickness / 2); 

    // We generate the model standing up on its legs
    difference() {
        
        // --- 1. Main Solid Body ---
        union() {
            // A. Left Leg (Extruded straight up)
            translate([0, 0, 0])
                linear_extrude(height = C_Z)
                    chamfered_profile(Thickness, Width, Chamfer_size);

            // B. Right Leg (Extruded straight up)
            translate([Length, 0, 0])
                linear_extrude(height = C_Z)
                    chamfered_profile(Thickness, Width, Chamfer_size);

            // C. Left Top Corner (Rotated and swept 90 degrees)
            translate([Bend_Radius, 0, C_Z])
                rotate([90, 0, 180])
                    rotate_extrude(angle = 90)
                        translate([Bend_Radius, 0, 0])
                            chamfered_profile(Thickness, Width, Chamfer_size);

            // D. Right Top Corner (Rotated and swept 90 degrees)
            translate([Length - Bend_Radius, 0, C_Z])
                rotate([90, 0, 0])
                    rotate_extrude(angle = 90)
                        translate([Bend_Radius, 0, 0])
                            chamfered_profile(Thickness, Width, Chamfer_size);

            // E. Top Horizontal Bar
            translate([Bend_Radius, 0, C_Z + Bend_Radius])
                rotate([0, 90, 0])
                    linear_extrude(height = Length - 2 * Bend_Radius)
                        chamfered_profile(Thickness, Width, Chamfer_size);
        }

        // --- 2. Screw Holes ---
        // Left hole going up into the leg
        translate([0, 0, -1])
            cylinder(d = Skrew_diameter, h = Thickness + 10);

        // Right hole going up into the leg
        translate([Length, 0, -1])
            cylinder(d = Skrew_diameter, h = Thickness + 10);
    }
}

// Generate the model
// Note: If you want to lay it flat for 3D printing, 
// wrap this function in: rotate([90, 0, 0]) Parametric_Handle();
Parametric_Handle();