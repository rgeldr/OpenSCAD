

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
// Should the gasket be generated.  NOTE: The gasket will still only be generated if the boxSealType is = 1 (Gasket)
generateGasket = true;
// Use this option to generate a test gasket and casket insert.  This is so you can do a small print to test your tolerances before printing a full box.  You will need to separate/split the in the slicer and print them one at a time.  This "sample case rim(where the gasket will be inserted)" in your filament of choice, and the gasket itself in TPU.
generateGasketTestObjects = true;
// Should the feet be generated.  This has NO effect on if the feet cutouts are added to the box top and bottom.  Those settings are below...  This just determines if the feet themselves get generated.
generateFeetIfSetInSettings = true;
// For empty box bottoms (boxes with no divider/section) should we generate a blank insert for later customization.
generateEmptyBottomBoxTPUInsert = false;
// For empty box tops (boxes with no divider/section) should we generate a blank insert for later customization.
generateEmptyTopBoxTPUInsert = false;


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

/*[Gridfinity Box Settings]*/
// *********************************
// **** Gridfinity Box Settingss **** 
// *********************************

/* [Gridfinity Box Settings] */
// Box width in Gridfinity units (42mm each)
gridUnitsX = 3; 
// Box length in Gridfinity units (42mm each)
gridUnitsY = 2;
// Internal base height in Gridfinity units (7mm each)
gridUnitsZ = 6;

// --- Auto-Calculated Gridfinity Dimensions ---
// Horizontal dimensions are multiples of 42mm, minus a 0.5mm tolerance gap.
boxWidthXMm = (gridUnitsX * 42) - 0.5;
boxLengthYMm = (gridUnitsY * 42) - 0.5;
// 4.75mm of the first 7mm layer is used up by the bin base[cite: 1].
internalboxBottomHeightZMm = (gridUnitsZ * 7) - 4.75;

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


/*[Box Divider Settings]*/
// **************************************
// **** Settings for adding dividers **** 
// **************************************

// Choose how you want to define your rows and columns
gridMode = 1; // [1:Uniform Grid, 2:Custom Array]

// --- UNIFORM GRID SETTINGS (Used if Grid Mode = 1) ---
// The number of horizontal rows (front to back)
numberOfRows = 3; // [1:20]
// The number of columns in EVERY row
columnsInEveryRow = 2; // [1:20]

// --- CUSTOM ARRAY SETTINGS (Used if Grid Mode = 2) ---
// Example: [1, 2, 4] means 1 col in row 1, 2 cols in row 2, and 4 cols in row 3.
customColumnsPerRow = [1, 2, 4];

// This is the number of vertical dividers to skip, this will effectively make a larger section followed by smaller ones
numBoxLengthYSectionsToSkip = 0; // 1
// The width of the divider walls
boxSectionSeparatorWidth = 1.2; // .1


/* [Hidden] */
// The Customizer ignores expressions, so these stay hidden and calculate automatically.
// This uses a conditional statement to check the gridMode variable[cite: 2].
columnsPerRow = gridMode == 1 ? [ for (i = [1 : numberOfRows]) columnsInEveryRow ] : customColumnsPerRow;

// The len() function calculates the length of whichever list was generated above[cite: 2].
boxLengthYSections = len(columnsPerRow);


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
requestedLatchCenterOffsetMm = 30;
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


/*[Box Full Fill Insert Settings]*/
// ***************************************************
// **** Settings for generating full case inserts **** 
// ***************************************************
// These inserts are meant for customizing your own holders for custom parts inside the cause.  Likely printed in TPU. The isert will fill the entire top/bottom of the case, then you can use the CAD tool of your choice to cutout spaces for your stuff.

// The tolerance around the TPU insert that can be customized to hold random shapes
insertTolerance = 0.1; // .05


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

// The width(X) of the inner box wall
internalBoxWidthXMm = boxWidthXMm - (2 * boxWallWidthMm);
// The length(Y) of the inner box wall
internalboxLengthYMm = boxLengthYMm - (2 * boxWallWidthMm);

