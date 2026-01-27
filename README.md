# ECS324-VLSI-Testing-Verification



(note to self : iverilog and gtkwave sits at ~/Documents (not to be confused with verilator))


Tool #1 : Icarus Verilog (Compilation)

    Installation : sudo apt install iverilog


Tool #2 : GTKWave (Simulation)

    Installation : sudo apt install gtkwave

Working Flow : 
1) Write a design file in verilog
2) Write a testbench for the design file in verilog
3) Compile using iverilog -> iverilog design.v tb.v -o sim
4) Run the waveform dumpfile -> vvp sim
5) Run the simulation -> gtkwave <whatever>.vcd


Tool #3 : Yosys (Synthesis)

    Installation : sudo apt install yosys

    cd into /examples/cmos


    read_verilog <whatever>.v
    hierarchy -check -top <topmodulename>
    read_verilog -lib cmos_cells.v 
    synth
    dfflibmap -liberty cmos_cells.lib
    abc -liberty cmos_cells.lib 
    opt_clean
    write_verilog synth.v 
    exit





    
