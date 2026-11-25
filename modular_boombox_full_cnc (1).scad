// ============================================================================
// OPEN-SOURCE MODULAR 3-PIECE BOOMBOX (FULL CNC EDITION - 4-PIN POGO VERSION)
// Speakers: JVC CS-J520X (5.25" / 13 cm Coaxial)
// Electronics: AI-Thinker ESP32-A1S AudioKit + TPA3116D2 Amp
// ============================================================================

/* [View & Export Selector] */
part = "preview_3d"; // [preview_3d, spk_side, spk_top_bot, spk_front_left, spk_front_right, spk_back, ctr_side, ctr_top_bot, ctr_front, ctr_back, cnc_jig]

/* [Material & CNC Parameters] */
wood_thick      = 12.0;  // Actual measured sheet thickness (mm)
slot_tolerance  = 0.2;   // Extra width in dado/rabbet for glue & fit
dado_depth      = 4.0;   // Depth of rabbet/dado grooves
bit_dia         = 3.175; // 1/8" (3.175mm) end mill for dogbone fillets
corner_radius   = 6.0;   // Outer silhouette corner radius (0 = sharp 90 deg)

/* [Enclosure Exterior Dimensions (Sized for 300x180mm 3018-PRO Bed)] */
box_height      = 230.0; // Z height (fits inside 300mm X-axis)
box_depth       = 170.0; // Y depth (fits inside 180mm Y-axis with bit clearance)
spk_width       = 170.0; // Width of each detachable speaker pod
ctr_width       = 140.0; // Width of center electronics unit

/* [JVC CS-J520X Speaker Cutout Dimensions] */
spk_cutout_dia  = 118.0; // Through-hole diameter
spk_flange_dia  = 132.0; // Counterbore diameter for flush grille/rim
spk_flange_dep  = 3.0;   // Counterbore depth

/* [4-Pin Magnetic Pogo Connector Dimensions] */
pogo_w          = 18.5;  // Connector housing width (measure physical part)
pogo_h          = 6.5;   // Connector housing height
pogo_dep_male   = 3.5;   // Center box Male pocket depth (0.5mm safety recess)
pogo_dep_female = 3.0;   // Speaker box Female pocket depth (flush)
pogo_wire_hole  = 7.0;   // Through-hole for 90-deg bent solder tabs & wires

/* [Center Unit Electronics & Hardware] */
esp_pocket_w    = 82.0;  // Rear pocket width for ESP32-A1S AudioKit
esp_pocket_h    = 48.0;  // Rear pocket height for ESP32-A1S AudioKit
esp_pocket_dep  = 9.0;   // Leaves 3mm front wood wall for buttons
pot_hole_dia    = 7.5;   // TPA3116D2 volume potentiometer shaft hole
pot_pocket_dia  = 24.0;  // Rear counterbore so short pot shaft reaches through
switch_hole_dia = 12.2;  // Main toggle power switch hole
dowel_dia       = 6.0;   // Alignment dowel diameter (6mm)
latch_w         = 16.0;  // Half-width of toggle latch plate per side
latch_h         = 22.0;  // Height of toggle latch plate
latch_dep       = 2.0;   // Flush mortise depth for toggle latches

$fn = 72;
groove_w = wood_thick + slot_tolerance;

module round_rect(w, h, r) {
    if (r <= 0.01) {
        square([w, h], center = true);
    } else {
        offset(r = r) offset(delta = -r) square([w, h], center = true);
    }
}

module dogbone_rect(w, h, r) {
    offset_r = r * 0.7071;
    union() {
        square([w, h], center = true);
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx * (w/2 - offset_r), sy * (h/2 - offset_r)])
                circle(r = r);
        }
    }
}

module panel_spk_side() {
    difference() {
        linear_extrude(wood_thick, center = true)
            round_rect(box_height, box_depth, corner_radius);
        for (sy = [-1, 1]) {
            translate([0, sy * (box_depth/2 - groove_w/2), wood_thick/2 - dado_depth/2 + 0.05])
                cube([box_height + 2, groove_w, dado_depth + 0.1], center = true);
        }
        dado_len = box_depth - 2 * (wood_thick - dado_depth);
        for (sx = [-1, 1]) {
            translate([sx * (box_height/2 - groove_w/2), 0, wood_thick/2 - dado_depth/2 + 0.05])
                linear_extrude(dado_depth + 0.1)
                    dogbone_rect(groove_w, dado_len, bit_dia/2);
        }
        // 4 Alignment Dowel Holes on mating face
        for (dx = [-65, 65], dy = [-45, 45]) {
            translate([dx, dy, -wood_thick/2 + 3.0])
                cylinder(d = dowel_dia, h = 6.2, center = true);
        }
        // Centered 4-Pin Female Magnetic Pogo Mortise + Wire Pass-Through
        translate([0, 0, -wood_thick/2 + pogo_dep_female/2 - 0.05])
            linear_extrude(pogo_dep_female + 0.1)
                dogbone_rect(pogo_w, pogo_h, bit_dia/2);
        cylinder(d = pogo_wire_hole, h = wood_thick + 2, center = true);
    }
}