// Define the missing internal top height (Lid depth in mm)
internalBoxTopHeightZMm = 15; // Feel free to adjust this value to change the lid depth!

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

// WALL Testing
//translate([0,-50,0]) rotate([90,0,0]) linear_extrude(6) Wall2D(boxWallWidthMm, 0, boxBottomHeightZMm, true, true);



// ***********************************************************************************************************
// **** Create the objects for testing the fit of the gasket on YOUR prinyter before printin the full box **** 
// ***********************************************************************************************************

if(generateGasketTestObjects) {
    // Add in the Gasket if needed
    if(boxSealType == 2) {
        translate([(-internalBoxWidthXMm/2)-(boxWallWidthMm*4), 0, rimHeightMm]) 
            difference() {
                BoxBottom(true);
                translate([-boxWidthXMm/2, -boxLengthYMm/2, (-2*boxBottomHeightZMm)-rimHeightMm]) cube([2*boxWidthXMm, 2*boxLengthYMm, 2*boxBottomHeightZMm]);
                translate([boxWallWidthMm*4, -boxLengthYMm/2, -boxBottomHeightZMm/2]) cube([2*boxWidthXMm, 2*boxLengthYMm, 2*boxBottomHeightZMm]);
                translate([-boxWidthXMm/2, boxLengthYMm/2, -boxBottomHeightZMm/2]) cube([2*boxWidthXMm, 2*boxLengthYMm, 2*boxBottomHeightZMm]);
            }
        
        translate([(-internalBoxWidthXMm/2)+(boxWallWidthMm*2), 0, 0])        
            difference() {       
                BoxGasketSealExtrude(gasketSlotWidth-(2*gasketTolerance),gasketSlotDepth+additionalGasketHeight,(gasketSlotDepth+additionalGasketHeight)/2);
                translate([-boxWidthXMm/2, -boxLengthYMm/2, (-2*boxBottomHeightZMm)-rimHeightMm]) cube([2*boxWidthXMm, 2*boxLengthYMm, 2*boxBottomHeightZMm]);
                translate([boxWallWidthMm*4, -boxLengthYMm/2, -boxBottomHeightZMm/2]) cube([2*boxWidthXMm, 2*boxLengthYMm, 2*boxBottomHeightZMm]);
                translate([-boxWidthXMm/2, boxLengthYMm/2, -boxBottomHeightZMm/2]) cube([2*boxWidthXMm, 2*boxLengthYMm, 2*boxBottomHeightZMm]);      }      
    }
}


// *****************************************
// **** Create the box components **** 
// *****************************************

closedBoxZOffset = viewBoxClosed ? boxBottomHeightZMm : 0;

translate([0,0,closedBoxZOffset])
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

// Create the inserts if requested
CreateBoxInserts(generateEmptyBottomBoxTPUInsert, generateEmptyTopBoxTPUInsert);


if(generateGasket) {
    // Add in the Gasket if needed
    if(boxSealType == 2) {  
        translate([0,0,boxBottomHeightZMm]) translate([0,(boxLengthYMm*2)+(hingeRadiusMm*5)+(latchSupportRadius*5),-boxBottomHeightZMm]) 
        BoxGasketSealExtrude(gasketSlotWidth-(2*gasketTolerance),gasketSlotDepth+additionalGasketHeight,(gasketSlotDepth+additionalGasketHeight)/2);                 
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
            BoxCircularSealExtrude(boxCircularSealRadius-openingTolerance,0.3*boxCircularSealRadius);
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
                translate([0,0,-(boxTopHeightZMm-boxWallWidthMm-.01)]) cube([boxWidthXMm, boxLengthYMm, boxTopHeightZMm-boxWallWidthMm-.02]);
                BoxShellBase(boxTopHeightZMm, boxChamferRadiusMm*2);
            }
    }
