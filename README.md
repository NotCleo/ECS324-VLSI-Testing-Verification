# ECS324-VLSI-Testing-Verification

(note to self : iverilog and gtkwave sits at ~/Documents (not to be confused with verilator))

---

Tool #1 : Icarus Verilog (Compilation)

    Installation : 
        sudo apt install iverilog

---

Tool #2 : GTKWave (Simulation)

    Installation : sudo apt install gtkwave

        Working Flow : 
        1) Write a design file in verilog
        2) Write a testbench for the design file in verilog
        3) Compile using iverilog -> iverilog design.v tb.v -o sim
        4) Run the waveform dumpfile -> vvp sim
        5) Run the simulation -> gtkwave <whatever>.vcd

---

Tool #3 : Fault (DFT + ATPG)

    Installation :

     mkdir fault_environment
     cd fault_environment
     python3 -m venv venv
     source venv/bin/activate
     pip install fault-dft
     fault --help
     git clone https://github.com/AUCOHL/Fault.git
     cd Fault/Tech/osu035/
     vim <design file>.v
     fault synth -t <top module name> -l osu035_stdcells.lib -o <output netlist name>.netlist.v <design file name>.v
     fault cut --clock clk --reset rst_n --activeLow -o <output file name>.cut.v <output netlist name>.netlist.v
     fault -g swift -c osu035_stdcells.v -v 100 <output file name>.cut.v --clock clk --reset rst_n --activeLow
     fault -c osu035_stdcells.v -v 100 hadder.cut.v --clock clk --reset rst_n --activeLow
     cat *.json

    Regarding Cut,

    ATPG (Automatic Test Pattern Generation) tools struggle with loops. A Flip-Flop creates a loop (state) because the output depends on the previous input.

        The "Cut" command virtually removes the Flip-Flops from the circuit.
    
        It treats the Output of the Flip-Flop as a new Input for the logic.
    
        It treats the Input of the Flip-Flop as a new Output for the logic.

    This turns a difficult "Sequential Circuit" into a much easier "Combinational Circuit" so the tool can mathematically calculate the test patterns.


    Alright four ways here : 

    Note : we cannot perform "Scan Chain Insertion" on a purely Combinational Circuit (like a Half Adder) unless you add Flip-Flops to it first.

    Why? A Scan Chain is literally a chain of Shift Registers (Flip-Flops). If your Half Adder has no Flip-Flops (only AND/XOR gates), there is nothing to chain together.

    The Industry Standard: For pure combinational blocks, we simply apply patterns to the inputs. We don't "scan" them unless they are wrapped in Flip-Flops (Registers).

     1) To add scan chain manually (for combinational circuit) : 

         Read above Note!!
         However, 

         Since a Half Adder has no memory, we must manually wrap the inputs and outputs in Flip-Flops to make it a "Registered Half Adder." Then, we manually modify those Flip-Flops to be scannable.

         Workflow:

            Synthesize (fault synth).
        
            SKIP fault chain (because you already built the chain manually!).
        
            Run fault cut (to break the FFs for testing).
        
            Run fault atpg.

         Why do this? To test the adder inside a larger pipeline.

    2) To add scan chain via Fault (for combinational circuit) : 

    Let' say , you have a plain Half Adder. You want Fault to handle the testing.

    The Catch: fault chain will fail or do nothing because there are no Flip-Flops to replace.

    The Solution: You generally do not insert scan chains here. You skip directly to ATPG.

    How to do it:

            RTL: Pure Half Adder (No clk, no FFs).
        
            Synth: fault synth ...
        
            Chain: SKIP THIS. (Nothing to chain).
        
            Cut: SKIP THIS. (No loops/FFs to cut).
        
            ATPG: Run fault atpg directly. The tool will just generate vectors
        


    3) To add scan chain manually (for sequential circuit) : 

        Kinda lame to do via this approach but... Let's take 4 bit up counter

        Concept: You will have to write the "Shift Register" logic yourself inside the counter.

        Difficulty: Pretty High. Cause you have to manually connect Q[0] to Q[1], Q[1] to Q[2], etc., using if(scan_en) statements.

        Workflow:
        
            Synthesize (fault synth).
        
            SKIP fault chain (You did it manually).
        
            Run fault cut (Required).
        
            Run fault atpg.

    4) To add scan chain via Fault (for sequential circuit) : 

        The best thing!!

        Run the Full Flow:

            Synth: fault synth -t counter -l osu035.lib -o netlist.v counter.v

                Result: Netlist with normal D-Flip-Flops.

            Chain: fault chain netlist.v --clock clk --reset rst --liberty osu035.lib -o scanned.v

                Result: The tool rips out D-Flip-Flops, puts in Scan-Flip-Flops, and wires Q[0]->SI[1].

            Cut: fault cut scanned.v --clock clk -o cut.v

                Result: Prepares for ATPG.

            ATPG: fault atpg cut.v ...


        Extra Notes about flags utilized : 

        (venv) amrut@Maverick:~/fault_environment$ fault chain --help
        OVERVIEW: Manipulate a netlist to create a scan chain, and resynthesize.
        
        USAGE: fault chain [<options>] --liberty <liberty> --clock <clock> <file>
        
        ARGUMENTS:
          <file>
        
        OPTIONS:
          -o, --output <output>   Path to the output file. (Default: input + .chained.v)
          -c, --cell-model, --cellModel <cell-model>
                                  Verify scan chain using given cell model.
          --inv-clock <inv-clock> Inverted clk tree source cell name. (Default: none)
          -l, --liberty <liberty> Liberty file. (Required.)
          --bypassing <bypassing> Inputs to bypass when performing operations. May be
                                  specified multiple times to bypass multiple inputs.
                                  Will be held high during simulations by default,
                                  unless =0 is appended to the option.
          --clock <clock>         Clock name. In addition to being bypassed for certain
                                  manipulation operations, during simulations it will
                                  always be held high.
          --reset <reset>         Reset name. In addition to being bypassed for certain
                                  manipulation operations, during simulations it will
                                  always be held low. (default: rst)
          --reset-active-low, --activeLow
                                  The reset signal is considered active-low insted, and
                                  will be held high during simulations.
          -s, --scl-config, --sclConfig <scl-config>
                                  Path for the YAML SCL config file. Recommended.
          -d, --dff <dff>         Optional override for the DFF names from the PDK
                                  config. Comma-delimited.
          -b, --blackbox <blackbox>
                                  Blackbox module names. Comma-delimited. (Default:
                                  none)
          -B, --blackbox-models, --blackboxModel <blackbox-models>
                                  Files containing definitions for blackbox models.
                                  Comma-delimited. (Default: none)
          -D, --define <define>   define statements to include during simulations.
                                  Comma-delimited. (Default: none)
          --inc <inc>             Extra verilog models to include during simulations.
                                  Comma-delimited. (Default: none)
          --skip-synth            Skip Re-synthesizing the chained netlist. (Default:
                                  none)
          --sin <sin>             Name for scan-chain serial data in signal. (default:
                                  sin)
          --sout <sout>           Name for scan-chain serial data out signal. (default:
                                  sout)
          --shift <shift>         Name for scan-chain shift enable signal. (default:
                                  shift)
          --test <test>           Name for scan-chain test enable signal. (default:
                                  test)
          --tck <tck>             Name for JTAG test clock signal. (default: tck)
          --version               Show the version.
          -h, --help              Show help information.
        
        (venv) amrut@Maverick:~/fault_environment$ fault cut --help
        OVERVIEW: Cut away D-flipflops, converting them into inputs and outputs. This
        is a necessary precursor to the ATPG step.
        
        USAGE: fault cut [--dff <dff>] [--scl-config <scl-config>] [--blackbox <blackbox> ...] [--blackbox-models <blackbox-models> ...] [--bypassing <bypassing> ...] --clock <clock> [--reset <reset>] [--reset-active-low] [--output <output>] <file>
        
        ARGUMENTS:
          <file>                  The file to process.
        
        OPTIONS:
          -d, --dff <dff>         Override for flip-flop cell names. Comma-delimited.
                                  (Default: DFF).
          -s, --scl-config, --sclConfig <scl-config>
                                  Path for the YAML SCL config file. Recommended.
          -b, --blackbox <blackbox>
                                  Blackbox module names. Comma-delimited. (Default:
                                  none)
          -B, --blackbox-models, --blackboxModel <blackbox-models>
                                  Files containing definitions for blackbox models.
                                  Comma-delimited. (Default: none)
          --bypassing <bypassing> Inputs to bypass when performing operations. May be
                                  specified multiple times to bypass multiple inputs.
                                  Will be held high during simulations by default,
                                  unless =0 is appended to the option.
          --clock <clock>         Clock name. In addition to being bypassed for certain
                                  manipulation operations, during simulations it will
                                  always be held high.
          --reset <reset>         Reset name. In addition to being bypassed for certain
                                  manipulation operations, during simulations it will
                                  always be held low. (default: rst)
          --reset-active-low, --activeLow
                                  The reset signal is considered active-low insted, and
                                  will be held high during simulations.
          -o, --output <output>   Path to the output file. (Default: input + .chained.v)
          --version               Show the version.
          -h, --help              Show help information.
        
        (venv) amrut@Maverick:~/fault_environment$ 

