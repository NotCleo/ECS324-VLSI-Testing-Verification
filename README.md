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

    find . -type f -name "*.synth" (if a .ys file with all process laid out exists for instance refer below : 

    read_verilog scan_counter.v sdff.v

    hierarchy -check -top <top module name>
    
    proc
    opt
    techmap
    synth -top <top module name>
    write_verilog <output file name>.v
    write_blif synthesized.blif
    
    show -prefix scan_proof -format dot

    )


    read_verilog <whatever>.v
    hierarchy -check -top <topmodulename>
    read_verilog -lib cmos_cells.v 
    synth
    dfflibmap -liberty cmos_cells.lib
    abc -liberty cmos_cells.lib 
    opt_clean
    write_verilog synth.v 
    exit


Tool #4 : Atalanta (ATPG)

    Installation procedure : 
    cd ~/ 
    git clone https://github.com/hsluoyz/Atalanta.git
    cd Atalanta
    make
    cd ..
    mkdir bin
    cp /Atalanta/atalanta /bin
    add $PATH to ~/.bashrc 
    source ~/.bashrc 
    cd Atalanta 
    atalanta -h

    

    To run ATPG

    Perform cd into /home/amrut/Atalanta
    vim a bench file and on top always add a #
    atalanta -h
    atalanta -t <whatever>.test -v <whatever>.bench
    Read the ufaults file, vec file, bench file, test file
    Draw the circuit
    Compare the ufaults file with the circuits
    HUH


    To add a stuck at fault and run fault coverage: 

    EXAMPLE OF .FLT FILE IS

    “
    1 /0 -> means at net 1 it is stuck at 0
    
    “

    atalanta -f <name of stuck at fault file>.flt -t <output file name>.test -v <netlist translated to a bench file name>.bench 


    issue with using ffs with atalanta is this ; 
    """"    
    before
    after
    Error: 2 flip-flop exists in the circuit.
    Fatal error:  Error in circuit file
    """"

    Therefore proving that we cannot do scan chain ATPGs on this tool
    




# What is DFT (Design for Testability)?

**Design for Testability (DFT)** is a design technique aimed at making the testing of an integrated circuit (IC) after fabrication easier, faster, and more cost-effective. It involves adding extra test logic to a design to improve the **controllability** and **observability** of internal circuit nodes that are otherwise hard to access.

---

## DFT Technique: Scan Cell Design

The most widely used DFT technique is **scan cell design**.

In scan-based DFT, normal functional flip-flops are replaced with **scan flip-flops (SDFFs)**. These scan flip-flops can operate in two modes:

- **Functional mode**: Behave like normal flip-flops.
- **Test (scan) mode**: Act as elements of a shift register, forming a **scan chain**.

This transformation allows sequential elements to be controlled and observed through external pins.

### Key Benefits

- **Controllability**  
  Ability to set the state of every flip-flop to a known value by shifting in test data.

- **Observability**  
  Ability to read the state of every flip-flop by shifting out the captured data.

---

## Scan Chain Implementation

- Functional flip-flops are replaced with **scan flip-flops (SDFF)**.
- Scan flip-flops are connected serially to form a **scan chain**.
- A **scan multiplexer** selects between functional data and scan data.
- During synthesis, the presence of scan logic is confirmed by:
  - Scan flip-flops such as `$_DFF_PP0_`
  - Scan multiplexers such as `$_MUX_`

---

## Significance of DFT in VLSI Testing

From a VLSI testing perspective, DFT is extremely important because:

- It converts the complex problem of testing **sequential logic** into a much simpler problem of testing **combinational logic**.
- Test vectors can be:
  1. **Scanned in** through the scan chain
  2. **Applied** to the combinational logic
  3. **Captured** in flip-flops
  4. **Scanned out** for analysis

This process enables efficient detection of manufacturing defects such as:
- Stuck-at faults
- Transition faults
- Bridging faults (with advanced techniques)

---

## Summary

DFT, particularly scan-based design, is a cornerstone of modern VLSI testing. It significantly improves test coverage, reduces test cost, and ensures reliable detection of faults in complex digital designs.




    
