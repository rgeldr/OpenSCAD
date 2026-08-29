/******************************************************************
Parametric Junction Box (junctionbox.scad)
(C) 2022 by Adam Oellermann <adam@oellermann.com>

The Parametric Junction Box is free software: you can redistribute 
it and/or modify it under the terms of the GNU General Public 
License as published by the Free Software Foundation, either 
version 3 of the License, or (at your option) any later version.

This clip is distributed in the hope that it will be useful, but 
WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
General Public License for more details.

You should have received a copy of the GNU General Public License 
along with ScotBot. If not, see <https://www.gnu.org/licenses/>.
-------------------------------------------------------------------
junctionbox.scad
Parametric junction box for electric wiring
Note: the lid as-is does not make for a waterproof seal. Also the
mounting holes would need to be used with a washer compressing an 
o-ring or similar in order to seal.

Instructions:
Edit the parameters just below to generate your junction box.
In the Main section (at the end of this file), uncomment a line to
generate the relevant object.
/******************************************************************/
$fs = 0.4;
$fa = 1;

// Parameters
junctionbox_width = 100; // the x-axis size of the box
junctionbox_height = 100; // the y-axis size of the box
junctionbox_thickness = 50; // the z-axis size of the box
junctionbox_skin = 3; // skin thickness - 3 is probably slightly overkill for a 100x100x50 box
junctionbox_radius = 8; // the curve radius of the corners
junctionbox_lidscrewdiam = 3; // Use M3x12 self-tapping screws to screw the lid down
junctionbox_cablediam = 20.5; // sized for M20 cable glands
junctionbox_mountscrewdiam = 3; // M3x12 self-tapping screws to fix in place
junctionbox_mountoffset = 20; // offset for mounting screws from edge of box

// number of holes on each side
nh = 1; // north side
wh = 1; // west side
eh = 1; // eastside
sh = 1; // south side

module radiuspanel_screwholes(width, height, thickness, radius, holediam) {
  // these are screwholes for fastening the lid to the body
  translate([radius, radius, -0.05])
    cylinder(d=holediam,h=thickness+0.1);
  translate([width-radius, radius, -0.05])
    cylinder(d=holediam,h=thickness+0.1);
  translate([radius, height-radius, -0.05])
    cylinder(d=holediam,h=thickness+0.1);
  translate([width-radius, height-radius, -0.05])
    cylinder(d=holediam,h=thickness+0.1);
  
}

module radiuspanel_fastenerholes(width, height, thickness, screwoffset, holediam) {
  // these are screwholes for fixing the panel/box to a surface
    translate([screwoffset, screwoffset, -0.05])
      cylinder(d=holediam,h=thickness+0.1);
    translate([width-screwoffset, screwoffset, -0.05])
      cylinder(d=holediam,h=thickness+0.1);
    translate([screwoffset, height-screwoffset, -0.05])
      cylinder(d=holediam,h=thickness+0.1);
    translate([width-screwoffset, height-screwoffset, -0.05])
      cylinder(d=holediam,h=thickness+0.1);
  
}

module radiuspanel(width, height, thickness, radius) {
  // a rounded-corner panel/solid box
  hull() {
    translate([radius, radius, 0])
      cylinder(r=radius,h=thickness);
    translate([width-radius, radius, 0])
      cylinder(r=radius,h=thickness);
    translate([radius, height-radius, 0])
      cylinder(r=radius,h=thickness);
    translate([width-radius, height-radius, 0])
      cylinder(r=radius,h=thickness);
  }
}

module radiuspanel_mountpillars(width, height, thickness, radius, pillardiam, holediam) {
  // pillars with screwholes for fixing a lide to
  translate([radius, radius, 0])
    difference() {
      cylinder(d=pillardiam,h=thickness);
      translate([0, 0, -0.05])
        cylinder(d=holediam,h=thickness+0.1);
    }
  translate([width-radius, radius, -0.05])
    difference() {
      cylinder(d=pillardiam,h=thickness);
      translate([0, 0, -0.05])
        cylinder(d=holediam,h=thickness+0.1);
    }
  translate([radius, height-radius, -0.05])
    difference() {
      cylinder(d=pillardiam,h=thickness);
      translate([0, 0, -0.05])
        cylinder(d=holediam,h=thickness+0.1);
    }
  translate([width-radius, height-radius, -0.05])
    difference() {
      cylinder(d=pillardiam,h=thickness);
      translate([0, 0, -0.05])
        cylinder(d=holediam,h=thickness+0.1);
    }
  
}

module junctionbox_cableglands(numholes, sidelength) {
  // generates the cable gland entries for a given side
  if (numholes > 0) {
    for (i=[1:numholes]) {
      xoff = sidelength*i*(1/(numholes+1));
      translate([xoff,junctionbox_skin+0.5,junctionbox_thickness/2]) 
        rotate([90,0,0])
          cylinder(d=junctionbox_cablediam, h=(junctionbox_skin*2)+1);
    }
  }
}