---

Tool #4 : Yosys (Synthesis)

    Installation : 
    
        sudo apt install yosys
    
        cd into /examples/cmos
    
        find . -type f -name "*.synth" 
        (if a .ys file with all process laid out exists for instance refer below : 
    
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

---

Tool #5 : Atalanta (ATPG)

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

---

Tool #6 : OpenLane (RTL to GDS)

    Installation :
        First time installation and run : 
            in terminal window 1 : 
                sudo apt update
                sudo apt install docker.io
                sudo systemctl start docker
                sudo systemctl enable docker
                sudo usermod -aG docker $USER
                newgrp docker
                git clone --depth 1 https://github.com/The-OpenROAD-Project/OpenLane.git
                cd OpenLane
                make
                make mount


            in terminal window 2 : 
                cd OpenLane/designs
                mkdir -p <whatever>/src
                vim <whatever>/src/<whatever>.v
                cd ..
                vim <whatever>/config.json


                    {
                    
                        "DESIGN_NAME": "<whatever>",
                    
                        "VERILOG_FILES": "dir::src/<whatever>.v",
                    
                        "CLOCK_PORT": "clk",
                    
                        "CLOCK_PERIOD": 10.0,
                    
                        "FP_SIZING": "absolute",
                    
                        "DIE_AREA": "0 0 50 50",
                    
                        "PL_TARGET_DENSITY": 0.50
                    
                    }


            in terminal window 1 : 

                ./flow.tcl -design <whatever>
                klayout OpenLane/designs/whatever/runs/*/results/final/gds/<whatever>.gds 

            To see analysis (metrics) : 

                metrics.csv lies in /OpenLane/designs/half_adder_scan/runs/RUN_2026.02.01_16.39.58/reports

                Look at column critical_path_ns in the CSV. it would be <something>
                CLOCK_PERIOD is <as defined in config.json>.
                Slack = <as defined in config.json> - <something>


            For fresh run :

            in terminal window 1 : 
            
                cd ~/OpenLane/designs
                mkdir -p <whatever>/src
                vim <whatever>/src/<whatever>.v
                cd ..
                vim <whatever>/config.json
                
                    {
                    
                        "DESIGN_NAME": "<whatever>",
                    
                        "VERILOG_FILES": "dir::src/<whatever>.v",
                    
                        "CLOCK_PORT": "clk",
                    
                        "CLOCK_PERIOD": 10.0,
                    
                        "FP_SIZING": "absolute",
                    
                        "DIE_AREA": "0 0 60 60",
                    
                        "PL_TARGET_DENSITY": 0.50
                    
                    }


            in terminal window 2 : 
            
                cd ~/OpenLane
                make mount
                ./flow.tcl -design <whatever>
                klayout ~/OpenLane/designs/<whatever>/runs/*/results/final/gds/<whatever>.gds

        https://unic-cass.github.io/training/01-course-intro.html
        http://opencircuitdesign.com/
                                            
                    
    
---
    
     

Tool #7 : klayout

    Installation :
        sudo apt install klayout
        klayout <whatever>.gds 
        


---
     






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




    
