module dadda4(
    input [3:0] A,
    input [3:0] B,
    output [7:0] y
    );

    wire pp00, pp01, pp02, pp03;
    wire pp10, pp11, pp12, pp13;
    wire pp20, pp21, pp22, pp23;
    wire pp30, pp31, pp32, pp33;

    assign pp00 = A[0] & B[0]; assign pp01 = A[1] & B[0]; assign pp02 = A[2] & B[0]; assign pp03 = A[3] & B[0];
    assign pp10 = A[0] & B[1]; assign pp11 = A[1] & B[1]; assign pp12 = A[2] & B[1]; assign pp13 = A[3] & B[1];
    assign pp20 = A[0] & B[2]; assign pp21 = A[1] & B[2]; assign pp22 = A[2] & B[2]; assign pp23 = A[3] & B[2];
    assign pp30 = A[0] & B[3]; assign pp31 = A[1] & B[3]; assign pp32 = A[2] & B[3]; assign pp33 = A[3] & B[3];

    // Stage 1 (Reduction)
    wire s1_3, c1_4;
    // HA at Column 3
    assign s1_3 = pp30 ^ pp21;
    assign c1_4 = pp30 & pp21;

    // Stage 2 (Reduction)
    wire s2_2, c2_3;
    wire s2_3, c2_4;
    wire s2_4, c2_5;

    // FA at Col 2
    assign s2_2 = pp20 ^ pp11 ^ pp02;
    assign c2_3 = (pp20 & pp11) | (pp20 & pp02) | (pp11 & pp02);

    // FA at Col 3
    assign s2_3 = s1_3 ^ pp12 ^ pp03;
    assign c2_4 = (s1_3 & pp12) | (s1_3 & pp03) | (pp12 & pp03);

    // FA at Col 4
    assign s2_4 = pp31 ^ pp22 ^ pp13;
    assign c2_5 = (pp31 & pp22) | (pp31 & pp13) | (pp22 & pp13);

    // Stage 3 (Reduction)
    wire s3_4, c3_5;
    wire s3_5, c3_6;

    // FA at Col 4
    assign s3_4 = s2_4 ^ c1_4 ^ c2_4;
    assign c3_5 = (s2_4 & c1_4) | (s2_4 & c2_4) | (c1_4 & c2_4);

    // FA at Col 5
    assign s3_5 = pp32 ^ pp23 ^ c2_5;
    assign c3_6 = (pp32 & pp23) | (pp32 & c2_5) | (pp23 & c2_5);

    // Final Ripple Carry Adder
    wire cf2, cf3, cf4, cf5, cf6;

    assign y[0] = pp00;
    assign y[1] = pp10 ^ pp01;
    assign cf2  = pp10 & pp01;

    assign y[2] = s2_2 ^ cf2;
    assign cf3  = s2_2 & cf2; 

    assign y[3] = s2_3 ^ c2_3 ^ cf3;
    assign cf4 = (s2_3 & c2_3) | (s2_3 & cf3) | (c2_3 & cf3);

    assign y[4] = s3_4 ^ cf4;
    assign cf5  = s3_4 & cf4;

    assign y[5] = s3_5 ^ c3_5 ^ cf5;
    assign cf6  = (s3_5 & c3_5) | (s3_5 & cf5) | (c3_5 & cf5);

    // y6 (FA) - Fixed Logic
    assign y[6] = pp33 ^ c3_6 ^ cf6;
    
    assign y[7] = (pp33 & c3_6) | (pp33 & cf6) | (c3_6 & cf6);

endmodule
