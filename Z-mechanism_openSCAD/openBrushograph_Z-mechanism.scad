$fn = 30;

// Redesigned and modified from https://www.thingiverse.com/thing:5719788
// Now available in OpenSCAD, for further modifications
// Gears from: https://www.thingiverse.com/thing:1604369
// Its mostly in german, but you should be ok...
// To Do:
// Implement gears as imported library

/* [Render Selection] */
// Which part to display?
part_to_render = "rail"; // [assembly:Full Assembly, core:Core Assembly (Rail/Rack/Gear), rail:Z Rail, gearwheel:Z Gearwheel, rackpen:Z Rackpen, pen_holder:Pen Holder, brush_insert:Brush Insert, hand_wheel:Hand Wheel]
// Resolution of rounded edges in Preview mode (F5)
preview_fn = 12; // [4:2:32]
// Move the rack up and down in the assembly view to check collisions
assembly_z_travel = -9; // [-30:0.5:20]

/* [General Shape] */
// Diameter of the spherical tool used to round corners (don't exceed 5)
round_edge = 4;
// Extra clearance added to the rail's guide channel to let the rack slide freely
slide_tol = 0.2;
// Adjusts the gear mesh depth by moving the rack closer to the gearwheel (increase if gearwheel is smaller)
tight = 2.4;
// Baseline X-axis offset for the rack's internal geometry
dist = 2.8;
// The total usable Z travel distance (up + down)
z_travel_range = 18; // [10:0.5:50]
// Include cutouts for Rubber Holder on the Z Rail
include_rubber_holder = false;
// Radius of round strengthening fillet between motor bar and vertical spine
motor_mount_fillet_radius = 12; // [0:0.5:16]
// Radius of round strengthening fillet underneath motor bar
motor_mount_bottom_fillet_radius = 5; // [0:0.5:8]

/* [Gears and Wheels] */
// How much of the available travel space to fill with teeth
teeth_ratio = 1; // [0.1:0.05:1.0]
// Helical angle for the gear and rack teeth (0 = straight teeth)
tooth_angle = 0;
// Module of the gear (height of the tooth tip above the pitch line)
tooth_size = 1;
// Overall width of the rack
rackWidth = 8;
// Overall depth/thickness of the rack (do not change from 6 due to hardcoded dependencies)
rackDepth = 6;

/* [Pen Holder] */
// Diameter of the pen/brush to be inserted
pen_diam = 12;
// Diameter of the hole in the brush insert
brush_hole_diam = 6.5;
// Offset the pen holder up or down along the rack
pen_z_offset = 6; // [-20:1:20]

/* [Holes and Screws] */
// Diameter for holes where M3 screws self-tap directly into the plastic
M3_screwhole = 2.8;
// Diameter for holes designed to receive heated M3 brass threaded inserts
M3_insert = 4.1;
// Diameter for loose clearance holes where M3 screws pass through freely
M3_hole = 3.5;
// Diameter of the counterbore to hide M3 screw heads inside the material
M3_screwhead = 5.8;
// Diameter for holes where M4 screws self-tap directly into the plastic
M4_screwhole = 3.9;
// Additional tolerance (air) added to the stepper motor D-shaft hole to ensure it fits easily
Z_luft = 0.1;

/* [Hidden] */
// Command line override for part_to_render
export_part = "";
// Command line override for pen_diam
export_pen_diam = 0;
// Command line override for brush_hole_diam
export_brush_hole = 0;

// Depth of the hole for the threaded insert in the rack
insert_depth = 10;
// Starting Y position of the insert hole (controls how far out the front it starts)
insert_start_y = 1;

// X of the gearwheel's outer face; the gear extends rackWidth from it toward the motor
gear_x = 10.5;

// Uncomment if you have the StepMotor STL
// color("DarkSlateGray") translate([-25,8,9.6]) rotate([90,0,90]) import("StepMotorModelScaled.stl");

actual_part = (export_part != "") ? export_part : part_to_render;
actual_pen_diam = (export_pen_diam > 0) ? export_pen_diam : pen_diam;
actual_brush_hole = (export_brush_hole > 0) ? export_brush_hole : brush_hole_diam;

