`timescale 1ns / 1ps
module FA(
    input A,
    input B,
    input Carry_in,
    output Sum, 
    output Carry
    );
    
    assign Sum = A ^ B ^ Carry_in;
    assign Carry = (A & B) | ((Carry_in) & (A | B));
    
endmodule


`timescale 1ns / 1ps

// taken from https://www.chipverify.com/systemverilog/systemverilog-class

class stimulus;
    rand bit a;
    rand bit b;
    rand bit cin;

    constraint c_inputs {
        a inside {0, 1};
        b inside {0, 1};
        cin inside {0, 1};
    }
endclass

module tb_FA_partB;

    logic a_tb, b_tb, cin_tb;
    logic sum_tb, cout_tb;

   FA dut (
        .A(a_tb),
        .B(b_tb),
        .Carry_in(cin_tb),
        .Sum(sum_tb),
        .Carry(cout_tb)
    );

    // Define Covergroup
    covergroup cg_fa;
        cp_a    : coverpoint a_tb;
        cp_b    : coverpoint b_tb;
        cp_cin  : coverpoint cin_tb;
        cp_sum  : coverpoint sum_tb;
        cp_cout : coverpoint cout_tb;
        
        cross_ab : cross cp_a, cp_b;
    endgroup

    initial begin
        stimulus stim = new();
        cg_fa cg = new();
        
        $display("A B Cin | Sum Cout");
        
        for (int i = 0; i < 50; i++) begin
            
            a_tb   = stim.a;
            b_tb   = stim.b;
            cin_tb = stim.cin;
            
            #5; 
            cg.sample();
            $display("%b %b  %b  |  %b    %b", a_tb, b_tb, cin_tb, sum_tb, cout_tb);
            #5;
        end

        $display("Coverpoint A coverage: %0.2f%%", cg.cp_a.get_coverage());
        $display("Coverpoint B coverage: %0.2f%%", cg.cp_b.get_coverage());
        $display("Cross AxB coverage: %0.2f%%", cg.cross_ab.get_coverage());
        $display("Overall Functional Coverage: %0.2f%%", cg.get_inst_coverage());
        
        $finish;
    end
endmodule


/*Output

                         Chronologic VCS (TM)
       Version X-2025.06-SP1_Full64 -- Fri Feb 27 03:35:42 2026

                    Copyright (c) 1991 - 2025 Synopsys, Inc.
   This software and the associated documentation are proprietary to Synopsys,
 Inc. This software may only be used in accordance with the terms and conditions
 of a written license agreement with Synopsys, Inc. All other use, reproduction,
   or distribution of this software is strictly prohibited.  Licensed Products
     communicate with Synopsys servers for the purpose of providing software
    updates, detecting software piracy and verifying that customers are using
    Licensed Products in conformity with the applicable License Key for such
  Licensed Products. Synopsys will use information gathered in connection with
    this process to deliver software updates and pursue software pirates and
                                   infringers.

 Inclusivity & Diversity - Visit SolvNetPlus to read the "Synopsys Statement on
            Inclusivity and Diversity" (Refer to article 000036315 at
                        https://solvnetplus.synopsys.com)

Parsing design file 'design.sv'
Parsing design file 'testbench.sv'
Top Level Modules:
       tb_FA_partB
TimeScale is 1 ns / 1 ps
Starting vcs inline pass...
1 module and 0 UDP read.
recompiling module tb_FA_partB
rm -f _cuarc*.so _csrc*.so pre_vcsobj_*.so share_vcsobj_*.so
if [ -x ../simv ]; then chmod a-x ../simv; fi
g++  -o ../simv      -rdynamic  -Wl,-rpath='$ORIGIN'/simv.daidir -Wl,-rpath=./simv.daidir -Wl,-rpath=/apps/vcsmx/vcs/X-2025.06-SP1/linux64/lib -L/apps/vcsmx/vcs/X-2025.06-SP1/linux64/lib  -Wl,-rpath-link=./   objs/amcQw_d.o  _287_archive_1.so  SIM_l.o       rmapats_mop.o rmapats.o rmar.o rmar_nd.o  rmar_llvm_0_1.o rmar_llvm_0_0.o            -lvirsim -lerrorinf -lsnpsmalloc -lvfs      -lvcsnew -ldistsimclient -lsimprofile -luclinative /apps/vcsmx/vcs/X-2025.06-SP1/linux64/lib/vcs_tls.o   -Wl,-whole-archive  -lvcsucli    -Wl,-no-whole-archive          /apps/vcsmx/vcs/X-2025.06-SP1/linux64/lib/vcs_save_restore_new.o -ldl  -lc -lm -lpthread -ldl 
../simv up to date
CPU time: .568 seconds to compile + .509 seconds to elab + .526 seconds to link
Chronologic VCS simulator copyright 1991-2025
Contains Synopsys proprietary information.
Compiler version X-2025.06-SP1_Full64; Runtime version X-2025.06-SP1_Full64;  Feb 27 03:35 2026
--- Starting Part B: Constrained Object Randomization ---
A B Cin | Sum Cout
1 1  0  |  0    1
0 1  0  |  1    0
1 0  1  |  0    1
0 1  0  |  1    0
0 1  1  |  0    1
0 1  1  |  0    1
1 1  0  |  0    1
0 0  0  |  0    0
1 0  0  |  1    0
1 0  1  |  0    1
0 0  1  |  1    0
0 0  0  |  0    0
1 1  0  |  0    1
1 0  1  |  0    1
0 0  0  |  0    0
0 1  1  |  0    1
0 0  1  |  1    0
0 0  0  |  0    0
0 0  0  |  0    0
0 1  0  |  1    0
0 0  1  |  1    0
1 1  1  |  1    1
1 1  1  |  1    1
0 0  0  |  0    0
1 0  0  |  1    0
1 1  0  |  0    1
0 1  0  |  1    0
0 0  0  |  0    0
0 1  1  |  0    1
0 1  0  |  1    0
1 1  0  |  0    1
1 0  0  |  1    0
1 0  1  |  0    1
0 0  0  |  0    0
0 1  0  |  1    0
1 0  1  |  0    1
1 1  0  |  0    1
1 1  1  |  1    1
1 0  0  |  1    0
0 1  1  |  0    1
1 0  1  |  0    1
0 1  1  |  0    1
0 1  1  |  0    1
1 1  1  |  1    1
1 1  1  |  1    1
0 1  1  |  0    1
0 1  1  |  0    1
0 0  0  |  0    0
1 0  0  |  1    0
1 1  0  |  0    1

--- Coverage Report (Part B) ---
Coverpoint A coverage: 100.00%
Coverpoint B coverage: 100.00%
Cross AxB coverage: 100.00%
Overall Functional Coverage: 0.00%
$finish called from file "testbench.sv", line 78.
$finish at simulation time               500000
           V C S   S i m u l a t i o n   R e p o r t 
Time: 500000 ps
CPU Time:      0.560 seconds;       Data structure size:   0.0Mb
Fri Feb 27 03:35:44 2026
*/ 
