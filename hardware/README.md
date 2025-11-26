# openBrushograph Hardware

This folder contains the buildable hardware for the openBrushograph project.

## Structure
- X-Y_freeCAD/
  - openBrushograph_XY.FCStd (source)
  - V3_STL/ (exported printable parts for X and Y)
- Z-mechanism_openSCAD/
  - openBrushograph_Z-mechanism.scad (source)
  - Z-mechanism_V3_STL/ (exported printable parts for Z)
- BOM.csv (bill of materials)

## Print guidance (quick)
- Material: PLA
- Layer height: 0.2 mm typical
- Perimeters: 2
- Infill: 30-40%
- Supports: should all work without support

## Assemblies
- X axis: rail, rack, pinion, endstop mount
- Y axis: rail, rack, pinion
- Z mechanism: rail, rack with pen holder, hand wheel, gear, pen holder & brush inserts

## Notes

## License
- Hardware is licensed under CERN-OHL-S-2.0 by default (see LICENSES/). Documentation is CC BY-SA 4.0.