if (actual_part == "assembly") {
  ext_z = z_travel_range - 16.5 - pen_z_offset;
  Z_rail();
  Z_gearwheel();
  translate([0, 0, ext_z + assembly_z_travel]) Z_rackpen(M3_insert);
  translate([25.5, -6.8 + tight, 18.5 + ext_z + pen_z_offset + assembly_z_travel]) penHolder();
  translate([25.5, -6.8 + tight, 18.5 + ext_z + pen_z_offset + assembly_z_travel]) brushInsert(actual_brush_hole);
  translate([25.5, -10.8 + tight - 9.5, 18.5 + ext_z + pen_z_offset + assembly_z_travel]) rotate([90, 0, 0]) handWheel();
} else if (actual_part == "core") {
  ext_z = z_travel_range - 16.5 - pen_z_offset;
  Z_rail();
  Z_gearwheel();
  translate([0, 0, ext_z + assembly_z_travel]) Z_rackpen(M3_insert);
} else if (actual_part == "rail") {
  rotate([90, 0, 0]) Z_rail();
} else if (actual_part == "gearwheel") {
  rotate([0, 90, 0]) Z_gearwheel();
} else if (actual_part == "rackpen") {
  rotate([0, -90, 0]) Z_rackpen(M3_insert); // Alternatively use M3_screwhole
} else if (actual_part == "pen_holder") {
  penHolder();
} else if (actual_part == "brush_insert") {
  brushInsert(actual_brush_hole);
} else if (actual_part == "hand_wheel") {
  handWheel();
}

// Z-rack with mountable penHolder
module Z_rackpen(lochli) {
  translate([0, 0, 10]) difference() {
      color("fuchsia") translate([0, tight - 0.2, 15]) Z_rack();
      // Hole for threaded insert (red transparent for debugging depth)
      #translate([dist + 5.5, insert_start_y, 9.2 + pen_z_offset]) rotate([90, 0, 0]) cylinder(insert_depth, d=lochli, center=false);
      translate([dist + 6, -6.68 + tight, 8.8 + pen_z_offset]) cube([10, 3.1, 12.4], center=true);
      translate([dist + 6, -6.68 + tight, 50 + pen_z_offset]) cube([1.8, 18.1, 12], center=true);
      translate([dist + 6.8, -6.68 + tight, 45 + pen_z_offset]) cube([2.0, 18.1, 2], center=true);
    }
}

module brushInsert(brushHole) {
  difference() {
    union() {
      cylinder(h=13, d=actual_pen_diam - 0.25, center=true);
      rotate([0, 0, 45]) translate([0, 5.45, 0]) cylinder(h=13, d=1.8, center=true);
      rotate([0, 0, 45]) translate([5.45, 0, 0]) cylinder(h=13, d=1.8, center=true);
    }
    cylinder(h=22, d=brushHole, center=true);
    translate([0, -0, 0]) rotate([90, 0, 0]) cylinder(14, d=4, center=false); // penholder-Holes
  }
}

module penHolder() {

  difference() {
    minkowski() {
      union() {
        cylinder(h=11, d=actual_pen_diam + 1, center=true);
        translate([0, -7, 0]) rotate([90, 0, 0]) cylinder(h=3, d=8, center=true);
      }
      $fn = $preview ? preview_fn : 30;
      sphere(d=2);
    }
    cylinder(h=23, d=actual_pen_diam, center=true);
    rotate([0, 0, 45]) translate([0, 5.5, 0]) cylinder(h=23, d=2, center=true);
    rotate([0, 0, 45]) translate([5.5, 0, 0]) cylinder(h=23, d=2, center=true);

    translate([0, -2, 0]) rotate([90, 0, 0]) cylinder(20, d=3.8, center=false); // penholder-Holes
  }

