//////////////////////////////////////////////////////////////////////
// Parametric Text Stencil Plate (multi-line via separate params)
// - Manual plate width/height (mm) OR autosize from textmetrics()
// - Reliable multi-line for Makerworld (line1/line2/line3)
// - Bridges OFF by default
//////////////////////////////////////////////////////////////////////

include <BOSL2/std.scad>;

//////////////////////////////
// User parameters
//////////////////////////////

// CHRISTIAN: organize parameters using tabs for better user experience.
/*[Texts]*/
// Text (multi-line)
line1 = "SPRAY";
line2 = "STENCIL";   // set "" to disable
line3 = "";        // set "" to disable
//////////////////////////////
// Simple spacing controls
//////////////////////////////
// CHRISTIAN: Add a custom comment to each parameter explaining its functionality, this will appear in Parametric Model Maker. Also, add minimum, maximum and step values in the form [min:step:max] so this edit becomes a slider in Parametric Model Maker
// CHRISTIAN: Also, the line spacing value can be defined as a percentage of text height rather than a floating point value which is more obscure to the users. Instead of 1.50 which means 150% of text height, you could ask the user to select 50% of text height, that's the spacing. Basically 0% means the texts touch between themselves, 100% means there's a space between texts that equals the text height.
// Spacing between lines. (as percentage of text height)
line_spacing = 50; // [0:300]
// CHRISTIAN: Same here. Note that the biggest plate is the one for H2D which is 325 millimeters with and 320 millimeters height, this defines a good range to give to users.
// Move texts on horizontal axis, negative values move it to the left, positive values move it to the right. (in millimeters)
text_x       = 0; // [-165:0.1:165]
// Move texts on vertical axis, negative values move it to the top, positive values move it to the bottom (in millimeters).
text_y       = 0; // [-160:0.1:160]


// CHRISTIAN: first of all, this is duplicated code that shouldn't be here and OpenSCAD should give you an error, don't know why Parametric Model Maker is accepting it, but OpenSCAD states that all parameters must be on top of file. My OpenSCAD Nightly Build was not showing them. */

////////////////////////////////////////////////////////////////////////
//// Text helpers
////////////////////////////////////////////////////////////////////////
//
//// Enabled lines (ignore blanks)
//function _lines() =
//    [ for (s = [line1, line2, line3]) if (len(s) > 0) s ];
//
//// Single-line text
//module _text_line(s) {
//    text(
//        s,
//        size=text_size,
//        font=_font_name,
//        halign=text_halign,
//        valign="center"
//    );
//}
//
//// Multi-line layout (centered as a group)
//module text2d_shape() {
//    L = _lines();
//    n = len(L);
//
//    // CHRISTIAN: calculate line spacing as percentage.
//    step = text_size * ((100 + line_spacing) / 100);
//
//    translate([text_x, text_y]) {
//        for (i = [0 : n-1]) {
//            y = (n==1) ? 0 : (((n-1)/2.0 - i) * step);
//            translate([0, y]) _text_line(L[i]);
//        }
//    }
//}

// CHRISTIAN: If you have a limited selection of fonts to be used, use a combo box selector for this parameter providing all possible values. Note that special characters are not accepted, you will find a fix below that fixes the fontname of Stardos Stencil by adding ":style=Bold" to it.
// Select the font.
font_name = "Stardos Stencil"; // [Saira Stencil,Allerta Stencil,Stardos Stencil]
// Select the text height. (in millimeters)
text_size = 30; // [0:0.1:100]
// CHRISTIAN: another parameter that can be a simple selector.
// Where to align text horizontally.
text_halign = "center"; // [left,center,right]
// Where to align text vertically for each line (we position lines manually).
text_valign = "center"; // [top,center, baseline,bottom]

// CHRISTIAN: commented this out, line_spacing is already declared some lines above, OpenSCAD even shows a warning:
// WARNING: "line_spacing" was assigned on line 21 but was overwritten in file Text Stencil Plate v4.2.scad, line 33
// // Line spacing control (distance between line centers)
// line_spacing   = 1.5;      // 1.0–1.3 typical. (multiplier of text_size)

/*[Plate]*/
// CHRISTIAN: for things like this always consider giving at least a minimum value because it avoids user setting 0 (zero), in that case you script would fail.
// Plate thickness. (in millimeters)
plate_thickness = 1.0; // [0.2:0.1:30]
// CHRISTIAN: corrected the comment, there's no "autosize" parameter.
// Border around the plate which will be added only when the size is calculated automatically. (in millimeters)
border = 8; // [0:.1:50]
// Rounding of the plate corners. (in millimeters)
plate_rounding  = 4; // [0:.1:100]

// Plate sizing
// CHRISTIAN: changed the checkbox "use_manual_size" to a most convenient combobox "size_mode" explaining both options.
// Choose the mode the size of the plate is selected.
size_mode = 0; // [0:Use the values specified by user,1:Calculate automatically based on text and border]
// CHRISTIAN: as said before, a good reference for size limits is the H2D plate which is the largest yet available.
// Manual width of the plate. (in millimeters)
plate_width = 200; // [20:.1:325]
// Manual height of the plate. (in millimeters)
plate_height = 200; // [20:.1:320]