module solidjunctionbox() {
  difference() {
    radiuspanel(width=junctionbox_width, height=junctionbox_height, thickness=junctionbox_thickness, radius=junctionbox_radius);
    translate([junctionbox_skin,junctionbox_skin,junctionbox_skin])
      radiuspanel(width=junctionbox_width-(junctionbox_skin*2), height=junctionbox_height-(junctionbox_skin*2), thickness=junctionbox_thickness, radius=junctionbox_radius-junctionbox_skin);
  }
  radiuspanel_mountpillars(width=junctionbox_width, height=junctionbox_height, thickness=junctionbox_thickness, radius=junctionbox_radius, pillardiam=(junctionbox_radius*2), holediam=junctionbox_lidscrewdiam);
}

module junctionbox(northholes=2,westholes=2,eastholes=2,southholes=2) {
  // the junction box body
  // parameters specify the number of holes in each face
  difference() {
    solidjunctionbox();

    // the cable entries
    // south
    junctionbox_cableglands(southholes, sidelength=junctionbox_width);
    // north
    translate([0,junctionbox_height,0])
      junctionbox_cableglands(northholes, sidelength=junctionbox_width);
    // west
    rotate([0,0,90])
      junctionbox_cableglands(westholes, sidelength=junctionbox_height);
    // east
    translate([junctionbox_width,0,0])
      rotate([0,0,90])
        junctionbox_cableglands(eastholes, sidelength=junctionbox_height);
    
    // mounting screw holes
    radiuspanel_fastenerholes(
      width=junctionbox_width, 
      height=junctionbox_height, 
      thickness=junctionbox_thickness, 
      screwoffset=20, 
      holediam=junctionbox_mountscrewdiam);
  }
}

module junctionbox_lid() {
  // the lid of the junction box
  difference() {
    radiuspanel(width=junctionbox_width, height=junctionbox_height, thickness=junctionbox_skin, radius=junctionbox_radius);
    radiuspanel_screwholes(width=junctionbox_width, height=junctionbox_height, thickness=junctionbox_thickness, radius=junctionbox_radius, holediam=junctionbox_lidscrewdiam);
  } 
}

module piewedge(radius=10, angle=45) {
  // generates a pie wedge
  polygon(points=[
    [0, 0],
    for(theta=0; theta<angle; theta=theta+$fa)
      [radius*cos(theta), radius*sin(theta)],
    [radius*cos(angle), radius*sin(angle)]
  ]);
}

module cable_gland_bushing(od, id, length, slitangle) {
  // cable gland reducer bushing
  // od = the diameter of the cable entry in the gland
  // id = the diameter of the cable (maybe add 0.4 or so for easy fit
  // slitangle - the angle of the bushing to cut out for compression
  // fitting - 18° works well for me
  // note: the slit will make this not watertight... unless you get some
  // silicone in there before fastening the cable gland?
  linear_extrude(height=length)
    difference() {
      piewedge(radius=(od/2), angle=360-slitangle);
      circle(d=id);
    }
}

module cable_gland_blocker() {
  // friction-fit blocker for cable gland hole
  // note: not watertight - it would be better simply not to
  // generate the unneeded hole, but in a pinch...
  
  // base plate
  cylinder(d=junctionbox_cablediam+(junctionbox_skin*2),h=junctionbox_skin);
  
  // friction ring
  taper = 1;
  ring_thickness = 0.6;
  cgb_od = junctionbox_cablediam; 
  cgb_top = cgb_od - taper; // taper
  cgb_id = cgb_od - (ring_thickness*2); // makes the thickness of the ring 0.8
  cgb_itop = cgb_top - taper; //taper
  slotangle = 5;
  translate([0,0,junctionbox_skin-0.01]) {
    difference() {
      cylinder(d1=cgb_od,d2=cgb_top,h=junctionbox_skin);
      translate([0,0,-0.05])
      cylinder(d1=cgb_id,d2=cgb_itop,h=junctionbox_skin+0.1);
      // wiggle room
      linear_extrude(height=junctionbox_skin+0.1) 
        piewedge(radius=cgb_od+1, angle=slotangle);
      rotate([0,0,90])
        linear_extrude(height=junctionbox_skin+0.1) 
          piewedge(radius=cgb_od+1, angle=slotangle);
      rotate([0,0,180])
        linear_extrude(height=junctionbox_skin+0.1) 
          piewedge(radius=cgb_od+1, angle=slotangle);
      rotate([0,0,270])
        linear_extrude(height=junctionbox_skin+0.1) 
          piewedge(radius=cgb_od+1, angle=slotangle);
    }
  }
}

/******************************************************************
Main Section
Uncomment the appropriate line to generate the object you want
*******************************************************************/
//junctionbox(northholes=nh, southholes=sh, westholes=wh, eastholes=eh);
junctionbox(northholes=nh, southholes=sh, westholes=wh, eastholes=eh);
//junctionbox_lid();
//cable_gland_bushing(od=12, id=6.8, length=30, slitangle=18);
//cable_gland_blocker();