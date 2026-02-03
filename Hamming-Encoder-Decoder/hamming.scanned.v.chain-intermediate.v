

module BoundaryScanRegister_input
(
  din,
  dout,
  sin,
  sout,
  clock,
  reset,
  testing,
  shift
);

  input din;
  output dout;
  input sin;
  output sout;
  input clock;input reset;input testing;input shift;
  reg store;

  always @(posedge clock or posedge reset) begin
    if(reset) begin
      store <= 1'b0;
    end else begin
      store <= (shift)? sin : dout;
    end
  end

  assign sout = store;
  assign dout = (testing)? store : din;

endmodule



module BoundaryScanRegister_output
(
  din,
  dout,
  sin,
  sout,
  clock,
  reset,
  testing,
  shift
);

  input din;
  output dout;
  input sin;
  output sout;
  input clock;input reset;input testing;input shift;
  reg store;

  always @(posedge clock or posedge reset) begin
    if(reset) begin
      store <= 1'b0;
    end else begin
      store <= (shift)? sin : dout;
    end
  end

  assign sout = store;
  assign dout = din;

endmodule



module \hamming_codec.original 
(
  clk,
  rst,
  data_in,
  data_out,
  sin,
  shift,
  sout,
  tck,
  test
);

  input sin;
  output sout;
  input shift;
  input tck;
  input test;
  wire __clk_source__;
  wire __chain_0__;
  assign __chain_0__ = sin;
  wire _00_;
  wire _01_;
  wire _02_;
  wire _03_;
  wire _04_;
  wire _05_;
  wire _06_;
  wire _07_;
  wire _08_;
  wire _09_;
  wire _10_;
  wire _11_;
  wire _12_;
  wire _13_;
  wire _14_;
  wire _15_;
  wire _16_;
  wire _17_;
  wire _18_;
  wire _19_;
  wire _20_;
  wire _21_;
  wire _22_;
  wire _23_;
  wire _24_;
  wire _25_;
  wire _26_;
  wire _27_;
  wire _28_;
  wire _29_;
  wire _30_;
  wire _31_;
  wire _32_;
  wire _33_;
  wire _34_;
  wire _35_;
  wire _36_;
  wire _37_;
  wire _38_;
  wire _39_;
  wire _40_;
  input clk;
  wire clk;
  wire [6:0] code_reg;
  input [3:0] data_in;
  wire [3:0] data_in;
  output [3:0] data_out;
  wire [3:0] data_out;
  wire [6:0] encoded_next;
  wire p0;
  wire p1;
  wire p2;
  input rst;
  wire rst;

  INVX1
  _41_
  (
    .A(data_in[3]),
    .Y(_11_)
  );


  INVX1
  _42_
  (
    .A(data_in[1]),
    .Y(_12_)
  );


  INVX1
  _43_
  (
    .A(data_in[0]),
    .Y(_13_)
  );


  INVX1
  _44_
  (
    .A(data_in[2]),
    .Y(_14_)
  );


  NOR2X1
  _45_
  (
    .A(_13_),
    .B(rst),
    .Y(_00_)
  );


  NOR2X1
  _46_
  (
    .A(_12_),
    .B(rst),
    .Y(_01_)
  );


  NOR2X1
  _47_
  (
    .A(_14_),
    .B(rst),
    .Y(_02_)
  );


  NOR2X1
  _48_
  (
    .A(_11_),
    .B(rst),
    .Y(_03_)
  );


  XOR2X1
  _49_
  (
    .A(data_in[1]),
    .B(data_in[0]),
    .Y(_15_)
  );


  XNOR2X1
  _50_
  (
    .A(data_in[3]),
    .B(_15_),
    .Y(_16_)
  );


  NOR2X1
  _51_
  (
    .A(rst),
    .B(_16_),
    .Y(_04_)
  );


  XOR2X1
  _52_
  (
    .A(data_in[0]),
    .B(data_in[2]),
    .Y(_17_)
  );


  XNOR2X1
  _53_
  (
    .A(data_in[3]),
    .B(_17_),
    .Y(_18_)
  );


  NOR2X1
  _54_
  (
    .A(rst),
    .B(_18_),
    .Y(_05_)
  );


  XOR2X1
  _55_
  (
    .A(data_in[1]),
    .B(data_in[2]),
    .Y(_19_)
  );


  XNOR2X1
  _56_
  (
    .A(data_in[3]),
    .B(_19_),
    .Y(_20_)
  );


  NOR2X1
  _57_
  (
    .A(rst),
    .B(_20_),
    .Y(_06_)
  );


  XOR2X1
  _58_
  (
    .A(code_reg[4]),
    .B(code_reg[0]),
    .Y(_21_)
  );


  XNOR2X1
  _59_
  (
    .A(code_reg[1]),
    .B(_21_),
    .Y(_22_)
  );


  XNOR2X1
  _60_
  (
    .A(code_reg[3]),
    .B(_22_),
    .Y(_23_)
  );


  XOR2X1
  _61_
  (
    .A(code_reg[0]),
    .B(code_reg[5]),
    .Y(_24_)
  );


  XNOR2X1
  _62_
  (
    .A(code_reg[2]),
    .B(_24_),
    .Y(_25_)
  );


  XNOR2X1
  _63_
  (
    .A(code_reg[3]),
    .B(_25_),
    .Y(_26_)
  );


  XOR2X1
  _64_
  (
    .A(code_reg[3]),
    .B(_25_),
    .Y(_27_)
  );


  NAND2X1
  _65_
  (
    .A(_23_),
    .B(_26_),
    .Y(_28_)
  );


  XOR2X1
  _66_
  (
    .A(code_reg[1]),
    .B(code_reg[6]),
    .Y(_29_)
  );


  XNOR2X1
  _67_
  (
    .A(code_reg[2]),
    .B(_29_),
    .Y(_30_)
  );


  INVX1
  _68_
  (
    .A(_30_),
    .Y(_31_)
  );


  XOR2X1
  _69_
  (
    .A(code_reg[3]),
    .B(_30_),
    .Y(_32_)
  );


  XNOR2X1
  _70_
  (
    .A(code_reg[3]),
    .B(_30_),
    .Y(_33_)
  );


  NAND3X1
  _71_
  (
    .A(_23_),
    .B(_26_),
    .C(_32_),
    .Y(_34_)
  );


  XOR2X1
  _72_
  (
    .A(code_reg[0]),
    .B(_34_),
    .Y(_35_)
  );


  NOR2X1
  _73_
  (
    .A(rst),
    .B(_35_),
    .Y(_07_)
  );


  NAND3X1
  _74_
  (
    .A(_23_),
    .B(_27_),
    .C(_33_),
    .Y(_36_)
  );


  XOR2X1
  _75_
  (
    .A(code_reg[1]),
    .B(_36_),
    .Y(_37_)
  );


  NOR2X1
  _76_
  (
    .A(rst),
    .B(_37_),
    .Y(_08_)
  );


  NOR3X1
  _77_
  (
    .A(_23_),
    .B(_27_),
    .C(_32_),
    .Y(_38_)
  );


  XNOR2X1
  _78_
  (
    .A(code_reg[2]),
    .B(_38_),
    .Y(_39_)
  );


  NOR2X1
  _79_
  (
    .A(rst),
    .B(_39_),
    .Y(_09_)
  );


  MUX2X1
  _80_
  (
    .A(code_reg[3]),
    .B(_31_),
    .S(_28_),
    .Y(_40_)
  );


  NOR2X1
  _81_
  (
    .A(rst),
    .B(_40_),
    .Y(_10_)
  );


  DFFPOSX1
  _82_
  (
    .CLK(__clk_source__),
    .D((shift)? __chain_0__ : _00_),
    .Q(code_reg[0])
  );


  DFFPOSX1
  _83_
  (
    .CLK(__clk_source__),
    .D((shift)? code_reg[0] : _01_),
    .Q(code_reg[1])
  );


  DFFPOSX1
  _84_
  (
    .CLK(__clk_source__),
    .D((shift)? code_reg[1] : _02_),
    .Q(code_reg[2])
  );


  DFFPOSX1
  _85_
  (
    .CLK(__clk_source__),
    .D((shift)? code_reg[2] : _03_),
    .Q(code_reg[3])
  );


  DFFPOSX1
  _86_
  (
    .CLK(__clk_source__),
    .D((shift)? code_reg[3] : _04_),
    .Q(code_reg[4])
  );


  DFFPOSX1
  _87_
  (
    .CLK(__clk_source__),
    .D((shift)? code_reg[4] : _05_),
    .Q(code_reg[5])
  );


  DFFPOSX1
  _88_
  (
    .CLK(__clk_source__),
    .D((shift)? code_reg[5] : _06_),
    .Q(code_reg[6])
  );


  DFFPOSX1
  _89_
  (
    .CLK(__clk_source__),
    .D((shift)? code_reg[6] : _07_),
    .Q(data_out[0])
  );


  DFFPOSX1
  _90_
  (
    .CLK(__clk_source__),
    .D((shift)? data_out[0] : _08_),
    .Q(data_out[1])
  );


  DFFPOSX1
  _91_
  (
    .CLK(__clk_source__),
    .D((shift)? data_out[1] : _09_),
    .Q(data_out[2])
  );


  DFFPOSX1
  _92_
  (
    .CLK(__clk_source__),
    .D((shift)? data_out[2] : _10_),
    .Q(data_out[3])
  );

  assign encoded_next[3:0] = data_in;
  assign p0 = encoded_next[4];
  assign p1 = encoded_next[5];
  assign p2 = encoded_next[6];
  assign sout = data_out[3];
  assign __clk_source__ = (test)? tck : clk;

