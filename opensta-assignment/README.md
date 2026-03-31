# OpenLane Custom Design Flow: RTL to GDSII

This repository contains the setup, configuration, and constraints required to run a custom 2-flip-flop design through the complete OpenLane RTL-to-GDSII flow using the SkyWater 130nm PDK.

## File Structure

To run this custom design, the directory structure must be set up correctly within the OpenLane `designs` folder:


    /home/amrut/OpenLane/designs/mydesign/
    │
    ├── myconfig.json      # The main OpenLane configuration file
    ├── mysdc.sdc          # Custom timing constraints for STA
    └── src/
        └── design.v       # The Verilog RTL source code


    cd ~/OpenLane
    make mount
    ./flow.tcl -design mydesign -config_file designs/mydesign/myconfig.json


---

Troubleshooting: PDN "Area Too Small" Error

During the initial run, the flow failed at Step 6: Generating PDN (Power Distribution Network) with the following error:

    [WARNING]: Current core area is too small for the power grid settings chosen.
    [ERROR PDN-0175] Pitch 2.5300 is too small for, must be atleast 6.6000

Why This Happened:

By default, OpenLane calculates the total silicon area based on the number of standard cells in the RTL (target core utilization). Because this design is extremely small (only two flip-flops and some combinational logic), the tool generated a microscopic floorplan. When the OpenROAD engine attempted to lay down the power and ground straps (VDD/VGND), the required spacing (pitch) between the metal wires was smaller than the foundry's minimum manufacturing limit of 6.6 µm.
The Fix:

To solve this, the automatic sizing was disabled, and an absolute, fixed die area was enforced to give the power grid enough physical space to be drawn.

Add this in config.json

    "FP_SIZING": "absolute",
    "DIE_AREA": "0 0 50 50"