  difference() {
    union() {
      translate([-11.5, 0, -0.8]) cube([12, 3, 11.3], center=true);
      translate([-14, -2.8, 0]) rotate([90, 0, 0]) cylinder(h=2.6, d=7, center=true);
    }
    #translate([-14, 10, 0]) rotate([90, 0, 0]) cylinder(20, d=3.2, center=false);
    cylinder(h=23, d=actual_pen_diam, center=true);
    // penholder-Holes
  }
}

module handWheel() {
  difference() {
    minkowski() {
      union() {
        cylinder(h=1.5, d=17, center=true);
      }
      $fn = $preview ? preview_fn : 30;
      sphere(d=1.5);
    }
    translate([0, -0, -2]) cylinder(14, d=3.7, center=false); // penholder-Holes
  }
  for (a = [0:45:360]) {
    rotate([0, 0, a]) translate([0, -8, 0]) cylinder(h=3, d=5, center=true);
  }
}

module Z_rail() {
  ext_z = z_travel_range - 16.5 - pen_z_offset;
  color("SteelBlue") difference() {
      minkowski() {
        union() {
          difference() {
            translate([1, -10, 24 + ext_z / 2]) cube([14 - round_edge, 10 - round_edge, 54 - round_edge + ext_z], center=true); // Vertikal
            translate([2, -18, 2]) cube([20, 50, 40 + ext_z]);
            translate([2, -9, -12 + 2]) cube([20, 50, 30]);
          }
          translate([-3, 8, 8]) cube([6 - round_edge, 46 - round_edge, 12 - round_edge], center=true); // Balken
          // Round strengthening fillet between motor bar (Balken) and vertical spine (Vertikal)
          if (motor_mount_fillet_radius > 0) {
            fillet_z = 14 - round_edge / 2;
            fillet_y = -5 - round_edge / 2;
            fillet_overlap = 2;
            translate([-3, 0, 0]) rotate([0, -90, 0])
              linear_extrude(height = 6 - round_edge, center = true)
                difference() {
                  translate([fillet_z - fillet_overlap, fillet_y - fillet_overlap])
                    square([motor_mount_fillet_radius + fillet_overlap, motor_mount_fillet_radius + fillet_overlap]);
                  translate([fillet_z + motor_mount_fillet_radius, fillet_y + motor_mount_fillet_radius])
                    circle(r = motor_mount_fillet_radius, $fn = 40);
                }
          }
          // Round strengthening fillet underneath motor bar merged into the rail guide block
          if (motor_mount_bottom_fillet_radius > 0) {
            b_fillet_z = 2 + round_edge / 2;
            b_fillet_y = -5 - round_edge / 2;
            b_fillet_overlap = 2;
            R_bot = motor_mount_bottom_fillet_radius;

            // Spans from motor face (X = -6) across X = 0 and merges into the rail block (X = 1.5)
            x0 = -6 + round_edge / 2;
            x1 = 1.5 - round_edge / 2;

            translate([(x0 + x1) / 2, 0, 0]) rotate([0, -90, 0])
              linear_extrude(height = x1 - x0, center = true)
                difference() {
                  translate([b_fillet_z - R_bot, b_fillet_y - b_fillet_overlap])
                    square([R_bot + b_fillet_overlap, R_bot + b_fillet_overlap + 4]);
                  translate([b_fillet_z - R_bot, b_fillet_y + R_bot + 4])
                    circle(r = R_bot, $fn = 40);
                }
          }
          difference() {
            translate([8, -4, 20 + ext_z / 2]) cube([16 - round_edge, 22 - round_edge, 62 - round_edge + ext_z], center=true); // Z-Rail
            translate([10, 7.0, 36.5 + ext_z / 2]) cube([28.0, 10.1, 30 + ext_z], center=true);
            translate([0, -18, 2]) cube([20, 50, 40 + ext_z]);
            translate([0, -3 + 2, -32 + 0]) cube([20, 50, 60]);
          }
        }
        $fn = $preview ? preview_fn : 30;
        sphere(d=round_edge);
      }
      translate([rackWidth / 2 + dist + 1, -rackDepth - 0.5 + tight - 0.5 * slide_tol, 14 + ext_z / 2]) cube([rackWidth + 2 + slide_tol, 3 + 0.5 * slide_tol, 78 + ext_z], center=true); // Führung
      translate([rackWidth / 2 + dist, -2 + tight - 0.5 * slide_tol, 0 + ext_z / 2]) cube([rackWidth + slide_tol, rackDepth + 0.5 * slide_tol, 70 + ext_z], center=true); // Führung
      translate([rackWidth / 2 + dist - 4, -rackDepth + 1 + tight - 0.25 * slide_tol, 15.9]) rotate([0, 0, 0]) linear_extrude(78.2, center=true, scale=1) polygon(points=[[-slide_tol / 2, 0], [2, 2 + slide_tol / 2], [8, 2 + slide_tol / 2], [10 + slide_tol / 2, 0]]);
      translate([-10, 8, 0]) rotate([0, 90, 0]) cylinder(20, d=12, center=false); // MotorCenter
      translate([-10, 25.7, 8.2]) rotate([0, 90, 0]) cylinder(20, d=3.5, center=false); // MotorScrewHoles
      translate([-2, 25.7, 8.2]) rotate([0, 90, 0]) cylinder(8.1, d=5.8, center=false); // MotorHolesHead
      translate([-10, -9.7, 8.2]) rotate([0, 90, 0]) cylinder(20, d=3.5, center=false); // MotorScrewHoles
      translate([-2, -9.7, 8.2]) rotate([0, 90, 0]) cylinder(8.1, d=5.8, center=false); // MotorScrewHead
      //Rubber Holder
      if (include_rubber_holder) {
        translate([14.4, -6.68 + tight, 36.7]) cube([1.5, 28.1, 12], center=true);
        translate([12, -6.68 + tight + 9.4, 46.5]) rotate([0, -28, 0]) cube([1.6, 8.1, 12], center=true);
        //translate([14,-6.68+tight-13,46.5]) rotate([0,-28,0]) cube([2.0,8.1,12], center = true);
      }
    }
}

