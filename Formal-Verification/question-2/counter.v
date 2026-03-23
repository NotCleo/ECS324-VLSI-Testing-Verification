module counter(input clk, input rst, output reg [1:0] count);
    always @(posedge clk) begin
        if (rst)
            count <= 2'b00;
        else
            count <= count + 1;
    end

    // --- Added for Property Check ---
    `ifdef FORMAL
    always @(posedge clk) begin
        // The property: The counter should never reach state 11
        assert(count != 2'b11);
    end
    `endif
endmodule
