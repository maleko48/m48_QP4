# STOCK FreeDi CONFIGS

## PATH:```~/home/mks/printer_data/config```

### crowsnest.conf
```
#### crowsnest.conf
#### This is the default config after installation.
#### It is also used as the default config in MainsailOS.
#### For details on how to configure this to your needs, see:
#### https://github.com/mainsail-crew/crowsnest/blob/master/README.md


#####################################################################
####                                                            #####
####      Information about ports and according URL's           #####
####                                                            #####
#####################################################################
####                                                            #####
####    Port 8080 equals /webcam/?action=[stream/snapshot]      #####
####    Port 8081 equals /webcam2/?action=[stream/snapshot]     #####
####    Port 8082 equals /webcam3/?action=[stream/snapshot]     #####
####    Port 8083 equals /webcam4/?action=[stream/snapshot]     #####
####                                                            #####
####    Note: These ports are default for most Mainsail         #####
####    installations. Using any other port would involve       #####
####    changing the proxy configuration or using URLs          #####
####    with the specific port like                             #####
####    http://<ip>:<port>/?action=[stream/snapshot]            #####
####                                                            #####
#####################################################################
####    RTSP Stream URL: ( if enabled and supported )           #####
####    rtsp://<ip>:<rtsp_port>/stream.h264                     #####
#####################################################################


[crowsnest]
log_path: /home/mks/printer_data/logs/crowsnest.log
log_level: verbose                      # Valid Options are quiet/verbose/debug
delete_log: true                       # Deletes log on every restart, if set to true
no_proxy: false                         # If set to true, no reverse proxy is required. Only change this, if you know what you are doing.

[cam 1]
mode: ustreamer                         # ustreamer - Provides MJPG and snapshots. (All devices)
                                        # camera-streamer - Provides WebRTC, MJPG and snapshots. (only RPiOS + RPi 0/1/2/3/4)
enable_rtsp: false                      # If camera-streamer is used, this also enables usage of an RTSP server
rtsp_port: 8554                         # Set different ports for each device!
port: 8080                              # HTTP/MJPG stream/snapshot port

# Stock X3 series, Q1 Pro and Plus4 series camera
device: /dev/v4l/by-id/usb-SYX-231020-J_HD_Camera-video-index0
resolution: 640x480
max_fps: 16

# # Stock X3 series camera
# device: /dev/v4l/by-id/usb-SYX-231020-J_HD_Camera-video-index0
# resolution: 1920x1080
# max_fps: 16

# # Sunplus camera:
# device: /dev/v4l/by-id/usb-Sunplus_IT_Co_FHD_Camera-video-index0
# resolution: 800x600
# max_fps: 10

```

### freedi.cfg
```
#####################################################################
# FreeDi config
#####################################################################
[freedi]
# Printer model. Currently supported: x-smart3, x-plus3, x-max3, q1_pro, plus4 and unknown (for autodetection)
printer_model: unknown
# Baud rate for serial communication. Stock mainboard with standard firmware: 921600 | Legacy firmware: 115200
baudrate: 921600
# Serial port for the LCD. Stock: /dev/ttyS1 | USB<->TTL adapter: /dev/ttyUSB0 | BTT Manta M5P: /dev/ttyS0
# For the Plus4 if you use the USB<->TTL adapter: TX <-> A, RX <-> Y
serial_port: /dev/ttyS1
# URL of the printer service
url: 127.0.0.1
# Port of the moonraker service. Default: 7125
moonraker_port: 7125
# Port of the web user interface (Mainsail | Fluidd). Default: 80
webUI_port: 80
# API key for the printer
api_key: XXXXXX
# Path to the Klippy socket file
klippy_socket: /home/mks/printer_data/comms/klippy.sock
# Specify if you want to use the stable or beta channel. Caution: beta firmwares have more potential to have bugs.
channel: stable
# Enable FreeDi wizzard: True | False
wizard: True

# default values for on screen activation
default_temp_extruder: 220
default_temp_bed: 60
default_temp_chamber: 45
default_speed_partfan: 100
default_speed_sidefan: 100
default_speed_filterfan: 100

# Synchronize case light with display: True | False
sync_case_light_with_display: True
# Default brightness of the display
default_brightness: 100
# Dim display: time in minutes | 0 to disable
lcd_dim_time: 10
# Dim display: intensity in percent
lcd_dim_brightness: 20
# Sleep display: time in minutes | 0 to disable
lcd_sleep_time: 20


#### not yet integrated #### 
# Toggle to install the klipper module: True | False
install_klipper_module: False 
# Toggle to flash the MCU: True | False
flash_MCU: False
# Toggle to flash the toolhead: True | False 
flash_toolhead: False
# Toggle to flash the display: True | False
flash_display: False

# Preset names on the display home screen: 
preset1_name: PLA
preset2_name: ABS
preset3_name: PETG
preset4_name: TPU

#####################################################################
# FreeDi macros
#####################################################################
# Description: 
# This section is used to define the preset buttons on the display.
# This gives you maximum flexiblity to replace them with your own custom macros.
[gcode_macro PRESET_MACRO_1]
# Preset macro 1 (default for PLA)
gcode:
    M104 S210                                                         ; Set extruder temp
    M140 S60                                                          ; Set bed temp
    M141 S0                                                           ; Set chamber temp

[gcode_macro PRESET_MACRO_2]
# Preset macro 12 (default for ABS)
gcode:
    M104 S250                                                         ; Set extruder temp
    M140 S95                                                          ; Set bed temp
    M141 S45                                                          ; Set chamber temp

[gcode_macro PRESET_MACRO_3]
# Preset macro 3 (default for PETG)
gcode:
    M104 S240                                                         ; Set extruder temp
    M140 S70                                                          ; Set bed temp
    M141 S0                                                           ; Set chamber temp

[gcode_macro PRESET_MACRO_4]
## Preset macro 4 (default for TPU)
gcode:
    M104 S250                                                         ; Set extruder temp
    M140 S40                                                          ; Set bed temp
    M141 S0                                                           ; Set chamber temp


```

