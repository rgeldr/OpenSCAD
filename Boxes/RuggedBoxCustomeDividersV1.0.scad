

/*[View Options]*/
// *********************************
// **** View and Layout Options **** 
// *********************************

// This option controls if you want to view the box closed or open.  False = the box will be open, and everything will be on the build plate.  True = view the box closed and latches in place (but the feet and TPU inserts will remain separate).
viewBoxClosed = false;

/*[Objects To Generate]*/
// *****************************
// **** Objects To Generate **** 
// *****************************
// These settings indicate what components of the box you want to generate.

// Should the bottom of the main box be generated
generateBoxBottom = true;
// Should the top of the main box be generated
generateBoxTop = true;
// Should the latches be generated
generateLatches = false;
// Should the gasket be generated.  NOTE: The gasket will still only be generated if the boxSealType == 2 (Gasket)
generateGasket = true;
// Use this option to generate a test gasket and casket insert.  This is so you can do a small print to test your tolerances before printing a full box.  You will need to separate/split the in the slicer and print them one at a time.  This "sample case rim(where the gasket will be inserted)" in your filament of choice, and the gasket itself in TPU.
// Should the feet be generated.  This has NO effect on if the feet cutouts are added to the box top and bottom.  Those settings are below...  This just determines if the feet themselves get generated.
generateFeetIfSetInSettings = true;


/*[Poly Level]*/
// ***************************
// **** Poly Level Option **** 
// ***************************

// 1 = Extra Low Poly, 2 = Low Poly, 3 = Curved 
BoxPolygonStyle = 2; // [1:ExtraLowPoly, 2:LowPoly, 3:Curved]

polyLvl = 
  BoxPolygonStyle == 1 
    ? 4
    : BoxPolygonStyle == 2 
        ? 8
        : 80;

/*[Main Box Settings]*/
// *********************************
// **** Main Box Settings **** 
// *********************************

// The width(X) of the inside box wall in MM
internalBoxWidthXMm = 160; // .1
// The length(Y) of the inside box wall in MM
internalboxLengthYMm = 60; // .1
// ***LID***- The internal height on the box lid MIN-15mm
internalBoxTopHeightZMm = 15; // [15:1:50]
// The internal height on the box bottom
internalboxBottomHeightZMm = 30; //[20:1:250]

// The width on the box wall and floor.  (NOTE: If you want square inside corners, the boxWallWidthMm must be > the  boxChamferRadiusMm.)
boxWallWidthMm = 2.0; // [1:0.1:10]
// TODO: Add contrraint for this
// The chamfer radius of the boxes corners.  (NOTE1: the floor/top radius is slightly differentthan the sides to eliminate the need for supports. NOTE2: If you want square inside corners, the boxWallWidthMm must be >= the boxChamferRadiusMm.)
boxChamferRadiusMm = 1; // .1

// The type of seal for the case. 1 = Circular Non-Gasket (less water resistant), 2 = Gasket type seal (more water resistant)
boxSealType = 1; // [1:NonGasket,2:Gasket]
// TODO: Add constraint for this
// The radius of the seal (NOTE: 2*boxCircularSealRadius MUST be < the (boxWallWidthMm+rimWidthMm))
boxCircularSealRadius = 1.1; // .1
// The with of the slot that holds the gasket for a water resistant seal.  Only used if boxSealType = 1(Gasket)
gasketSlotWidth = 1.75; // 0.01
// The depth of the slot that holds the gasket for a water resistant seal.  Only used if boxSealType = 1(Gasket)
gasketSlotDepth = 2.2; // 0.1
// The tolerance subtracted from the actual gasket size do it will fit into the slot.  Only used if boxSealType = 1(Gasket)
gasketTolerance = 0.2; // .05
// If you feel like you need to add some additional height to your gasket (so it protrudes out of the gasket slot) to make sure you get a good seal, you can add that here.  By default, I have set this to the same value as the opening tolerance
additionalGasketHeight = 0.1; //.05

// The width of the rim that goes around the case opening
rimWidthMm = 2; //.1
// The height of the top/bottom rim that goes around the case opening (This excludes the rim chamfer which is just a 45 degree angle)
rimHeightMm = 3; // .1

// Number of side ribs on the side
numSideSupportRibs = 2; // 1
// The offset from the center for the side ribs (moves the ribs away from the center)
ribCenterOffsetMm = 5; // 1
// The thickness of the side ribs, you probably want this to match the rimWidthMm.  This is the thickness of the rib from the box wall.
supportRibThickness = 2; // 1
// The width of the side rib along the wall
supportRibWidth = 4; // 1

// The tolerance/separation between the top and bottom box sections
openingTolerance = 0.1; // .05

/*[Dividers]*/
// Height shares along Y, front (Y=0) to back. Trailing 0s are unused. [2, 3] is 40% then 60%.
dividerRowHeights = [2, 3, 0, 0, 0, 0];
// Width shares along X for row 1. One positive number means no column wall. Trailing 0s are unused.
dividerRow1Widths = [62, 38, 0, 0, 0, 0, 0, 0];
// Width shares along X for row 2.
dividerRow2Widths = [74, 26, 0, 0, 0, 0, 0, 0];
// Width shares along X for row 3. Ignored while that row's height is 0.
dividerRow3Widths = [1, 0, 0, 0, 0, 0, 0, 0];
// Width shares along X for row 4. Ignored while that row's height is 0.
dividerRow4Widths = [1, 0, 0, 0, 0, 0, 0, 0];
// Width shares along X for row 5. Ignored while that row's height is 0.
dividerRow5Widths = [1, 0, 0, 0, 0, 0, 0, 0];
// Width shares along X for row 6. Ignored while that row's height is 0.
dividerRow6Widths = [1, 0, 0, 0, 0, 0, 0, 0];
// Divider wall thickness in mm.
dividerWallThickness = 1.2; // [1:0.1:4]
// Gap from each divider tip to the opening. The closed gap is twice this plus openingTolerance.
dividerTopClearance = 0.5; // [0.2:0.1:2]

/*[Tool outlines]*/
// Shaped block in the bottom. Off keeps the dividers and does not read outline files.
toolInsertEnabled = false;
// Whole bottom, or one compartment addressed by row and column.
toolInsertTarget = 0; // [0:Whole bottom, 1:One compartment]
// Row of that compartment. 1 is the front. Ignored for the whole bottom.
toolInsertRow = 1; // [1:6]
// Column of that compartment. 1 is the left.
toolInsertColumn = 1; // [1:8]
// Keep dividers, or remove them in the target. One compartment clears that row's column walls and keeps the cross walls.
toolDividers = 0; // [0:Keep, 1:Remove in the target]
// Solid insert fills up to the divider tips. Pocket floor is a thin plate on the floor.
toolBlockMode = 0; // [0:Solid insert, 1:Pocket floor]
// Plate thickness in pocket-floor mode.
toolPocketPlateMm = 4; // [1:0.1:30]
// Material that must remain under a pocket.
toolMinPocketFloor = 1.2; // [0.8:0.1:5]
// Mirror the bottom dividers onto the lid, or leave the lid empty. The lid never gets pockets.
toolLid = 0; // [0:Mirror dividers, 1:Plain lid]
// Used only when an SVG width/height is not in mm. 25.4 means 1 user unit = 1 mm.
toolSvgDpi = 25.4; // [1:0.1:96]
// Multiplier applied with scale() after import. 1 keeps the file size.
toolOutlineScale = 1; // [0.5:0.01:2]
// Slot 1 on/off.
tool1Enabled = false;
// Slot 1 file, relative to this .scad file. tools/_blank.svg means unused.
tool1File = "tools/_blank.svg";
// Slot 1 drawing width in mm, from Inkscape after resizing the page to the drawing.
tool1WidthMm = 0; // [0:0.1:500]
// Slot 1 drawing height in mm.
tool1HeightMm = 0; // [0:0.1:500]
// Slot 1 origin X, mm from the interior's left.
tool1XMm = 0; // [0:0.1:500]
// Slot 1 origin Y, mm from the interior's front.
tool1YMm = 0; // [0:0.1:500]
// Slot 1 rotation around the drawing origin, degrees counterclockwise.
tool1Rotation = 0; // [-180:1:180]
// Slot 1 pocket depth from the top of the block, mm.
tool1CutDepthMm = 8; // [0:0.1:80]
// Slot 1 extra clearance around the outline, mm. 0 is a snug cut.
tool1ClearanceMm = 0.3; // [0:0.05:5]
// Slot 1 finger notch on the front edge of the outline.
tool1FingerNotch = false;
// Slot 2 on/off.
tool2Enabled = false;
// Slot 2 file, relative to this .scad file.
tool2File = "tools/_blank.svg";
// Slot 2 drawing width in mm.
tool2WidthMm = 0; // [0:0.1:500]
// Slot 2 drawing height in mm.
tool2HeightMm = 0; // [0:0.1:500]
// Slot 2 origin X, mm.
tool2XMm = 0; // [0:0.1:500]
// Slot 2 origin Y, mm.
tool2YMm = 0; // [0:0.1:500]
// Slot 2 rotation, degrees.
tool2Rotation = 0; // [-180:1:180]
// Slot 2 pocket depth, mm.
tool2CutDepthMm = 8; // [0:0.1:80]
// Slot 2 extra clearance, mm.
tool2ClearanceMm = 0.3; // [0:0.05:5]
// Slot 2 finger notch.
tool2FingerNotch = false;
// Slot 3 on/off.
tool3Enabled = false;
// Slot 3 file, relative to this .scad file.
tool3File = "tools/_blank.svg";
// Slot 3 drawing width in mm.
tool3WidthMm = 0; // [0:0.1:500]
// Slot 3 drawing height in mm.
tool3HeightMm = 0; // [0:0.1:500]
// Slot 3 origin X, mm.
tool3XMm = 0; // [0:0.1:500]
// Slot 3 origin Y, mm.
tool3YMm = 0; // [0:0.1:500]
// Slot 3 rotation, degrees.
tool3Rotation = 0; // [-180:1:180]
// Slot 3 pocket depth, mm.
tool3CutDepthMm = 8; // [0:0.1:80]
// Slot 3 extra clearance, mm.
tool3ClearanceMm = 0.3; // [0:0.05:5]
// Slot 3 finger notch.
tool3FingerNotch = false;
// Slot 4 on/off.
tool4Enabled = false;
// Slot 4 file, relative to this .scad file.
tool4File = "tools/_blank.svg";
// Slot 4 drawing width in mm.
tool4WidthMm = 0; // [0:0.1:500]
// Slot 4 drawing height in mm.
tool4HeightMm = 0; // [0:0.1:500]
// Slot 4 origin X, mm.
tool4XMm = 0; // [0:0.1:500]
// Slot 4 origin Y, mm.
tool4YMm = 0; // [0:0.1:500]
// Slot 4 rotation, degrees.
tool4Rotation = 0; // [-180:1:180]
// Slot 4 pocket depth, mm.
tool4CutDepthMm = 8; // [0:0.1:80]
// Slot 4 extra clearance, mm.
tool4ClearanceMm = 0.3; // [0:0.05:5]
// Slot 4 finger notch.
tool4FingerNotch = false;
// Finger notch width, shared by every slot that turns the notch on.
toolFingerNotchWidth = 12; // [4:0.5:40]
// Finger notch depth toward the back, mm.
toolFingerNotchDepth = 8; // [2:0.5:30]



