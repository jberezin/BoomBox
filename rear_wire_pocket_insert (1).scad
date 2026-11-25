// ============================================================================
// OPEN-SOURCE MODULAR BOOMBOX — 3D-PRINTABLE REAR WIRE POCKET & PORT INSERT
// Fits the 178mm x 96mm cutout window in the Center Back Panel (ctr_back)
// Houses: 5.5x2.1mm DC Barrel Jack, Panel-Mount USB-C Data Port,
//         4x 4mm Banana Plug Jacks (L+/L-/R+/R-), & Coiled Speaker Wire Pocket
// ============================================================================

/* [View / Print Part Selector] */
// "preview"       = Assembled rear pocket + snap-fit cable cover
// "pocket_body"   = Main recessed bucket (print open-side up, no supports needed)
// "cable_cover"   = Friction/magnet snap-fit hatch that retains coiled cables
part = "pocket_body"; // [preview, pocket_body, cable_cover]

/* [Cutout & Flange Dimensions (Matches ctr_back 178 x 96 mm window)] */
cutout_h        = 178.0; // Height of opening in center back wood panel
cutout_w        = 96.0;  // Width of opening in center back wood panel
clearance       = 0.4;   // Total fit clearance (0.2mm per side)
flange_overlap  = 8.0;   // Outer bezel overlap onto back wood face
flange_thick    = 3.0;   // Outer bezel thickness
wall_thick      = 2.6;   // Pocket wall thickness
pocket_depth    = 32.0;  // Recess depth into center box (leaves room for battery/amp)
corner_radius   = 6.0;   // Matches rounded CNC window in ctr_back

/* [Connector Mounting Hole Sizes] */
dc_jack_dia     = 11.2;  // Standard panel-mount 5.5x2.1mm DC barrel jack
usbc_w          = 9.2;   // Panel-mount USB-C female port width (or D-series cutout)
usbc_h          = 3.5;   // Panel-mount USB-C female port height
usbc_mount_sp   = 18.0;  // M3 screw hole spacing for panel-mount USB-C pigtail
banana_dia      = 8.2;   // Standard 4mm insulated banana binding post hole
magnet_dia      = 6.2;   // 6x2mm neodymium magnet holes for cable hatch
magnet_dep      = 2.2;   // Depth of magnet pockets

$fn = 72;

body_h = cutout_h - clearance;
body_w = cutout_w - clearance;

// ============================================================================
// HELPER MODULES
// ============================================================================
module round_rect(w, h, r) {
    offset(r = r) offset(delta = -r) square([w, h], center = true);
}

// ============================================================================
// 1. MAIN RECESSED WIRE POCKET & CONNECTOR BULKHEAD
// ============================================================================
module rear_pocket_body() {
    connector_zone_h = 46.0; // Top bulkhead for DC jack, USB-C, & banana posts
    wire_zone_h      = body_h - connector_zone_h - wall_thick;
    
