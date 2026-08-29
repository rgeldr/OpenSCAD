/* Parameters */

/* Geometry */
// Height of the jar in mm
height = 40;
// Outer radius of the jar in mm
outer_radius = 30;
// Thickness of the jar walls in mm
thickness = 2;
// Height of the threading section in mm
thread_height = 10;
// Height of the chamfer at the bottom
chamfer_height = 5; 

/* [Advanced] */
// General tolerance for fitting parts
general_tolerance = 0.3; 
// Resolution in steps/360°
fn = 256; // [8,16,32,64,128,256]
// Amount to reduce the radius by
reduced_radius_offset = thickness + 2; 
// Thickness of the lid walls
lid_thickness = reduced_radius_offset - general_tolerance; 
// Height of the chamfer at the top of the inner hollow body
top_chamfer_height = thickness * 2 - 2; 

/* [Thread Parameters] */
// Turns of thread
thread_turns = 3;

/* [Features] */
// Toggle for stackable feature
stackable = true; // [true, false]

/* Derived Parameters */
thread_thickness = (thread_height / thread_turns) / 2;
ThreadSize = thread_height / thread_turns;

/* Main Code */

// Jar Module
module jar(height, outer_radius, thickness, thread_height, reduced_radius_offset, chamfer_height, top_chamfer_height) {
    difference() {
        union() {
            // Main body of the jar, translated up by chamfer_height
            translate([0, 0, chamfer_height])
                cylinder(h = height - thread_height - chamfer_height, r = outer_radius, $fn=fn);
            
            // Threading section at the top
            translate([0, 0, height - thread_height])
                cylinder(h = thread_height, r = outer_radius - reduced_radius_offset, $fn=fn);
            
            // Chamfer at the bottom
            cylinder(h = chamfer_height, r1 = outer_radius - chamfer_height, r2 = outer_radius, $fn=fn);

            // Thread on the outside of the reduced radius section
            translate([0, 0, height - thread_height])
                screw_extrude(
                    P = [
                        [-general_tolerance, thread_thickness - general_tolerance],
                        [thread_thickness, 0],
                        [-general_tolerance, -(thread_thickness - general_tolerance)]
                    ],
                    r = outer_radius - reduced_radius_offset,
                    p = ThreadSize,
                    d = 360 * thread_turns,
                    sr = 0,
                    er = 45,
                    fn = fn
                );
        }

        // Inner hollow part with chamfer
        translate([0, 0, thickness])
            union() {
                // Main body inner hollow part, stopping thickness before the threading part, translated up by chamfer_height
                translate([0, 0, chamfer_height])
                    cylinder(h = height - thread_height - thickness - thickness - chamfer_height - top_chamfer_height, r = outer_radius - thickness, $fn=fn);
                
                // Inner hollow part within the threading section, extending thickness into the main body
                translate([0, 0, height - thread_height - thickness - thickness - top_chamfer_height])
                    cylinder(h = thread_height + thickness + top_chamfer_height, r = outer_radius - reduced_radius_offset - thickness, $fn=fn);
                
                // Chamfer at the bottom inner hollow
                cylinder(h = chamfer_height, r1 = outer_radius - thickness - chamfer_height, r2 = outer_radius - thickness, $fn=fn);

                // Chamfer at the top of the main hollow body
                translate([0, 0, height - thread_height - thickness - top_chamfer_height - thickness])
                    cylinder(h = top_chamfer_height, r1 = outer_radius - thickness, r2 = outer_radius - reduced_radius_offset - thickness, $fn=fn);
            }

        // Subtracting the top cut cylinder to prevent thread going over the top
        translate([0, 0, height])
            cylinder(h = 2 * thickness, r = outer_radius, $fn=fn);
    }
}
// Lid Module
module lid(thread_height, lid_thickness, outer_radius, general_tolerance, reduced_radius_offset, stackable) {
    // Adjust lid thickness based on stackable parameter
    lid_base_thickness = stackable ? lid_thickness * 2 : lid_thickness;

