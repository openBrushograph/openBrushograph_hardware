
all();

module all(){
    /*
// Petri ishes
 translate([0,0,3]) difference(){  
    minkowski(){ 
        translate([60,-120,0]) translate([18,157,-0.1]) cylinder(h=9, r=18, $fn=96, center=false);
        sphere(r=2.1, $fn=96);
    }
      minkowski(){
      translate([60,-120,1]) translate([18,157,-0.1]) cylinder(h=9, r=17, $fn=96, center=false);
         sphere(r=2, $fn=96);
     }
     translate([50,10,9]) cube([50,50,20]);
 }
    
    
    /*

// Petri dish holders 4 x
translate([0,-120,0]) difference(){
    union(){
        minkowski(){
        color("red") translate([4,0,1]) cube([50-12, 180, 1], center=false);
        $fn=30;
        sphere(r=4);
        }
    }
    translate([18,157,-0.1]) cylinder(h=15, r=20.2, center=false);
    translate([18,113,-0.1]) cylinder(h=15, r=20.2, center=false);
    translate([18,69,-0.1]) cylinder(h=15, r=20.2, center=false);
    translate([18,24,-0.1]) cylinder(h=15, r=20.2, center=false);
    translate([-4,-4,-4]) cube([60, 190, 6], center=false);
    translate([38,4,-4]) cylinder(h=25, r=1.4, center=false, $fn=20);
    translate([38,176,-4]) cylinder(h=25, r=1.4, center=false, $fn=20);
    translate([38,91,-4]) cylinder(h=25, r=1.4, center=false, $fn=20);
    translate([44,15,5.6]) rotate([0,0,90]) linear_extrude(height = 2) text("WASH", font = "Liberation Sans:style=Bold", size = 4); 
    translate([44,64,5.6]) rotate([0,0,90]) linear_extrude(height = 2) text("C 1", font = "Liberation Sans:style=Bold", size = 4);
    translate([44,108,5.6]) rotate([0,0,90]) linear_extrude(height = 2) text("C 2", font = "Liberation Sans:style=Bold", size = 4);
    translate([44,154,5.6]) rotate([0,0,90]) linear_extrude(height = 2) text("C 3", font = "Liberation Sans:style=Bold", size = 4);
}
*/

// Petri dish Cover
difference(){
minkowski(){
translate([-3,-126,3]) cube([52, 192, 7], center=false);
    $fn=30;
        sphere(r=2);
}
translate([-12,-130,-3]) cube([80, 200, 6], center=false);

translate([1,-120,0]) difference(){
    union(){
        minkowski(){
        color("red") translate([2,0,0]) cube([40, 180, 5.5], center=false);
        $fn=30;
        sphere(r=6);
        }
    }
    translate([-4,-4,-4]) cube([60, 190, 5], center=false);

    }
  }

}