rotate([180,0,0]) translate([0,-boxLengthYMm,-openingTolerance]) 
        union() {
            // Add ", true" to the end of this next line!
            BoxLengthXSeparators(boxSectionSeparatorWidth,boxTopHeightZMm, false, true);
            BoxWidthYSeparators(boxSectionSeparatorWidth,boxTopHeightZMm, true);
    }
}

module BoxBottom(isStdHinge) {
    // Wrap everything in a union so the new base attaches to the hollowed shell
    union() {
        difference() {
            union() {
                BoxShellBase(boxBottomHeightZMm);
                LatchMount(latchSupportTotalWidth, latchSupportWidth, latchScrewPositionPct, boxBottomHeightZMm, latchSupportRadius, latchToloerance);
                
                if(isStdHinge) {
                    BotomStandardHinge();
                }
            }
            // Cut off anything over/under the top/bottom of the case
            translate([-(boxWidthXMm/2), -(boxLengthYMm/2), -boxBottomHeightZMm*11]) cube([boxWidthXMm*2,boxLengthYMm*2, boxBottomHeightZMm*10]);
            
            // Cutout the seal 
            if(boxSealType == 2) {
                BoxGasketSealExtrude(gasketSlotWidth,gasketSlotDepth,-(gasketSlotDepth/2)+.01);            
            }
            else {
                BoxCircularSealExtrude(boxCircularSealRadius,0.3*boxCircularSealRadius);
            }
            
            // 1. TRIM INTRUDING GEOMETRY (Preserves the flat floor)
            difference() {
                // Shift the cutout cube up by boxWallWidthMm so it only deletes the ribs in the empty space
                translate([0, 0, -(boxBottomHeightZMm - boxWallWidthMm - 0.01)]) 
                    cube([boxWidthXMm, boxLengthYMm, boxBottomHeightZMm - boxWallWidthMm - 0.02]);
                BoxShellBase(boxBottomHeightZMm, boxChamferRadiusMm * 2);
            }
        }
        
        // 3. INJECT THE GRIDFINITY BASE 
        // Shifted down by 4.75mm so the stacking profile protrudes downwards from the bottom
        translate([0, 0, -(boxBottomHeightZMm + 4.75)]) {
            GridfinityBase(gridUnitsX, gridUnitsY);
        }
        
        // Keep your existing dividers intact
        union() {
            BoxLengthXSeparators(boxSectionSeparatorWidth,boxBottomHeightZMm, false);
            BoxWidthYSeparators(boxSectionSeparatorWidth,boxBottomHeightZMm, false);
        }
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
    rotate([90,0,0])
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



module CreateBoxInserts(generateBottomInsert = true, generateTopInsert = true) {

    if(generateBottomInsert) {
        // TPU Top box insert
        translate([boxWidthXMm + 20, 0, boxBottomHeightZMm-boxWallWidthMm-insertTolerance])
            resize([boxWidthXMm-(boxWallWidthMm*2)-(insertTolerance*2),boxLengthYMm-(boxWallWidthMm*2)-(insertTolerance*2),boxBottomHeightZMm-boxWallWidthMm-insertTolerance])
                difference() {
                    translate([0,0,-(boxBottomHeightZMm-boxWallWidthMm-.01)]) cube([boxWidthXMm, boxLengthYMm, boxBottomHeightZMm-boxWallWidthMm-.02]);
                    BoxShellBase(boxBottomHeightZMm, 50);
                }
    }
    
