module simple_fifo #(
    parameter WIDTH = 8,        // Data width in bits
    parameter DEPTH = 16,       // FIFO depth (must be a power of 2)
    parameter ADDR_WIDTH = 4    // Address width ($clog2(DEPTH))
) (
    input wire clk,             // Clock input
    input wire rst,             // Reset input (active high)
    input wire wr_en,           // Write enable
    input wire rd_en,           // Read enable
    input wire [WIDTH-1:0] data_in, // Data input
    output reg [WIDTH-1:0] data_out, // Data output
    output reg full,            // Full flag
    output reg empty            // Empty flag
);

    // Internal memory array using a register bank
    reg [WIDTH-1:0] mem_array [0:DEPTH-1];

    // Read and write pointers
    reg [ADDR_WIDTH-1:0] rd_ptr, wr_ptr;

    // Internal signal to track the number of words in the FIFO
    reg [ADDR_WIDTH:0] count; // One extra bit for full/empty logic

    // Function to calculate ceil(log2(x)) for ADDR_WIDTH parameter
    function integer clog2(input integer value);
        begin
            clog2 = 0;
            while (value > 1) begin
                value = value >> 1;
                clog2 = clog2 + 1;
            end
        end
    endfunction

    // Memory write operation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 0;
            // Only write when not full and write enable is asserted
        end else if (wr_en && !full) begin
            mem_array[wr_ptr] <= data_in;
            wr_ptr <= wr_ptr + 1;
        end
    end

    // Memory read operation and output assignment
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_ptr <= 0;
            data_out <= 0;
            // Only read when not empty and read enable is asserted
        end else if (rd_en && !empty) begin
            data_out <= mem_array[rd_ptr];
            rd_ptr <= rd_ptr + 1;
        end
    end

    // FIFO count, full, and empty logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            full <= 0;
            empty <= 1; // FIFO is empty after reset
        end else begin
            // Update count based on simultaneous read/write, write only, or read only
            if (wr_en && !full && (!rd_en || empty)) begin
                count <= count + 1;
            end else if (rd_en && !empty && (!wr_en || full)) begin
                count <= count - 1;
            end
            
            // Update flags based on count
            full <= (count == DEPTH - 1); // Full when one less than depth to avoid pointer overlap issue
            empty <= (count == 0);
        end
    end

endmodule


/*

parameter DATA_WIDTH = 8;
parameter ADDR_BUS_WIDTH = 4;
parameter ADDR_WIDTH = 5;

module fifo(data_in, wr_en, rd_en, data_out, full, empty, clk, rst);
  
    input [DATA_WIDTH-1:0] data_in;
    input wr_en, rd_en, rst, clk;
    output reg [DATA_WIDTH-1:0] data_out;
    output reg full, empty;

    integer i; // used for looping as a procedural manner
    logic [ADDR_WIDTH:0] rd_ptr; //6 bits
    logic [ADDR_WIDTH:0] wr_ptr; //6 bits
    logic [ADDR_BUS_WIDTH:0] wr_loc; //5 bits
    logic [ADDR_BUS_WIDTH:0] rd_loc; //5 bits
    logic [7:0]mem[31:0]; //32 rows of 8 bit memory 

  assign wr_loc = wr_ptr[ADDR_BUS_WIDTH:0]; //first 5 bits from LSB of ptr put into loc
  assign rd_loc = rd_ptr[ADDR_BUS_WIDTH:0]; //first 5 bits from LSB of ptr put into loc

    always @(rd_ptr or wr_ptr) begin
        empty <= 1'b0;
        full <= 1'b0;

        if (rd_ptr[4:0] == wr_ptr[4:0]) begin
            if (rd_ptr[5] == wr_ptr[5]) begin
                empty <= 1'b1;
            end
            else begin
                full <= 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if(rst) begin
            for (i = 0; i <= 31; i = i + 1)
                mem[i] <= 8'dx;
            wr_ptr <= 0;
        end
        else if (wr_en && !full) begin
            mem[wr_loc] <= data_in;
            wr_ptr <= wr_ptr +1;
        end
        else wr_ptr <= wr_ptr;
    end

    always @(posedge clk) begin
        if (rst) begin
            data_out <= 8'dx;
            rd_ptr <= 1'b0;
        end
        else if (rd_en && !empty) begin
            data_out <= mem[rd_loc];
            rd_ptr <= rd_ptr + 1;
        end
        else begin
            data_out <= 8'dx;
            rd_ptr <= rd_ptr;
        end
    end
endmodule

*?