### macros.cfg
```
#####################################################################
# Specific Plus4 macros
#####################################################################
#Danger Zone Y 318 -323
[gcode_macro SET_PRINT_STATS_INFO]
rename_existing: BASE_SET_PRINT_STATS_INFO_BASE
gcode:
    # To prevent the chamber heater to blow hot air directly onto the left side of the print bed 
    {% if (printer.toolhead.position.z) > 260 %}
        M141 S0
    {% endif %}
    #TIMELAPSE_TAKE_FRAME
    BASE_SET_PRINT_STATS_INFO_BASE {rawparams}
    CHAMBER_TEMP_CONTROLLER

# Safety macro that gets frequently called by SET_PRINT_STATS_INFO to prevent too high chamber temperatures
[gcode_macro CHAMBER_TEMP_CONTROLLER]
gcode:
    {% set chamber_target_temp = printer['heater_generic chamber'].target %}
    {% set chamber_temp = printer['heater_generic chamber'].temperature %}
    {% if chamber_temp > printer.configfile.settings['heater_generic chamber'].max_temp %}
        M106 P3 S255
    {% else %}
        {% if chamber_target_temp > 0 %}
            # Allow for 3C of "grace" before we start ramping the exhaust fan speed
            # This prevents the macro from fighting with the chamber heater PID algorithm
            {% set difference = chamber_temp - (chamber_target_temp + 3) %}
            {% if difference > 0 %}
                {% set filterfan_speed = ([(difference * 50), 255] | min) | int %}
                M106 P3 S{filterfan_speed}
            {% else %}
                M106 P3 S0
            {% endif %}
        {% endif %}
    {% endif %}

    
[gcode_macro ENABLE_ALL_SENSOR]
gcode:
    ENABLE_FILAMENT_WIDTH_SENSOR
    RESET_FILAMENT_WIDTH_SENSOR
    query_filament_width
    SET_FILAMENT_SENSOR SENSOR=filament_tangle_sensor ENABLE=1


[gcode_macro DISABLE_ALL_SENSOR]
gcode:
    SET_FILAMENT_SENSOR SENSOR=filament_tangle_sensor ENABLE=0
    DISABLE_FILAMENT_WIDTH_SENSOR


[gcode_macro AUTO_LEVEL_BED]
gcode:
    {% set Z_max = printer.toolhead.axis_maximum.z %}
    G28    
    G1 Z{Z_max-30} F600
    SET_TMC_CURRENT STEPPER=stepper_z CURRENT={printer.configfile.settings['tmc2209 stepper_z'].run_current * 0.5 }
    SET_TMC_CURRENT STEPPER=stepper_z1 CURRENT={printer.configfile.settings['tmc2209 stepper_z1'].run_current * 0.5 }
    G1 Z{Z_max} F600
    SET_KINEMATIC_POSITION Z=0
    G1 Z10 F600
    G1 Z0 F600
    G1 Z15 F600
    SET_TMC_CURRENT STEPPER=stepper_z CURRENT={printer.configfile.settings['tmc2209 stepper_z'].run_current}
    SET_TMC_CURRENT STEPPER=stepper_z1 CURRENT={printer.configfile.settings['tmc2209 stepper_z1'].run_current}
    G28


[gcode_macro SCREWS_TILT_CALCULATE]
rename_existing: BASE_SCREWS_TILT_CALCULATE_BASE
gcode:
    { action_respond_info("starting screw rotation calculation...") }
    M141 S0             # disable chamber heater (see https://github.com/qidi-community/Plus4-Wiki/tree/main/content/chamber-heater-issue)
    BASE_SCREWS_TILT_CALCULATE_BASE


[gcode_macro HOME_IF_NEEDED]
description: Homes X and Y if needed
gcode:
    {% if "y" not in printer.toolhead.homed_axes %}
        G28 Y
    {% endif %}
    {% if "x" not in printer.toolhead.homed_axes %}
        G28 X
    {% endif %}
    {% if "z" not in printer.toolhead.homed_axes %}
        G28 Z
    {% endif %}


[gcode_macro CUT_FILAMENT]
description: Cuts the filament
gcode:
    HOME_IF_NEEDED
    
    {% if printer.gcode_move.position.y < 20 %}
      G1 Y40 F9000
    {% endif %}
    {% if printer.gcode_move.position.y > 300 %}
      G1 Y300 F9000
    {% endif %}
    G1 X305 Y40 F9000
    G1 Y20 F9000
    G1 Y5 F3000
    G4 P500
    G1 Y20 F9000
    G1 Y5 F3000
    G4 P500
    G1 Y20 F9000


[gcode_macro GO_TO_POOP_SHOOT]
description: Move toolhead to poop shoot
gcode:
    HOME_IF_NEEDED

    G90
    {% if printer.gcode_move.position.y > 300 %}
      G1 Y300 F9000
    {% endif %}

    G1 X95 Y312 F12000
    G1 Y316 F600
    G1 Y320 F9000
    G1 Y324 F600


[gcode_macro LEAVE_POOP_SHOOT]
description: Primes the nozzle with fresh filament before load/unload/print start
gcode:
    HOME_IF_NEEDED

    {% if printer.gcode_move.position.y > 323 %}
      G1 X95 F1200
      G1 Y300 F1200
    {% else %}
        {% if printer.gcode_move.position.y < 318  %}
            G1 X95 Y300 F1200
        {% else %}
            {% if (printer.gcode_move.position.x < 83 or printer.gcode_move.position.x > 106 or 
                    (printer.gcode_move.position.x >= 93 and printer.gcode_move.position.x <= 97)) %}
                G1 Y300 F1200
                G1 X95    
            {% else %}
               M118 Warning: Nozzle in dangerous position!        
            {% endif %}
        {% endif %}
    {% endif %}


[gcode_macro _SILICON_WIPE]
description: Wipe on the silicon pad with custom min and max coordinates and margin
gcode:
    G90
    {% if (printer.gcode_move.position.y) > 300 %}
      G1 Y300 F600      
    {% endif %}

    G1 X95 F12000
    G1 Y314 F9000
    G1 Y324 F600

    ; Wipe movements in X direction
    G1 X58 F12000
    G1 X78 F12000
    G1 Y324
    G1 X58 F12000
    G1 X78 F12000
    G1 Y323.5
    G1 X58 F12000
    G1 X78 F12000
    G1 Y323
    G1 X58 F12000
    G1 X78 F12000
    G1 Y322.5
    G1 X58 F12000
    G1 X78 F12000
    G1 Y322
    G1 X58 F12000
    G1 X75 F12000
    G1 Y321.5

    ; Wipe movements in circles
    G2 I0.8 J0.8 F600
    G2 I0.8 J0.8 F600
    G2 I0.8 J0.8 F600

    G1 Y324 F600
    G1 X95 F12000


[gcode_macro _PEI_WIPE]
description: Wipe on the PEI pad
gcode:
    # Input values for the minimum and maximum coordinates of the pad
    {% set pad_min_coordinate_x = 111 %}
    {% set pad_max_coordinate_x = 136 %}
    {% set pad_min_coordinate_y = 317 %}
    {% set pad_max_coordinate_y = 325 %}
    {% set margin = 1.0 %} # margin from the edge of the pad
    {% set repetitions = 3 %}

    # Arc parameters and radius to keep full arc inside limits
    {% set arc_i = 0.5 %}
    {% set arc_j = 0.5 %}
    {% set arc_r = ((arc_i|float)**2 + (arc_j|float)**2) ** 0.5 %}

    G90 # absolute positioning
    {% if (printer.gcode_move.position.y) < 300 %}
      G1 Y300 F9000
    {% endif %}

    G1 X108 F9000

    # Compute safe max/min positions (account for margin and arc radius)
    {% set X_max_position = pad_max_coordinate_x - margin - arc_r %}
    {% set Y_max_position = pad_max_coordinate_y - margin - arc_r %}
    {% set X_min_position = pad_min_coordinate_x + margin + arc_r %}
    {% set Y_min_position = pad_min_coordinate_y + margin + arc_r %}

    # Calculate random end positions within the defined safe boundaries (0.05 mm steps)
    {% set random_x_steps = ((X_max_position - X_min_position) * 20) | int %}
    {% if random_x_steps < 1 %}{% set random_x_steps = 1 %}{% endif %}
    {% set random_x = (range(0, random_x_steps) | random) / 20.0 %}
    {% set X_move_position = X_min_position + random_x %}

    {% set random_y_steps = ((Y_max_position - Y_min_position) * 20) | int %}
    {% if random_y_steps < 1 %}{% set random_y_steps = 1 %}{% endif %}
    {% set random_y = (range(0, random_y_steps) | random) / 20.0 %}
    {% set Y_move_position = Y_min_position + random_y %}

    # Calculate a random starting Y position within the safe range (0.1 mm steps)
    {% set random_start_y_steps = ((Y_max_position - Y_min_position) * 10) | int %}
    {% if random_start_y_steps < 1 %}{% set random_start_y_steps = 1 %}{% endif %}
    {% set random_start_y = (range(0, random_start_y_steps) | random) / 10.0 + Y_min_position %}

    # Move the print head to the random starting Y position
    G1 Y{random_start_y} F500

    # Wiping movements in X direction
    {% for move in range(repetitions|int) %}
        G1 X{X_max_position} F400
        G1 X{X_move_position} F400
    {% endfor %}

    # Wiping movements in Y direction
    {% for move in range(repetitions|int) %}
        G1 Y{Y_move_position} F400
        G1 Y{Y_max_position} F400
    {% endfor %}

    G1 X{X_move_position} Y{Y_move_position} F300

    # Circular wiping movements (kept inside safe area by arc radius)
    {% for move in range(repetitions|int) %}
        G2 I{arc_i} J{arc_j} F500
    {% endfor %}

    # Rectangular wiping movements
    {% for move in range(repetitions|int) %}
        G1 Y{Y_max_position} F400
        G1 X{X_max_position} F400
        G1 Y{Y_move_position} F400
        G1 X{X_move_position} F400
    {% endfor %}


[gcode_macro PRIME_NOZZLE]
description: Primes the nozzle with fresh filament before load/unload/print start
gcode:
    {% set hotend_target_temp = params.HOTEND_TARGET_TEMP|default(220)|int %}
    M106 S0
    M104 S{hotend_target_temp}

    HOME_IF_NEEDED

    TEMPERATURE_WAIT SENSOR=extruder MINIMUM={hotend_target_temp-50}
    GO_TO_POOP_SHOOT

    M109 S{hotend_target_temp}

    G92 E0
    G1 E5 F50
    G1 E50 F200
    G92 E0
    G1 E-0.8 F200
    G4 P300

   
    M104 S{([hotend_target_temp-80, 150]|min)} 
    M106 S255
    G4 P4000
    
    _PEI_WIPE
    TEMPERATURE_WAIT SENSOR=extruder MAXIMUM={([hotend_target_temp-80, 150]|min)}
    _SILICON_WIPE
    GO_TO_POOP_SHOOT 
    M106 S0
    LEAVE_POOP_SHOOT


[gcode_macro M603]
description: Unload filament with cutting filament
gcode:
    {% set hotend_target_temp = params.S|default(220)|int %}
    {% set accel = printer.toolhead.max_accel|int %}
    
	M104 S{hotend_target_temp}
    
    HOME_IF_NEEDED
    M204 S10000
    CUT_FILAMENT
    
    M106 S0
    M400
    M204 S{accel}
    M118 Unload finished


[gcode_macro M604]
description: Load filament with priming nozzle
gcode:
    {% set hotend_target_temp = params.S|default(250)|int %}
    {% set accel = printer.toolhead.max_accel|int %}
    
    M104 S{hotend_target_temp}

    HOME_IF_NEEDED
    M204 S10000
    PRIME_NOZZLE hotend_target_temp={hotend_target_temp}

    M106 S0
    M400
    M204 S{accel}
    M118 Load finished


#####################################################################
# Homing modification
#####################################################################
[gcode_macro G28]
rename_existing: G28.1
gcode:
    {% set reduced_current_x = 0.55 %}
    {% set reduced_current_y = 0.45 %}
    {% set home_all = ('X' in rawparams.upper() and 'Y' in rawparams.upper() and 'Z' in rawparams.upper()) or 
                      ('X' not in rawparams.upper() and 'Y' not in rawparams.upper() and 'Z' not in rawparams.upper()) %}
    {% set home_current_x = printer.configfile.settings['tmc2240 stepper_x'].run_current * reduced_current_x %}
    {% set home_current_y = printer.configfile.settings['tmc2240 stepper_y'].run_current * reduced_current_y %}

    {% set init_XY_move = 30 %}
    #{% set y_init_move = 5 %}
    {% set z_clearance = 2 %}

    {% set home_all_final_position_x = printer.toolhead.axis_maximum.x / 2 %}
    {% set home_all_final_position_y = printer.toolhead.axis_maximum.y - 40 %}
    {% set home_all_final_position_z = 20 %}


    {% if 'x' not in printer.toolhead.homed_axes %}
      {% set X_axis_was_homed = false %}                                                                           ; Set Z_axis_was_homed to false if Z is not homed
    {% endif %}
    {% if 'y' not in printer.toolhead.homed_axes %}
      {% set Y_axis_was_homed = false %}                                                                           ; Set Z_axis_was_homed to false if Z is not homed
    {% endif %}
            
    # If homing should at least move X or Y axis
    {% if home_all or 'X' in rawparams.upper() or 'Y' in rawparams.upper() %}     
        # Check if Z is homed
        {% if 'z' in printer.toolhead.homed_axes %}
            {% set Z_axis_was_homed = true %}                                                                       ; Set Z_axis_was_homed to true if Z is already homed
            G91                                                                                                     ; Use relative positioning
            G1 Z2 F600                                                                                              ; Move bed down
            G90                                                                                                     ; Use absolute positioning
        {% else %}
            {% set Z_axis_was_homed = false %}                                                                      ; Set Z_axis_was_homed to false if Z is not homed
            G90
            SET_KINEMATIC_POSITION Z=0                                                                              ; To allow bed move down
            G1 Z{z_clearance}                                                                                       ; Move bed down
            {% if X_axis_was_homed == false %}
              SET_KINEMATIC_POSITION SET_HOMED= CLEAR_HOMED=X                                                       ; Set X to be unhomed
            {% endif %}
            {% if Y_axis_was_homed == false %}
              SET_KINEMATIC_POSITION SET_HOMED= CLEAR_HOMED=Y                                                       ; Set Y to be unhomed
            {% endif %}            
        {% endif %}
    {% endif %}

    {% if home_all or 'X' in rawparams.upper() or 'Y' in rawparams.upper() %} 
        FORCE_MOVE STEPPER=stepper_x DISTANCE={init_XY_move} VELOCITY=40                                            ; Move X a little before homing
        SET_KINEMATIC_POSITION X={printer.toolhead.position.x + (init_XY_move/2)}                                   ; Compensate the FORCE_MOVE position 
        SET_KINEMATIC_POSITION Y={printer.toolhead.position.y + (init_XY_move/2)}                                   ; Compensate the FORCE_MOVE position
        {% if X_axis_was_homed == false %}
          SET_KINEMATIC_POSITION SET_HOMED= CLEAR_HOMED=X                                                           ; Set X to be unhomed
        {% endif %}
        {% if Y_axis_was_homed == false %}
          SET_KINEMATIC_POSITION SET_HOMED= CLEAR_HOMED=Y                                                           ; Set Y to be unhomed
        {% endif %} 
    {% endif %}

    # Home Y
    {% if home_all or 'Y' in rawparams.upper() %}
        SET_TMC_CURRENT STEPPER=stepper_x CURRENT={home_current_x}                                                  ; Lower motor current
        SET_TMC_CURRENT STEPPER=stepper_y CURRENT={home_current_y}                                                  ; Lower motor current
        G28.1 Y                                                                                                     ; Home Y
        SET_TMC_CURRENT STEPPER=stepper_x CURRENT={printer.configfile.settings['tmc2240 stepper_x'].run_current}    ; Set motor current to the previous value
        SET_TMC_CURRENT STEPPER=stepper_y CURRENT={printer.configfile.settings['tmc2240 stepper_y'].run_current}    ; Set motor current to the previous value
        G1 Y10 F1200                                                                                                ; Move Y-axis slightly
    {% endif %}
    
    # Home X
    {% if home_all or 'X' in rawparams.upper() %}        
        SET_TMC_CURRENT STEPPER=stepper_x CURRENT={home_current_x}                                                  ; Lower motor current
        SET_TMC_CURRENT STEPPER=stepper_y CURRENT={home_current_x}                                                  ; Lower motor current
        G28.1 X                                                                                                     ; Home X
        SET_TMC_CURRENT STEPPER=stepper_x CURRENT={printer.configfile.settings['tmc2240 stepper_x'].run_current}    ; Set motor current to the previous value
        SET_TMC_CURRENT STEPPER=stepper_y CURRENT={printer.configfile.settings['tmc2240 stepper_y'].run_current}    ; Set motor current to the previous value
        G1 X10 F1200                                                                                                ; Move X-axis slightly
    {% endif %}

    # Raise the bed again if only X or only Y axes were homed
    {% if not (home_all or 'Z' in rawparams.upper()) %}
        {% if Z_axis_was_homed %}
            G91                                                                                                     ; Use relative positioning
            G1 Z-2 F600                                                                                             ; Raise the bed back again
            G90                                                                                                     ; Use absolute positioning
        {% else %}
            G1 Z0.1                                                                                                 ; Raise the bed back again
            SET_STEPPER_ENABLE STEPPER=stepper_z enable=0                                                           ; Disable Z to prevent collisions
            SET_STEPPER_ENABLE STEPPER=stepper_z1 enable=0                                                          ; Disable Z to prevent collisions
            SET_KINEMATIC_POSITION SET_HOMED= CLEAR_HOMED=Z                                                         ; Set Z to be unhomed
        {% endif %}
    {% endif %}

    # Home Z
    {% if home_all or 'Z' in rawparams.upper() %}
        G1 X{printer.toolhead.axis_maximum.x / 2} Y{printer.toolhead.axis_maximum.x / 2} F12000 
        G28.1 Z                                                                                                     ; Home Z
        G90                                                                                                         ; Set absolute positioning
        G1 Z{home_all_final_position_z} F600                                                                        ; Move bed down
    {% endif %}

    # Move to the final position if all axes were homed
    {% if home_all %}
        G90                                                                                                         ; Set absolute positioning
        G1 X{home_all_final_position_x} Y{home_all_final_position_y} Z{home_all_final_position_z} F7800             ; Move to the rear center
    {% endif %}


# Unconditional stop
[gcode_macro M0]
gcode:
    PAUSE


# Pause SD print
[gcode_macro M25]
rename_existing: M9925
gcode:
    PAUSE


########################################
# Basic Macros
########################################
[gcode_macro PRINT_START]
# Use PRINT_START for the slicer starting script
description: Start printing
gcode:
    {% set bed_target_temp = params.BED|int %}
    {% set hotend_target_temp = params.HOTEND|int %}
    {% set chamber_target_temp = params.CHAMBER|default(0)|int %}
    {% set bed_center_x = printer.configfile.config["stepper_x"]["position_max"]|float / 2 %}
    {% set bed_center_y = printer.configfile.config["stepper_y"]["position_max"]|float / 2 %}

    {% set start_position_x = printer.toolhead.axis_maximum.x / 2 %}
    {% set start_position_y = printer.toolhead.axis_maximum.y - 40 %}
    {% set start_position_z = 10 %}

    CLEAR_PAUSE                                                                                                    ; Clear existing pause states
    BED_MESH_CLEAR                                                                                                 ; Clear previous adaptive mesh

    SET_TEMPERATURE_FAN_TARGET TEMPERATURE_FAN=Mainboard_fan TARGET=1                                              ; Decrease the mainboard target temp to fully turn the fan on
    
    M140 S{bed_target_temp}
    M141 S{chamber_target_temp}
    G28

    {% if chamber_target_temp > 0 %}                                                                               ; Accelerate chamber heating by using the bed as additional heater    
        G0 X{bed_center_x} Y{bed_center_y} Z3 F780                                                                 ; Move print bed to perfect postion to help chamber heating
        M106 P2 S185                                                                                               ; Turn sidefan on to use bed heat and mix air
        M106 P0 S128                                                                                               ; Turn part cooling fan on to help air mixing
        TEMPERATURE_WAIT SENSOR="heater_generic chamber" MINIMUM={chamber_target_temp - 5}                         ; Wait for chamber to heat up
        M106 P2 S0                                                                                                 ; Turn off sidefan
        M106 P0 S0                                                                                                 ; Turn off part cooling fan                                      
    {% endif %}

    {% if bed_target_temp !=0 %}
      TEMPERATURE_WAIT SENSOR=heater_bed MINIMUM={bed_target_temp * 0.95} MAXIMUM={bed_target_temp * 1.05}
    {% endif %}

    BED_MESH_CALIBRATE PROFILE=adaptive ADAPTIVE=1

    M191 S{chamber_target_temp}                                                                                    ; Set and wait for chamber temperature
    M190 S{bed_target_temp}                                                                                        ; Set and wait for bed temperature 
    G90                                                                                                            ; Set absolute positioning
    G1 X{start_position_x} Y{start_position_y} Z{start_position_z} F7800                                           ; Move to start position
    G28 Z                                                                                                          ; Home Z again for to compensate bed expansion  

    PRIME_NOZZLE hotend_target_temp={hotend_target_temp}

    M109 S{hotend_target_temp}                                                                                     ; Set and wait for hotend temperature 


[gcode_macro PRINT_END]
gcode:
    {% set max_x = printer.configfile.config["stepper_x"]["position_max"]|float %}
    {% set max_y = printer.configfile.config["stepper_y"]["position_max"]|float %}
    {% set max_z = printer.configfile.config["stepper_z"]["position_max"]|float %}
    {% set z_clearance = 50 %}

    {% if (printer.toolhead.position.z + z_clearance) < max_z %}
        {% set z_hop = 2  %}
    {% else %}
        {% set z_hop = 0 %}
    {% endif %}

    M106 P0 S0                                                                                                      ; Turn off part cooling fan
    M106 P2 S0                                                                                                      ; Turn off side fan
    M106 P3 S0                                                                                                      ; Turn off activated charcoal fan

    M104 S0                                                                                                         ; Turn off hotend
    M140 S0                                                                                                         ; Turn off heated bed
    M141 S0                                                                                                         ; Turn off heated chamber

    G91                                                                                                             ; Relative positioning
    G0 Z{z_hop} E-4.0 F3600                                                                                         ; Move nozzle up and retract filament
    G90                                                                                                             ; Absolute positioning
    G0 X{max_x/2} Y{max_y-40} F20000                                                                                ; Move nozzle to remove stringing
    _Z_CLEARANCE DISTANCE={z_clearance}                                                                             ; Lower bed
    M400                                                                                                            ; Wait for buffer to clear
    G92 E0                                                                                                          ; Zero the extruder

    M220 S100                                                                                                       ; Set feedrate (speed percentage) back to 100%
    M221 S100                                                                                                       ; Set flow percentage back to 100%

    SET_IDLE_TIMEOUT TIMEOUT={printer.configfile.settings.idle_timeout.timeout}                                     ; Set timeout back to configured value
    CLEAR_PAUSE                                                                                                     ; Ensure pause state is cleared if applicable

    M84                                                                                                             ; Disable steppers
    SET_TEMPERATURE_FAN_TARGET TEMPERATURE_FAN=Mainboard_fan TARGET=45                                              ; Reset the mainboard fan temp
    BEEP I=2 DUR=500                                                                                                ; Alert at the end of the print (if sound is enabled)


[gcode_macro PAUSE]
rename_existing: BASE_PAUSE
gcode:
    {% set z_hop = params.Z|default(30)|int %}                                                                     ; Z hop amount
    
    {% if printer['pause_resume'].is_paused|int == 0 %}     
        SET_GCODE_VARIABLE MACRO=RESUME VARIABLE=zhop VALUE={z_hop}                                                ; Set Z hop variable for reference in resume macro
        SET_GCODE_VARIABLE MACRO=RESUME VARIABLE=etemp VALUE={printer['extruder'].target}                          ; Set hotend temperature variable for reference in resume macro
        SAVE_GCODE_STATE NAME=PAUSE                                                                                ; Save current position for resume
        BASE_PAUSE                                                                                                 ; Pause print
        {% if (printer.gcode_move.position.z + z_hop) < printer.toolhead.axis_maximum.z %}                         ; Check that Z hop doesn't exceed Z max
            G91                                                                                                    ; Use Relative positioning
            G1 Z{z_hop} F600                                                                                       ; Raise Z up by Z hop amount
        {% else %}
            SET_GCODE_VARIABLE MACRO=RESUME VARIABLE=zhop VALUE=0                                                  ; Set Z hop to 0 if exceeds max
        {% endif %}
        SAVE_GCODE_STATE NAME=PAUSEPARK2
        G90                                                                                                        ; Absolute positioning
        G1 X{printer.toolhead.axis_maximum.x/2} Y{printer.toolhead.axis_maximum.y-40} F6000                        ; Park toolhead  at rear center
        SAVE_GCODE_STATE NAME=PAUSEPARK                                                                            ; Save parked position in case toolhead is moved during the pause (otherwise the return zhop can error)
        M104 S0                                                                                                    ; Turn off hotend
        SET_IDLE_TIMEOUT TIMEOUT=43200                                                                             ; Set timeout to 12 hours
        SET_STEPPER_ENABLE STEPPER=extruder enable=0                                                               ; Disable extruder stepper
    {% endif %}


[gcode_macro RESUME]
rename_existing: BASE_RESUME
variable_zhop: 0
variable_etemp: 0
gcode:
    {% set e = params.E|default(2.5)|int %}                                                                        ; Hotend prime amount (in mm)

    {% if printer['pause_resume'].is_paused|int == 1 %}
        SET_IDLE_TIMEOUT TIMEOUT={printer.configfile.settings.idle_timeout.timeout}                                ; Set idle timeout back to configured value
        {% if etemp > 0 %}
            M109 S{etemp|int}                                                                                      ; Wait for hotend to heat up
        {% endif %}
        RESTORE_GCODE_STATE NAME=PAUSEPARK MOVE=1 MOVE_SPEED=150                                                   ; Restore back to parked position in case toolhead was moved during pause (otherwise the return zhop can error)  
        G91                                                                                                        ; Relative positioning
        M83                                                                                                        ; Relative extruder positioning
        {% if printer[printer.toolhead.extruder].temperature >= printer.configfile.settings.extruder.min_extrude_temp %}
            G1  E{e} F900                                                                                          ; Prime nozzle
        {% endif %}  
        RESTORE_GCODE_STATE NAME=PAUSEPARK2 MOVE=1 MOVE_SPEED=150                           
        RESTORE_GCODE_STATE NAME=PAUSE MOVE=1 MOVE_SPEED=10                                                        ; Restore position
        BASE_RESUME                                                                                                ; Resume print
        G90                                                                                                        ; Absolute positioning
    {% endif %}


[gcode_macro CANCEL_PRINT]
rename_existing: BASE_CANCEL_PRINT
gcode:
    {% set max_z = printer.configfile.config["stepper_z"]["position_max"]|float %}
    {% if (printer.toolhead.position.z + 12) < max_z %}
        {% set z_hop = 2  %}
    {% else %}
        {% set z_hop = 0 %}
    {% endif %}

    G91                                                                                                            ; Relative positioning
    G1 Z{z_hop} F600                                                                                               ; Do a tiny z-hop
    G90                                                                                                            ; Absolute positioning

    G1 X{printer.toolhead.axis_maximum.x/2} Y{printer.toolhead.axis_maximum.y-40} F12000
    CLEAR_PAUSE
    SDCARD_RESET_FILE

    PRINT_END
    BASE_CANCEL_PRINT


[gcode_macro _Z_CLEARANCE]
description: Lower the bed to give some clearance
gcode:
    {% set current_z_height = printer.toolhead.position.z %}
    {% set max_z_height = printer.toolhead.axis_maximum.z %}
    {% set target_z_height = current_z_height + params.DISTANCE|default(5)|float %}

    G90                                                                                                            ; Absolute positioning
    G1 Z { [target_z_height, max_z_height]|min }


########################################
#  Filament Macros
########################################
[gcode_macro UNLOAD_FILAMENT]
description: Unloads filament from toolhead
gcode:
  {% set EXTRUDER_TEMP = params.TEMP|default(230)|int %}
  {% set CURRENT_TEMP = printer.extruder.temperature|int %}
  {% if CURRENT_TEMP < EXTRUDER_TEMP %}
    M104 S{EXTRUDER_TEMP}                                                                                          ; heat up the hotend
  {% endif %}
   
  GO_TO_POOP_SHOOT                                                                                                 ; go to poop shoot

  {% if CURRENT_TEMP < EXTRUDER_TEMP %}
    M109 S{EXTRUDER_TEMP}                                                                                          ; heat up the hotend
  {% endif %}  
  M83                                                                                                              ; set extruder to relative mode
  G1 E5 F150                                                                                                       ; extrude a small amount to elimate soften the filament
  G1 E-8 F1800                                                                                                     ; quickly retract a small amount to elimate stringing
  G4 P200                                                                                                          ; pause for a short amount of time
  G1 E-50 F300                                                                                                     ; retract slowly the rest of the way
  M104 S0                                                                                                          ; turn off hotend
  LEAVE_POOP_SHOOT                                                                                                 ; leave poop shoot
  M400                                                                                                             ; wait for moves to finish
  M118 Unload Complete!


[gcode_macro LOAD_FILAMENT]
description: Loads filament to toolhead
gcode:
  {% set EXTRUDER_TEMP = params.TEMP|default(230)|int %}
  {% set CURRENT_TEMP = printer.extruder.temperature|int %}
  {% if CURRENT_TEMP < EXTRUDER_TEMP %}
    M104 S{EXTRUDER_TEMP}                                                                                          ; heat up the hotend
  {% endif %}
   
  GO_TO_POOP_SHOOT                                                                                                 ; go to poop shoot
  
  {% if CURRENT_TEMP < EXTRUDER_TEMP %}
    M109 S{EXTRUDER_TEMP}                                                                                          ; heat up the hotend
  {% endif %}  
  M83                                                                                                              ; set extruder to relative mode
  G1 E5 F120                                                                                                       ; feed filament
  G1 E5 F300                                                                                                       ; feed filament
  G1 E40 F600                                                                                                      ; feed filament
  G1 E15 F300                                                                                                      ; feed filament
  G1 E15 F120                                                                                                      ; feed filament
  G4 P200                                                                                                          ; pause for a short amount of time
  G1 E10 F90                                                                                                       ; feed filament
  M104 S0                                                                                                          ; turn off hotend
  LEAVE_POOP_SHOOT                                                                                                 ; leave poop shoot
  M400                                                                                                             ; wait for moves to finish
  M118 Load Complete!


# Filament runout sensor enable/disable
[gcode_macro M8029]
gcode:
     {% if params.D is defined %}
       {% if (params.D|int)==1 %} 
        SET_FILAMENT_SENSOR SENSOR=filament_tangle_sensor ENABLE=1
       {% endif %}
       {% if (params.D|int)==0 %} 
        SET_FILAMENT_SENSOR SENSOR=filament_tangle_sensor ENABLE=0
       {% endif %}
     {% endif %}


########################################
# Fan Macros
########################################
# Set Fan Speed macro
# Mainly name castings for nicer web interface names and display functionality
[gcode_macro M106]
rename_existing: M106.1
gcode:
    {% if params.P is defined %}
      {% if params.S is defined %}
        {% set speed = 0.003921*params.S|int %}
        {% if (params.P|int) == 0 %}
          M106.1 S{params.S|int}
        {% elif (params.P|int) == 2 %}
          SET_FAN_SPEED FAN=sidefan SPEED={speed}
        {% elif (params.P|int) == 3 %}
          SET_FAN_SPEED FAN=filterfan SPEED={speed}
        {% else %}
          SET_FAN_SPEED FAN=fan{params.P|int} SPEED={speed}
        {% endif %}
      {% else %}
        {% if (params.P|int) == 0 %}
          M106.1 S255
        {% elif (params.P|int) == 2 %}
          SET_FAN_SPEED FAN=sidefan SPEED=1
        {% elif (params.P|int) == 3 %}
          SET_FAN_SPEED FAN=filterfan SPEED=1
        {% else %}
          SET_FAN_SPEED FAN=fan{params.P|int} SPEED=1
        {% endif %}
      {% endif %}
    {% endif %} 

    {% if params.T is defined %}
      {% if (params.T|int) == -2 %}
        {% if params.S is defined %}
          {% set speed = 0.003921*params.S|int %}
          SET_FAN_SPEED FAN=filterfan SPEED={speed}
        {% else %}
          SET_FAN_SPEED FAN=filterfan SPEED=1
        {% endif %}
      {% endif %}
    {% endif %}

    {% if params.P is undefined %}
      {% if params.T is undefined %}
        {% if params.S is defined %}
          M106.1 S{params.S|int}
        {% else %}
          M106.1 S255
        {% endif %}
      {% endif %}
    {% endif %}

[gcode_macro M107]
rename_existing: M107.1
gcode:  
    M106.1 S0


########################################
# Temperature Macros
########################################
# Wait for Hotend Temperature
[gcode_macro M109]
rename_existing: M109.1
gcode:
    #Parameters
    {% set s = params.S|float %}

    M104 {% for p in params %}{'%s%s' % (p, params[p])}{% endfor %}                                              ; Set hotend temp
    {% if s != 0 %}
        TEMPERATURE_WAIT SENSOR=extruder MINIMUM={s} MAXIMUM={s+1}                                               ; Wait for hotend temp (within 1 degree)
    {% endif %}


# PID autotune
[gcode_macro M303]
gcode:
    {% if params.E is defined %}
     {% if params.S is defined %}
        {% if (params.E|int)==-1 %} 
         PID_CALIBRATE HEATER=heater_bed TARGET={params.S|int}
        {% endif %}
        {% if (params.E|int)==0 %}
         PID_CALIBRATE HEATER=extruder TARGET={params.S|int}
        {% endif %}
     {% endif %}
  {% endif %}


# Set chamber temperature
[gcode_macro M141]
gcode:
    {% if printer["heater_generic chamber"] is defined %}
        {% set chamber_target_temp = params.S|float %}
        SET_HEATER_TEMPERATURE HEATER=chamber TARGET={([chamber_target_temp, 65]|min)}
    {% endif %}


# Set wait chamber temperature
[gcode_macro M191]
gcode:
    #Parameters
    {% set chamber_target_temp = params.S|float %}

    {% if chamber_target_temp == 0 %}
        M118 Chamber heater off
    {% else %}
        M141 S{chamber_target_temp}
        TEMPERATURE_WAIT SENSOR="heater_generic chamber" MINIMUM={([chamber_target_temp, 65]|min)-2} MAXIMUM={chamber_target_temp + 5}  
        M118 Chamber at target temperature
    {% endif %}


########################################
# Sound Macros
########################################
[gcode_macro BEEP]
gcode:
    # Parameters
    {% set i = params.I|default(1)|int %}                                                                        ; Iterations (number of times to beep).
    {% set dur = params.DUR|default(100)|int %}                                                                  ; Duration/wait of each beep in ms. Default 100ms.

    {% if printer["output_pin sound"].value|int == 1 %}
        {% for iteration in range(i|int) %}
            SET_PIN PIN=buzzer VALUE=1
            G4 P{dur}
            SET_PIN PIN=buzzer VALUE=0
            G4 P{dur}
        {% endfor %}
    {% endif %}


[gcode_macro beep_on]
gcode:
    SET_PIN PIN=buzzer VALUE=1


[gcode_macro beep_off]
gcode:
    SET_PIN PIN=buzzer VALUE=0


########################################
# Z-height Macros
########################################
# Bed Leveling (Unified)
[gcode_macro G29]
variable_k:1
gcode:
    {% set temp = printer["heater_generic chamber"].target %}
      M141 S0
    {% if temp > 0 %}
      G4 P15000
    {% endif %}

    {% if k|int==1 %}
        BED_MESH_CLEAR                                                                                           ; Clear levelling data
        BED_MESH_CALIBRATE ADAPTIVE=1 ADAPTIVE_MARGIN=5                                                          ; Start adaptive meshing
    {% endif %}   
    M141 S{temp}


# Babystep
[gcode_macro M290]
gcode:
   SET_GCODE_OFFSET Z_ADJUST={params.Z}


########################################
# Tuning Macros
########################################
[gcode_macro SHAPER_CALIBRATE]
rename_existing: RESHAPER_CALIBRATE
gcode:
    RESHAPER_CALIBRATE FREQ_START=30 FREQ_END=130


# Linear Advance Factor
[gcode_macro M900]
gcode:
    {% if params.K is defined %} 
          SET_PRESSURE_ADVANCE ADVANCE={params.K}
    {% endif %}  
    {% if params.T is defined %}    
       SET_PRESSURE_ADVANCE SMOOTH_TIME={params.T}
    {% endif %} 


# Set Starting Acceleration
[gcode_macro M204]
rename_existing: M99204
gcode:
    {% if params.S is defined %}
        {% set s = params.S|float %}
    {% endif %}
    {% if params.P is defined %}
    {% if params.T is defined %}
        {% set s = [params.P|float ,params.T|float] | min %}
    {% endif %}
    {% endif %}

    SET_VELOCITY_LIMIT ACCEL={s}
    SET_VELOCITY_LIMIT ACCEL_TO_DECEL={s/2}


# Bed leveling
# For more information, see https://www.klipper3d.org/Manual_Level.html#adjusting-bed-leveling-screws-using-the-bed-probe
[gcode_macro LEVEL_BED]
description: "Measure bed and calculate screw adjustments for manual bed leveling"
gcode:
    G28                                                                                                         ; Home all
    SCREWS_TILT_CALCULATE                                                                                       ; Perform measurements and output screw adjustments


# Probe Calibration
# For more information, see https://www.klipper3d.org/Probe_Calibrate.html
[gcode_macro CALIBRATE_Z_OFFSET]
description: "Calibrate the Z offset using the probe"
gcode:
    {% set max_x = printer.configfile.config["stepper_x"]["position_max"]|float %}
    {% set max_y = printer.configfile.config["stepper_y"]["position_max"]|float %}

    G28                                                                                                         ; Home all
    G0 Z10                                                                                                      ; Increase z clearance
    G0 X{max_x/2} Y{max_y-40} F6000                                                                             ; Move to bed center 
    PROBE_CALIBRATE                                                                                             ; Perform a probe calibration


# Nozzle PID tuning
# For more information, see https://www.klipper3d.org/Config_checks.html#calibrate-pid-settings
[gcode_macro NOZZLE_PID_TUNE]
description: "Perform PID tuning for the nozzle heater"
gcode:
    PID_CALIBRATE HEATER=extruder TARGET=220                                                                    ; PID tune the nozzle


# Bed PID tuning
# For more information, see https://www.klipper3d.org/Config_checks.html#calibrate-pid-settings
[gcode_macro BED_PID_TUNE]
description: "Perform PID tuning for the bed heater"
gcode:
    PID_CALIBRATE HEATER=heater_bed TARGET=80                                                                   ; PID tune the bed


########################################
# Macros for display functionallity
########################################
[gcode_macro INPUT_SHAPING_CALIBRATE]
description: "Perform Input Shaping calibration and save the results to printer.cfg"
gcode:
    SHAPER_CALIBRATE                                                                                            ; Step 1: Perform the Input Shaping calibration
    PAUSE                                                                                                       ; Step 2: Pause to allow the calibration to complete
    SAVE_CONFIG                                                                                                 ; Step 3: Save the configuration to printer.cfg
    RESTART                                                                                                     ; Step 4: Restart the firmware to apply the new settings



```