module panel_spk_top_bot() {
    p_w = spk_width - 2 * (wood_thick - dado_depth);
    difference() {
        cube([p_w, box_depth, wood_thick], center = true);
        for (sy = [-1, 1]) {
            translate([0, sy * (box_depth/2 - groove_w/2), wood_thick/2 - dado_depth/2 + 0.05])
                cube([p_w + 2, groove_w, dado_depth + 0.1], center = true);
        }
    }
}

module panel_spk_front(is_left = true) {
    b_h = box_height - 2 * (wood_thick - dado_depth);
    b_w = spk_width - 2 * (wood_thick - dado_depth);
    inner_r = max(0, corner_radius - (wood_thick - dado_depth));
    latch_side = is_left ? 1 : -1;
    difference() {
        linear_extrude(wood_thick, center = true)
            round_rect(b_h, b_w, inner_r);
        cylinder(d = spk_cutout_dia, h = wood_thick + 2, center = true);
        translate([0, 0, wood_thick/2 - spk_flange_dep/2 + 0.05])
            cylinder(d = spk_flange_dia, h = spk_flange_dep + 0.1, center = true);
        for (lz = [-55, 55]) {
            translate([lz, latch_side * (b_w/2 - latch_w/2 + 1), wood_thick/2 - latch_dep/2 + 0.05])
                linear_extrude(latch_dep + 0.1)
                    dogbone_rect(latch_h, latch_w + 2, bit_dia/2);
        }
    }
}

module panel_spk_back() {
    b_h = box_height - 2 * (wood_thick - dado_depth);
    b_w = spk_width - 2 * (wood_thick - dado_depth);
    inner_r = max(0, corner_radius - (wood_thick - dado_depth));
    // Solid airtight rear panel (no external terminal cup hole needed)
    linear_extrude(wood_thick, center = true)
        round_rect(b_h, b_w, inner_r);
}

module panel_ctr_side() {
    difference() {
        linear_extrude(wood_thick, center = true)
            round_rect(box_height, box_depth, corner_radius);
        for (sy = [-1, 1]) {
            translate([0, sy * (box_depth/2 - groove_w/2), wood_thick/2 - dado_depth/2 + 0.05])
                cube([box_height + 2, groove_w, dado_depth + 0.1], center = true);
        }
        dado_len = box_depth - 2 * (wood_thick - dado_depth);
        for (sx = [-1, 1]) {
            translate([sx * (box_height/2 - groove_w/2), 0, wood_thick/2 - dado_depth/2 + 0.05])
                linear_extrude(dado_depth + 0.1)
                    dogbone_rect(groove_w, dado_len, bit_dia/2);
        }
        for (dx = [-65, 65], dy = [-45, 45]) {
            translate([dx, dy, -wood_thick/2 + 3.0])
                cylinder(d = dowel_dia + 0.15, h = 6.2, center = true);
        }
        // Centered 4-Pin Male Magnetic Pogo Mortise (recessed 0.5mm for short protection)
        translate([0, 0, -wood_thick/2 + pogo_dep_male/2 - 0.05])
            linear_extrude(pogo_dep_male + 0.1)
                dogbone_rect(pogo_w, pogo_h, bit_dia/2);
        cylinder(d = pogo_wire_hole, h = wood_thick + 2, center = true);
    }
}

module panel_ctr_top_bot() {
    p_w = ctr_width - 2 * (wood_thick - dado_depth);
    difference() {
        cube([p_w, box_depth, wood_thick], center = true);
        for (sy = [-1, 1]) {
            translate([0, sy * (box_depth/2 - groove_w/2), wood_thick/2 - dado_depth/2 + 0.05])
                cube([p_w + 2, groove_w, dado_depth + 0.1], center = true);
        }
    }
}

