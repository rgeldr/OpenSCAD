/* [Pipe Adapter Settings] */

// --- Bottom Pipe Section ---
// Inner diameter of the bottom pipe
bottom_inner_dia = 20;   // [1:0.1:150]
// Outer diameter of the bottom pipe
bottom_outer_dia = 25;   // [1:0.1:150]
// Length of the bottom pipe section
bottom_length = 30;      // [0.1:0.1:200]

// --- Top Pipe Section ---
// Inner diameter of the top pipe
top_inner_dia = 10;      // [1:0.1:150]
// Outer diameter of the top pipe
top_outer_dia = 15;      // [1:0.1:150]
// Length of the top pipe section
top_length = 30;         // [0.1:0.1:200]

// --- Transition Section ---
// Length of the conical transition between the two pipes
transition_length = 15;  // [0:0.1:200]

/* [Hidden] */
// Smoothness of the cylinders (higher = smoother, but takes longer to render)
$fn = 120; 

module parametric_pipe_adapter() {
    
    // --- Validation Checks ---
    // These will stop the render and throw a console error if the wall is thinner than 1mm
    assert(bottom_outer_dia - bottom_inner_dia >= 2, "ERROR: Bottom inner diameter is too large! It must be at least 2mm smaller than the bottom outer diameter.");
    assert(top_outer_dia - top_inner_dia >= 2, "ERROR: Top inner diameter is too large! It must be at least 2mm smaller than the top outer diameter.");

    difference() {
        // 1. CREATE THE SOLID OUTER SHELL
        union() {
            // Bottom pipe outer cylinder
            cylinder(d = bottom_outer_dia, h = bottom_length);
            
            // Conical transition outer shell
            translate([0, 0, bottom_length])
                cylinder(d1 = bottom_outer_dia, d2 = top_outer_dia, h = transition_length);
            
            // Top pipe outer cylinder
            translate([0, 0, bottom_length + transition_length])
                cylinder(d = top_outer_dia, h = top_length);
        }
        
        // 2. SUBTRACT THE INNER VOID
        union() {
            // Bottom pipe inner void (extended slightly down to ensure a clean cut)
            translate([0, 0, -1])
                cylinder(d = bottom_inner_dia, h = bottom_length + 1.01);
            
            // Conical transition inner void
            translate([0, 0, bottom_length])
                cylinder(d1 = bottom_inner_dia, d2 = top_inner_dia, h = transition_length + 0.02);
            
            // Top pipe inner void (extended slightly up to ensure a clean cut)
            translate([0, 0, bottom_length + transition_length + 0.01])
                cylinder(d = top_inner_dia, h = top_length + 1);
        }
    }
}

// Render the module
parametric_pipe_adapter();