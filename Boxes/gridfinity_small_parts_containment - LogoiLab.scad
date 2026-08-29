// Created By: LogoiLab
// https://doslabelectronics.com/
// https://github.com/LogoiLab
// UNITS: mm
$fn = $preview ? 32 : 100;

// limited to 10 due to render time
gridfinity_blocks_x = 2; // [1:10]
// limited to 10 due to render time
gridfinity_blocks_y = 1; // [1:10]
lid = false;

tray_grid_x = 3; // number of tray routes in x direction
tray_grid_y = 2; // number of tray routes in y direction
// between 9.0 and 13.5 (higher = shallower)
tray_depth_offset = 9; // [9.0:13.5]

inner_fillet = true; // fillet the bottom of the trays

gridfinity_pitch = 42; // gridfinity standard size
gridfinity_zpitch = 7;
gridfinity_clearance = 0.5;  // each bin is undersize by this much

tray_size_x = (((gridfinity_pitch * gridfinity_blocks_x) - 6) / tray_grid_x);
tray_size_y = (((gridfinity_pitch * gridfinity_blocks_y) - 6) / tray_grid_y);

tray_grid_size_x = tray_size_x * tray_grid_x;
tray_grid_size_y = tray_size_y * tray_grid_y;

if (lid) {
    union() {
        grid_block(gridfinity_blocks_x, gridfinity_blocks_y, 1.0, 0, center=true);
        scale([1.0,1.05,0.5]) translate([0,0,-9]) divots(tray_depth, false);
    }
} else {
    base_part();
}

module base_part() {
    difference() {
        grid_block(gridfinity_blocks_x, gridfinity_blocks_y, 2, center=true);
        if(inner_fillet) {
            divots(tray_depth_offset + 0.5, true);
        } else {
            divots(tray_depth_offset, false);
        }
    }
}

module divots(z_offset, f) {
    translate([-tray_grid_size_x/2,-tray_grid_size_y/2, 0]) for(i=[0,1,tray_grid_x - 1]) {
        for(j=[0,1,tray_grid_y - 1]){
            translate([i * tray_size_x, j * tray_size_y, 0]) translate([tray_size_x/2, tray_size_y/2,0]) rounded_corners_hull((tray_size_x/2) - 2, (tray_size_y/2) - 2,z_offset,10,1, f);
        }
    }
}

module post(r, h, f) {
    union() {
        cylinder(r = r, h = h, center=false);
        if(f) sphere(r);
    }
}

module rounded_corners_hull(x,y,z,h,r,f) {
    hull() {
        translate([x,y,z]) post(r = r, h = h, f = f);
        translate([-x,y,z]) post(r = r, h = h, f = f);
        translate([-x,-y,z]) post(r = r, h = h, f = f);
        translate([x,-y,z]) post(r = r, h = h, f = f);
    }
}

// basic block with cutout in top to be stackable, optional holes in bottom
// start with this and begin 'carving'
module grid_block(num_x=1, num_y=1, num_z=2, bot_hole_depth=6, center=false) {
  corner_radius = 3.75;
  outer_size = gridfinity_pitch - gridfinity_clearance;  // typically 41.5
  block_corner_position = outer_size/2 - corner_radius;  // need not match center of pad corners
  
  totalht=gridfinity_zpitch*num_z+3.75;
  translate( center ? [-(num_x-1)*gridfinity_pitch/2, -(num_y-1)*gridfinity_pitch/2, 0] : [0, 0, 0] )
  difference() {
    intersection() {
      union() {
        // grid of pads
        gridcopy(num_x, num_y) pad_oversize();
        // main body will be cut down afterward
        translate([-gridfinity_pitch/2, -gridfinity_pitch/2, 5]) 
        cube([gridfinity_pitch*num_x, gridfinity_pitch*num_y, totalht-5]);
      }
      
      // crop with outer cylinders
      translate([0, 0, -0.1])
      hull() 
      cornercopy(block_corner_position, num_x, num_y) 
      cylinder(r=corner_radius, h=totalht+0.2, $fn=44);
    }
    
    // remove top so XxY can fit on top
      color("blue") 
      translate([0, 0, gridfinity_zpitch*num_z]) 
      pad_oversize(num_x, num_y, 1);
    
    // add holes in bottom pads if requested
    if (bot_hole_depth > 0) {
      gridcopy(num_x, num_y) bottomholes(bot_hole_depth);
    }
  }
}


// holes in the bottom of the pads (slightly short to allow deeper
module bottomholes(depth=6) {
  magnet_position = 13;
  magnet_od = 6.5;
  magnet_thickness = 2.4;
  eps = 0.1;  // differences are annoying with coincident faces
  if (depth > 0) {
    cornercopy(magnet_position) {
      translate([0, 0, -eps]) cylinder(d=magnet_od, h=magnet_thickness+eps, $fn=41);
      cylinder(d=3, h=depth, $fn=28);
    }
  }
}


// unit pad slightly oversize at the top to be trimmed or joined with other feet or the rest of the model
// also useful as cutouts for stacking
module pad_oversize(num_x=1, num_y=1, margins=0) {
  pad_corner_position = 17; // must be 17 to be compatible
  bevel1_top = 0.8;     // z of top of bottom-most bevel (bottom of bevel is at z=0)
  bevel2_bottom = 2.6;  // z of bottom of second bevel
  bevel2_top = 5;       // z of top of second bevel
  bonus_ht = 0.2;       // extra height (and radius) on second bevel
  
  // female parts are a bit oversize for a nicer fit
  radialgap = margins ? 0.25 : 0;  // oversize cylinders for a bit of clearance
  axialdown = margins ? 0.1 : 0;   // a tiny bit of axial clearance present in Zack's design
  
  translate([0, 0, -axialdown])
  difference() {
    union() {
      hull() cornercopy(pad_corner_position, num_x, num_y) {
        cylinder(d=1.6+2*radialgap, h=0.1, $fn=24);
        translate([0, 0, bevel1_top]) cylinder(d=3.2+2*radialgap, h=1.9, $fn=32);
      }
      
      hull() cornercopy(pad_corner_position, num_x, num_y) {
        translate([0, 0, bevel2_bottom]) 
        cylinder(d1=3.2+2*radialgap, d2=7.5+0.5+2*radialgap+2*bonus_ht, h=bevel2_top-bevel2_bottom+bonus_ht, $fn=32);
      }
    }
    
    // cut off bottom if we're going to go negative
    if (margins) {
      translate([-gridfinity_pitch/2, -gridfinity_pitch/2, 0])
      cube([gridfinity_pitch*num_x, gridfinity_pitch*num_y, axialdown]);
    }
  }
}


// similar to quadtranslate but expands to extremities of a block
module cornercopy(r, num_x=1, num_y=1) {
  for (xx=[-r, gridfinity_pitch*(num_x-1)+r]) for (yy=[-r, gridfinity_pitch*(num_y-1)+r]) 
    translate([xx, yy, 0]) children();
}


// make repeated copies of something(s) at the gridfinity spacing of 42mm
module gridcopy(num_x, num_y) {
  for (xi=[1:num_x]) for (yi=[1:num_y]) translate([gridfinity_pitch*(xi-1), gridfinity_pitch*(yi-1), 0]) children();
}