/*[Hinge Settings]*/
// ************************
// **** Hinge Settings **** 
// ************************

// The number of hinges
numberOfHinges = 2; // 1
// The number of MM you want to move each hinge away from center.  If there is a middle hinge, that one won't move. 
hingeCenterOffsetMm = 30; // 1
// AKA: Hinge Screw Length. The full hinge width.  This is also the length of the screw you will need to assemble the case
hingeTotalWidthMm = 25; // 1
// The radius of the hinge pivot
hingeRadiusMm = 4; // .1
// The width of the outside portion of the hinge connector
hingeOutsideWidth = 6; // .5
// The radius of hinge screw hole that does not get threaded and allows the hinge to pivot/rotate. 3mmScrew=1.7 
hingeScrewLargeRadiusMm = 1.7; // .05
// The radius of hinge screw hole gets threaded and holds the hinge together. 3mmScrew=1.5 
hingeScrewSmallRadiusMm = 1.45; // .05
// the tolerance between all the hinge components.  The small gap that allows the hinge to move.
hingeToleranceMm = 0.35; // .05

/*[Latch Settings]*/
// ************************
// **** Latch Settings **** 
// ************************

// The number of latches to generate
numberOfLatches = 2;
// The number in MM you want to move each hinge away from center.  If there is a middle hinge, that one won't move.
requestedLatchCenterOffsetMm = 5;
// AKA: Latch Screw Length. The total width of the latch.  This is the length of the screws needed to assemble the latch.
latchSupportTotalWidth = 25;
// The width of the outside portions of the latch mount
latchSupportWidth = 4;
// The vertical position of the latch screw position.  The position is calculated be the percentage of the top/bottom box heights.
latchScrewPositionPct = 50;
//DO NOT MODIFY - this changes the latch length 10mm fits the curvy latches
latchScrewOffsetMm = 10;
// The radius of the latch pivot.
latchSupportRadius = 4; // .1
// The tolerance of the gaps between the latch and the latch mount so the latch can move.
latchToloerance = 0.2; // .05
// The radius of hinge screw hole does not get threaded and allows the latch to pivot/rotate. 3mmScrew=1.7 
latchScrewLargeRadiusMm = 1.7; // .05
// The radius of hinge screw hole gets threaded and holds the latch together. 3mmScrew=1.5 
latchScrewSmallRadiusMm = 1.45; // .05

// Controls the length of the tab that allows you to open the latch. 1 is pretty short, 2 is pretty long. It's easy to make this too short or too long... Somewhere between 1 and 2 seems like a good value.
latchOpenerLengthMultiplier = 1.75; //[.5:.1:3]
// This is the angle of the latch opener tab. The valid values are between 0 and 45 seem to be okay values.
latchOpenerAngle = 10; //[0:1:45]

// Min: 10, Max: 50. The shallower the angle the Harder it will be to close, at 10 you probably won't be able to bend the latch enough to close it, as you approach 50, it may not hold very well.
latchClipCutoutAngle = 40; //[10:1:50]


/*[Handle Settings]*/
// ************************
// **** Handle Settings *** 
// ************************

// Should the handle be generated between the latches?
generateHandle = true;
// Minimum distance between latches (MM)
minDistanceBetweenLatches = 80;
// How far the handle sticks out for fingers (MM)
handleOutwardExtension = 30;
// Thickness of the handle arms (MM)
handleThickness = 4; // [2:1:10]


/*[Feet Settings]*/
// ***********************
// **** Feet Settings **** 
// ***********************

// Should feet be generated and the feet connections be cutout from the containet top and bottom.  (NOTE: this will require some glue... sorry, no tome to create a snap-in connector)
isFeetAdded = false;
// The width of the feet
feetwidthMm = 4; // 1
// the length of the feet
feetLengthMm = 10; // 1
// the depth that the feet will insert into the top and bottom cases
feetInsertDepth = 1; // .1
// The gap size between the stacked top and bottom box
boxGapMm = 1.5; // .1
// The actual distance of the feet from the exterior wall(not including the rim) wall will be the boxChamferRadiusMm + additionaldistanceFromWallAfterChamfer
additionaldistanceFromWallAfterChamferMm = 5; // .1
// The tolerance that allows the feet to be inserted into the box cutouts
footInsertToleranceMm = 0.4; // .1


// **********************
// **** END Settings ****
// **********************


// Calculated Variables

// The width(X) of the outside box wall (excluding the rim width) in MM
boxWidthXMm = internalBoxWidthXMm + (2*boxWallWidthMm);
// The length(Y) of the outside box wall (excluding the rim width) in MM
boxLengthYMm = internalboxLengthYMm + (2*boxWallWidthMm);
// The height of the box top
boxTopHeightZMm = internalBoxTopHeightZMm + boxWallWidthMm;
// The height of the box bottom
boxBottomHeightZMm = internalboxBottomHeightZMm + boxWallWidthMm;

// --- Handle & Latch Math ---
latchSpacingBase = (boxWidthXMm - (numberOfLatches*latchSupportTotalWidth)) / (numberOfLatches + 1);
// Automatically overrides your requested offset if the latches are closer than your minimum distance
latchCenterOffsetMm = (generateHandle && numberOfLatches >= 2 && (latchSpacingBase + (2*requestedLatchCenterOffsetMm) < minDistanceBetweenLatches))
    ? (minDistanceBetweenLatches - latchSpacingBase) / 2
    : requestedLatchCenterOffsetMm;


/* [Hidden] */
// How far divider and insert solids overlap the shell so the union stays one piece.
rb_embed = 0.2;

function rb_width_rows() = [
    dividerRow1Widths, dividerRow2Widths, dividerRow3Widths,
    dividerRow4Widths, dividerRow5Widths, dividerRow6Widths
];

function _rb_kept_tree(orig) =
    (!toolInsertEnabled || toolDividers == 0) ? orig :
    toolInsertTarget == 0 ? [] :
    rb_clear_cell(orig, toolInsertRow, toolInsertColumn);

function rb_bottom_layout(orig) =
    let(kept = _rb_kept_tree(orig))
    assert(rb_validate(kept, internalBoxWidthXMm, internalboxLengthYMm, dividerWallThickness, dividerTopClearance, internalboxBottomHeightZMm, internalBoxTopHeightZMm, rb_embed, boxWallWidthMm))
    assert(rb_check_insert(orig, kept))
    kept;

_rb_orig_tree = rb_row_layout(dividerRowHeights, rb_width_rows(), internalBoxWidthXMm, internalboxLengthYMm, dividerWallThickness);
_bottom_divider_tree = rb_bottom_layout(_rb_orig_tree);
_lid_divider_tree = rb_lid_mode(_bottom_divider_tree, toolLid, boxWallWidthMm, boxWallWidthMm + internalboxLengthYMm);

// WALL Testing
//translate([0,-50,0]) rotate([90,0,0]) linear_extrude(6) Wall2D(boxWallWidthMm, 0, boxBottomHeightZMm, true, true);



// *****************************************
// **** Create the box components **** 
// *****************************************

closedBoxZOffset = viewBoxClosed ? boxBottomHeightZMm : 0;

previewHingeLatchMounts = is_undef(previewHingeLatchMounts) ? false : previewHingeLatchMounts;
previewHingeLatchPart = is_undef(previewHingeLatchPart) ? "bottom" : previewHingeLatchPart;

if (previewHingeLatchMounts) {
    // Same placement as BoxBottom / BoxTop. LatchMount already moves itself to the front wall.
    if (previewHingeLatchPart == "bottom") {
        union() {
            BotomStandardHinge();
            LatchMount(
                latchSupportTotalWidth,
                latchSupportWidth,
                latchScrewPositionPct,
                boxBottomHeightZMm,
                latchSupportRadius,
                latchToloerance
            );
        }
    } else if (previewHingeLatchPart == "lid") {
        union() {
            TopStandardHinge();
            translate([boxWidthXMm, 0, 0])
                rotate([0, 0, 180])
                    translate([0, -boxLengthYMm, 0])
                        rotate([180, 0, 0])
                            translate([0, -boxLengthYMm, -openingTolerance])
                                LatchMount(
                                    latchSupportTotalWidth,
                                    latchSupportWidth,
                                    latchScrewPositionPct,
                                    boxTopHeightZMm,
                                    latchSupportRadius,
                                    latchToloerance
                                );
        }
    } else {
        assert(false, str("previewHingeLatchPart must be bottom or lid, got ", previewHingeLatchPart));
    }
} else translate([0,0,closedBoxZOffset])
    union() {
        // Create the box Bottom
        if(generateBoxBottom) {
            if(viewBoxClosed) {
                BoxBottom(true);
            }
            else {
                translate([0,0,boxBottomHeightZMm]) BoxBottom(true);
            }
        }

        // Create the box Top
        if(generateBoxTop) {
            if(viewBoxClosed) {
                BoxTop(true);
            }
            else {
            translate([0,hingeRadiusMm*2,boxTopHeightZMm])
                translate([0,(boxLengthYMm+rimWidthMm+hingeRadiusMm+openingTolerance)*2, openingTolerance]) rotate([-180,0,0])
                    BoxTop(true);
            }
        }

        // Create the latches
        if(generateLatches) {
            StandardLatch(latchSupportTotalWidth, latchSupportWidth, latchScrewPositionPct, boxTopHeightZMm, boxBottomHeightZMm, latchSupportRadius, latchToloerance);
        }
        
        // --- GENERATE SEPARATE HANDLES ---
        if(generateHandle && numberOfLatches >= 2) {
            // Ensures exactly 0.5mm gap by subtracting half the remaining gap from the screw offset
            handlePrintHeight = latchScrewOffsetMm - ((0.5 - openingTolerance) / 2); 
            
            if(viewBoxClosed) {
                translate([boxWidthXMm,0,0])
                rotate([0,0,180])
                translate([0,-boxLengthYMm,0])
                translate([0, boxLengthYMm + latchSupportRadius + rimWidthMm, -latchScrewOffsetMm]) {
                    // Position Bottom Handle
                    mirror([0,0,1]) translate([0, 0, -handlePrintHeight]) CaseHandle();
                    
                    // Position Top Handle
                    translate([0, 0, (latchScrewOffsetMm * 2) + openingTolerance])
                        translate([0, 0, -handlePrintHeight]) CaseHandle();
                }
            }
            else {
                // Generate handles flat on the build plate (safely placed in front of the box)
                translate([0, -(handleOutwardExtension + latchSupportRadius*2 + 10), 0]) {
                    CaseHandle(); 
                    translate([0, -(handleOutwardExtension + latchSupportRadius*2 + 10), 0])
                        CaseHandle(); 
                }
            }
        }
        
    }

// Create feet if requested
if(generateFeetIfSetInSettings) {
    CreateFeet();
}



if(generateGasket) {
    // Add in the Gasket if needed
    if(boxSealType == 2) {  
        translate([0,0,boxBottomHeightZMm]) translate([0,(boxLengthYMm*2)+(hingeRadiusMm*5)+(latchSupportRadius*5),-boxBottomHeightZMm]) 
        BoxGasketSealExtrude(gasketSlotWidth-(2*gasketTolerance),gasketSlotDepth+additionalGasketHeight,(gasketSlotDepth+additionalGasketHeight)/2);                 
    }
}




function rb_divider_tip_z(clearance) = -clearance;
function rb_closed_divider_gap(clearance, opening_tol) = 2 * clearance + opening_tol;
function rb_inside_corner_trimmed(wall, chamfer) = wall <= chamfer;

