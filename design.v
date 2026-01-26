module half_adder_scan (
    input  clk,
    input  rst_n,

    input  a_in,
    input  b_in,

    input  scan_en,
    input  scan_in,
    output scan_out,

    output sum,
    output carry
);

  reg a_ff, b_ff;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      a_ff <= 1'b0;
      b_ff <= 1'b0;
    end else if (scan_en) begin
      a_ff <= scan_in;
      b_ff <= a_ff;
    end else begin
      a_ff <= a_in;
      b_ff <= b_in;
    end
  end

  assign scan_out = b_ff;

  assign sum   = a_ff ^ b_ff;
  assign carry = a_ff & b_ff;

endmodule
