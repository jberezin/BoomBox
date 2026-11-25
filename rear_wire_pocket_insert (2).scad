// ============================================================================
// 3D-PRINTABLE REAR CABLE-STORAGE & CHARGING PORT INSERT (CLEAN POGO EDITION)
// Fits into the 178mm x 96mm cutout window of ctr_back
// ============================================================================

part = "pocket_body"; // [pocket_body, cable_cover, preview]

/* [Cutout & Flange Dimensions] */
cutout_h      = 178.0; // Matches b_h - 36 (214 - 36 = 178mm)
cutout_w      = 96.0;  // Matches b_w - 28 (124 - 28 = 96mm)
clearance     = 0.4;   // Total fit clearance inside wood window
corner_r      = 6.0;   // Corner radius matching CNC cutout
flange_over   = 8.0;   // Outer trim bezel overlap onto rear wood face
flange_thick  = 2.4;   // Thickness of rear trim bezel
pocket_depth  = 34.0;  // Total depth extending inside center box
wall_thick    = 2.4;   // Bucket wall thickness

/* [Top Bulkhead Port Cutouts] */
bulkhead_h    = 36.0;  // Height of top connector shelf
dc_jack_dia   = 8.2;   // 5.5x2.1mm panel-mount DC barrel jack hole
usbc_w        = 9.2;   // Panel-mount USB-C female port width
usbc_h        = 3.4;   // Panel-mount USB-C female port height

/* [Magnetic Cover Parameters] */
magnet_dia    = 6.2;   // Press-fit pocket for 6x2mm neodymium magnets
magnet_dep    = 2.2;
cover_thick   = 2.2;

$fn = 64;
body_h = cutout_h - clearance;
body_w = cutout_w - clearance;

module rrect(w, h, r) {
    offset(r = r) offset(delta = -r) square([w, h], center = true);
}

module pocket_body() {
    difference() {
        union() {
            // Outer Trim Flange
            linear_extrude(flange_thick)
                rrect(body_w + flange_over * 2, body_h + flange_over * 2, corner_r + 2);
            // Main Recessed Bucket Body
            linear_extrude(pocket_depth)
                rrect(body_w, body_h, corner_r);
        }
        
        // Hollow out lower sealed storage pocket for optional magnetic extension cords
        pocket_inner_h = body_h - bulkhead_h - wall_thick;
        translate([0, -bulkhead_h/2, -0.1])
            linear_extrude(pocket_depth - wall_thick + 0.1)
                rrect(body_w - wall_thick * 2, pocket_inner_h, max(2, corner_r - 2));
                
        // Hollow out back of top bulkhead shelf so wires attach from inside box
        translate([0, body_h/2 - bulkhead_h/2 - wall_thick/2, flange_thick + wall_thick])
            linear_extrude(pocket_depth)
                rrect(body_w - wall_thick * 2, bulkhead_h - wall_thick, max(2, corner_r - 2));
                
        // Top Bulkhead Port 1: 5.5x2.1mm DC Barrel Jack
        translate([-18, body_h/2 - bulkhead_h/2, -1])
            cylinder(d = dc_jack_dia, h = flange_thick + wall_thick + 4);
            
        // Top Bulkhead Port 2: USB-C Firmware Port
        translate([18, body_h/2 - bulkhead_h/2, -1])
            linear_extrude(flange_thick + wall_thick + 4)
                rrect(usbc_w, usbc_h, 1.5);
                
        // 4 Corner Mounting Screw Holes in Outer Flange
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx * (body_w/2 + flange_over/2), sy * (body_h/2 + flange_over/2), -1])
                cylinder(d = 3.4, h = flange_thick + 2);
        }
        
        // 4 Corner Magnet Pockets on lower storage lip for snap-in cable cover
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx * (body_w/2 - 5.5), -bulkhead_h/2 + sy * (pocket_inner_h/2 - 5.5), -0.1])
                cylinder(d = magnet_dia, h = magnet_dep + 0.1);
        }
    }
}

module cable_cover() {
    pocket_inner_h = body_h - bulkhead_h - wall_thick - 0.6;
    pocket_inner_w = body_w - wall_thick * 2 - 0.6;
    difference() {
        linear_extrude(cover_thick)
            rrect(pocket_inner_w, pocket_inner_h, max(2, corner_r - 2));
        // 4 Corner Magnet Pockets matching pocket_body
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx * (pocket_inner_w/2 - 5.2), sy * (pocket_inner_h/2 - 5.2), cover_thick - magnet_dep])
                cylinder(d = magnet_dia, h = magnet_dep + 0.2);
        }
        // Bottom Finger Pull Notch
        translate([0, -pocket_inner_h/2 + 6, -0.5])
            linear_extrude(1.4) rrect(24, 6, 3);
    }
}

if (part == "pocket_body") pocket_body();
else if (part == "cable_cover") cable_cover();
else {
    pocket_body();
    translate([0, -bulkhead_h/2, -4]) cable_cover();
}