// --- Layout tree (leaf = []; split = [axis, pos_mm, child_lo, child_hi]) ---

function rb_is_leaf(node) = len(node) == 0;

function rb_walls(node, xmin, ymin, xmax, ymax) =
    rb_is_leaf(node) ? [] :
    let(axis = node[0], pos_rel = node[1], lo = node[2], hi = node[3])
    axis == "y" ?
        let(pos = ymin + pos_rel)
        concat(
            [["y", pos, xmin, xmax, ymin, ymax]],
            rb_walls(lo, xmin, ymin, xmax, pos),
            rb_walls(hi, xmin, pos, xmax, ymax)
        ) :
        let(pos = xmin + pos_rel)
        concat(
            [["x", pos, xmin, xmax, ymin, ymax]],
            rb_walls(lo, xmin, ymin, pos, ymax),
            rb_walls(hi, pos, ymin, xmax, ymax)
        );

function rb_mirror_y(node, ymin, ymax) =
    rb_is_leaf(node) ? [] :
    let(axis = node[0], pos_rel = node[1], lo = node[2], hi = node[3])
    let(span = ymax - ymin, pos_abs = ymin + pos_rel)
    axis == "y" ?
        ["y", span - pos_rel,
            rb_mirror_y(hi, ymin, pos_abs),
            rb_mirror_y(lo, pos_abs, ymax)
        ] :
        ["x", pos_rel,
            rb_mirror_y(lo, ymin, ymax),
            rb_mirror_y(hi, ymin, ymax)
        ];

function rb_lid_tree(bottom_tree, ymin, ymax) = rb_mirror_y(bottom_tree, ymin, ymax);
function rb_lid_mode(bottom, mode, ymin, ymax) = mode == 1 ? [] : rb_lid_tree(bottom, ymin, ymax);

function _rb_mm(x) = round(x * 100) / 100;

function _rb_sum(v, i = 0, acc = 0) =
    i >= len(v) ? acc : _rb_sum(v, i + 1, acc + v[i]);

function _rb_rest(v, i = 1) =
    i >= len(v) ? [] : concat([v[i]], _rb_rest(v, i + 1));

function _rb_tail_zeros(v, i, name) =
    i >= len(v) ? true :
    assert(v[i] == 0, str(name, ": a 0 must be trailing, found 0 before ", v[i]))
    _rb_tail_zeros(v, i + 1, name);

function _rb_used(v, i, name) =
    i >= len(v) ? [] :
    assert(v[i] >= 0, str(name, "[", i, "] is ", v[i], "; shares must be 0 or positive"))
    (v[i] == 0 ? (assert(_rb_tail_zeros(v, i, name)) []) :
        concat([v[i]], _rb_used(v, i + 1, name)));

function _rb_check_heights(shares, total, wall, i = 0, sum = -1) =
    let(s = sum < 0 ? _rb_sum(shares) : sum)
    i >= len(shares) ? true :
    let(mm = shares[i] / s * total)
    assert(mm + 1e-6 >= wall, str("divider row ", i + 1, " height is ", _rb_mm(mm), " mm; minimum is dividerWallThickness (", wall, " mm)"))
    _rb_check_heights(shares, total, wall, i + 1, s);

function _rb_check_cols(shares, total, wall, row, i = 0, sum = -1) =
    let(s = sum < 0 ? _rb_sum(shares) : sum)
    i >= len(shares) ? true :
    let(mm = shares[i] / s * total)
    assert(mm + 1e-6 >= wall, str("divider row ", row, " column ", i + 1, " is ", _rb_mm(mm), " mm; minimum is dividerWallThickness (", wall, " mm)"))
    _rb_check_cols(shares, total, wall, row, i + 1, s);

function _rb_x_chain(ws, w) =
    len(ws) <= 1 ? [] :
    let(pos = ws[0] / _rb_sum(ws) * w)
    ["x", pos, [], _rb_x_chain(_rb_rest(ws), w - pos)];

function _rb_one_row(widths, w, wall, row_i) =
    let(ws = _rb_used(widths, 0, str("dividerRow", row_i + 1, "Widths")))
    assert(len(ws) > 0, str("divider row ", row_i + 1, " has a height share but no column widths"))
    assert(_rb_check_cols(ws, w, wall, row_i + 1))
    _rb_x_chain(ws, w);

function _rb_y_chain(hs, width_rows, row_i, w, l, wall) =
    len(hs) <= 1 ? _rb_one_row(width_rows[row_i], w, wall, row_i) :
    let(pos = hs[0] / _rb_sum(hs) * l)
    ["y", pos,
        _rb_one_row(width_rows[row_i], w, wall, row_i),
        _rb_y_chain(_rb_rest(hs), width_rows, row_i + 1, w, l - pos, wall)];

function rb_row_layout(heights, width_rows, interior_w, interior_l, wall) =
    let(hs = _rb_used(heights, 0, "dividerRowHeights"))
    len(hs) == 0 ? [] :
    assert(_rb_check_heights(hs, interior_l, wall))
    _rb_y_chain(hs, width_rows, 0, interior_w, interior_l, wall);

function rb_row_count(node) =
    rb_is_leaf(node) ? 1 :
    node[0] == "y" ? rb_row_count(node[2]) + rb_row_count(node[3]) : 1;

function rb_col_count(node) =
    rb_is_leaf(node) ? 1 :
    node[0] == "x" ? rb_col_count(node[2]) + rb_col_count(node[3]) : 1;

function _rb_band_node(node, row) =
    row <= 1 ? (rb_is_leaf(node) || node[0] != "y" ? node : node[2]) :
    _rb_band_node(node[3], row - 1);

function _rb_row_box(node, row, xmin, ymin, xmax, ymax) =
    row <= 1 ?
        (rb_is_leaf(node) || node[0] != "y" ? [xmin, ymin, xmax, ymax] : [xmin, ymin, xmax, ymin + node[1]]) :
    _rb_row_box(node[3], row - 1, xmin, ymin + node[1], xmax, ymax);

function _rb_col_box(node, col, xmin, ymin, xmax, ymax) =
    col <= 1 ?
        (rb_is_leaf(node) || node[0] != "x" ? [xmin, ymin, xmax, ymax] : [xmin, ymin, xmin + node[1], ymax]) :
    _rb_col_box(node[3], col - 1, xmin + node[1], ymin, xmax, ymax);

function rb_cell_rect(tree, row, col, w, l) =
    let(rows = rb_row_count(tree))
    assert(row >= 1 && row <= rows, str("tool insert row ", row, " does not exist; this layout has ", rows, " rows"))
    let(band = _rb_band_node(tree, row))
    let(cols = rb_col_count(band))
    assert(col >= 1 && col <= cols, str("tool insert column ", col, " does not exist; this row has ", cols, " columns"))
    let(box = _rb_row_box(tree, row, 0, 0, w, l))
    _rb_col_box(band, col, box[0], box[1], box[2], box[3]);

function _rb_clear_band(node, row) =
    row <= 1 ?
        (rb_is_leaf(node) || node[0] != "y" ? [] : ["y", node[1], [], node[3]]) :
    ["y", node[1], node[2], _rb_clear_band(node[3], row - 1)];

function rb_clear_cell(tree, row, col) =
    let(box = rb_cell_rect(tree, row, col, 1, 1))
    assert(box[0] >= 0)
    _rb_clear_band(tree, row);

function _rb_rot(x, y, deg) = [x * cos(deg) - y * sin(deg), x * sin(deg) + y * cos(deg)];

function rb_outline_aabb(x, y, w, h, rot, scale, clearance) =
    let(
        ww = w * scale, hh = h * scale, c = clearance,
        p0 = _rb_rot(-c, -c, rot),
        p1 = _rb_rot(ww + c, -c, rot),
        p2 = _rb_rot(ww + c, hh + c, rot),
        p3 = _rb_rot(-c, hh + c, rot),
        xs = [p0[0], p1[0], p2[0], p3[0]],
        ys = [p0[1], p1[1], p2[1], p3[1]]
    )
    [x + min(xs), y + min(ys), x + max(xs), y + max(ys)];

function rb_notch_aabb(x, y, w, h, rot, scale, notch_w, notch_d) =
    let(box = rb_outline_aabb(x, y, w, h, rot, scale, 0), cx = (box[0] + box[2]) / 2)
    [cx - notch_w / 2, box[1], cx + notch_w / 2, box[1] + notch_d];

function _rb_fit_edge(slot, box, target, what) =
    assert(box[2] <= target[2] + 0.001, str("tool slot ", slot, " ", what, "extends past the compartment: right edge ", _rb_mm(box[2]), " mm, compartment ends at ", _rb_mm(target[2]), " mm"))
    assert(box[0] >= target[0] - 0.001, str("tool slot ", slot, " ", what, "extends past the compartment: left edge ", _rb_mm(box[0]), " mm, compartment starts at ", _rb_mm(target[0]), " mm"))
    assert(box[3] <= target[3] + 0.001, str("tool slot ", slot, " ", what, "extends past the compartment: back edge ", _rb_mm(box[3]), " mm, compartment ends at ", _rb_mm(target[3]), " mm"))
    assert(box[1] >= target[1] - 0.001, str("tool slot ", slot, " ", what, "extends past the compartment: front edge ", _rb_mm(box[1]), " mm, compartment starts at ", _rb_mm(target[1]), " mm"))
    true;

function _rb_overlap(a0, a1, b0, b1) = a1 > b0 + 1e-6 && a0 < b1 - 1e-6;

function _rb_hits_wall(box, wall, thick) =
    wall[0] == "x" ?
        _rb_overlap(box[0], box[2], wall[1] - thick / 2, wall[1] + thick / 2) &&
            _rb_overlap(box[1], box[3], wall[4], wall[5]) :
        _rb_overlap(box[1], box[3], wall[1] - thick / 2, wall[1] + thick / 2) &&
            _rb_overlap(box[0], box[2], wall[2], wall[3]);

function _rb_cross_at(slot, box, walls, thick, i) =
    i >= len(walls) ? "" :
    _rb_hits_wall(box, walls[i], thick) ?
        str("tool slot ", slot, " crosses the divider at ", walls[i][0], "=", _rb_mm(walls[i][1])) :
        _rb_cross_at(slot, box, walls, thick, i + 1);

function rb_tool_file_ok(slot, file) =
    assert(file != "tools/_blank.svg", str("tool slot ", slot, " is on but still set to tools/_blank.svg"))
    true;

function rb_tool_size_ok(slot, w, h) =
    assert(w > 0 && h > 0, str("tool slot ", slot, " width and height must be the Inkscape page size in mm"))
    true;

function rb_tool_clearance_ok(slot, c) =
    assert(c >= 0, str("tool slot ", slot, " clearance is ", _rb_mm(c), " mm; use 0 or a positive gap"))
    true;

function rb_tool_depth_ok(slot, depth, mode, block, min_floor) =
    assert(depth > 0, str("tool slot ", slot, " cut depth must be > 0"))
    mode == 0 ?
        assert(block - depth + 1e-6 >= min_floor, str("tool slot ", slot, " cut depth ", _rb_mm(depth), " mm leaves ", _rb_mm(block - depth), " mm of floor; minimum is ", _rb_mm(min_floor), " mm (block height ", _rb_mm(block), " mm)"))
        true :
        assert(depth + 1e-6 <= block - min_floor, str("tool slot ", slot, " cut depth ", _rb_mm(depth), " mm is deeper than the ", _rb_mm(block), " mm plate allows; minimum floor is ", _rb_mm(min_floor), " mm"))
        true;