    if(generateTopInsert) {
        // TPU Top box insert
        translate([boxWidthXMm + 20, boxLengthYMm + 20, boxTopHeightZMm-boxWallWidthMm-insertTolerance])
            resize([boxWidthXMm-(boxWallWidthMm*2)-(insertTolerance*2),boxLengthYMm-(boxWallWidthMm*2)-(insertTolerance*2),boxTopHeightZMm-boxWallWidthMm-insertTolerance])
                difference() {
                    translate([0,0,-(boxTopHeightZMm-boxWallWidthMm-.01)]) cube([boxWidthXMm, boxLengthYMm, boxTopHeightZMm-boxWallWidthMm-.02]);
                    BoxShellBase(boxTopHeightZMm, 50);
                }
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
                                        // TODO: calculate the langth of the attachment piece, don't just use 6 :-/
                                        translate([0,-hingeRadiusMm*6,0])
                                            cube([hingeOutsideWidth, hingeRadiusMm*6, hingeConnectorHeight]);
                            translate([0, adjustment, -(hingeRadiusMm-adjustment)-(2*adjustment)])
                                translate([hingeX+hingeInsideWidthMm+hingeToleranceMm,(boxLengthYMm+openingTolerance+hingeRadiusMm),hingeRadiusMm+(openingTolerance/2)])
                                    rotate([45,0,0])
                                        // TODO: calculate the langth of the attachment piece, don't just use 6 :-/
                                        translate([0,-hingeRadiusMm*6,0])
                                            cube([hingeOutsideWidth, hingeRadiusMm*6, hingeConnectorHeight]);
                        } 
                        // TODO: fix this cutout as it doesn't work when the case is very curved!!!                  
                        //ranslate([0,boxLengthYMm-boxWallWidthMm-boxLengthYMm,-boxBottomHeightZMm])
                        //   cube([boxWidthXMm,boxLengthYMm,boxBottomHeightZMm]);
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
                                    // TODO: calculate the langth of the attachment piece, don't just use 6 :-/
                                    translate([0,-hingeRadiusMm*6,-hingeConnectorHeight])
                                        cube([hingeInsideWidthMm, hingeRadiusMm*6, hingeConnectorHeight]);
                        // TODO: fix this cutout as it doesn't work when the case is very curved!!!
                        //translate([0,boxLengthYMm-boxWallWidthMm-boxLengthYMm,0])
                        //    cube([boxWidthXMm,boxLengthYMm,boxTopHeightZMm]);
                    }
                };
                // Cut the screw hole out
                translate([hingeX-.1,boxLengthYMm+hingeRadiusMm+openingTolerance,openingTolerance/2]) rotate([0,90,0])
                    cylinder(hingeInsideWidthMm+.2,hingeScrewLargeRadiusMm,hingeScrewLargeRadiusMm, $fn=100);
        }
    }
}

module BoxLengthXSeparators(separatorWidth, height, isSkipFromEnd, isReversed = false) {
    numRows = len(columnsPerRow);
    rowLengthY = (boxLengthYMm - (2 * boxWallWidthMm)) / numRows;

    for (rowIndex = [0 : numRows - 1]) {
        
        // If isReversed is true, read the array backwards so the lid perfectly mirrors the base!
        actualRowIndex = isReversed ? (numRows - 1 - rowIndex) : rowIndex;
        cols = columnsPerRow[actualRowIndex];
        
        if (cols > 1) {
            colWidth = (boxWidthXMm - (2 * boxWallWidthMm)) / cols;
            
            for (colIndex = [1 : cols - 1]) {
                xOffset = boxWallWidthMm + (colIndex * colWidth) - (separatorWidth / 2);
                yOffset = boxWallWidthMm + (rowIndex * rowLengthY);

                translate([xOffset, yOffset, -(height - boxWallWidthMm)]) {
                    difference() {
                        // Create the divider segment just for this specific row
                        cube([separatorWidth, rowLengthY, height - boxWallWidthMm]);

                        // Match the front wall chamfer cutout for the first physical row
                        if (rowIndex == 0) {
                            translate([-0.1, (boxChamferRadiusMm - boxWallWidthMm), height - boxWallWidthMm]) 
                                rotate([90, 0, 90]) 
                                    linear_extrude(separatorWidth + 0.2) 
                                        Wall2D(boxWallWidthMm, boxChamferRadiusMm, height, false, false);
                        }
                        
                        // Match the back wall chamfer cutout for the last physical row
                        if (rowIndex == numRows - 1) {
                            translate([separatorWidth + 0.1, rowLengthY, 0]) 
                                rotate([0, 0, 180]) 
                                    translate([0, (boxChamferRadiusMm - boxWallWidthMm), height - boxWallWidthMm]) 
                                        rotate([90, 0, 90]) 
                                            linear_extrude(separatorWidth + 0.2) 
                                                Wall2D(boxWallWidthMm, boxChamferRadiusMm, height, false, false);
                        }
                    }
                }
            }
        }
    }
}