module Z_rack() {
  ext_z = z_travel_range - 16.5 - pen_z_offset;
  L_rod = 71 + ext_z;

  // The teeth stop at the upper end of the pen holder.
  // In Z_rack coordinates, the pen holder top is at Z = 5.0 + pen_z_offset.
  // We use Z = 2.0 + pen_z_offset for the teeth top (which matches the original 42mm length perfectly).
  // Teeth bottom is -40 - ext_z. Max length = (2.0 + pen_z_offset) - (-40 - ext_z) = 42 + ext_z + pen_z_offset.
  L_teeth_max = 42 + ext_z + pen_z_offset;
  L_teeth_raw = L_teeth_max * teeth_ratio;

  // Quantize teeth length so it's always a full number of teeth
  modul_eff = 1 * (1 - spiel);
  c_eff = modul_eff / 6;
  mx = modul_eff / cos(tooth_angle);
  pitch = pi * mx;
  num_teeth = floor(L_teeth_raw / pitch); // floor ensures we never clip into the block
  L_teeth = num_teeth * pitch;

  // Calculate exactly how the zahnstange module anchors its geometry so we can align it flush with the rod bottom
  a_eff = 2 * mx * tan(25) + c_eff * tan(25);
  b_eff = pi * mx / 2 - 2 * mx * tan(25);
  x_shift = rackWidth * tan(tooth_angle);
  nz = ceil((L_teeth + abs(2 * x_shift)) / pitch);
  min_x = -pitch * (nz - 1) / 2 - a_eff - b_eff / 2;

  rod_bottom = -39 - ext_z;
  teeth_center_z = rod_bottom + L_teeth + min_x;