/*[Bridges]*/
// Enable bridge tabs to keep islands from dropping out.
enable_bridges = false; // OFF by default
// CHRISTIAN: this is a good parameter to think of, knowing we need at least three lines to have a good solid and that most people use a 0.4mm nozzle, we can set it to be a value that is a multiple of this value with a determined minimum.
// Bridge width. (in millimeters)
bridge_width = 1.2; // [1.2:.4:10]
// Spacing between bridges. (in millimeters)
bridge_spacing = 7.0; // [.4:.4:100]
// CHRISTIAN: another good parameter to be limited, the degrees of angles.
// Angle of bridges. (in degrees)
bridge_angle = 25; // [-180:180]

// CHRISTIAN: I added this to select the quality of curves.
/*[Other settings]*/
//Choose the quality of generation of the object.
render_quality = 30; // [10:Draft,20:Printable draft,30:Normal,50:Good quality,75:High quality,100:Very high quality]

// CHRISTIAN: parameters above this line will not be shown.
/*[Hidden]*/

/* CHRISTIAN: fixes the font name. As you can see, you can't reuse the same variable or you will get a warning in OpenSCAD. */
_font_name = font_name == "Stardos Stencil" ? str(font_name, ":style=Bold") : font_name;

//////////////////////////////////////////////////////////////////////
// Helpers
//////////////////////////////////////////////////////////////////////

// Build an array of enabled lines (ignore blanks)
function _lines() =
    [ for (s = [line1, line2, line3]) if (len(s) > 0) s ];

// Single-line text primitive
module _text_line(s) {
    text(
        s,
        size=text_size,
        font=_font_name,
        halign=text_halign,
        valign=text_valign,
        $fn = render_quality // CHRISTIAN: sets render quality of curves
    );
}

// Multi-line layout: stack lines around the origin (centered as a group)
module text2d_shape() {
    L = _lines();
    n = len(L);

    // Step between line centers
    // CHRISTIAN: calculate line spacing as percentage.
    step = text_size * ((100 + line_spacing) / 100);

    // If only one line, no offset; otherwise distribute evenly about 0
    for (i = [0 : n-1]) {
        y = (n==1) ? 0 : (( (n-1)/2.0 - i) * step);
        translate([0, y]) _text_line(L[i]);
    }
}

// Repeating bar mask; intersect with text to create "kept" bridge tabs
module bridge_mask_2d(W, H) {
    rotate(bridge_angle) union() {
        bar_len = max([W, H]) * 3;
        for (y = [-bar_len : bridge_spacing : bar_len]) {
            translate([0, y])
                square([bar_len, bridge_width], center=true);
        }
    }
}

module stencil_plate() {

    // Optional autosize path (rough but works with multi-line)
    // We estimate width as max line width, height as sum of line heights + spacing.
    L = _lines();
    n = len(L);

    // Compute metrics per line
    widths  = [ for (s = L) textmetrics(s, size=text_size, font=_font_name).size[0] ];
    heights = [ for (s = L) textmetrics(s, size=text_size, font=_font_name).size[1] ];

    txt_w = (n>0) ? max(widths) : text_size;
    // Total text height = sum(line heights) + gaps between lines (using step)
    // CHRISTIAN: calculate line spacing as percentage.
    step  = text_size * ((100 + line_spacing) / 100);
    txt_h = (n==0) ? text_size :
            (sum(heights) + (n-1)*max([0, step - (heights[0]) ]));  // simple, stable

    // Manual vs autosize (IMPORTANT: expressions, not if-block vars)
    /* CHRISTIAN: changed use_manual_size (boolean) to size_mode (integer). */
    W = size_mode == 0 ? plate_width  : (txt_w + 2*border);
    H = size_mode == 0 ? plate_height : (txt_h + 2*border);

    // Guard against weird/zero values
    W2 = max(W, 0.1);
    H2 = max(H, 0.1);

    module plate2d() {
        rect([W2, H2], rounding=plate_rounding, anchor=CENTER, $fn = render_quality // CHRISTIAN: sets render quality of curves
        );
    }

    module cutout2d() {
        if (!enable_bridges) {
            text2d_shape();
        } else {
            difference() {
                text2d_shape();
                intersection() {
                    text2d_shape();
                    bridge_mask_2d(W2, H2);
                }
            }
        }
    }

    difference() {
        linear_extrude(height=plate_thickness)
            plate2d();

        translate([0,0,-0.2])
        linear_extrude(height=plate_thickness + 0.4)
            cutout2d();
    }
}

//////////////////////////////////////////////////////////////////////
// Output - Created by Liam / Improved by CHRISTIAN
//////////////////////////////////////////////////////////////////////
stencil_plate();