function rb_tool_plate_ok(plate, interior_h, clearance) =
    let(limit = interior_h - clearance)
    assert(plate <= limit + 1e-6, str("tool pocket plate ", _rb_mm(plate), " mm is taller than the interior allows (", _rb_mm(limit), " mm)"))
    true;

function rb_tool_slot_fits(slot, x, y, w, h, rot, scale, clearance, notch, notch_w, notch_d, target, walls, thick) =
    let(box = rb_outline_aabb(x, y, w, h, rot, scale, clearance))
    assert(_rb_fit_edge(slot, box, target, ""))
    let(msg = _rb_cross_at(slot, box, walls, thick, 0))
    assert(msg == "", msg)
    notch ? _rb_fit_edge(slot, rb_notch_aabb(x, y, w, h, rot, scale, notch_w, notch_d), target, "finger notch ") :
    true;

function _rb_check_one_slot(slot, enabled, file, x, y, w, h, rot, depth, clearance, notch, target, walls, block_h) =
    !enabled ? true :
    assert(rb_tool_file_ok(slot, file))
    assert(rb_tool_size_ok(slot, w, h))
    assert(rb_tool_clearance_ok(slot, clearance))
    assert(rb_tool_depth_ok(slot, depth, toolBlockMode, block_h, toolMinPocketFloor))
    rb_tool_slot_fits(slot, x, y, w, h, rot, toolOutlineScale, clearance, notch, toolFingerNotchWidth, toolFingerNotchDepth, target, walls, dividerWallThickness);

function rb_check_insert(orig, kept) =
    !toolInsertEnabled ? true :
    assert(toolOutlineScale > 0, "tool outline scale must be > 0")
    assert(toolBlockMode == 0 ? true : rb_tool_plate_ok(toolPocketPlateMm, internalboxBottomHeightZMm, dividerTopClearance))
    let(
        target = toolInsertTarget == 0 ? [0, 0, internalBoxWidthXMm, internalboxLengthYMm] :
            rb_cell_rect(orig, toolInsertRow, toolInsertColumn, internalBoxWidthXMm, internalboxLengthYMm),
        walls = rb_walls(kept, 0, 0, internalBoxWidthXMm, internalboxLengthYMm),
        block_h = toolBlockMode == 0 ? internalboxBottomHeightZMm - dividerTopClearance : toolPocketPlateMm
    )
    assert(_rb_check_one_slot(1, tool1Enabled, tool1File, tool1XMm, tool1YMm, tool1WidthMm, tool1HeightMm, tool1Rotation, tool1CutDepthMm, tool1ClearanceMm, tool1FingerNotch, target, walls, block_h))
    assert(_rb_check_one_slot(2, tool2Enabled, tool2File, tool2XMm, tool2YMm, tool2WidthMm, tool2HeightMm, tool2Rotation, tool2CutDepthMm, tool2ClearanceMm, tool2FingerNotch, target, walls, block_h))
    assert(_rb_check_one_slot(3, tool3Enabled, tool3File, tool3XMm, tool3YMm, tool3WidthMm, tool3HeightMm, tool3Rotation, tool3CutDepthMm, tool3ClearanceMm, tool3FingerNotch, target, walls, block_h))
    assert(_rb_check_one_slot(4, tool4Enabled, tool4File, tool4XMm, tool4YMm, tool4WidthMm, tool4HeightMm, tool4Rotation, tool4CutDepthMm, tool4ClearanceMm, tool4FingerNotch, target, walls, block_h))
    true;

function rb_is_dxf(file) =
    let(n = len(file))
    n >= 4 && file[n - 4] == "." &&
        (file[n - 3] == "d" || file[n - 3] == "D") &&
        (file[n - 2] == "x" || file[n - 2] == "X") &&
        (file[n - 1] == "f" || file[n - 1] == "F");

// --- Validation ---

function _rb_count_walls(node) =
    rb_is_leaf(node) ? 0 : 1 + _rb_count_walls(node[2]) + _rb_count_walls(node[3]);

function _rb_validate_node(node, xmin, ymin, xmax, ymax, wall_thick, n_walls) =
    rb_is_leaf(node) ? n_walls :
    let(axis = node[0], pos_rel = node[1], lo = node[2], hi = node[3])
  axis == "y" ?
    let(span = ymax - ymin)
    let(pos_lo = pos_rel)
    let(pos_hi = span - pos_rel)
    assert(pos_lo >= wall_thick, "rb_validate: Y split too close to ymin")
    assert(pos_hi >= wall_thick, "rb_validate: Y split too close to ymax")
    let(pos = ymin + pos_rel)
    _rb_validate_node(hi, xmin, pos, xmax, ymax, wall_thick,
        _rb_validate_node(lo, xmin, ymin, xmax, pos, wall_thick, n_walls + 1)) :
    let(span = xmax - xmin)
    let(pos_lo = pos_rel)
    let(pos_hi = span - pos_rel)
    assert(pos_lo >= wall_thick, "rb_validate: X split too close to xmin")
    assert(pos_hi >= wall_thick, "rb_validate: X split too close to xmax")
    let(pos = xmin + pos_rel)
    _rb_validate_node(hi, pos, ymin, xmax, ymax, wall_thick,
        _rb_validate_node(lo, xmin, ymin, pos, ymax, wall_thick, n_walls + 1));


function _rb_wall_list(tree, xmin, ymin, xmax, ymax) =
    rb_walls(tree, xmin, ymin, xmax, ymax);

function _rb_near(a, b, eps = 0.001) = abs(a - b) < eps;

module rb_divider_column(w, d, h) {
    top_chamfer = min(w, d) * tan(30);
    chamfer_h = min(h - 0.02, top_chamfer);
    if (chamfer_h <= 0.01) {
        cube([w, d, h]);
    } else {
        difference() {
            cube([w, d, h]);
            translate([-0.01, -0.01, h - chamfer_h])
                rotate([30, 0, 0])
                    linear_extrude(w + 0.02)
                        square([d + 0.02, chamfer_h + 0.02]);
        }
    }
}

module rb_fused_divider_solids(tree, z_floor_top, z_tip, thick, xmin, ymin, xmax, ymax) {
    walls = _rb_wall_list(tree, xmin, ymin, xmax, ymax);
    z0 = min(z_floor_top, z_tip);
    z1 = max(z_floor_top, z_tip);
    for (w = walls) {
        ax = w[0];
        pos = w[1];
        cx0 = w[2];
        cx1 = w[3];
        cy0 = w[4];
        cy1 = w[5];
        ex0 = _rb_near(cx0, xmin) ? -rb_embed : (_rb_near(cy0, ymin) || _rb_near(cy1, ymax) ? -rb_embed : 0);
        ex1 = _rb_near(cx1, xmax) ? rb_embed : (_rb_near(cy0, ymin) || _rb_near(cy1, ymax) ? rb_embed : 0);
        ey0 = _rb_near(cy0, ymin) ? -rb_embed : 0;
        ey1 = _rb_near(cy1, ymax) ? rb_embed : 0;
        if (ax == "y") {
            ey0 = _rb_near(cy0, ymin) ? -rb_embed : -rb_embed;
            ey1 = _rb_near(cy1, ymax) ? rb_embed : rb_embed;
            translate([cx0 + ex0, pos - thick / 2 + ey0, z0])
                rb_divider_column(cx1 - cx0 + (-ex0) + ex1, thick + (-ey0) + ey1, z1 - z0);
        } else {
            ex0 = _rb_near(cx0, xmin) ? -rb_embed : -rb_embed;
            ex1 = _rb_near(cx1, xmax) ? rb_embed : rb_embed;
            translate([pos - thick / 2 + ex0, cy0 + ey0, z0])
                rb_divider_column(thick + (-ex0) + ex1, cy1 - cy0 + (-ey0) + ey1, z1 - z0);
        }
    }
}

function rb_validate(node, w, l, wall_thick, clearance, clearance_bottom, clearance_top, embed, wall_width) =
    assert(wall_thick >= 1.0, "rb_validate: dividerWallThickness must be >= 1.0")
    assert(clearance > 0, "rb_validate: dividerTopClearance must be > 0")
    assert(embed < wall_width, "rb_validate: rb_embed must be < boxWallWidthMm")
    assert(clearance + embed < clearance_bottom, "rb_validate: clearance + embed vs bottom height")
    assert(clearance + embed < clearance_top, "rb_validate: clearance + embed vs lid height")
    let(n = _rb_validate_node(node, 0, 0, w, l, wall_thick, 0))
    assert(n <= 32, str("rb_validate: too many walls (", n, ", max 32)"))
    true;

module rb_import_outline(file) {
    if (rb_is_dxf(file))
        import(file, layer = "0");
    else
        import(file, dpi = toolSvgDpi);
}

module rb_grow_2d(clearance) {
    if (clearance > 0)
        offset(delta = clearance) children();
    else
        children();
}

module rb_outline_2d(file, x, y, rot, clearance) {
    translate([boxWallWidthMm + x, boxWallWidthMm + y])
        rotate([0, 0, rot])
            rb_grow_2d(clearance)
                scale([toolOutlineScale, toolOutlineScale])
                    rb_import_outline(file);
}

module rb_notch_2d(x, y, w, h, rot) {
    box = rb_notch_aabb(x, y, w, h, rot, toolOutlineScale, toolFingerNotchWidth, toolFingerNotchDepth);
    translate([boxWallWidthMm + box[0], boxWallWidthMm + box[1]])
        square([box[2] - box[0], box[3] - box[1]]);
}

module rb_cut_slot(file, x, y, rot, depth, clearance, notch, w, h) {
    z_floor = -(boxBottomHeightZMm - boxWallWidthMm);
    block_h = toolBlockMode == 0 ? internalboxBottomHeightZMm - dividerTopClearance : toolPocketPlateMm;
    z_top = z_floor + block_h;
    translate([0, 0, z_top - depth])
        linear_extrude(height = depth + 0.02, convexity = 8)
            union() {
                rb_outline_2d(file, x, y, rot, clearance);
                if (notch)
                    rb_notch_2d(x, y, w, h, rot);
            }
}

module rb_wall_slots(tree, z0, z1) {
    gap = dividerWallThickness - 2 * rb_embed;
    if (gap > 0.05) {
        walls = rb_walls(tree, 0, 0, internalBoxWidthXMm, internalboxLengthYMm);
        for (wall = walls) {
            if (wall[0] == "x")
                translate([boxWallWidthMm + wall[1] - gap / 2, boxWallWidthMm + wall[4], z0])
                    cube([gap, max(wall[5] - wall[4], 0.01), z1 - z0]);
            else
                translate([boxWallWidthMm + wall[2], boxWallWidthMm + wall[1] - gap / 2, z0])
                    cube([max(wall[3] - wall[2], 0.01), gap, z1 - z0]);
        }
    }
}