  // Stange (Teeth)
  translate([dist, 0, teeth_center_z]) rotate([0, 90, 0]) zahnstange(modul=1, laenge=L_teeth, hoehe=rackDepth, breite=rackWidth, eingriffswinkel=25, schraegungswinkel=tooth_angle);
  // Base Bar
  translate([rackWidth / 2 + dist + 1, -rackDepth - 0.5, -3.5 - ext_z / 2]) cube([rackWidth + 2, 3, L_rod], center=true);
  // Side Wedge
  translate([rackWidth / 2 + dist - 4, -rackDepth + 1, -3.5 - ext_z / 2]) rotate([0, 0, 0]) linear_extrude(L_rod, center=true, scale=1) polygon(points=[[0, 0], [2, 2], [8, 2], [10, 0]]);
}

module Z_gearwheel() {
  // Stirnrad 
  translate([gear_x, 8, 0]) rotate([0, -90, 0]) mirror([1, 0, 0]) difference() {
          stirnrad(modul=1, zahnzahl=12, breite=rackWidth, bohrung=0, eingriffswinkel=25, schraegungswinkel=tooth_angle, optimiert=true);
          shaft();
        }
  translate([-2, 8, 0]) rotate([0, 90, 0]) difference() {
        cylinder(10, d=9, center=false);
        shaft();
      }
}

module old() {
  color("PaleVioletRed") translate([6.2, 2, 15.5]) rotate([0, -90, 0]) import("Holder_closed.stl");
  color("fuchsia") translate([-4, 0, 0]) rotate([-90, 0, 0]) import("Z_rack.stl");
  translate([36, -8, -16]) rotate([-90, 0, 90]) import("Z.stl");
  color("HotPink") translate([10, 14.5, 2]) rotate([0, 180, 0]) import("Z_gear.stl");
  color("DarkSlateGray") translate([5, 14.5, -36]) rotate([0, 0, 90]) import("StepMotorModelScaled.stl");
}

module shaft() {
  $fn = 96;
  difference() {
    cylinder(h=10, d=5 + 2 * Z_luft, center=false);
    translate([-5, 1.5 + Z_luft, -1]) cube([10, 10, 20]);
    translate([-5, -11.5 - Z_luft, -1]) cube([10, 10, 20]);
  }
}

/* Bibliothek für Evolventen-Zahnräder, Schnecken und Zahnstangen

Enthält die Module
- zahnstange(modul, laenge, hoehe, breite, eingriffswinkel=20, schraegungswinkel=0)
- stirnrad(modul, zahnzahl, breite, bohrung, eingriffswinkel=20, schraegungswinkel=0, optimiert=true)
- zahnstange_und_rad (modul, laenge_stange, zahnzahl_rad, hoehe_stange, bohrung_rad, breite, eingriffswinkel=20, schraegungswinkel=0, zusammen_gebaut=true, optimiert=true)


Beispiele für jedes Modul befinden sich auskommentiert am Ende dieser Datei

Autor:		Dr Jörg Janssen
Stand:		29. Oktober 2018
Version:	2.3
Lizenz:		Creative Commons - Attribution, Non Commercial, Share Alike

Erlaubte Module nach DIN 780:
0.05 0.06 0.08 0.10 0.12 0.16
0.20 0.25 0.3  0.4  0.5  0.6
0.7  0.8  0.9  1    1.25 1.5
2    2.5  3    4    5    6
8    10   12   16   20   25
32   40   50   60

*/

//translate([6,0,0]) rotate([0,90,0]) zahnstange_und_rad (modul=1.0, laenge_stange=70, zahnzahl_rad=15, hoehe_stange=6, bohrung_rad=1, breite=8, eingriffswinkel=25, schraegungswinkel=-10, zusammen_gebaut=true, optimiert=true);

// Allgemeine Variablen
pi = 3.14159;
rad = 57.29578;
spiel = 0.05; // Spiel zwischen Zähnen

// zahnstange(modul=1, laenge=30, hoehe=5, breite=5, eingriffswinkel=20, schraegungswinkel=20);

// stirnrad (modul=1, zahnzahl=30, breite=5, bohrung=4, eingriffswinkel=20, schraegungswinkel=20, optimiert=true);

/*	Wandelt Radian in Grad um */
function grad(eingriffswinkel) = eingriffswinkel * rad;

/*	Wandelt Grad in Radian um */
function radian(eingriffswinkel) = eingriffswinkel / rad;

