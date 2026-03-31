module lint_test (
    input wire clk,
    input wire reset,
    input wire [7:0] data_in,
    output reg [15:0] data_out
);

    wire [7:0] intermediate;
    wire unused_flag; // Mistake 1: Declared but never driven or read

    assign intermediate = data_in;

    always @(posedge clk) begin
        if (reset) begin
            data_out <= 16'b0;
        end else begin
            // Mistake 2: Assigning an 8-bit signal to a 16-bit register
            // without explicit zero-extension or concatenation.
            data_out <= intermediate; 
        end
    end

endmodule