module rb_tool_insert() {
    rect = toolInsertTarget == 0 ? [0, 0, internalBoxWidthXMm, internalboxLengthYMm] :
        rb_cell_rect(_rb_orig_tree, toolInsertRow, toolInsertColumn, internalBoxWidthXMm, internalboxLengthYMm);
    z_floor = -(boxBottomHeightZMm - boxWallWidthMm);
    block_h = toolBlockMode == 0 ? internalboxBottomHeightZMm - dividerTopClearance : toolPocketPlateMm;
    difference() {
        translate([boxWallWidthMm + rect[0] - rb_embed, boxWallWidthMm + rect[1] - rb_embed, z_floor - rb_embed])
            cube([
                rect[2] - rect[0] + 2 * rb_embed,
                rect[3] - rect[1] + 2 * rb_embed,
                block_h + rb_embed
            ]);
        rb_wall_slots(_bottom_divider_tree, z_floor - rb_embed - 0.01, z_floor + block_h + 0.02);
        // Separate ifs so a disabled slot does not import().
        if (tool1Enabled)
            rb_cut_slot(tool1File, tool1XMm, tool1YMm, tool1Rotation, tool1CutDepthMm, tool1ClearanceMm, tool1FingerNotch, tool1WidthMm, tool1HeightMm);
        if (tool2Enabled)
            rb_cut_slot(tool2File, tool2XMm, tool2YMm, tool2Rotation, tool2CutDepthMm, tool2ClearanceMm, tool2FingerNotch, tool2WidthMm, tool2HeightMm);
        if (tool3Enabled)
            rb_cut_slot(tool3File, tool3XMm, tool3YMm, tool3Rotation, tool3CutDepthMm, tool3ClearanceMm, tool3FingerNotch, tool3WidthMm, tool3HeightMm);
        if (tool4Enabled)
            rb_cut_slot(tool4File, tool4XMm, tool4YMm, tool4Rotation, tool4CutDepthMm, tool4ClearanceMm, tool4FingerNotch, tool4WidthMm, tool4HeightMm);
    }
}



// ***************************
// **** Modules/Functions **** 
// ***************************

module BoxTop(isStdHinge) {
    difference() {
        union() {
            rotate([180,0,0]) translate([0,-boxLengthYMm,-openingTolerance]) 
                difference() {
                    BoxShellBase(boxTopHeightZMm);
                    if(isFeetAdded) {
                        FeetCutout(boxTopHeightZMm);
                    }
                    
                    // remove back rim ??? 
                    // TODO: Is this needed?
                    //translate([-.1,boxLengthYMm,openingTolerance-.1]) cube([boxWidthXMm+.2, rimWidthMm+.2, rimHeightMm+.2]);
                }
            // Lid bead seal omitted here (subtractive groove lives on the bottom shell).
            translate([boxWidthXMm,0,0])
            rotate([0,0,180])
            translate([0,-boxLengthYMm,0]) // add back in the rim width
            rotate([180,0,0]) translate([0,-boxLengthYMm,-openingTolerance]) LatchMount(latchSupportTotalWidth, latchSupportWidth, latchScrewPositionPct, boxTopHeightZMm, latchSupportRadius, latchToloerance);
            
            if(isStdHinge) {
                TopStandardHinge();
            }
        };
        // TODO: Cut off anything over/under the top/bottom of the case
        translate([-(boxWidthXMm/2), -(boxLengthYMm/2), boxTopHeightZMm+openingTolerance]) cube([boxWidthXMm*2,boxLengthYMm*2, boxTopHeightZMm*10]);
        
        // TODO: Cut off anything in the inside of the case
        rotate([180,0,0]) translate([0,-boxLengthYMm,-openingTolerance]) 
            difference() {
                // Overlap the opening plane so the rim does not keep a paper-thin downward skin.
                translate([0,0,-(boxTopHeightZMm-boxWallWidthMm)+0.02])
                    cube([boxWidthXMm, boxLengthYMm, (boxTopHeightZMm-boxWallWidthMm)+0.03]);
                BoxShellBase(boxTopHeightZMm, boxChamferRadiusMm*2);
            }
    }
        rotate([180,0,0]) translate([0,-boxLengthYMm,-openingTolerance])
            rb_fused_divider_solids(
                _lid_divider_tree,
                -internalBoxTopHeightZMm - rb_embed,
                rb_divider_tip_z(dividerTopClearance),
                dividerWallThickness,
                boxWallWidthMm,
                boxWallWidthMm,
                boxWallWidthMm + internalBoxWidthXMm,
                boxWallWidthMm + internalboxLengthYMm);
}


module BoxBottom(isStdHinge) {
    render() union() {
        difference() {
            union() {
                BoxShellBase(boxBottomHeightZMm);
                LatchMount(latchSupportTotalWidth, latchSupportWidth, latchScrewPositionPct, boxBottomHeightZMm, latchSupportRadius, latchToloerance);
                
                if(isStdHinge) {
                    BotomStandardHinge();
                }
            }
            translate([-(boxWidthXMm/2), -(boxLengthYMm/2), -boxBottomHeightZMm*11]) cube([boxWidthXMm*2,boxLengthYMm*2, boxBottomHeightZMm*10]);
            
            if(boxSealType == 2) {
                BoxGasketSealExtrude(gasketSlotWidth,gasketSlotDepth,-(gasketSlotDepth/2)+.01);            
            }
            else {
                BoxCircularSealExtrude(boxCircularSealRadius,0.3*boxCircularSealRadius);
            }
            
            difference() {
                // Overlap the opening plane so the rim does not keep a paper-thin downward skin.
                translate([0,0,-(boxBottomHeightZMm-boxWallWidthMm)+0.02])
                    cube([boxWidthXMm, boxLengthYMm, (boxBottomHeightZMm-boxWallWidthMm)+0.03]);
                BoxShellBase(boxBottomHeightZMm, boxChamferRadiusMm);
            }
            if(isFeetAdded) {
                FeetCutout(boxBottomHeightZMm);
            }
        }
        rb_fused_divider_solids(
            _bottom_divider_tree,
            -(boxBottomHeightZMm - boxWallWidthMm) - rb_embed,
            rb_divider_tip_z(dividerTopClearance),
            dividerWallThickness,
            boxWallWidthMm,
            boxWallWidthMm,
            boxWallWidthMm + internalBoxWidthXMm,
            boxWallWidthMm + internalboxLengthYMm);
        if (toolInsertEnabled)
            rb_tool_insert();
    }
}





module FeetCutout(height) {
    translate([boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm,boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm,-(height+(feetInsertDepth+.1)-feetInsertDepth)]) rotate([0,0,0]) cube([feetwidthMm+(2*footInsertToleranceMm), feetLengthMm+(2*footInsertToleranceMm), feetInsertDepth+.1]);
    translate([boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm,boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm,-(height+(feetInsertDepth+.1)-feetInsertDepth)]) rotate([0,0,0]) cube([feetLengthMm+(2*footInsertToleranceMm), feetwidthMm+(2*footInsertToleranceMm),feetInsertDepth+.1]);

    translate([boxWidthXMm-(boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm),boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm,-(height+(feetInsertDepth+.1)-feetInsertDepth)]) rotate([0,0,90]) cube([feetwidthMm+(2*footInsertToleranceMm), feetLengthMm+(2*footInsertToleranceMm), feetInsertDepth+.1]);
    translate([boxWidthXMm-(boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm),boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm,-(height+(feetInsertDepth+.1)-feetInsertDepth)]) rotate([0,0,90]) cube([feetLengthMm+(2*footInsertToleranceMm), feetwidthMm+(2*footInsertToleranceMm),feetInsertDepth+.1]);

    translate([boxWidthXMm-(boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm),boxLengthYMm-(boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm),-(height+(feetInsertDepth+.1)-feetInsertDepth)]) rotate([0,0,180]) cube([feetwidthMm+(2*footInsertToleranceMm), feetLengthMm+(2*footInsertToleranceMm), feetInsertDepth+.1]);
    translate([boxWidthXMm-(boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm),boxLengthYMm-(boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm),-(height+(feetInsertDepth+.1)-feetInsertDepth)]) rotate([0,0,180]) cube([feetLengthMm+(2*footInsertToleranceMm), feetwidthMm+(2*footInsertToleranceMm),feetInsertDepth+.1]);

    translate([boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm,boxLengthYMm-(boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm),-(height+(feetInsertDepth+.1)-feetInsertDepth)]) rotate([0,0,270]) cube([feetwidthMm+(2*footInsertToleranceMm), feetLengthMm+(2*footInsertToleranceMm), feetInsertDepth+.1]);
    translate([boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm,boxLengthYMm-(boxChamferRadiusMm + additionaldistanceFromWallAfterChamferMm),-(height+(feetInsertDepth+.1)-feetInsertDepth)]) rotate([0,0,270]) cube([feetLengthMm+(2*footInsertToleranceMm), feetwidthMm+(2*footInsertToleranceMm),feetInsertDepth+.1]);
}

module CreateFeet() {
    if(isFeetAdded) {
        for (i =[1:4]) {
            translate([0,(-(feetLengthMm+2)*i)-10,0]) Foot();
        }
    }
}


module Foot() {
    rotate([-90,0,0])
        union() {
            translate([0,0,feetwidthMm])
                linear_extrude(feetLengthMm-feetwidthMm-(footInsertToleranceMm*2))
                    polygon([[footInsertToleranceMm,0],[(footInsertToleranceMm*2),(feetInsertDepth*2)+boxGapMm],[feetwidthMm-(footInsertToleranceMm*2),(feetInsertDepth*2)+boxGapMm],[feetwidthMm-footInsertToleranceMm,0]]);
            rotate([0,90,0])
                translate([-feetwidthMm,0,feetwidthMm])
                    linear_extrude(feetLengthMm-feetwidthMm-(footInsertToleranceMm*2))
                        polygon([[footInsertToleranceMm,0],[(footInsertToleranceMm*2),(feetInsertDepth*2)+boxGapMm],[feetwidthMm-(footInsertToleranceMm*2),(feetInsertDepth*2)+boxGapMm],[feetwidthMm-footInsertToleranceMm,0]]);
            translate([feetwidthMm,0,feetwidthMm])
                rotate([0,-90,0])
                    rotate([0,-90,-90])
                        rotate_extrude(angle = -90, $fn=8) 
                            rotate([0,0,0]) 
                                polygon([[footInsertToleranceMm,0],[(footInsertToleranceMm*2),(feetInsertDepth*2)+boxGapMm],[feetwidthMm-(footInsertToleranceMm*2),(    feetInsertDepth*2)+boxGapMm],[feetwidthMm-footInsertToleranceMm,0]]);
        }
    }





module BoxCircularSealExtrude(radius, zOffset) {

    pivotDistanceFromWall = max(boxChamferRadiusMm, boxWallWidthMm);

    translate([pivotDistanceFromWall,boxWallWidthMm-((boxWallWidthMm+rimWidthMm)/2),zOffset]) 
        rotate([0,90,0]) linear_extrude(boxWidthXMm-(2*pivotDistanceFromWall)) circle(radius, $fn=64);
    translate([pivotDistanceFromWall,boxLengthYMm-boxWallWidthMm+((boxWallWidthMm+rimWidthMm)/2),zOffset]) 
        rotate([0,90,0]) linear_extrude(boxWidthXMm-(2*pivotDistanceFromWall)) circle(radius, $fn=64);
    translate([boxWallWidthMm-((boxWallWidthMm+rimWidthMm)/2),pivotDistanceFromWall,zOffset]) 
        rotate([-90,0,0]) linear_extrude(boxLengthYMm-(2*pivotDistanceFromWall)) circle(radius, $fn=64);
    translate([boxWidthXMm-boxWallWidthMm+((boxWallWidthMm+rimWidthMm)/2),pivotDistanceFromWall,zOffset]) 
        rotate([-90,0,0]) linear_extrude(boxLengthYMm-(2*pivotDistanceFromWall)) circle(radius, $fn=64);

