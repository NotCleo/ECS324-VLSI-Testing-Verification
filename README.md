# ECS324-VLSI-Testing-Verification


Tool #1 : Icarus Verilog 

    Installation : sudo apt install iverilog


Tool #2 : GTKWave

    Installation : sudo apt install gtkwave

Working Flow : 
1) Write a design file in verilog
2) Write a testbench for the design file in verilog
3) Compile using iverilog -> iverilog design.v tb.v -o sim
4) Run the waveform dumpfile -> vvp sim
5) Run the simulation -> gtkwave <whatever>.vcd




    
