# REPLACE STOCK SLICER PURGE

## STOCK PLUS4 PURGE LINE (FROM: SLICER > MACHINE START GCODE)
```
; STOCK PLUS4 PURGE LINE (PITA TO REMOVE FROM PLATE)
G1 E3 F1800
G1 X{(min(print_bed_max[0] - 12, first_layer_print_min[0] + 80))} E{85 * 0.5 * initial_layer_print_height * nozzle_diameter[0]} F3000
G1 Y{max((min(print_bed_max[1] - 3, first_layer_print_min[1] + 80) - 85), 0) + 2} E{2 * 0.5 * initial_layer_print_height * nozzle_diameter[0]} F3000
G1 X{max((min(print_bed_max[0] - 12, first_layer_print_min[0] + 80) - 85), 0)} E{85 * 0.5 * initial_layer_print_height * nozzle_diameter[0]} F3000
G1 Y{max((min(print_bed_max[1] - 3, first_layer_print_min[1] + 80) - 85), 0) + 85} E{83 * 0.5 * initial_layer_print_height * nozzle_diameter[0]} F3000
G1 X{max((min(print_bed_max[0] - 12, first_layer_print_min[0] + 80) - 85), 0) + 2} E{2 * 0.5 * initial_layer_print_height * nozzle_diameter[0]} F3000
G1 Y{max((min(print_bed_max[1] - 3, first_layer_print_min[1] + 80) - 85), 0) + 3} E{82 * 0.5 * initial_layer_print_height * nozzle_diameter[0]} F3000
G1 X{max((min(print_bed_max[0] - 12, first_layer_print_min[0] + 80) - 85), 0) + 3} Z0
```

### CHATGPT'S EXPLANATION OF THE STOCK PURGE ROUTINE:
```
G1 E3 F1800
; PRIMES THE EXTRUDER BY PUSHING 3 MM OF FILAMENT AT 30 MM/S TO ENSURE
; THE NOZZLE IS FULLY PRESSURIZED BEFORE DRAWING THE PURGE LINE

G1 X{(min(print_bed_max[0] - 12, first_layer_print_min[0] + 80))} E{85 * 0.5 * initial_layer_print_height * nozzle_diameter[0]} F3000
; MOVES IN THE POSITIVE X DIRECTION WHILE EXTRUDING A CALCULATED VOLUME OF FILAMENT
; THIS DRAWS THE FIRST LONG HORIZONTAL SEGMENT OF THE PURGE LINE
; THE X POSITION IS CLAMPED TO STAY INSIDE THE BED AND NEAR THE FRONT/EDGE
; EXTRUSION AMOUNT IS COMPUTED FROM LINE LENGTH (85), LAYER HEIGHT, AND NOZZLE DIAMETER

G1 Y{max((min(print_bed_max[1] - 3, first_layer_print_min[1] + 80) - 85), 0) + 2} E{2 * 0.5 * initial_layer_print_height * nozzle_diameter[0]} F3000
; MOVES SLIGHTLY IN THE POSITIVE Y DIRECTION WHILE EXTRUDING A SMALL AMOUNT
; THIS CREATES A SHORT VERTICAL JOG TO FORM A ZIG-ZAG PATTERN
; THE POSITION IS CLAMPED TO PREVENT MOVING OFF THE FRONT EDGE OF THE BED

G1 X{max((min(print_bed_max[0] - 12, first_layer_print_min[0] + 80) - 85), 0)} E{85 * 0.5 * initial_layer_print_height * nozzle_diameter[0]} F3000
; MOVES BACK IN THE NEGATIVE X DIRECTION WHILE EXTRUDING
; THIS DRAWS THE SECOND LONG HORIZONTAL PURGE LINE IN THE OPPOSITE DIRECTION
; COMPLETES A FULL BACK-AND-FORTH PURGE STROKE

G1 Y{max((min(print_bed_max[1] - 3, first_layer_print_min[1] + 80) - 85), 0) + 85} E{83 * 0.5 * initial_layer_print_height * nozzle_diameter[0]} F3000
; MOVES UPWARD IN Y WHILE EXTRUDING MOST OF THE LINE LENGTH
; THIS EXTENDS THE PURGE PATTERN INTO A LARGE RECTANGULAR SHAPE
; USED TO FLUSH OLD FILAMENT AND STABILIZE FLOW

G1 X{max((min(print_bed_max[0] - 12, first_layer_print_min[0] + 80) - 85), 0) + 2} E{2 * 0.5 * initial_layer_print_height * nozzle_diameter[0]} F3000
; MOVES SLIGHTLY IN POSITIVE X WHILE EXTRUDING A VERY SMALL AMOUNT
; THIS IS A MICRO OFFSET TO AVOID OVERLAPPING THE PREVIOUS LINE
; HELPS PREVENT OVEREXTRUSION LINES FROM STACKING

G1 Y{max((min(print_bed_max[1] - 3, first_layer_print_min[1] + 80) - 85), 0) + 3} E{82 * 0.5 * initial_layer_print_height * nozzle_diameter[0]} F3000
; MOVES BACK DOWN IN Y WHILE EXTRUDING
; DRAWS THE FINAL LONG VERTICAL PURGE SEGMENT
; COMPLETES THE RECTANGULAR ZIG-ZAG PURGE BLOCK

G1 X{max((min(print_bed_max[0] - 12, first_layer_print_min[0] + 80) - 85), 0) + 3} Z0
; MOVES SLIGHTLY IN X WHILE DROPPING Z TO 0
; THIS FINAL MOVE OFTEN SMEARS OR ANCHORS THE END OF THE PURGE LINE
; CAN CAUSE THE PURGE TO STICK TO THE BED MORE THAN NECESSARY

```


## ADAPTIVE / KAMP-STYLE PURGE LINE (FROM: https://www.youtube.com/watch?v=PqcEz09jQ7c )

```
; RESET EXTRUDER
G92 E0.0

; POSITION 10mm DOWN FROM THE LOWER LEFT OF THE FIRST LAYER
G1 X{first_layer_print_min[0]} Y{first_layer_print_min[1]-10} Z0.8 F6000.0 

; EXTRUDE 30mm OF FILAMENT IN THE X DIRECTION
G1 X{first_layer_print_min[0]+30} Y{first_layer_print_min[1]-10} E30 F360.0 

; RESET EXTRUDER
G92 E0.0

; SMALL RETRACTION
G1 E-0.5 F2100

; MOVE AN ADDITIONAL 10mm WITHOUT EXTRUDING
G1 X{first_layer_print_min[0]+40} F6000.0

; RESET EXTRUDER
G92 E0.0
```

