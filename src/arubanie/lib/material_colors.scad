// Dark colors not meant to be realistic, but be able to see edges in OpenSCAD!

BRONZE = "#b08d57";
STAINLESS_STEEL = "#CFD4D9";
BLACK_IRON = "#3a3c3e";

COPPER = "#B87333";

IVORY = "#FFFFF0";
PTFE_COLOR = IVORY;

BLACK_PLASTIC_1 = "#5A5A5A";
BLACK_PLASTIC_2  = "#2A4028";
CREALITY_POWDER_COATED_METAL_PLATE = "#573434";

PART_1 = "Blue";
PART_2 = "Red";
PART_3 = "Green";
PART_4 = "Yellow";
PART_5 = "Brown";
PART_6 = "Orange";
PART_7 = "Pink";
PART_8 = "Purple";
PART_9 = "Gray";
PART_10 = "Beige";
PART_11 = "Turquoise";
PART_12 = "Indigo";
PART_13 = "Teal";
PART_14 = "Magenta";
PART_15 = "Maroon";
PART_16 = "Cyan";
PART_17 = "Olive";
PART_18 = "Navy";
PART_19 = "Lavender";
PART_20 = "PeachPuff";
PART_21 = "Coral";
PART_22 = "Salmon";
PART_23 = "#e0b0ff"; // "Mauve";
PART_24 = "#9b111e"; // "Ruby";
PART_25 = "#50c878"; //"Emerald";

// Need RGB color codes for these;
PART_26 = "Plum";
PART_27 = "Mustard";
PART_28 = "Lilac";
PART_29 = "Sage";
PART_30 = "Rust";
PART_31 = "Periwinkle";
PART_32 = "Tangerine";


PART_33 = "violet";
PART_34 = "OliveDrab";



function visualize_info(color_code, alpha) = [color_code, alpha];
    

module visualize(info,  show_part_colors=false) {
    color_code = info[0];
    alpha = info[1];
    if (show_part_colors) {
        // Just pass through, so that underlying colors can be seen
        children();
    } else if (alpha == 0) {
        // Don't create anything.  This avoids some artifacts in rendering
        // such as wrong z ordering or not enough convexity being specified.
    } else {
        color(color_code, alpha) {
            children();
        }
    }
}
