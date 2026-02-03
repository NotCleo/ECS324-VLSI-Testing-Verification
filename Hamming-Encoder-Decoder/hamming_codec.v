module hamming_codec(
    input clk,
    input rst,
    input [3:0] data_in,
    output reg [3:0] data_out
);

    // 1. Internal Register (The "Hidden" 7 bits)
    reg [6:0] code_reg;

    // --- ENCODER LOGIC (Combinational) ---
    wire p0, p1, p2;
    wire [6:0] encoded_next;

    // Hamming (7,4) Generator Matrix Logic
    // p0 covers d0, d1, d3
    assign p0 = data_in[0] ^ data_in[1] ^ data_in[3];
    // p1 covers d0, d2, d3
    assign p1 = data_in[0] ^ data_in[2] ^ data_in[3];
    // p2 covers d1, d2, d3
    assign p2 = data_in[1] ^ data_in[2] ^ data_in[3];

    // Construct the 7-bit code: {p2, p1, p0, d3, d2, d1, d0}
    assign encoded_next = {p2, p1, p0, data_in};

    // --- PIPELINE REGISTER (Sequential) ---
    always @(posedge clk) begin
        if (rst)
            code_reg <= 7'b0;
        else
            code_reg <= encoded_next;
    end

    // --- DECODER LOGIC (Combinational) ---
    wire s0, s1, s2; // Syndrome bits
    wire [2:0] syndrome;
    reg [3:0] corrected_data;

    // Calculate Syndrome from the Register (code_reg)
    // code_reg format: [6]=p2, [5]=p1, [4]=p0, [3]=d3, [2]=d2, [1]=d1, [0]=d0
    assign s0 = code_reg[4] ^ code_reg[0] ^ code_reg[1] ^ code_reg[3];
    assign s1 = code_reg[5] ^ code_reg[0] ^ code_reg[2] ^ code_reg[3];
    assign s2 = code_reg[6] ^ code_reg[1] ^ code_reg[2] ^ code_reg[3];

    assign syndrome = {s2, s1, s0};

    // Error Correction Logic
    always @(*) begin
        // Default: just pass the data bits from the register
        corrected_data = code_reg[3:0]; 
        
        // If syndrome is not 0, flip the bit corresponding to the error location
        case (syndrome)
            3'b011: corrected_data[0] = ~corrected_data[0]; // Error in d0
            3'b101: corrected_data[1] = ~corrected_data[1]; // Error in d1
            3'b110: corrected_data[2] = ~corrected_data[2]; // Error in d2
            3'b111: corrected_data[3] = ~corrected_data[3]; // Error in d3
            default: corrected_data = code_reg[3:0];        // No error in data bits
        endcase
    end

    // --- OUTPUT REGISTER (Sequential) ---
    // Registering the output to make the whole system stable
    always @(posedge clk) begin
        if (rst)
            data_out <= 4'b0;
        else
            data_out <= corrected_data;
    end

endmodule