    translate([pivotDistanceFromWall,pivotDistanceFromWall,zOffset]) 
        rotate([0,0,180]) rotate_extrude(angle = 90, $fn=polyLvl) translate([(pivotDistanceFromWall+(pivotDistanceFromWall-boxWallWidthMm)+rimWidthMm)/2,0]) circle(radius, $fn=64);
    translate([pivotDistanceFromWall,boxLengthYMm-pivotDistanceFromWall,zOffset]) 
        rotate([0,0,90]) rotate_extrude(angle = 90, $fn=polyLvl) translate([(pivotDistanceFromWall+(pivotDistanceFromWall-boxWallWidthMm)+rimWidthMm)/2,0]) circle(radius, $fn=64);
    translate([pivotDistanceFromWall+boxWidthXMm-(2*pivotDistanceFromWall),boxLengthYMm-pivotDistanceFromWall,zOffset]) 
        rotate([0,0,0]) rotate_extrude(angle = 90, $fn=polyLvl) translate([(pivotDistanceFromWall+(pivotDistanceFromWall-boxWallWidthMm)+rimWidthMm)/2,0]) circle(radius, $fn=64);
    translate([pivotDistanceFromWall+boxWidthXMm-(2*pivotDistanceFromWall),pivotDistanceFromWall,zOffset]) 
        rotate([0,0,270]) rotate_extrude(angle = 90, $fn=polyLvl) translate([(pivotDistanceFromWall+(pivotDistanceFromWall-boxWallWidthMm)+rimWidthMm)/2,0]) circle(radius, $fn=64);

}

module BoxGasketSealExtrude(gasketWidth, gasketDepth, zOffset) {

    pivotDistanceFromWall = max(boxChamferRadiusMm, boxWallWidthMm);

    translate([pivotDistanceFromWall,boxWallWidthMm-((boxWallWidthMm+rimWidthMm)/2),zOffset]) 
        rotate([0,90,0]) rotate([0,0,90]) linear_extrude(boxWidthXMm-(2*pivotDistanceFromWall)) Gasket2D(gasketWidth, gasketDepth);
    translate([pivotDistanceFromWall,boxLengthYMm-boxWallWidthMm+((boxWallWidthMm+rimWidthMm)/2),zOffset]) 
        rotate([0,90,0]) rotate([0,0,90])linear_extrude(boxWidthXMm-(2*pivotDistanceFromWall)) Gasket2D(gasketWidth, gasketDepth);
    translate([boxWallWidthMm-((boxWallWidthMm+rimWidthMm)/2),pivotDistanceFromWall,zOffset]) 
        rotate([-90,0,0]) linear_extrude(boxLengthYMm-(2*pivotDistanceFromWall)) Gasket2D(gasketWidth, gasketDepth);
    translate([boxWidthXMm-boxWallWidthMm+((boxWallWidthMm+rimWidthMm)/2),pivotDistanceFromWall,zOffset]) 
        rotate([-90,0,0]) linear_extrude(boxLengthYMm-(2*pivotDistanceFromWall)) Gasket2D(gasketWidth, gasketDepth);

    translate([pivotDistanceFromWall,pivotDistanceFromWall,zOffset]) 
        rotate([0,0,180]) rotate_extrude(angle = 90, $fn=polyLvl) translate([(pivotDistanceFromWall+(pivotDistanceFromWall-boxWallWidthMm)+rimWidthMm)/2,0]) Gasket2D(gasketWidth, gasketDepth);
    translate([pivotDistanceFromWall,boxLengthYMm-pivotDistanceFromWall,zOffset]) 
        rotate([0,0,90]) rotate_extrude(angle = 90, $fn=polyLvl) translate([(pivotDistanceFromWall+(pivotDistanceFromWall-boxWallWidthMm)+rimWidthMm)/2,0]) Gasket2D(gasketWidth, gasketDepth);
    translate([pivotDistanceFromWall+boxWidthXMm-(2*pivotDistanceFromWall),boxLengthYMm-pivotDistanceFromWall,zOffset]) 
        rotate([0,0,0]) rotate_extrude(angle = 90, $fn=polyLvl) translate([(pivotDistanceFromWall+(pivotDistanceFromWall-boxWallWidthMm)+rimWidthMm)/2,0]) Gasket2D(gasketWidth, gasketDepth);
    translate([pivotDistanceFromWall+boxWidthXMm-(2*pivotDistanceFromWall),pivotDistanceFromWall,zOffset]) 
        rotate([0,0,270]) rotate_extrude(angle = 90, $fn=polyLvl) translate([(pivotDistanceFromWall+(pivotDistanceFromWall-boxWallWidthMm)+rimWidthMm)/2,0]) Gasket2D(gasketWidth, gasketDepth);

}

module Gasket2D(gasketWidth, gasketDepth) {
    
    translate([-gasketWidth/2, -gasketDepth/2]) square([gasketWidth,gasketDepth]);
    
    // Old version... too hard to get the gasket in
    //translate([-boxCircularSealRadius,-boxCircularSealRadius]) polygon([[0,boxCircularSealRadius],[0.2,(boxCircularSealRadius*2)],[((boxCircularSealRadius*2)-0.2),(boxCircularSealRadius*2)],[(boxCircularSealRadius*2),boxCircularSealRadius],[((boxCircularSealRadius*2)-0.2),0],[0.2,0]]);
}


module StandardLatch(latchSupportTotalWidth, latchSupportWidth, latchScrewPositionPct, topCaseHeight, bottomCaseHeight, latchSupportRadius, latchToloerance) {
    
    latchPolyLvl = polyLvl <= 8 ? 8 : polyLvl;
    
    latchInsideWidthMm = latchSupportTotalWidth - (2*latchSupportWidth) - (2*latchToloerance);

    latchSpacing = (boxWidthXMm - (numberOfLatches*latchSupportTotalWidth)) / (numberOfLatches + 1);

   
    //StandardLatch2D(latchSupportTotalWidth, latchSupportWidth, latchScrewPositionPct, topCaseHeight, bottomCaseHeight, latchSupportRadius, latchToloerance);
                    

    translate([boxWidthXMm,0,0])
    rotate([0,0,180])
    translate([0,-boxLengthYMm,0]) // add back in the rim width
    translate([0,rimWidthMm,0]) // add back in the rim width
        for (h =[1:numberOfLatches]) { 
            
            actualLatchCenterOffsetMm = 
                h < (numberOfLatches+1)/2 
                    ? -latchCenterOffsetMm 
                    : h == (numberOfLatches+1)/2
                        ? 0
                        : latchCenterOffsetMm;
            latchX = (h*latchSpacing)+((h-1)*latchSupportTotalWidth)+latchSupportWidth+latchToloerance+actualLatchCenterOffsetMm;
            
            if(viewBoxClosed) {
                // Generate the latches as if they are connected to the case
translate([latchX, boxLengthYMm+latchSupportRadius, openingTolerance + latchScrewOffsetMm])
                    rotate([90,0,90])
                        linear_extrude(latchInsideWidthMm)
                            StandardLatch2D(latchSupportTotalWidth, latchSupportWidth, latchScrewPositionPct, topCaseHeight, bottomCaseHeight, latchSupportRadius, latchToloerance);
            }
            else {
                // Generate the latches for printing
                translate([latchSupportRadius*4*h,boxLengthYMm+bottomCaseHeight+(topCaseHeight*2)+(latchSupportRadius*2),0])
                    linear_extrude(latchInsideWidthMm)
                        StandardLatch2D(latchSupportTotalWidth, latchSupportWidth, latchScrewPositionPct, topCaseHeight, bottomCaseHeight, latchSupportRadius, latchToloerance);
            }
        }
}



module StandardLatch2D(latchSupportTotalWidth, latchSupportWidth, latchScrewPositionPct, topCaseHeight, bottomCaseHeight, latchSupportRadius, latchToloerance) {
    latchPolyLvl = polyLvl <= 8 ? 8 : polyLvl;
    
    latchInsideWidthMm = latchSupportTotalWidth - (2*latchSupportWidth) - (2*latchToloerance);

    latchSpacing = (boxWidthXMm - (numberOfLatches*latchSupportTotalWidth)) / (numberOfLatches + 1);

    rimChamferPositionAdj = rimWidthMm * tan(67.5);
    rimChamferRadius = sqrt(rimChamferPositionAdj^2+rimChamferPositionAdj^2);
  
    //rimCutoutPositionAdj = rimChamferPositionAdj+rimHeightMm+(openingTolerance/2)+1;
    //rimCutoutRadius = sqrt(rimCutoutPositionAdj^2+rimCutoutPositionAdj^2);

    
    rimCutoutPositionAdj = rimWidthMm;
    rimCutoutRadius = (rimWidthMm*1.5)+rimHeightMm;

    difference() {
 union() {
            circle(latchSupportRadius, $fn=latchPolyLvl);
            // Replace height-based math with (latchScrewOffsetMm * 2)
            translate([0,-(latchScrewOffsetMm * 2) - openingTolerance]) circle(latchSupportRadius, $fn=latchPolyLvl);
            translate([-latchSupportRadius,-(latchScrewOffsetMm * 2) - openingTolerance]) square([latchSupportRadius*2, (latchScrewOffsetMm * 2) + openingTolerance]);
         
            translate([0,-(latchScrewOffsetMm * 2) - openingTolerance])
            rotate(-(90-latchOpenerAngle))
                translate([0,latchScrewLargeRadiusMm])
                    union() {
                        latchOpenerLength = (latchSupportRadius-latchScrewLargeRadiusMm)*2;
                        square([latchOpenerLength*latchOpenerLengthMultiplier, (latchSupportRadius-latchScrewLargeRadiusMm)]);
                        translate([latchOpenerLength*latchOpenerLengthMultiplier, (latchSupportRadius-latchScrewLargeRadiusMm)/2]) circle((latchSupportRadius-latchScrewLargeRadiusMm)/2, $fn=latchPolyLvl);
                    }
        }
        
        // Cutout the screw holes
        circle(latchScrewLargeRadiusMm, $fn=100);
        translate([0,-(latchScrewOffsetMm * 2) - openingTolerance]) circle(latchScrewLargeRadiusMm, $fn=100);
        
        translate([0,-(latchScrewOffsetMm * 2) - openingTolerance]) 
            rotate(-45)
                translate([-latchSupportRadius*4,-latchScrewLargeRadiusMm])
                    square([latchSupportRadius*4,latchScrewLargeRadiusMm*2]);
        translate([0,-(latchScrewOffsetMm * 2) - openingTolerance]) 
            rotate(latchClipCutoutAngle)
                translate([-latchSupportRadius*4,0])
                    square([latchSupportRadius*4,latchSupportRadius*4]);
        
        translate([-latchSupportRadius-rimCutoutPositionAdj,(-(latchScrewOffsetMm * 2) - openingTolerance)/2]) 
        circle(r = rimCutoutRadius, $fn=latchPolyLvl*2);

    }

}



module LatchMount(latchSupportTotalWidth, latchSupportWidth, latchScrewPositionPct, caseSectionHeight, latchSupportRadius, latchToloerance) {
    
