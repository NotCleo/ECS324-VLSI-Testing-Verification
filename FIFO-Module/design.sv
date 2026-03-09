module fifo #(parameter DATA_WIDTH = 8, parameter DEPTH = 16)(
  input clk, reset,
  input wr_en, rd_en,
  input [DATA_WIDTH-1:0] wdata,
  output reg [DATA_WIDTH-1:0] rdata,
  output full, empty
);
  reg [DATA_WIDTH-1:0] mem [DEPTH-1:0];
  reg [4:0] wptr, rptr;
  
  assign full = (wptr - rptr) == DEPTH;
  assign empty = (wptr == rptr);

  always @(posedge clk) begin
    if (reset) wptr <= 0;
    else if (wr_en && !full) begin
      mem[wptr[$clog2(DEPTH)-1:0]] <= wdata;
      wptr <= wptr + 1;
    end
  end

  always @(posedge clk) begin
    if (reset) rptr <= 0;
    else if (rd_en && !empty) begin
      rdata <= mem[rptr[$clog2(DEPTH)-1:0]];
      rptr <= rptr + 1;
    end
  end
endmodule