    difference() {
        // Outer body of the lid
        cylinder(h = thread_height + lid_base_thickness, r = outer_radius, $fn=fn);
        
        // Inner hollow part of the lid
        translate([0, 0, lid_base_thickness])
            cylinder(h = thread_height, r = outer_radius - lid_thickness, $fn=fn);

        // Subtracting the thread from the lid with added tolerance
        translate([0, 0, lid_base_thickness])
            screw_extrude(
                P = [
                    [-general_tolerance, thread_thickness - general_tolerance],
                    [thread_thickness, 0],
                    [-general_tolerance, -(thread_thickness - general_tolerance)]
                ],
                r = outer_radius - reduced_radius_offset + general_tolerance, // Added general tolerance
                p = ThreadSize,
                d = 360 * thread_turns,
                sr = 0,
                er = 45,
                fn = fn
            );

        // Adding a chamfer at the top of the lid where the threads end
        translate([0, 0, thread_height + lid_base_thickness - thickness])
            cylinder(h = thickness, r1 = outer_radius - reduced_radius_offset, r2 = outer_radius - thickness / 2, $fn=fn);

        if (stackable) {
            // Adding a chamfer to the cut-out for stackable feature
            translate([0, 0, 0])
                difference() {
                    // Main cut-out for stackable feature
                    cylinder(h = lid_base_thickness / 2, r1 = outer_radius - chamfer_height + thickness + general_tolerance, r2 = outer_radius - chamfer_height + general_tolerance, $fn=fn);
     }
        }
    }
}

// Call the jar module
jar(height, outer_radius, thickness, thread_height, reduced_radius_offset, chamfer_height, top_chamfer_height);

// Call the lid module at the correct height for visibility, moved to the side
translate([outer_radius * 2 + 10, 0, 0])
    lid(thread_height, lid_thickness, outer_radius, general_tolerance, reduced_radius_offset, stackable);

/**
 * screw_extrude(P, r, p, d, sr, er, fn)
    by Philipp Klostermann
    
    screw_rotate rotates polygon P 
    with the radius r 
    with increasing height by p mm per turn 
    with a rotation angle of d degrees
    with a starting-ramp of sr degrees length
    with an ending-ramp of er degrees length
    in fn steps per turn.
    
    the points of P must be defined in clockwise direction looking from the outside.
    r must be bigger than the smallest negative X-coordinate in P.
    sr+er <= d
**/

module screw_extrude(P, r, p, d, sr, er, fn) {
    anz_pt = len(P);
    steps = round(d * fn / 360);
    mm_per_deg = p / 360;
    points_per_side = len(P);
    echo ("steps: ", steps, " mm_per_deg: ", mm_per_deg);
    
    VL = [ [ r, 0, 0] ];
    PL = [ for (i=[0:1:anz_pt-1]) [ 0, 1+i,1+((i+1)%anz_pt)] ];
    V = [
        for(n=[1:1:steps-1])
            let (
                w1 = n * d / steps,
                h1 = mm_per_deg * w1,
                s1 = sin(w1),
                c1 = cos(w1),
                faktor = (w1 < sr)
                ? (w1 / sr)
                : (
                    (w1 > (d - er))
                    ? 1 - ((w1-(d-er)) / er)
                    : 1
                )
            )
            for (pt=P)
            [
                r * c1 + pt[0] * c1 * faktor, 
                r * s1 + pt[0] * s1 * faktor, 
                h1 + pt[1] * faktor 
            ]
    ];
    P1 = [
        for(n=[0:1:steps-3])
            for (i=[0:1:anz_pt-1]) 
            [
                1+(n*anz_pt)+i,
                1+(n*anz_pt)+anz_pt+i,
                1+(n*anz_pt)+anz_pt+(i+1)%anz_pt
            ]
    ];
    P2 = [
        for(n=[0:1:steps-3])
            for (i=[0:1:anz_pt-1]) 
            [
                1+(n*anz_pt)+i,
                1+(n*anz_pt)+anz_pt+(i+1)%anz_pt,
                1+(n*anz_pt)+(i+1)%anz_pt
            ]
    ];

    VR = [ [ r * cos(d), r * sin(d), mm_per_deg * d ] ];
    PR = [
        for (i=[0:1:anz_pt-1]) 
        [
            1+(steps-1)*anz_pt,
            1+(steps-2)*anz_pt+((i+1)%anz_pt),
            1+(steps-2)*anz_pt+i
        ]
    ];
            
    VG = concat(VL, V, VR);
    PG = concat(PL, P1, P2, PR);
    convex = round(d/45)+4;
    echo ("convexity = round(d/180)+4 = ", convex);
    polyhedron(VG, PG, convexity = convex);
}
