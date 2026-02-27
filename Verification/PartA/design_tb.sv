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


// Part A

`timescale 1ns / 1ps

module tb_FA_partA;

    logic a_tb, b_tb, cin_tb;
    logic sum_tb, cout_tb;

    FA dut (
        .A(a_tb),
        .B(b_tb),
        .Carry_in(cin_tb),
        .Sum(sum_tb),
        .Carry(cout_tb)
    );

    covergroup cg_fa;
        cp_a    : coverpoint a_tb;
        cp_b    : coverpoint b_tb;
        cp_cin  : coverpoint cin_tb;
        cp_sum  : coverpoint sum_tb;
        cp_cout : coverpoint cout_tb;
        
        cross_ab : cross cp_a, cp_b;
    endgroup

    initial begin
        cg_fa cg = new();
        
        $display("A B Cin | Sum Cout");
        
        for (int i = 0; i < 50; i++) begin
            a_tb   = $urandom_range(0, 1);
            b_tb   = $urandom_range(0, 1);
            cin_tb = $urandom_range(0, 1);
            
            #5; 
            cg.sample();             
            $display("%b %b  %b  |  %b    %b", a_tb, b_tb, cin_tb, sum_tb, cout_tb);
            #5;
        end

        $display("\n--- Coverage Report (Part A) ---");
        $display("Coverpoint A coverage: %0.2f%%", cg.cp_a.get_coverage());
        $display("Coverpoint B coverage: %0.2f%%", cg.cp_b.get_coverage());
        $display("Cross AxB coverage: %0.2f%%", cg.cross_ab.get_coverage());
        $display("Overall Functional Coverage: %0.2f%%", cg.get_inst_coverage());
        
        $finish;
    end
endmodule


/*
[2026-02-27 08:39:00 UTC] vcs -full64 -licqueue '-timescale=1ns/1ns' '+vcs+flush+all' '+warn=all' '-sverilog' design.sv testbench.sv  && ./simv +vcs+lic+wait  
                         Chronologic VCS (TM)
       Version X-2025.06-SP1_Full64 -- Fri Feb 27 03:39:02 2026

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
       tb_FA_partA
TimeScale is 1 ns / 1 ps
Starting vcs inline pass...
1 module and 0 UDP read.
recompiling module tb_FA_partA
rm -f _cuarc*.so _csrc*.so pre_vcsobj_*.so share_vcsobj_*.so
if [ -x ../simv ]; then chmod a-x ../simv; fi
g++  -o ../simv      -rdynamic  -Wl,-rpath='$ORIGIN'/simv.daidir -Wl,-rpath=./simv.daidir -Wl,-rpath=/apps/vcsmx/vcs/X-2025.06-SP1/linux64/lib -L/apps/vcsmx/vcs/X-2025.06-SP1/linux64/lib  -Wl,-rpath-link=./   objs/amcQw_d.o  _286_archive_1.so  SIM_l.o       rmapats_mop.o rmapats.o rmar.o rmar_nd.o  rmar_llvm_0_1.o rmar_llvm_0_0.o            -lvirsim -lerrorinf -lsnpsmalloc -lvfs      -lvcsnew -ldistsimclient -lsimprofile -luclinative /apps/vcsmx/vcs/X-2025.06-SP1/linux64/lib/vcs_tls.o   -Wl,-whole-archive  -lvcsucli    -Wl,-no-whole-archive          /apps/vcsmx/vcs/X-2025.06-SP1/linux64/lib/vcs_save_restore_new.o -ldl  -lc -lm -lpthread -ldl 
../simv up to date
CPU time: .662 seconds to compile + .585 seconds to elab + .621 seconds to link
Chronologic VCS simulator copyright 1991-2025
Contains Synopsys proprietary information.
Compiler version X-2025.06-SP1_Full64; Runtime version X-2025.06-SP1_Full64;  Feb 27 03:39 2026
A B Cin | Sum Cout
0 0  1  |  1    0
0 1  1  |  0    1
0 1  0  |  1    0
1 1  0  |  0    1
0 1  1  |  0    1
0 0  1  |  1    0
0 0  0  |  0    0
1 1  0  |  0    1
1 0  1  |  0    1
0 0  1  |  1    0
1 0  0  |  1    0
1 0  1  |  0    1
0 0  0  |  0    0
1 0  1  |  0    1
1 0  0  |  1    0
1 1  1  |  1    1
0 0  1  |  1    0
1 1  0  |  0    1
0 1  1  |  0    1
0 1  0  |  1    0
0 1  1  |  0    1
1 0  0  |  1    0
1 1  0  |  0    1
1 0  1  |  0    1
0 1  1  |  0    1
0 1  1  |  0    1
1 1  1  |  1    1
0 0  1  |  1    0
0 0  0  |  0    0
0 0  0  |  0    0
1 1  1  |  1    1
1 0  1  |  0    1
1 0  0  |  1    0
0 1  1  |  0    1
1 0  0  |  1    0
1 0  1  |  0    1
1 0  0  |  1    0
0 1  1  |  0    1
0 1  1  |  0    1
0 0  1  |  1    0
1 0  1  |  0    1
1 0  0  |  1    0
1 1  0  |  0    1
0 1  0  |  1    0
0 1  1  |  0    1
0 1  0  |  1    0
0 0  1  |  1    0
1 0  0  |  1    0
1 1  1  |  1    1
0 0  0  |  0    0

--- Coverage Report (Part A) ---
Coverpoint A coverage: 100.00%
Coverpoint B coverage: 100.00%
Cross AxB coverage: 100.00%
Overall Functional Coverage: 0.00%
$finish called from file "testbench.sv", line 48.
$finish at simulation time               500000
           V C S   S i m u l a t i o n   R e p o r t 
Time: 500000 ps
CPU Time:      0.590 seconds;       Data structure size:   0.0Mb
Fri Feb 27 03:39:05 2026
Done

*/


