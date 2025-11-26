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
- Material: PLA or PETG
- Layer height: 0.2 mm typical
- Perimeters: 3
- Infill: 20–35% (gear/rack 40–60% if needed)
- Supports: Only where required; racks and rails no supports; pen holder insert may need support depending on printer

## Assemblies
- X axis: rail, rack, pinion, endstop mount
- Y axis: rail, rack, pinion
- Z mechanism: rail, rack/pen holder, hand wheel or gear, brush/pen inserts

## Notes
- Naming is standardized to `openBrushograph_*` for all STLs.
- Z `.scad` contains parameterized modules to export each part variant as separate STL.

## License
- Hardware is licensed under CERN-OHL-S-2.0 by default (see LICENSES/). Documentation is CC BY-SA 4.0.

