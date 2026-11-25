// ============================================================================
// OPEN-SOURCE MODULAR BOOMBOX — HYBRID PRODUCTION (3018-PRO + DEXTER 1300W)
// 4-Pin Magnetic Pogo Side-Wall Edition
// ============================================================================

/* [Select Part / Template to Render] */
part = "tpl_spk_front"; // [preview_3d, tpl_spk_front, tpl_ctr_back, tpl_dowel_pogo_latch, cnc_ctr_front_5mm, cnc_ctr_front_12mm]

/* [Dexter 1300W Router Bit / Bushing Setup] */
use_guide_bushing = false; 
bushing_od        = 17.0;  
router_bit_dia    = 8.0;   

/* [Material & Enclosure Dimensions] */
wood_thick      = 12.0;  
dado_depth      = 4.0;   
template_thick  = 5.0;   // Set to 5.0 for your 5mm garage MDF templates
cnc_bit_dia     = 3.175; 
corner_radius   = 6.0;   

box_height      = 230.0; 
box_depth       = 170.0; 
spk_width       = 170.0; 
ctr_width       = 140.0; 

/* [Speaker, Pogo & Electronics Dimensions] */
spk_cutout_dia  = 118.0; 
spk_flange_dia  = 132.0; 
pogo_w          = 18.5;  // 4-pin magnetic pogo connector width
pogo_h          = 6.5;   // 4-pin magnetic pogo connector height
pogo_wire_hole  = 7.0;   // Center wire pass-through hole
esp_pocket_w    = 82.0;  
esp_pocket_h    = 48.0;  
esp_pocket_dep  = 9.0;   
pot_hole_dia    = 7.5;   
pot_pocket_dia  = 24.0;  
switch_hole_dia = 12.2;  
dowel_dia       = 6.0;   
latch_w         = 16.0;  
latch_h         = 22.0;  

$fn = 96;
bushing_offset = use_guide_bushing ? (bushing_od - router_bit_dia) / 2 : 0;
baffle_h     = box_height - 2 * (wood_thick - dado_depth);
spk_baffle_w = spk_width  - 2 * (wood_thick - dado_depth);
ctr_baffle_w = ctr_width  - 2 * (wood_thick - dado_depth);

module round_rect(w, h, r) {
    if (r <= 0.01) square([w, h], center = true);
    else offset(r = r) offset(delta = -r) square([w, h], center = true);
}

module dogbone_rect(w, h, r) {
    offset_r = r * 0.7071;
    union() {
        square([w, h], center = true);
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (w/2 - offset_r), sy * (h/2 - offset_r)]) circle(r = r);
    }
}

// 1. Nested 132mm Counterbore + 118mm Through-Hole Speaker Template
module template_speaker_front() {
    difference() {
        linear_extrude(template_thick)
            round_rect(baffle_h, spk_baffle_w, max(0, corner_radius - 8));
        translate([0, 0, -1])
            cylinder(d = spk_flange_dia + 2 * bushing_offset, h = template_thick + 2);
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (baffle_h/2 - 14), sy * (spk_baffle_w/2 - 14), -1])
                cylinder(d = 4.2, h = template_thick + 2);
    }
    difference() {
        cylinder(d = spk_flange_dia + 2 * bushing_offset - 0.3, h = template_thick);
        translate([0, 0, -1])
            cylinder(d = spk_cutout_dia + 2 * bushing_offset, h = template_thick + 2);
    }
}

// 2. Center Back Rear Cable Pocket Window Template
module template_center_back() {
    difference() {
        linear_extrude(template_thick)
            round_rect(baffle_h, ctr_baffle_w, max(0, corner_radius - 8));
        translate([0, 0, -1])
            linear_extrude(template_thick + 2)
                round_rect((baffle_h - 36) + 2 * bushing_offset, (ctr_baffle_w - 28) + 2 * bushing_offset, 6.0 + bushing_offset);
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (baffle_h/2 - 10), sy * (ctr_baffle_w/2 - 10), -1])
                cylinder(d = 4.2, h = template_thick + 2);
    }
}

