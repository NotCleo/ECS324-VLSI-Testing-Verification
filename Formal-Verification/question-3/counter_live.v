amrut@Maverick:~/yosys/examples/cmos$ cat counter_live.v 
module counter(input clk, input rst, output reg [1:0] count);
    initial count = 2'b00;

    always @(posedge clk) begin
        if (rst)
            count <= 2'b00;
        else
            count <= count + 1;
    end

    `ifdef FORMAL
    reg [2:0] cycles_since_zero;
    initial cycles_since_zero = 0;

    always @(posedge clk) begin
        if (rst || count == 2'b00) begin
            cycles_since_zero <= 0;
        end else begin
            cycles_since_zero <= cycles_since_zero + 1;
        end

        // Prove that the counter never goes 4 cycles without hitting 00.
        assert(cycles_since_zero < 4);
    end
    `endif
endmodule