### moonraker.conf
```
#####################################################################
# Basics
#####################################################################
[server]
host: 0.0.0.0
port: 7125
klippy_uds_address: /home/mks/printer_data/comms/klippy.sock

[authorization]
trusted_clients:
    10.0.0.0/8
    127.0.0.0/8
    169.254.0.0/16
    172.16.0.0/12
    192.168.0.0/16
    FE80::/10
    ::1/128
cors_domains:
    *.lan
    *.local
    *://localhost
    *://localhost:*
    *://my.mainsail.xyz
    *://app.fluidd.xyz


#####################################################################
# Features
#####################################################################
[octoprint_compat]

[history]

# For kemp, see https://github.com/kyleisah/Klipper-Adaptive-Meshing-Purging
[file_manager]
enable_object_processing: True

[announcements]
subscriptions:
  FreeDi

#####################################################################
# Update Mangers
#####################################################################
[update_manager]
channel: stable
refresh_interval: 168

# Mainsail update_manager entry
[update_manager mainsail]
type: web
channel: stable
repo: mainsail-crew/mainsail
path: ~/mainsail

# Crowsnest update_manager entry
[update_manager crowsnest]
type: git_repo
path: ~/crowsnest
origin: https://github.com/mainsail-crew/crowsnest.git
install_script: tools/pkglist.sh

# FreeDi update_manager entry
[update_manager FreeDi]
type: git_repo
path: ~/FreeDi
channel: stable
origin: https://github.com/Phil1988/FreeDi
virtualenv: ~/klippy-env
requirements: requirements.txt
managed_services: FreeDi
info_tags:
	desc=FreeDi

```