// 3. Combined Dowel + 4-Pin Magnetic Pogo + Latch Template (230x170mm)
module jig_dowel_pogo_latch() {
    difference() {
        cube([box_height, box_depth, template_thick], center = true);
        // 4 Alignment Dowel Drill Bushings (6mm)
        for (dx = [-65, 65], dy = [-45, 45])
            translate([dx, dy, 0]) cylinder(d = dowel_dia, h = template_thick + 2, center = true);
        // Centered 4-Pin Magnetic Pogo Router Guide + Center Wire Pilot
        linear_extrude(template_thick + 2, center = true)
            dogbone_rect(pogo_w + 2 * bushing_offset, pogo_h + 2 * bushing_offset, cnc_bit_dia/2);
        // Front Edge Toggle Latch Mortise Guides
        for (lz = [-55, 55])
            translate([lz, -box_depth/2 + latch_w/2 + 4, 0])
                linear_extrude(template_thick + 2, center = true)
                    round_rect(latch_h + 2 * bushing_offset, latch_w + 2 * bushing_offset, 2.0);
    }
}

// 4. Direct 3018-PRO CNC Center Control Panel for 5mm Wood-Grain MDF
module part_center_front_5mm() {
    difference() {
        linear_extrude(5.0, center = true)
            round_rect(baffle_h, ctr_baffle_w, max(0, corner_radius - 8));
        for (by = [-24, -8, 8, 24])
            translate([32, by, 0]) cylinder(d = 4.2, h = 7, center = true);
        translate([-15, 0, 0]) cylinder(d = pot_hole_dia, h = 7, center = true);
        translate([-65, 0, 0]) cylinder(d = switch_hole_dia, h = 7, center = true);
    }
}

// 5. Direct 3018-PRO CNC Center Control Panel for 12mm Stock (With Rear Pocket)
module part_center_front_12mm() {
    difference() {
        linear_extrude(wood_thick, center = true)
            round_rect(baffle_h, ctr_baffle_w, max(0, corner_radius - 8));
        translate([45, 0, -wood_thick/2 + esp_pocket_dep/2 - 0.05])
            linear_extrude(esp_pocket_dep + 0.1)
                dogbone_rect(esp_pocket_h, esp_pocket_w, cnc_bit_dia/2);
        for (by = [-24, -8, 8, 24])
            translate([32, by, 0]) cylinder(d = 4.2, h = wood_thick + 2, center = true);
        translate([-15, 0, 0]) {
            cylinder(d = pot_hole_dia, h = wood_thick + 2, center = true);
            translate([0, 0, -wood_thick/2 + esp_pocket_dep/2 - 0.05])
                cylinder(d = pot_pocket_dia, h = esp_pocket_dep + 0.1, center = true);
        }
        translate([-65, 0, 0]) cylinder(d = switch_hole_dia, h = wood_thick + 2, center = true);
    }
}

module full_preview() {
    color("BurlyWood") translate([0, -(box_depth/2 - wood_thick/2), 0]) rotate([90, 90, 0]) part_center_front_12mm();
    color("Tan") translate([-(ctr_width/2 + spk_width/2 + 6), -(box_depth/2 - wood_thick/2), 0]) rotate([90, 90, 0])
        difference() {
            linear_extrude(wood_thick, center = true) round_rect(baffle_h, spk_baffle_w, max(0, corner_radius - 8));
            cylinder(d = spk_cutout_dia, h = wood_thick + 2, center = true);
        }
    color("Tan") translate([(ctr_width/2 + spk_width/2 + 6), -(box_depth/2 - wood_thick/2), 0]) rotate([90, 90, 0])
        difference() {
            linear_extrude(wood_thick, center = true) round_rect(baffle_h, spk_baffle_w, max(0, corner_radius - 8));
            cylinder(d = spk_cutout_dia, h = wood_thick + 2, center = true);
        }
}

if (part == "preview_3d") full_preview();
else if (part == "tpl_spk_front") template_speaker_front();
else if (part == "tpl_ctr_back") template_center_back();
else if (part == "tpl_dowel_pogo_latch") jig_dowel_pogo_latch();
else if (part == "cnc_ctr_front_5mm") part_center_front_5mm();
else if (part == "cnc_ctr_front_12mm") part_center_front_12mm();