endmodule



module hamming_codec
(
  clk,
  rst,
  data_in,
  data_out,
  sin,
  shift,
  sout,
  tck,
  test
);

  input sin;
  output sout;
  input rst;
  input shift;
  input tck;
  input test;
  input clk;
  wire __chain_0__;
  assign __chain_0__ = sin;
  input [3:0] data_in;
  wire [3:0] data_in__dout;
  wire __chain_1__;

  BoundaryScanRegister_input
  __BoundaryScanRegister_input__0__
  (
    .din(data_in[0]),
    .dout(data_in__dout[0]),
    .sin(__chain_0__),
    .sout(__chain_1__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );

  wire __chain_2__;

  BoundaryScanRegister_input
  __BoundaryScanRegister_input__1__
  (
    .din(data_in[1]),
    .dout(data_in__dout[1]),
    .sin(__chain_1__),
    .sout(__chain_2__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );

  wire __chain_3__;

  BoundaryScanRegister_input
  __BoundaryScanRegister_input__2__
  (
    .din(data_in[2]),
    .dout(data_in__dout[2]),
    .sin(__chain_2__),
    .sout(__chain_3__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );

  wire __chain_4__;

  BoundaryScanRegister_input
  __BoundaryScanRegister_input__3__
  (
    .din(data_in[3]),
    .dout(data_in__dout[3]),
    .sin(__chain_3__),
    .sout(__chain_4__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );

  wire __chain_5__;
  output [3:0] data_out;
  wire [3:0] data_out_din;
  wire __chain_6__;

  BoundaryScanRegister_output
  __BoundaryScanRegister_output__4__
  (
    .din(data_out_din[0]),
    .dout(data_out[0]),
    .sin(__chain_5__),
    .sout(__chain_6__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );

  wire __chain_7__;

  BoundaryScanRegister_output
  __BoundaryScanRegister_output__5__
  (
    .din(data_out_din[1]),
    .dout(data_out[1]),
    .sin(__chain_6__),
    .sout(__chain_7__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );

  wire __chain_8__;

  BoundaryScanRegister_output
  __BoundaryScanRegister_output__6__
  (
    .din(data_out_din[2]),
    .dout(data_out[2]),
    .sin(__chain_7__),
    .sout(__chain_8__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );

  wire __chain_9__;

  BoundaryScanRegister_output
  __BoundaryScanRegister_output__7__
  (
    .din(data_out_din[3]),
    .dout(data_out[3]),
    .sin(__chain_8__),
    .sout(__chain_9__),
    .clock(tck),
    .reset(rst),
    .testing(test),
    .shift(shift)
  );


  \hamming_codec.original 
  __uuf__
  (
    .clk(clk),
    .rst(rst),
    .data_in(data_in__dout),
    .shift(shift),
    .tck(tck),
    .test(test),
    .sin(__chain_4__),
    .sout(__chain_5__),
    .data_out(data_out_din)
  );

  assign sout = __chain_9__;

endmodule