/*	Wandelt 2D-Polarkoordinaten in kartesische um
    Format: radius, phi; phi = Winkel zur x-Achse auf xy-Ebene */
function pol_zu_kart(polvect) =
  [
    polvect[0] * cos(polvect[1]),
    polvect[0] * sin(polvect[1]),
  ];

/*	Kreisevolventen-Funktion:
    Gibt die Polarkoordinaten einer Kreisevolvente aus
    r = Radius des Grundkreises
    rho = Abrollwinkel in Grad */
function ev(r, rho) =
  [
    r / cos(rho),
    grad(tan(rho) - radian(rho)),
  ];

/*  Kugelevolventen-Funktion
    Gibt den Azimutwinkel einer Kugelevolvente aus
    theta0 = Polarwinkel des Kegels, an dessen Schnittkante zur Großkugel die Evolvente abrollt
    theta = Polarwinkel, für den der Azimutwinkel der Evolvente berechnet werden soll */
function kugelev(theta0, theta) = 1 / sin(theta0) * acos(cos(theta) / cos(theta0)) - acos(tan(theta0) / tan(theta));

/*  Wandelt Kugelkoordinaten in kartesische um
    Format: radius, theta, phi; theta = Winkel zu z-Achse, phi = Winkel zur x-Achse auf xy-Ebene */
function kugel_zu_kart(vect) =
  [
    vect[0] * sin(vect[1]) * cos(vect[2]),
    vect[0] * sin(vect[1]) * sin(vect[2]),
    vect[0] * cos(vect[1]),
  ];

/*	prüft, ob eine Zahl gerade ist
	= 1, wenn ja
	= 0, wenn die Zahl nicht gerade ist */
function istgerade(zahl) =
  (zahl == floor(zahl / 2) * 2) ? 1 : 0;

/*	größter gemeinsamer Teiler
	nach Euklidischem Algorithmus.
	Sortierung: a muss größer als b sein */
function ggt(a, b) =
  a % b == 0 ? b : ggt(b, a % b);

/*	Polarfunktion mit polarwinkel und zwei variablen */
function spirale(a, r0, phi) =
  a * phi + r0;

/*	Kopiert und dreht einen Körper */
module kopiere(vect, zahl, abstand, winkel) {
  for (i = [0:zahl - 1]) {
    translate(v=vect * abstand * i)
      rotate(a=i * winkel, v=[0, 0, 1])
        children(0);
  }
}

/*  Zahnstange
    modul = Höhe des Zahnkopfes über der Wälzgeraden
    laenge = Länge der Zahnstange
    hoehe = Höhe der Zahnstange bis zur Wälzgeraden
    breite = Breite eines Zahns
    eingriffswinkel = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    schraegungswinkel = Schrägungswinkel zur Zahnstangen-Querachse; 0° = Geradverzahnung */
module zahnstange(modul, laenge, hoehe, breite, eingriffswinkel = 20, schraegungswinkel = 0) {

  // Dimensions-Berechnungen
  modul = modul * (1 - spiel);
  c = modul / 6; // Kopfspiel
  mx = modul / cos(schraegungswinkel); // Durch Schrägungswinkel verzerrtes modul in x-Richtung
  a = 2 * mx * tan(eingriffswinkel) + c * tan(eingriffswinkel); // Flankenbreite
  b = pi * mx / 2 - 2 * mx * tan(eingriffswinkel); // Kopfbreite
  x = breite * tan(schraegungswinkel); // Verschiebung der Oberseite in x-Richtung durch Schrägungswinkel
  nz = ceil((laenge + abs(2 * x)) / (pi * mx)); // Anzahl der Zähne

