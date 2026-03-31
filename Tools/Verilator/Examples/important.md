# Verilator Quickstart & RTL Linting Guide

Verilator is an open-source, high-performance Verilog/SystemVerilog simulator and linter. It translates synthesizable RTL into highly optimized C++ or SystemC code, offering simulation speeds significantly faster than traditional event-driven simulators. 

This guide covers the fundamentals of the linting process, basic Verilator usage, essential command-line flags, and standard workflow scripts.

---

## 1. The RTL Linting Process

Linting is the first line of defense in hardware design. It is a static analysis process that catches bugs, style violations, and potential synthesis issues long before you ever run a simulation or push to a physical device.

### Typical Lint Targets
A good linter like Verilator aggressively looks for:
* **Un-synthesizable constructs** (code that works in simulation but cannot be turned into physical gates)
* **Unintentional latches** (usually caused by incomplete `if/else` or `case` statements)
* **Unused declarations** (signals declared but never driven or read)
* **Multiple drivers and un-driven signals** (floating nets or bus contention)
* **Race conditions** (logic that depends on the exact timing of parallel events)
* **Incorrect usage of assignments** (mixing blocking `=` and non-blocking `<=` assignments)
* **Out-of-range indexing** (accessing bits outside a vector's defined width)

### Goals and Best Practices
To maintain a healthy codebase, linting should be integrated into your workflow at multiple stages:

1.  **Basic Connectivity (Pre-Commit):** Catch floating inputs and width mismatches. *These checks should be run after every change in RTL code prior to checking it in.*
2.  **Simulation Issues (Pre-Simulation):** Identify incomplete sensitivity lists, assignment errors, and potential simulation hangs/races. *Messages must be reviewed prior to all simulation runs.*
3.  **Synthesis Mismatches (Pre-Synthesis):** Report unsynthesizable constructs that will cause RTL vs. gate-level simulation mismatches. *Run twice a week, and always before handoff to the synthesis team.*
4.  **Structural Issues (Pre-Implementation):** Identify high fan-in muxes, synchronous/asynchronous reset conflicts, and multiple drivers that affect physical performance. *Run once a week and before handoff to implementation.*

---

## 2. Catching Errors with Verilator (Linting)

Verilator is notoriously strict, making it an excellent tool to enforce the goals outlined above. 

### Example: Linting a faulty design
To run the linter on a file (e.g., `rtl-with-error.v`) to catch width mismatches without compiling it into C++:

verilator --lint-only -Wall rtl-with-error.v


---


## 3. The Most Useful Flags

While verilator -help lists hundreds of options, these are the core flags you will use on a daily basis.
Linting & Warnings

    --lint-only : Checks the code for syntax and style errors without generating C++ output. Very fast.

    -Wall : Enables all style and lint warnings. Highly recommended.

    -Wno-<message> : Disables a specific warning globally (e.g., -Wno-WIDTHEXPAND).

    -Werror-<message> : Upgrades a specific warning to a fatal error.

    --waiver-output <file> : Generates a .vlt waiver file based on current warnings, allowing you to baseline an existing codebase.

Compilation & Execution

    --cc : Instructs Verilator to compile the RTL into C++ classes.

    --exe : Tells Verilator to create a Makefile to link the generated C++ model with your C++ testbench.

    --build : Automatically runs make on the generated files. Saves a manual step!

    -j <threads> : Compiles the C++ model in parallel using multiple CPU cores (e.g., -j 4).

    -O3 : Applies maximum C++ compiler optimizations. Simulation runs much faster, though initial compilation takes longer.

Paths & File Management

    --top-module <name> : Explicitly defines the top-level module (useful if multiple exist in your source files).

    -I<dir> : Adds a directory to the search path for `include files.

    -y <dir> : Adds a directory to search for implicitly instantiated modules.

    -f <file> : Reads a text file containing a list of source files and other command-line arguments.

Simulation & Tracing

    --trace : Instruments the C++ model to generate VCD waveform files.

    --trace-fst : Instruments the C++ model to generate FST waveform files (smaller and faster than VCD for large designs).

    --assert : Enables checking of SystemVerilog assert, assume, and cover statements.

    -D<var>=<value> : Passes a preprocessor macro to the Verilog code (e.g., -DDEBUG_MODE=1).


    
    verilator --lint-only -Wall src/my_module.sv
    
    verilator --cc --exe --build -j 4 -Wall --top-module my_top src/*.v tb_main.cpp
    
    verilator --cc --exe --build -j 4 --trace-fst -Wall --top-module my_top_level src/*.v tb_main.cpp
    

    verilator --cc --exe --build -j 8 --trace-fst --assert -Wall \
    
        -I./includes \
    
        -y ./ip_blocks \
    
        --top-module system_top \
    
        src/*.sv tb/tb_system.cpp
