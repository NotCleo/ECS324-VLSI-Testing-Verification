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


