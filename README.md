# openBrushograph
A simple, open source and DIY x-y gantry and z-mechanism for making a brush painting robot

## Quick links
- hardware/: printable parts and sources
- hardware/README.md: structure, print guidance, assembly overview
- LICENSES/: CERN-OHL-S/W/P and CC BY-SA texts

## Overview
openBrushograph is a small CNC-style plotter for brushes and pens. The X–Y gantry is modeled in FreeCAD and the Z mechanism in OpenSCAD.

Full background, tutorials and history live on the SGMK wiki:
https://wiki.sgmk-ssam.ch/wiki/Brushograph

## Setup options (controllers/firmware)
- FluidNC (ESP32 with WebUI): https://installer.fluidnc.com/
  - About FluidNC: http://wiki.fluidnc.com/en/home
- Arduino (GRBL): https://github.com/gnea/grbl
  - GRBL fork for 28BYJ-48 unipolar steppers: https://github.com/TGit-Tech/GRBL-28byj-48
- Universal Gcode Sender (UGS): https://winder.github.io/ugs_website/

See details and tips on the wiki: https://wiki.sgmk-ssam.ch/wiki/Brushograph#How_to_set_it_up

## Printing and assembly
- X–Y: FreeCAD source and STLs in hardware/X-Y_freeCAD/
- Z: OpenSCAD source and STLs in hardware/Z-mechanism_openSCAD/
- Basic print guidance is in hardware/README.md

More context and legacy designs: https://wiki.sgmk-ssam.ch/wiki/Brushograph#Printing_and_assembling_the_Brushograph

## Related links and credits
### Where the inspirations came from
- Z-mechanism inspiration (Thingiverse): https://www.thingiverse.com/thing:7050508
- Earlier mini plotter references:
  - https://www.thingiverse.com/thing:4579436
  - https://www.thingiverse.com/thing:4607077
  - https://www.thingiverse.com/thing:4796222
  - https://www.thingiverse.com/thing:5719788

### Credits
General openBrushograph concept and artistic director, Dominik Mahnic: https://app.assembla.com/spaces/dominik-mahnic/wiki
X–Y: FreeCAD version designed by Stahl: https://github.com/stahlnow
Z: OpenSCAD version designed by dusjagr: https://github.com/dusjagr
 

## License
- Hardware: CERN-OHL-S-2.0 (see LICENSE and LICENSES/)
- Documentation: CC BY-SA 4.0