    latchPolyLvl = polyLvl <= 8 ? 8 : polyLvl;
    latchInsideWidthMm = latchSupportTotalWidth - (2*latchSupportWidth) - (2*latchToloerance);
    latchSpacing = (boxWidthXMm - (numberOfLatches*latchSupportTotalWidth)) / (numberOfLatches + 1);

    translate([boxWidthXMm,0,0])
    rotate([0,0,180])
    translate([0,-boxLengthYMm,0]) // add back in the rim width
        union() {
            for (h =[1:numberOfLatches]) { 
                
                actualLatchCenterOffsetMm = 
                    h < (numberOfLatches+1)/2 
                        ? -latchCenterOffsetMm 
                        : h == (numberOfLatches+1)/2
                            ? 0
                            : latchCenterOffsetMm;
                latchMountX = (h*latchSpacing)+((h-1)*latchSupportTotalWidth)+latchSupportWidth+latchToloerance+actualLatchCenterOffsetMm;
                
                difference () {
                    union() {
                        // Main latch cylinder
                        translate([latchMountX-(latchSupportWidth+latchToloerance), (boxLengthYMm+latchSupportRadius)+rimWidthMm, -latchScrewOffsetMm]) rotate([0,90,0])
                            cylinder(latchSupportWidth,latchSupportRadius,latchSupportRadius, $fn=latchPolyLvl);
                        translate([latchMountX+latchInsideWidthMm+latchToloerance,(boxLengthYMm+latchSupportRadius)+rimWidthMm,-latchScrewOffsetMm]) rotate([0,90,0])
                            cylinder(latchSupportWidth,latchSupportRadius,latchSupportRadius, $fn=latchPolyLvl);
                        
                        // ribs
                        translate([latchMountX-latchToloerance,boxLengthYMm+(latchSupportRadius*2)+rimWidthMm,-latchScrewOffsetMm]) rotate([90,0,-90]) linear_extrude(latchSupportWidth) square([(latchSupportRadius*2)+rimWidthMm, latchScrewOffsetMm]);
                        translate([latchMountX+latchInsideWidthMm+latchToloerance+latchSupportWidth,boxLengthYMm+(latchSupportRadius*2)+rimWidthMm,-latchScrewOffsetMm]) rotate([90,0,-90]) linear_extrude(latchSupportWidth) square([(latchSupportRadius*2)+rimWidthMm, latchScrewOffsetMm]);
                        
                        translate([latchMountX-latchToloerance,boxLengthYMm-(boxChamferRadiusMm),0]) rotate([90,0,-90]) linear_extrude(latchSupportWidth) Wall2D(boxWallWidthMm, (rimWidthMm*2), caseSectionHeight, false);
                        translate([latchMountX+latchInsideWidthMm+latchToloerance+latchSupportWidth,boxLengthYMm-(boxChamferRadiusMm),0]) rotate([90,0,-90]) linear_extrude(latchSupportWidth) Wall2D(boxWallWidthMm, (rimWidthMm*2), caseSectionHeight, false);
                        
                        // Attach the hinge to the top
                        adjustment = sqrt((latchSupportRadius^2)/2);
                        hingeConnectorHeight = sqrt(latchSupportRadius^2+latchSupportRadius^2) + (latchSupportRadius-adjustment);    
                        
                        difference() {
                            union() {
                                translate([0, adjustment+rimWidthMm, -(latchSupportRadius-adjustment)-(2*adjustment)-latchScrewOffsetMm])
                                    translate([latchMountX-(latchSupportWidth+latchToloerance),(boxLengthYMm+latchSupportRadius),latchSupportRadius])
                                        rotate([45,0,0])
                                            translate([0,-latchSupportRadius*6,0])
                                                cube([latchSupportWidth, latchSupportRadius*6, hingeConnectorHeight]);
                                translate([0, adjustment+rimWidthMm, -(latchSupportRadius-adjustment)-(2*adjustment)-latchScrewOffsetMm])
                                    translate([latchMountX+latchInsideWidthMm+latchToloerance,(boxLengthYMm+latchSupportRadius),latchSupportRadius])
                                        rotate([45,0,0])
                                            translate([0,-latchSupportRadius*6,0])
                                                cube([latchSupportWidth, latchSupportRadius*6, hingeConnectorHeight]);
                            }                   
                        }
                    };
                    // Cut the screw hole out
                    translate([latchMountX-((latchSupportWidth+latchToloerance)+.1),boxLengthYMm+latchSupportRadius+rimWidthMm,-latchScrewOffsetMm]) rotate([0,90,0])
                        cylinder(latchInsideWidthMm+(latchSupportWidth*2)+(latchToloerance*2)+.2,latchScrewSmallRadiusMm,latchScrewSmallRadiusMm, $fn=100);
                }
            }       
        }
}



module BotomStandardHinge() {
    
    hingePolyLvl = polyLvl <= 8 ? 8 : polyLvl;
    
    hingeInsideWidthMm = hingeTotalWidthMm - (2*hingeOutsideWidth) - (2*hingeToleranceMm);

    hingeSpacing = (boxWidthXMm - (numberOfHinges*hingeTotalWidthMm)) / (numberOfHinges + 1);

    translate([0,rimWidthMm,0]) // add back in the rim width
        for (h =[1:numberOfHinges]) { 
            
            actualHingeCenterOffsetMm = 
                h < (numberOfHinges+1)/2 
                    ? -hingeCenterOffsetMm 
                    : h == (numberOfHinges+1)/2
                        ? 0
                        : hingeCenterOffsetMm;
            hingeX = (h*hingeSpacing)+((h-1)*hingeTotalWidthMm)+hingeOutsideWidth+hingeToleranceMm+actualHingeCenterOffsetMm;
            
            difference () {
                union() {
                    // Main hinge cylinder
                    translate([hingeX-(hingeOutsideWidth+hingeToleranceMm),boxLengthYMm+hingeRadiusMm+openingTolerance,openingTolerance/2]) rotate([0,90,0])
                        cylinder(hingeOutsideWidth,hingeRadiusMm,hingeRadiusMm, $fn=hingePolyLvl);
                    translate([hingeX+hingeInsideWidthMm+hingeToleranceMm,boxLengthYMm+hingeRadiusMm+openingTolerance,openingTolerance/2]) rotate([0,90,0])
                        cylinder(hingeOutsideWidth,hingeRadiusMm,hingeRadiusMm, $fn=hingePolyLvl);
                    
                    
                    // ribs
                    translate([hingeX-hingeToleranceMm,boxLengthYMm-(boxChamferRadiusMm+rimWidthMm),0]) rotate([90,0,-90]) linear_extrude(hingeOutsideWidth) Wall2D(boxWallWidthMm, supportRibThickness, boxBottomHeightZMm, false);
                    translate([hingeX+hingeInsideWidthMm+hingeToleranceMm+hingeOutsideWidth,boxLengthYMm-(boxChamferRadiusMm+rimWidthMm),0]) rotate([90,0,-90]) linear_extrude(hingeOutsideWidth) Wall2D(boxWallWidthMm, supportRibThickness, boxBottomHeightZMm, false);
                    
                    // Attach the hinge to the top
                    adjustment = sqrt((hingeRadiusMm^2)/2);
                    hingeConnectorHeight = sqrt(hingeRadiusMm^2+hingeRadiusMm^2) + (hingeRadiusMm-adjustment);    
                    
                    difference() {
                        union() {
                            translate([0, adjustment, -(hingeRadiusMm-adjustment)-(2*adjustment)])
                                translate([hingeX-(hingeOutsideWidth+hingeToleranceMm),(boxLengthYMm+openingTolerance+hingeRadiusMm),hingeRadiusMm+(openingTolerance/2)])
                                    rotate([45,0,0])
                                        translate([0,-hingeRadiusMm*6,0])
                                            cube([hingeOutsideWidth, hingeRadiusMm*6, hingeConnectorHeight]);
                            translate([0, adjustment, -(hingeRadiusMm-adjustment)-(2*adjustment)])
                                translate([hingeX+hingeInsideWidthMm+hingeToleranceMm,(boxLengthYMm+openingTolerance+hingeRadiusMm),hingeRadiusMm+(openingTolerance/2)])
                                    rotate([45,0,0])
                                        translate([0,-hingeRadiusMm*6,0])
                                            cube([hingeOutsideWidth, hingeRadiusMm*6, hingeConnectorHeight]);
                        } 
                    }
                };
                // Cut the screw hole out
                translate([hingeX-((hingeOutsideWidth+hingeToleranceMm)+.1),boxLengthYMm+hingeRadiusMm+openingTolerance,openingTolerance/2]) rotate([0,90,0])
                    cylinder(hingeInsideWidthMm+(hingeOutsideWidth*2)+(hingeToleranceMm*2)+.2,hingeScrewSmallRadiusMm,hingeScrewSmallRadiusMm, $fn=100);
            }
        }
}



module TopStandardHinge() {
    
    hingePolyLvl = polyLvl <= 8 ? 8 : polyLvl;
    
    hingeInsideWidthMm = hingeTotalWidthMm - (2*hingeOutsideWidth) - (2*hingeToleranceMm);

    hingeSpacing = (boxWidthXMm - (numberOfHinges*hingeTotalWidthMm)) / (numberOfHinges + 1);

    translate([0,rimWidthMm,0]) // add back in the rim width
        for (h =[1:numberOfHinges]) {
            actualHingeCenterOffsetMm = 
                h < (numberOfHinges+1)/2 
                    ? -hingeCenterOffsetMm 
                    : h == (numberOfHinges+1)/2
                        ? 0
                        : hingeCenterOffsetMm;
            hingeX = (h*hingeSpacing)+((h-1)*hingeTotalWidthMm)+hingeOutsideWidth+hingeToleranceMm+actualHingeCenterOffsetMm;
            
            difference () {
                union() {
                    // Main hinge cylinder
                    translate([hingeX,boxLengthYMm+hingeRadiusMm+openingTolerance,openingTolerance/2]) rotate([0,90,0])
                        cylinder(hingeInsideWidthMm,hingeRadiusMm,hingeRadiusMm, $fn=hingePolyLvl);
                      
                    // support ribs
                    translate([0,boxLengthYMm-2,openingTolerance]) rotate([180,0,0]) translate([hingeX,boxChamferRadiusMm,0]) rotate([90,0,90]) linear_extrude(hingeInsideWidthMm) Wall2D(boxWallWidthMm, supportRibThickness, boxTopHeightZMm, false);
                    
                    // Attach the hinge to the top
                    adjustment = sqrt((hingeRadiusMm^2)/2);
                    hingeConnectorHeight = sqrt(hingeRadiusMm^2+hingeRadiusMm^2) + (hingeRadiusMm-adjustment);                  
                    difference() {
                        translate([0, adjustment, -(hingeRadiusMm-adjustment)])
                            translate([hingeX,(boxLengthYMm+openingTolerance+hingeRadiusMm),hingeRadiusMm+(openingTolerance/2)])
                                rotate([-45,0,0])
                                    translate([0,-hingeRadiusMm*6,-hingeConnectorHeight])
                                        cube([hingeInsideWidthMm, hingeRadiusMm*6, hingeConnectorHeight]);
                    }
                };
                // Cut the screw hole out
                translate([hingeX-.1,boxLengthYMm+hingeRadiusMm+openingTolerance,openingTolerance/2]) rotate([0,90,0])
                    cylinder(hingeInsideWidthMm+.2,hingeScrewLargeRadiusMm,hingeScrewLargeRadiusMm, $fn=100);
            }
        }
}