  translate([-pi * mx * (nz - 1) / 2 - a - b / 2, -modul, 0]) {
    intersection() {
      // Erzeugt ein Prisma, das in eine Quadergeometrie eingepasst wird
      kopiere([1, 0, 0], nz, pi * mx, 0) {
        polyhedron(
          points=[
            [0, -c, 0],
            [a, 2 * modul, 0],
            [a + b, 2 * modul, 0],
            [2 * a + b, -c, 0],
            [pi * mx, -c, 0],
            [pi * mx, modul - hoehe, 0],
            [0, modul - hoehe, 0], // Unterseite
            [0 + x, -c, breite],
            [a + x, 2 * modul, breite],
            [a + b + x, 2 * modul, breite],
            [2 * a + b + x, -c, breite],
            [pi * mx + x, -c, breite],
            [pi * mx + x, modul - hoehe, breite],
            [0 + x, modul - hoehe, breite],
          ], // Oberseite
          faces=[
            [6, 5, 4, 3, 2, 1, 0], // Unterseite
            [1, 8, 7, 0],
            [9, 8, 1, 2],
            [10, 9, 2, 3],
            [11, 10, 3, 4],
            [12, 11, 4, 5],
            [13, 12, 5, 6],
            [7, 13, 6, 0],
            [7, 8, 9, 10, 11, 12, 13], // Oberseite
          ]
        );
      }
      ;
      translate([abs(x), -hoehe + modul - 0.5, -0.5]) {
        cube([laenge, hoehe + modul + 1, breite + 1]); // Quader, der das Volumen der Zahnstange umfasst
      }
    }
    ;
  }
  ;
}

/*  Stirnrad
    modul = Höhe des Zahnkopfes über dem Teilkreis
    zahnzahl = Anzahl der Radzähne
    breite = Zahnbreite
    bohrung = Durchmesser der Mittelbohrung
    eingriffswinkel = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    schraegungswinkel = Schrägungswinkel zur Rotationsachse; 0° = Geradverzahnung
	optimiert = Löcher zur Material-/Gewichtsersparnis bzw. Oberflächenvergößerung erzeugen, wenn Geometrie erlaubt */
module stirnrad(modul, zahnzahl, breite, bohrung, eingriffswinkel = 20, schraegungswinkel = 0, optimiert = true) {

  // Dimensions-Berechnungen	
  d = modul * zahnzahl; // Teilkreisdurchmesser
  r = d / 2; // Teilkreisradius
  alpha_stirn = atan(tan(eingriffswinkel) / cos(schraegungswinkel)); // Schrägungswinkel im Stirnschnitt
  db = d * cos(alpha_stirn); // Grundkreisdurchmesser
  rb = db / 2; // Grundkreisradius
  da = (modul < 1) ? d + modul * 2.2 : d + modul * 2; // Kopfkreisdurchmesser nach DIN 58400 bzw. DIN 867
  ra = da / 2; // Kopfkreisradius
  c = (zahnzahl < 3) ? 0 : modul / 6; // Kopfspiel
  df = d - 2 * (modul + c); // Fußkreisdurchmesser
  rf = df / 2; // Fußkreisradius
  rho_ra = acos(rb / ra); // maximaler Abrollwinkel;
  // Evolvente beginnt auf Grundkreis und endet an Kopfkreis
  rho_r = acos(rb / r); // Abrollwinkel am Teilkreis;
  // Evolvente beginnt auf Grundkreis und endet an Kopfkreis
  phi_r = grad(tan(rho_r) - radian(rho_r)); // Winkel zum Punkt der Evolvente auf Teilkreis
  gamma = rad * breite / (r * tan(90 - schraegungswinkel)); // Torsionswinkel für Extrusion
  schritt = rho_ra / 16; // Evolvente wird in 16 Stücke geteilt
  tau = 360 / zahnzahl; // Teilungswinkel

  r_loch = (2 * rf - bohrung) / 8; // Radius der Löcher für Material-/Gewichtsersparnis
  rm = bohrung / 2 + 2 * r_loch; // Abstand der Achsen der Löcher von der Hauptachse
  z_loch = floor(2 * pi * rm / (3 * r_loch)); // Anzahl der Löcher für Material-/Gewichtsersparnis

  optimiert = (optimiert && r >= breite * 1.5 && d > 2 * bohrung); // ist Optimierung sinnvoll?

