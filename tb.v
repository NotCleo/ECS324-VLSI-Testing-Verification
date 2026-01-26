`timescale 1ns/1ps

module half_adder_scan_tb;

  reg clk;
  reg rst_n;

  reg a_in, b_in;
  reg scan_en, scan_in;

  wire scan_out;
  wire sum, carry;

  half_adder_scan dut (
    .clk(clk),
    .rst_n(rst_n),
    .a_in(a_in),
    .b_in(b_in),
    .scan_en(scan_en),
    .scan_in(scan_in),
    .scan_out(scan_out),
    .sum(sum),
    .carry(carry)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("half_adder_scan.vcd");
    $dumpvars(0, half_adder_scan_tb);

    clk     = 0;
    rst_n   = 0;
    a_in    = 0;
    b_in    = 0;
    scan_en = 0;
    scan_in = 0;

    #12;
    rst_n = 1;


    scan_en = 1;

    scan_in = 1;  
    #10;

    scan_in = 0;  
    #10;

    scan_en = 0;

    #20;


    a_in = 0; b_in = 0; #10;
    a_in = 0; b_in = 1; #10;
    a_in = 1; b_in = 0; #10;
    a_in = 1; b_in = 1; #10;

    #20;
    $finish;
  end

endmodule
