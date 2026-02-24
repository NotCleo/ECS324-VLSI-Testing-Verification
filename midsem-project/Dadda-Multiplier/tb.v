`timescale 1ns / 1ps

module tb_dadda4;

    reg [3:0] A;
    reg [3:0] B;


    wire [7:0] y;


    dadda4 uut (
        .A(A), 
        .B(B), 
        .y(y)
    );


    initial begin
        $dumpfile("dadda4_wave.vcd"); 
        $dumpvars(0, tb_dadda4);     
    end

    initial begin

$monitor("Time: %0t ns | A = %d | B = %d | y (Result) = %d", $time, A, B, y);


        A = 4'b0000; B = 4'b0000;
        

        #10 A = 4'd2; B = 4'd3;
        

        #10 A = 4'd7; B = 4'd5;
        

        #10 A = 4'd15; B = 4'd15;
        

        #10 A = 4'd9; B = 4'd4;
        

        #10 A = 4'd0; B = 4'd10;
        

        #10 A = 4'd11; B = 4'd6;
        

        #10 A = 4'd8; B = 4'd8;


        #10 A = 4'd12; B = 4'd3;


        #10 A = 4'd14; B = 4'd2;

        #10;
        $finish;
    end

endmodule