  // Zeichnung
  union() {
    rotate([0, 0, -phi_r - 90 * (1 - spiel) / zahnzahl]) {
      // Zahn auf x-Achse zentrieren;
      // macht Ausrichtung mit anderen Rädern einfacher

      linear_extrude(height=breite, twist=gamma) {
        difference() {
          union() {
            zahnbreite = (180 * (1 - spiel)) / zahnzahl + 2 * phi_r;
            circle(rf); // Fußkreis	
            for (rot = [0:tau:360]) {
              rotate(rot) {
                // "Zahnzahl-mal" kopieren und drehen
                polygon(
                  concat(
                    // Zahn
                    [[0, 0]], // Zahnsegment beginnt und endet im Ursprung
                    [
                      for (rho = [0:schritt:rho_ra]) // von null Grad (Grundkreis)
                      // bis maximalen Evolventenwinkel (Kopfkreis)
                      pol_zu_kart(ev(rb, rho)),
                    ], // Erste Evolventen-Flanke

                    [pol_zu_kart(ev(rb, rho_ra))], // Punkt der Evolvente auf Kopfkreis

                    [
                      for (rho = [rho_ra:-schritt:0]) // von maximalen Evolventenwinkel (Kopfkreis)
                      // bis null Grad (Grundkreis)
                      pol_zu_kart([ev(rb, rho)[0], zahnbreite - ev(rb, rho)[1]]),
                    ]
                    // Zweite Evolventen-Flanke
                    // (180*(1-spiel)) statt 180 Grad,
                    // um Spiel an den Flanken zu erlauben
                  )
                );
              }
            }
          }
          circle(r=rm + r_loch * 1.49); // "Bohrung"
        }
      }
    }
    // mit Materialersparnis
    if (optimiert) {
      linear_extrude(height=breite) {
        difference() {
          circle(r=(bohrung + r_loch) / 2);
          circle(r=bohrung / 2); // Bohrung
        }
      }
      linear_extrude(height=(breite - r_loch / 2 < breite * 2 / 3) ? breite * 2 / 3 : breite - r_loch / 2) {
        difference() {
          circle(r=rm + r_loch * 1.51);
          union() {
            circle(r=(bohrung + r_loch) / 2);
            for (i = [0:1:z_loch]) {
              translate(kugel_zu_kart([rm, 90, i * 360 / z_loch]))
                circle(r=r_loch);
            }
          }
        }
      }
    }
    // ohne Materialersparnis
    else {
      linear_extrude(height=breite) {
        difference() {
          circle(r=rm + r_loch * 1.51);
          circle(r=bohrung / 2);
        }
      }
    }
  }
}

/*	Zahnstange und -Rad
    modul = Höhe des Zahnkopfes über dem Teilkreis
    laenge_stange = Laenge der Zahnstange
    zahnzahl_rad = Anzahl der Radzähne
	hoehe_stange = Höhe der Zahnstange bis zur Wälzgeraden
    bohrung_rad = Durchmesser der Mittelbohrung des Stirnrads
	breite = Breite eines Zahns
    eingriffswinkel = Eingriffswinkel, Standardwert = 20° gemäß DIN 867. Sollte nicht größer als 45° sein.
    schraegungswinkel = Schrägungswinkel zur Rotationsachse, Standardwert = 0° (Geradverzahnung) */
module zahnstange_und_rad(modul, laenge_stange, zahnzahl_rad, hoehe_stange, bohrung_rad, breite, eingriffswinkel = 20, schraegungswinkel = 0, zusammen_gebaut = true, optimiert = true) {

  abstand = zusammen_gebaut ? modul * zahnzahl_rad / 2 : modul * zahnzahl_rad;

  zahnstange(modul, laenge_stange, hoehe_stange, breite, eingriffswinkel, -schraegungswinkel);
  translate([0, abstand, 0])
    rotate(a=360 / zahnzahl_rad)
      stirnrad(modul, zahnzahl_rad, breite, bohrung_rad, eingriffswinkel, schraegungswinkel, optimiert);
}