module BoxWidthYSeparators(separatorWidth, height, isSkipFromEnd) {
    
    skipFromBegining = isSkipFromEnd ? 0 : numBoxLengthYSectionsToSkip;
    skipFromEnd = isSkipFromEnd ? numBoxLengthYSectionsToSkip : 0;
    
    if(boxLengthYSections > 1) {
        for (y =[1+skipFromBegining:(boxLengthYSections-1-skipFromEnd)]) {
            translate([boxWallWidthMm,separatorWidth+(((boxLengthYMm-(2*boxWallWidthMm))/boxLengthYSections)*y)+(boxWallWidthMm-(separatorWidth/2)),-(height-boxWallWidthMm)])
                rotate([0,0,-90])
                    BoxInsert(boxWidthXMm, height, separatorWidth);
        }
    }
    
}


module BoxInsert(width, height, separatorWidth) {
//translate([boxWidthXMm/2, boxWallWidthMm, -(boxBottomHeightZMm-boxWallWidthMm)])
    difference() {
        cube([separatorWidth,width-(2*boxWallWidthMm), height-boxWallWidthMm]);
        translate([-0.1,(boxChamferRadiusMm-boxWallWidthMm),height-boxWallWidthMm]) rotate([90,0,90]) linear_extrude(separatorWidth+0.2) Wall2D(boxWallWidthMm, boxChamferRadiusMm, height, false, false);
        translate([separatorWidth+0.1,width-(2*boxWallWidthMm),0]) rotate([0,0,180]) translate([0,(boxChamferRadiusMm-boxWallWidthMm),height-boxWallWidthMm]) rotate([90,0,90]) linear_extrude(separatorWidth+0.2) Wall2D(boxWallWidthMm, boxChamferRadiusMm, height, false, false);
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
        
        // If we are rotating, we need to cut off any execess floor or wall on the other side of the y axis
        if(isForRotation) {
            translate([0,-(height*2)]) square([wallThickness*20, (height*2)+.2]);
        }
    }
}

module GridfinityBase(gridX, gridY) {
    $fn = 64;
    pitch = 42; 
    bin_width = 41.5; // 42mm minus 0.5mm clearance[cite: 1]
    
    for (x = [0 : gridX - 1]) {
        for (y = [0 : gridY - 1]) {
            translate([x * pitch, y * pitch, 0]) {
                // Base 0.8mm straight section[cite: 1]
                translate([2.95, 2.95, 0]) 
                    gf_rounded_cube(bin_width - 5.9, bin_width - 5.9, 0.8, 0.8);
                
                // 1.8mm straight section[cite: 1]
                translate([2.95, 2.95, 0.8]) 
                    gf_rounded_cube(bin_width - 5.9, bin_width - 5.9, 1.8, 0.8);
                    
                // 2.15mm 45-degree flared section[cite: 1]
                hull() {
                    translate([2.95, 2.95, 2.6]) 
                        gf_rounded_cube(bin_width - 5.9, bin_width - 5.9, 0.01, 0.8);
                    // Bins are rounded with a radius of 3.75mm[cite: 1]
                    translate([0.25, 0.25, 4.75]) 
                        gf_rounded_cube(bin_width - 0.5, bin_width - 0.5, 0.01, 3.75);
                }
            }
        }
    }
}

// Helper module for faster rendering than minkowski()
module gf_rounded_cube(w, l, h, r) {
    hull() {
        translate([r, r, 0]) cylinder(r=r, h=h);
        translate([w-r, r, 0]) cylinder(r=r, h=h);
        translate([r, l-r, 0]) cylinder(r=r, h=h);
        translate([w-r, l-r, 0]) cylinder(r=r, h=h);
    }
}