    difference() {
        union() {
            // Outer Bezel Flange (sits flush against exterior rear wood face)
            linear_extrude(flange_thick)
                round_rect(body_h + 2 * flange_overlap, body_w + 2 * flange_overlap, corner_radius + flange_overlap/2);
                
            // Recessed Bucket Shell (extends into box)
            translate([0, 0, flange_thick])
                linear_extrude(pocket_depth)
                    round_rect(body_h, body_w, corner_radius);
        }
        
        // Hollow out Top Connector Bulkhead Cavern (open from inside of box for wiring)
        translate([body_h/2 - connector_zone_h/2 - wall_thick, 0, flange_thick + wall_thick])
            linear_extrude(pocket_depth + 2)
                round_rect(connector_zone_h - wall_thick, body_w - 2 * wall_thick, max(2, corner_radius - wall_thick));
                
        // Hollow out Lower Coiled Cable Storage Pocket (open from rear exterior)
        translate([-(body_h/2 - wire_zone_h/2 - wall_thick), 0, -1])
            linear_extrude(pocket_depth - wall_thick + 1)
                round_rect(wire_zone_h - wall_thick, body_w - 2 * wall_thick, max(2, corner_radius - wall_thick));
                
        // --- CONNECTOR HOLES IN TOP BULKHEAD FACE ---
        // Row 1 (Upper): 5.5x2.1mm DC Barrel Jack (Left) + USB-C Flash Port (Right)
        translate([body_h/2 - 15, -22, -1])
            cylinder(d = dc_jack_dia, h = flange_thick + wall_thick + 3);
            
        translate([body_h/2 - 15, 20, -1]) {
            linear_extrude(flange_thick + wall_thick + 3)
                round_rect(usbc_h, usbc_w, 1.2);
            for (sy = [-1, 1]) {
                translate([0, sy * usbc_mount_sp/2, 0])
                    cylinder(d = 3.1, h = flange_thick + wall_thick + 3);
            }
        }
        
        // Row 2 (Lower Bulkhead): 4x Banana Plug Sockets (L+, L-, R+, R-)
        for (i = [0 : 3]) {
            y_pos = -30 + i * 20;
            translate([body_h/2 - 34, y_pos, -1])
                cylinder(d = banana_dia, h = flange_thick + wall_thick + 3);
        }
        
        // Wire Pass-Through Slot between Banana Jacks & Cable Storage Pocket
        translate([body_h/2 - connector_zone_h - wall_thick/2, 0, flange_thick + 8])
            cube([wall_thick + 4, body_w - 24, 10], center = true);
            
        // Flange Wood-Screw Countersunk Mounting Holes (6x)
        for (sx = [-1, 0, 1], sy = [-1, 1]) {
            translate([sx * (body_h/2 - 12), sy * (body_w/2 + flange_overlap/2), -0.1]) {
                cylinder(d = 3.4, h = flange_thick + 1);
                cylinder(d1 = 6.5, d2 = 3.4, h = 1.8);
            }
        }
        
        // 4x Magnet Pockets inside Cable Storage Rim for Snap-Fit Hatch
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([-(body_h/2 - wire_zone_h/2 - wall_thick) + sx * (wire_zone_h/2 - 6),
                       sy * (body_w/2 - wall_thick - 4.5),
                       -0.1])
                cylinder(d = magnet_dia, h = magnet_dep + 0.1);
        }
    }
    
    // Add 4 Corner Ledge Tabs inside Cable Pocket to support Hatch & Magnets
    for (sx = [-1, 1], sy = [-1, 1]) {
        difference() {
            translate([-(body_h/2 - wire_zone_h/2 - wall_thick) + sx * (wire_zone_h/2 - 6),
                       sy * (body_w/2 - wall_thick - 4.5),
                       2.2])
                cylinder(d = 10.0, h = 4.0);
            translate([-(body_h/2 - wire_zone_h/2 - wall_thick) + sx * (wire_zone_h/2 - 6),
                       sy * (body_w/2 - wall_thick - 4.5),
                       -0.1])
                cylinder(d = magnet_dia, h = magnet_dep + 0.1);
        }
    }
}

// ============================================================================
// 2. MAGNETIC SNAP-FIT CABLE STORAGE HATCH (WITH FINGER PULL & CORD NOTCHES)
// ============================================================================
module rear_cable_cover() {
    connector_zone_h = 46.0;
    wire_zone_h      = body_h - connector_zone_h - wall_thick;
    cover_h          = wire_zone_h - wall_thick - 0.6;
    cover_w          = body_w - 2 * wall_thick - 0.6;
    cover_r          = max(1.5, corner_radius - wall_thick - 0.3);
    
    difference() {
        linear_extrude(2.2)
            round_rect(cover_h, cover_w, cover_r);
            
        // Finger Pull Notch at Bottom Edge
        translate([-cover_h/2, 0, -1])
            cylinder(d = 18.0, h = 5);
            
        // Left & Right Cable Exit Notches (allows wires to exit when speakers are detached!)
        for (sy = [-1, 1]) {
            translate([cover_h/2 - 14, sy * (cover_w/2), -1])
                cylinder(d = 9.0, h = 5);
        }
        
        // Matching 4x Magnet Pockets on Back of Hatch
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx * (wire_zone_h/2 - 6), sy * (body_w/2 - wall_thick - 4.5), 2.2 - magnet_dep])
                cylinder(d = magnet_dia, h = magnet_dep + 0.2);
        }
    }
}

// ============================================================================
// RENDER DISPATCHER
// ============================================================================
if (part == "preview") {
    color("DimGray") rear_pocket_body();
    color("SlateGray") translate([-(body_h/2 - (body_h - 46.0 - wall_thick)/2 - wall_thick), 0, -6])
        rear_cable_cover();
} else if (part == "pocket_body") {
    rear_pocket_body();
} else if (part == "cable_cover") {
    rear_cable_cover();
}
