module my_design (
    input wire CLK,
    input wire INP,
    input wire B,
    input wire C,
    output reg OUTB
);

    reg ff1_out;
    wire Y;

    // FF1: Captures INP
    always @(posedge CLK) begin
        ff1_out <= INP;
    end

    // Combinational Logic
    assign Y = (ff1_out & B) | C;

    // FF2: Captures Y and outputs to OUTB
    always @(posedge CLK) begin
        OUTB <= Y;
    end

endmodule
