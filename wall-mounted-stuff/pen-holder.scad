difference() {
	union() {
		cylinder(r=30, h=75);
		translate([-30,0,0])
			cube([60,30,75]);
	}
	translate([0,0,2.01])
		cylinder(r=26, h=75);
	translate([-26,0,2.01])
		cube([52,26,75]);
}


translate([0,30,75])
	rotate([90,0,0])
		difference() {
			cylinder(r=30, h=4);
			translate([0,10,-0.01]) {
				translate([0,0,2])
					cylinder(r1=2, r2=5, h=3);
				cylinder(r=2, h=4);
			}
		}