module BoxShellBase(height, additionalShellThickness = 0) {
    // Bottom
    translate([boxChamferRadiusMm,boxChamferRadiusMm,-height]) cube([boxWidthXMm-(2*boxChamferRadiusMm), boxLengthYMm-(2*boxChamferRadiusMm), boxWallWidthMm]);
    // Corners
    translate([boxChamferRadiusMm,boxChamferRadiusMm]) rotate_extrude(angle = 90, $fn=polyLvl) Wall2D(boxWallWidthMm, additionalShellThickness, height, true, true);
    translate([boxWidthXMm,0,0]) rotate([0,0,90]) translate([boxChamferRadiusMm,boxChamferRadiusMm]) rotate_extrude(angle = 90, $fn=polyLvl) Wall2D(boxWallWidthMm, additionalShellThickness, height, true, true);
    translate([boxWidthXMm,boxLengthYMm,0]) rotate([0,0,180]) translate([boxChamferRadiusMm,boxChamferRadiusMm]) rotate_extrude(angle = 90, $fn=polyLvl) Wall2D(boxWallWidthMm, additionalShellThickness, height, true, true);
    translate([0,boxLengthYMm,0]) rotate([0,0,270]) translate([boxChamferRadiusMm,boxChamferRadiusMm]) rotate_extrude(angle = 90, $fn=polyLvl) Wall2D(boxWallWidthMm, additionalShellThickness, height, true, true);
    // Sides
    translate([boxChamferRadiusMm,boxChamferRadiusMm]) rotate([90,0,90]) linear_extrude(boxWidthXMm-(2*boxChamferRadiusMm)) Wall2D(boxWallWidthMm, additionalShellThickness, height, true, false);
    translate([boxWidthXMm-boxChamferRadiusMm,boxLengthYMm-boxChamferRadiusMm]) rotate([90,0,270]) linear_extrude(boxWidthXMm-(2*boxChamferRadiusMm)) Wall2D(boxWallWidthMm, additionalShellThickness, height, true, false);
    translate([boxWidthXMm-boxChamferRadiusMm,boxChamferRadiusMm]) rotate([90,0,180]) linear_extrude(boxLengthYMm-(2*boxChamferRadiusMm)) Wall2D(boxWallWidthMm, additionalShellThickness, height, true, false);
    translate([boxChamferRadiusMm,boxLengthYMm-boxChamferRadiusMm]) rotate([90,0,0]) linear_extrude(boxLengthYMm-(2*boxChamferRadiusMm)) Wall2D(boxWallWidthMm, additionalShellThickness, height, true, false);
    
    
    // Add side ribs
    for(x = [1:numSideSupportRibs]) {
        actualRibCenterOffsetMm = 
                x < (numSideSupportRibs+1)/2 
                    ? -ribCenterOffsetMm 
                    : x == (numSideSupportRibs+1)/2
                        ? 0
                        : ribCenterOffsetMm;
        
        translate([boxChamferRadiusMm,(x*(((boxLengthYMm-(numSideSupportRibs*supportRibWidth))/(numSideSupportRibs+1))+supportRibWidth))+actualRibCenterOffsetMm,0]) rotate([90,0,0]) linear_extrude(supportRibWidth) Wall2D(boxWallWidthMm, supportRibThickness, height, false, false);
        translate([boxWidthXMm-boxChamferRadiusMm,(x*(((boxLengthYMm-(numSideSupportRibs*supportRibWidth))/(numSideSupportRibs+1))+supportRibWidth))-supportRibWidth+actualRibCenterOffsetMm,0]) rotate([90,0,180]) linear_extrude(supportRibWidth) Wall2D(boxWallWidthMm, supportRibThickness, height, false, false);
    }
    
}


module CaseHandle() {
    latchPolyLvl = polyLvl <= 8 ? 8 : polyLvl;
    latchInsideWidthMm = latchSupportTotalWidth - (2*latchSupportWidth) - (2*latchToloerance);
    latchSpacing = (boxWidthXMm - (numberOfLatches*latchSupportTotalWidth)) / (numberOfLatches + 1);

    latch1_Offset = 1 < (numberOfLatches+1)/2 ? -latchCenterOffsetMm : (1 == (numberOfLatches+1)/2 ? 0 : latchCenterOffsetMm);
    latch1_mountX = (1*latchSpacing)+((1-1)*latchSupportTotalWidth)+latchSupportWidth+latchToloerance+latch1_Offset;
    latch1_innerX = latch1_mountX + latchInsideWidthMm + latchToloerance + latchSupportWidth;

    latchLast_Offset = numberOfLatches < (numberOfLatches+1)/2 ? -latchCenterOffsetMm : (numberOfLatches == (numberOfLatches+1)/2 ? 0 : latchCenterOffsetMm);
    latchLast_mountX = (numberOfLatches*latchSpacing)+((numberOfLatches-1)*latchSupportTotalWidth)+latchSupportWidth+latchToloerance+latchLast_Offset;
    latchLast_innerX = latchLast_mountX - latchSupportWidth - latchToloerance;

    armLength = handleOutwardExtension;
    handlePrintHeight = latchScrewOffsetMm - ((0.5 - openingTolerance) / 2); 
    
    difference() {
        union() {
            // Left Arm
            hull() {
                translate([latch1_innerX, 0, handlePrintHeight]) rotate([0, 90, 0]) cylinder(h=handleThickness, r=latchSupportRadius, $fn=latchPolyLvl);
                translate([latch1_innerX, armLength, handlePrintHeight]) rotate([0, 90, 0]) cylinder(h=handleThickness, r=latchSupportRadius, $fn=latchPolyLvl);
                translate([latch1_innerX, -latchSupportRadius, 0]) cube([handleThickness, armLength + latchSupportRadius*2, 0.01]);
            }
            // Right Arm
            hull() {
                translate([latchLast_innerX - handleThickness, 0, handlePrintHeight]) rotate([0, 90, 0]) cylinder(h=handleThickness, r=latchSupportRadius, $fn=latchPolyLvl);
                translate([latchLast_innerX - handleThickness, armLength, handlePrintHeight]) rotate([0, 90, 0]) cylinder(h=handleThickness, r=latchSupportRadius, $fn=latchPolyLvl);
                translate([latchLast_innerX - handleThickness, -latchSupportRadius, 0]) cube([handleThickness, armLength + latchSupportRadius*2, 0.01]);
            }
            // Crossbar
            hull() {
                translate([latch1_innerX, armLength, handlePrintHeight]) rotate([0, 90, 0]) cylinder(h=latchLast_innerX - latch1_innerX, r=latchSupportRadius, $fn=latchPolyLvl);
                translate([latch1_innerX, armLength - latchSupportRadius, 0]) cube([latchLast_innerX - latch1_innerX, latchSupportRadius*2, 0.01]);
            }
        }
        // Extended screw holes for long latch screws to pass freely through
        translate([latch1_innerX - 0.1, 0, handlePrintHeight]) rotate([0, 90, 0]) cylinder(h=handleThickness + 0.2, r=latchScrewSmallRadiusMm + .05, $fn=100);
        translate([latchLast_innerX - handleThickness - 0.1, 0, handlePrintHeight]) rotate([0, 90, 0]) cylinder(h=handleThickness + 0.2, r=latchScrewSmallRadiusMm + .05 , $fn=100);
    }
}

// TODO: modify this so the bottom corner angle always starts at 60+ degrees.  be careful here so we can honor the poly counts and still connect correctly to the sides and bottom.
module Wall2D(wallThickness, additionalWallThickness, height, isRimIncluded, isForRotation) {
    
    floorChamferRadius = sqrt(boxChamferRadiusMm^2+boxChamferRadiusMm^2);
    chamferTrimAdj = sqrt(((floorChamferRadius-wallThickness)^2)/2);
    
    //floorAddition = sqrt(floorChamferRadius^2 - boxChamferRadiusMm^2);
    //floorAddition = boxChamferRadiusMm/2;
    floorAddition = (boxChamferRadiusMm*2)-floorChamferRadius;
    
    additionCount = ceil(additionalWallThickness/wallThickness);
    
    difference() {
        // make it wider if asked for
        for(cnt = [0:additionCount]) {
            additionXAdj = 
                (cnt == additionCount && ((additionalWallThickness % wallThickness) != 0)) 
                    ? ((cnt-1)*wallThickness)+(additionalWallThickness % wallThickness)
                    : cnt*wallThickness;
            
            translate([-boxChamferRadiusMm-(additionXAdj),0])
                union() {
                    // Add the rim
                    if(isRimIncluded) {
                        rimChamferPositionAdj = rimWidthMm * tan(67.5);
                        rimChamferRadius = sqrt(rimChamferPositionAdj^2+rimChamferPositionAdj^2);
                        
                        
                        difference() {
                            // 45 degree angle chamfer
                            translate([0,-rimHeightMm]) circle(r = rimWidthMm, $fn=4);
                            translate([-rimWidthMm-.1,-rimHeightMm]) square([(rimWidthMm*2)+.2, rimWidthMm+.1]);
                            translate([0,-rimHeightMm-rimWidthMm-.1]) square([(rimWidthMm*2)+.2, (rimWidthMm*2)+.2]);
                            
                            // This is the chamfer that allows the poly level to change.  No longer used... didn't like it
                            //translate([rimChamferPositionAdj,-rimHeightMm]) circle(r = rimChamferRadius, $fn=polyLvl*2);
                            //translate([rimChamferPositionAdj-rimChamferRadius-.1,-0]) square([(rimChamferRadius*2)+.2, rimChamferRadius+.1]);
                            //translate([0,-(rimChamferRadius*2)-.2]) square([(rimChamferRadius*2)+.2, (rimChamferRadius*2)+.2]);
                        }
                        
                        translate([-rimWidthMm,-rimHeightMm]) square([rimWidthMm,rimHeightMm]);
                    }

                    translate([0,-height + boxChamferRadiusMm]) square([wallThickness, height - boxChamferRadiusMm]);

                    //translate([boxChamferRadiusMm-floorAddition, -height]) square([floorAddition, wallThickness]);
                    translate([boxChamferRadiusMm-floorAddition, -height]) square([floorAddition, wallThickness]);

                    translate([floorChamferRadius, -height + boxChamferRadiusMm]) 
                        difference() {
                            translate([0,0]) circle(r = floorChamferRadius, $fn = polyLvl*2);
                            translate([0,0]) circle(r = (floorChamferRadius-wallThickness), $fn = polyLvl*2);
                            translate([-floorChamferRadius - .1,0]) square([(floorChamferRadius*2)+.2, floorChamferRadius + .1]);
                            if(wallThickness <= boxChamferRadiusMm) {
                                translate([-chamferTrimAdj,-floorChamferRadius - .1]) square([floorChamferRadius + chamferTrimAdj + .1, (floorChamferRadius*2)+.2]);
                            }
                            translate([-floorChamferRadius - .1,-(boxChamferRadiusMm*2)]) square([(floorChamferRadius*2)+.2, boxChamferRadiusMm]);
                        };
                }
        }      
        
        // NOT sure what this was for :-/
        //translate([(-wallThickness-additionalWallThickness)+chamferTrimAdj,-height]) square([(wallThickness+additionalWallThickness)-chamferTrimAdj, wallThickness]);
        
        // If we are rotating, we need to cut off any execess floor or wall on the other side of the y axis
        if(isForRotation) {
            translate([0,-(height*2)]) square([wallThickness*20, (height*2)+.2]);
        }
    }
}