module panel_ctr_front() {
    b_h = box_height - 2 * (wood_thick - dado_depth);
    b_w = ctr_width - 2 * (wood_thick - dado_depth);
    inner_r = max(0, corner_radius - (wood_thick - dado_depth));
    difference() {
        linear_extrude(wood_thick, center = true)
            round_rect(b_h, b_w, inner_r);
        translate([45, 0, -wood_thick/2 + esp_pocket_dep/2 - 0.05])
            linear_extrude(esp_pocket_dep + 0.1)
                dogbone_rect(esp_pocket_h, esp_pocket_w, bit_dia/2);
        for (by = [-24, -8, 8, 24]) {
            translate([32, by, 0])
                cylinder(d = 4.2, h = wood_thick + 2, center = true);
        }
        translate([-15, 0, 0]) {
            cylinder(d = pot_hole_dia, h = wood_thick + 2, center = true);
            translate([0, 0, -wood_thick/2 + esp_pocket_dep/2 - 0.05])
                cylinder(d = pot_pocket_dia, h = esp_pocket_dep + 0.1, center = true);
        }
        translate([-65, 0, 0])
            cylinder(d = switch_hole_dia, h = wood_thick + 2, center = true);
        for (lz = [-55, 55], side = [-1, 1]) {
            translate([lz, side * (b_w/2 - latch_w/2 + 1), wood_thick/2 - latch_dep/2 + 0.05])
                linear_extrude(latch_dep + 0.1)
                    dogbone_rect(latch_h, latch_w + 2, bit_dia/2);
        }
    }
}

module panel_ctr_back() {
    b_h = box_height - 2 * (wood_thick - dado_depth);
    b_w = ctr_width - 2 * (wood_thick - dado_depth);
    inner_r = max(0, corner_radius - (wood_thick - dado_depth));
    difference() {
        linear_extrude(wood_thick, center = true)
            round_rect(b_h, b_w, inner_r);
        linear_extrude(wood_thick + 2, center = true)
            round_rect(b_h - 36, b_w - 28, 6.0);
    }
}

module genmitsu_3018_jig() {
    difference() {
        union() {
            cube([250, 175, 3], center = false);
            cube([8, 175, 11], center = false);
            cube([250, 8, 11], center = false);
        }
        translate([8, 8, -1]) cylinder(r = 4, h = 15);
        for (px = [40, 120, 200], py = [30, 90, 150]) {
            translate([px, py, -1]) cylinder(d = 5.4, h = 15);
        }
    }
}

module speaker_box_3d(is_left = true) {
    translate([-(spk_width/2 - wood_thick/2), 0, 0]) rotate([0, 90, 0]) panel_spk_side();
    translate([(spk_width/2 - wood_thick/2), 0, 0]) rotate([0, -90, 0]) panel_spk_side();
    translate([0, 0, (box_height/2 - wood_thick/2)]) rotate([0, 0, 90]) panel_spk_top_bot();
    translate([0, 0, -(box_height/2 - wood_thick/2)]) rotate([0, 0, 90]) panel_spk_top_bot();
    translate([0, -(box_depth/2 - wood_thick/2), 0]) rotate([90, 90, 0]) panel_spk_front(is_left);
    translate([0, (box_depth/2 - wood_thick/2), 0]) rotate([-90, 90, 0]) panel_spk_back();
}

module center_box_3d() {
    translate([-(ctr_width/2 - wood_thick/2), 0, 0]) rotate([0, 90, 0]) panel_ctr_side();
    translate([(ctr_width/2 - wood_thick/2), 0, 0]) rotate([0, -90, 0]) panel_ctr_side();
    translate([0, 0, (box_height/2 - wood_thick/2)]) rotate([0, 0, 90]) panel_ctr_top_bot();
    translate([0, 0, -(box_height/2 - wood_thick/2)]) rotate([0, 0, 90]) panel_ctr_top_bot();
    translate([0, -(box_depth/2 - wood_thick/2), 0]) rotate([90, 90, 0]) panel_ctr_front();
    translate([0, (box_depth/2 - wood_thick/2), 0]) rotate([-90, 90, 0]) panel_ctr_back();
}

if (part == "preview_3d") {
    color("BurlyWood") center_box_3d();
    color("Tan") translate([-(ctr_width/2 + spk_width/2 + 6), 0, 0]) speaker_box_3d(true);
    color("Tan") translate([(ctr_width/2 + spk_width/2 + 6), 0, 0]) speaker_box_3d(false);
} else if (part == "spk_side") {
    panel_spk_side();
} else if (part == "spk_top_bot") {
    panel_spk_top_bot();
} else if (part == "spk_front_left") {
    panel_spk_front(true);
} else if (part == "spk_front_right") {
    panel_spk_front(false);
} else if (part == "spk_back") {
    panel_spk_back();
} else if (part == "ctr_side") {
    panel_ctr_side();
} else if (part == "ctr_top_bot") {
    panel_ctr_top_bot();
} else if (part == "ctr_front") {
    panel_ctr_front();
} else if (part == "ctr_back") {
    panel_ctr_back();
} else if (part == "cnc_jig") {
    genmitsu_3018_jig();
}