### printer.cfg
```
# Plus4 config created by Phil1988(github)/coco.33(discord) on 04.05.2025
# For more information check out my wiki: https://github.com/Phil1988/FreeDi/wiki


#####################################################################
# Kinematics
#####################################################################
[printer]
kinematics:corexy
max_velocity: 600
max_accel: 20000
max_z_velocity: 20
max_z_accel: 500
square_corner_velocity: 8


#####################################################################
# Motherboard and periphery
#####################################################################
[temperature_sensor Mainboard_RK3328]
sensor_type: temperature_host
min_temp: 10
max_temp: 100

[mcu]
serial: /dev/ttyS0
restart_method: command
baud: 500000

[temperature_sensor Mainboard_STM32F402]
sensor_type: temperature_mcu
sensor_mcu: mcu

[mcu Toolhead]
serial: /dev/ttyS2
restart_method: command
baud: 500000

[temperature_sensor Toolhead_STM32F103XE]
sensor_type: temperature_mcu
sensor_mcu: Toolhead
min_temp: 0
max_temp: 100


#####################################################################
# Features
#####################################################################
# For saving GCODE files
[virtual_sdcard]
path: ~/printer_data/gcodes
on_error_gcode: CANCEL_PRINT

# For enabling pause/resume
[pause_resume]

# Activating exclude objects feature
[display_status]
[exclude_object]

# Expanding idle timeout
[idle_timeout]
timeout: 5400   ; 90min timeout

# Activating GCODE arc feature
[gcode_arcs]
resolution: 1.0

# Allowing free move (can be dangerous!)
[force_move]
enable_force_move: True

# Activating responses
[respond]
default_type: echo


#####################################################################
# FreeDi
#####################################################################
[include freedi.cfg] 


#####################################################################
# Macros
#####################################################################
[include macros.cfg]


#####################################################################
# Input shaping
#####################################################################
[resonance_tester]
accel_chip: adxl345
probe_points:
    150, 150, 10
accel_per_hz: 75
sweeping_period: 0
max_smoothing: 0.5
    
[adxl345]
cs_pin: Toolhead:PA4
spi_software_sclk_pin: Toolhead:PA5
spi_software_mosi_pin: Toolhead:PA7
spi_software_miso_pin: Toolhead:PA6
axes_map: -x, z, -y

[input_shaper]
shaper_type_x: mzv
shaper_freq_x: 57.6
shaper_type_y: mzv
shaper_freq_y: 46.6


#####################################################################
# Hotend
#####################################################################
[extruder]
step_pin: Toolhead:PB9
dir_pin: Toolhead:PB8
enable_pin: !Toolhead:PC15
rotation_distance: 53.7
gear_ratio: 1517:170
microsteps: 16
full_steps_per_rotation: 200
nozzle_diameter: 0.400
filament_diameter: 1.75
min_temp: 0
max_temp: 360
min_extrude_temp: 170
smooth_time: 0.000001
step_pulse_duration: 0.000002

heater_pin: Toolhead:PB3
sensor_type: MAX6675
sensor_pin: Toolhead:PB12
max_power: 1.0
control: pid  
pid_Kp: 33.879
pid_Ki: 6.453
pid_Kd: 44.467

spi_speed: 100000
spi_software_sclk_pin: Toolhead:PB13
spi_software_mosi_pin: Toolhead:PA11
spi_software_miso_pin: Toolhead:PB14

pressure_advance: 0.032
pressure_advance_smooth_time: 0.03
max_extrude_cross_section:500
instantaneous_corner_velocity: 10.000
max_extrude_only_distance: 1000.0
max_extrude_only_velocity: 5000
max_extrude_only_accel: 5000

[verify_heater extruder]
max_error: 120
check_gain_time:20
hysteresis: 5
heating_gain: 1


#####################################################################
# Heated bed
#####################################################################
[heater_bed]
heater_pin: PB10
sensor_type: NTC 100K MGB18-104F39050L32
sensor_pin: PA0
max_power: 1.0
control: pid
pid_kp: 70.638
pid_ki: 0.671
pid_kd: 1859.554
min_temp: -50
max_temp: 125
pwm_cycle_time: 0.02 # for 50Hz line power 
#pwm_cycle_time: 0.016 # for 60Hz line power

[verify_heater heater_bed]
max_error: 200
check_gain_time: 360
hysteresis: 5
heating_gain: 1


#####################################################################
# Bed mesh
#####################################################################
[bed_mesh]
speed: 150               
horizontal_move_z: 2.6   
mesh_min: 25,10
mesh_max: 295,295   
probe_count: 9,9     
algorithm: bicubic
bicubic_tension: 0.3
mesh_pps: 4, 4


#####################################################################
# Probe
#####################################################################
#!# Pay attention to this section and compare it with your stock backup config
[probe]
pin: ^!Toolhead:PA10
x_offset: 25
y_offset: 1.3
z_offset: 1.00             #!# change this to 0 if you get a "Probe triggered prior to movement" - Error
speed: 5
samples: 2
samples_result: average
sample_retract_dist: 0.7
samples_tolerance: 0.08
samples_tolerance_retries: 3

# Check this for documentation https://github.com/frap129/qidi_auto_z_offset
# Add AUTO_Z_LOAD_OFFSET to your PRINT_START macro to load the value every time you start a print. 
# If you make adujstments to the offset by micro-stepping durring a print, you can save that with AUTO_Z_SAVE_GCODE_OFFSET and SAVE_CONFIG

[auto_z_offset]
pin: PC1
# Adjust this z_offset value for a good first layer: 
# decrease if lines are squished (eg -0.2 -> -0.25)
# increase if lines are thin/not sticking (-0.2 -> -0.15)
z_offset: -0.2 
calibrated_z_offset: -1.00
speed: 13
probe_accel: 50
samples: 5
samples_result: median
samples_tolerance: 0.013
samples_tolerance_retries: 5
offset_samples: 3
prepare_gcode:
   G90
   G0 Z3
   G91
   SET_PIN PIN=bed_sensor VALUE=0
   M204 S10000
   {% set i = 6 %}
   {% for iteration in range(i|int) %}
       G1 Z5 F1200
       G1 Z-5 F1200
   {% endfor %}
   G1 Z3
   G90
   SET_PIN PIN=bed_sensor VALUE=1

[output_pin bed_sensor]
pin: !PA14
pwm: false
shutdown_value:0
value:0

#####################################################################
# Heated chamber
#####################################################################
[temperature_sensor chamber_sensor]
sensor_type: NTC 100K MGB18-104F39050L32
sensor_pin: PA1


[heater_generic chamber]
heater_pin: PC8
#!# Caution!
#set max_power to 0.4 for 110V
#set max_power to 0.7 for 220V
#set max_power to 1.0 if you are using a quality aftermarket SSR with a heat sink
max_power: 0.4                #!# Pay attention to this value and compare it with your stock backup config and with caution (read the comments)
#sensor_type: NTC 100K MGB18-104F39050L32
#sensor_pin: PA1
sensor_type: temperature_combined
sensor_list: temperature_sensor Toolhead_STM32F103XE, temperature_sensor Toolhead_STM32F103XE, temperature_sensor Toolhead_STM32F103XE, temperature_sensor chamber_sensor
combination_method: mean
maximum_deviation: 70
control: pid
pid_Kp: 63.418 
pid_Ki: 1.342 
pid_Kd: 749.125
min_temp: -100
max_temp: 75

[verify_heater chamber]
max_error: 400
check_gain_time: 600
hysteresis: 5
heating_gain: 2

[temperature_sensor Chamber_Heater]
sensor_type: NTC 100K MGB18-104F39050L32
sensor_pin: PC2
min_temp: -100
max_temp: 140


########################################
# Filament sensors
########################################
[filament_switch_sensor filament_tangle_sensor]
switch_pin: PC3
pause_on_runout: True
runout_gcode:
            M118 Filament tangled!
event_delay: 3.0
pause_delay: 0.5


# Modified hall_filament_width_sensor.py implementation to only use it as filament detection sensor
# reason is that measured values are unreliable and it cant really be used as a real [hall_filament_width_sensor]
[freedi_hall_filament_width_sensor]
adc1: Toolhead:PA2
adc2: Toolhead:PA3
cal_dia1: 1.50
cal_dia2: 2.0
raw_dia1: 14206
raw_dia2: 15278
default_nominal_filament_diameter: 1.75
max_difference: 0.00
measurement_delay: 50
enable: True
measurement_interval: 3
logging: False
min_diameter: 1.00
use_current_dia_while_delay: False
pause_on_runout: True
runout_gcode:
            M118 Filament run out!
event_delay: 3.0
pause_delay: 0.5


#####################################################################
# Fans
#####################################################################
## Part cooling fan 
# [fan_generic partfan]
# pin: Toolhead:PA8
# max_power: 1.0
# cycle_time: 0.0100
# hardware_pwm: false
# kick_start_time: 0.200
# off_below: 0.08
# shutdown_speed: 0
[fan]
pin: Toolhead:PA8
max_power: 1.0
cycle_time: 0.0100
hardware_pwm: false
kick_start_time: 0.200
off_below: 0.08
shutdown_speed: 0.0

## Big side radial turbo fan
[fan_generic sidefan]
pin: PA8
max_power: 1.0
cycle_time: 0.0100
hardware_pwm: false
kick_start_time: 0.250
off_below: 0.3
shutdown_speed: 0

## Activated charcoal blowing fan
[fan_generic filterfan]
pin: PC9
max_power: 1.0
cycle_time: 0.0100
hardware_pwm: false
kick_start_time: 0.200
off_below: 0.3
shutdown_speed: 0

## Chamber heater fan
[heater_fan chamber_heater_fan]
pin: PA4
max_power: 1.0
shutdown_speed: 0
kick_start_time: 0.5
heater: chamber
fan_speed: 1.0
off_below: 0
heater_temp: 40 

## Cold end and toolhead housing fans
[heater_fan hotend_fan]
pin: Toolhead:PB5
max_power: 1.0
shutdown_speed: 1.0
kick_start_time: 0.5
heater: extruder
heater_temp: 50.0
fan_speed: 1.0
off_below: 0

# Toolhead cooling fan
[heater_fan hotend_fan2]
pin:Toolhead: PB4
max_power: 1.0
shutdown_speed: 1.0
kick_start_time: 0.5
heater: extruder
heater_temp: 50.0
fan_speed: 1.0
off_below: 0

# Toolhead cooling fan
[heater_fan hotend_fan3]
pin:Toolhead: PB10
max_power: 1.0
shutdown_speed: 1.0
kick_start_time: 0.5
heater: extruder
heater_temp: 50.0
fan_speed: 1.0
off_below: 0

#!# Delete the next section if your stock backup config doesnt have it
## Controllable Mainboard cooling fan
[temperature_fan Mainboard_fan]
sensor_type: temperature_host 
pin: PC4
max_power: 1.0  
cycle_time: 0.01
sensor_type: temperature_combined
sensor_list: temperature_sensor Mainboard_RK3328, temperature_sensor Mainboard_STM32F402
combination_method: max                                           # use the maximum reading of the sensors
maximum_deviation: 999.9                                          # we don't care about the difference in temperature
shutdown_speed: 0.0
kick_start_time: 0.4
off_below: 0.19
min_temp: 0
max_temp: 85.0 
target_temp: 42.0
min_speed: 0
max_speed: 1.0
control: pid
pid_deriv_time: 2.0
pid_Kp: 5.0
pid_Ki: 2.5
pid_Kd: 3.5


#####################################################################
# Light
#####################################################################
## caselight LEDs
[output_pin caselight]
pin: PC7
pwm: true
cycle_time: 0.0100
shutdown_value:0
value:1


#####################################################################
# Buzzer
#####################################################################
## Buzzer
[output_pin buzzer]
pin: PA2
pwm: false
shutdown_value:0
value:0

[output_pin sound]
pin: Toolhead:PA1
value:0


#####################################################################
# Power outage shutdown
#####################################################################
[output_pin pwc]
pin: PA3
pwm: False
value: 1
shutdown_value: 1


#####################################################################
# Drives
#####################################################################
[stepper_x]
step_pin: PB4
dir_pin: !PB3
enable_pin: !PB5
microsteps: 32
rotation_distance: 38.82
full_steps_per_rotation: 200 
endstop_pin: tmc2240_stepper_x:virtual_endstop
position_min: -1.5
position_endstop: -1.5
position_max: 307
homing_speed: 55
homing_retract_dist:0
homing_positive_dir:False
step_pulse_duration:0.0000001

[stepper_y]
step_pin: PC14
dir_pin: !PC13
enable_pin: !PC15
microsteps: 32
rotation_distance: 38.82
full_steps_per_rotation:200  
endstop_pin: tmc2240_stepper_y:virtual_endstop
position_min: -2
position_endstop: -2
position_max: 325
homing_speed: 55
homing_retract_dist: 0
homing_positive_dir: False
step_pulse_duration: 0.0000001

[stepper_z]
step_pin: PB1
dir_pin: PB6
enable_pin: !PB0
microsteps: 16
rotation_distance: 4
full_steps_per_rotation: 200
endstop_pin: probe:z_virtual_endstop
position_max:285
position_min: -4
homing_speed: 13
homing_retract_dist: 8.0
second_homing_speed: 5
homing_positive_dir: False
step_pulse_duration: 0.000002

[stepper_z1]
step_pin: PC10
dir_pin: PA15
enable_pin: !PC11
microsteps: 16
rotation_distance: 4
full_steps_per_rotation: 200
step_pulse_duration: 0.000002

#####################################################################
# Steppers configuration
#####################################################################
[tmc2209 extruder]
uart_pin: Toolhead:PC13
interpolate: False
run_current: 0.714             #!# Pay attention to this value and compare it with your stock backup config
stealthchop_threshold: 0
sense_resistor: 0.075

[tmc2240 stepper_x]
cs_pin: PD2
spi_software_sclk_pin: PA5
spi_software_mosi_pin: PA7
spi_software_miso_pin: PA6
spi_speed: 200000
run_current: 1.07               #!# Pay attention to this value and compare it with your stock backup config
interpolate: False
stealthchop_threshold: 0
diag0_pin: !PB8
driver_SGT: 1
rref: 12000

[tmc2240 stepper_y]
cs_pin: PB9
spi_software_sclk_pin: PA5
spi_software_mosi_pin: PA7
spi_software_miso_pin: PA6
spi_speed: 200000
run_current: 1.07              #!# Pay attention to this value and compare it with your stock backup config
interpolate: False
stealthchop_threshold: 0
diag0_pin: !PC0
driver_SGT:1
rref: 12000

[tmc2209 stepper_z]
uart_pin: PB7
run_current: 1.07              #!# Pay attention to this value and compare it with your stock backup config
interpolate: False
stealthchop_threshold: 9999999999
diag_pin: ^PA13
sense_resistor: 0.075


[tmc2209 stepper_z1]
uart_pin: PC5
run_current: 1.07              #!# Pay attention to this value and compare it with your stock backup config
interpolate: False
stealthchop_threshold: 9999999999
diag_pin: ^PC12
sense_resistor: 0.075

#####################################################################
# Bed tilt adjust
#####################################################################
[z_tilt]
z_positions:
    -17.5,138.5
    335.7,138.5

points:
    0,138.5
    255,138.5

speed: 150
horizontal_move_z: 10
retries: 5
retry_tolerance: 0.013

#####################################################################
# Screws tilt adjust
#####################################################################
[screws_tilt_adjust] 
horizontal_move_z: 5
screw_thread: CW-M4
speed: 300

screw1:0,20
screw1_name: Front left
screw2: 260,20
screw2_name: Front right
screw3: 260,280
screw3_name: Back right
screw4: 0,280
screw4_name: Back left


```