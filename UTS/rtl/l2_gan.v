// l2_gan.v - GAN Pipelined Top

module l2_gan
(
    // --- Global Ports ---
    input clk,
    input rst,

    // --- Input features ---
    input  signed [15:0] x1,
    input  signed [15:0] x2,
    input  signed [15:0] x3,
    input  signed [15:0] x4,

    // L1 (4 neurons, 4 inputs)
    input  signed [16*4*4-1:0] L1_w,
    input  signed [16*4-1:0]   L1_b,

    // L2 (2 neurons, 4 inputs)
    input  signed [16*2*4-1:0] L2_w,
    input  signed [16*2-1:0]   L2_b,

    // L3 (1 neuron, 2 inputs)
    input  signed [16*1*2-1:0] L3_w,
    input  signed [16*1-1:0]   L3_b,

    // L4 (1 neuron, 1 input)
    input  signed [16*1*1-1:0] L4_w,
    input  signed [16*1-1:0]   L4_b,

    // L5 (1 neuron, 1 input)
    input  signed [16*1*1-1:0] L5_w,
    input  signed [16*1-1:0]   L5_b,

    // L6 (2 neurons, 1 input)
    input  signed [16*2*1-1:0] L6_w,
    input  signed [16*2-1:0]   L6_b,

    // L7 (4 neurons, 2 inputs)
    input  signed [16*4*2-1:0] L7_w,
    input  signed [16*4-1:0]   L7_b,

    // L8 (4 neurons, 4 inputs)
    input  signed [16*4*4-1:0] L8_w,
    input  signed [16*4-1:0]   L8_b,

    // --- Outputs ---
    output signed [15:0] out1,
    output signed [15:0] out2,
    output signed [15:0] out3,
    output signed [15:0] out4
);

    localparam WIDTH = 16;
`define SLICE16(bus, idx) bus[(idx)*WIDTH +: WIDTH]

    wire signed [WIDTH*4-1:0] X4 = { x4, x3, x2, x1 };

    // --- L1 ---
    wire signed [15:0] L1_out [0:3];
    genvar g1;
    generate
        for (g1=0; g1<4; g1=g1+1) begin : GEN_L1
            wire signed [WIDTH*4-1:0] w_vec = L1_w[(g1*WIDTH*4) +: (WIDTH*4)];
            l2_neuron #(.N(4), .WIDTH(WIDTH)) n (
                .clk(clk), .rst(rst), // Pipelined
                .x(X4),
                .w(w_vec),
                .b(`SLICE16(L1_b, g1)),
                .y(L1_out[g1])
            );
        end
    endgenerate
    wire signed [WIDTH*4-1:0] L1_out_vec = { L1_out[3], L1_out[2], L1_out[1], L1_out[0] };

    // --- L2 ---
    wire signed [15:0] L2_out [0:1];
    genvar g2;
    generate
        for (g2=0; g2<2; g2=g2+1) begin : GEN_L2
            wire signed [WIDTH*4-1:0] w_vec = L2_w[(g2*WIDTH*4) +: (WIDTH*4)];
            l2_neuron #(.N(4), .WIDTH(WIDTH)) n (
                .clk(clk), .rst(rst), // Pipelined
                .x(L1_out_vec),
                .w(w_vec),
                .b(`SLICE16(L2_b, g2)),
                .y(L2_out[g2])
            );
        end
    endgenerate
    wire signed [WIDTH*2-1:0] L2_out_vec = { L2_out[1], L2_out[0] };

    // --- L3 ---
    wire signed [15:0] L3_out;
    l2_neuron #(.N(2), .WIDTH(WIDTH)) L3_n (
        .clk(clk), .rst(rst), // Pipelined
        .x(L2_out_vec),
        .w(L3_w),
        .b(L3_b[WIDTH-1:0]),
        .y(L3_out)
    );

    // --- L4 ---
    wire signed [15:0] L4_out;
    l2_neuron #(.N(1), .WIDTH(WIDTH)) L4_n (
        .clk(clk), .rst(rst), // Pipelined
        .x(L3_out),
        .w(L4_w),
        .b(L4_b[WIDTH-1:0]),
        .y(L4_out)
    );

    // --- L5 ---
    wire signed [15:0] L5_out;
    l2_neuron #(.N(1), .WIDTH(WIDTH)) L5_n (
        .clk(clk), .rst(rst), // Pipelined
        .x(L4_out),
        .w(L5_w),
        .b(L5_b[WIDTH-1:0]),
        .y(L5_out)
    );

    // --- L6 ---
    wire signed [15:0] L6_out [0:1];
    genvar g6;
    generate
        for (g6=0; g6<2; g6=g6+1) begin : GEN_L6
            l2_neuron #(.N(1), .WIDTH(WIDTH)) n (
                .clk(clk), .rst(rst), // Pipelined
                .x(L5_out),
                .w(`SLICE16(L6_w, g6)),
                .b(`SLICE16(L6_b, g6)),
                .y(L6_out[g6])
            );
        end
    endgenerate
    wire signed [WIDTH*2-1:0] L6_out_vec = { L6_out[1], L6_out[0] };

    // --- L7 ---
    wire signed [15:0] L7_out [0:3];
    genvar g7;
    generate
        for (g7=0; g7<4; g7=g7+1) begin : GEN_L7
            wire signed [WIDTH*2-1:0] w_vec = L7_w[(g7*WIDTH*2) +: (WIDTH*2)];
            l2_neuron #(.N(2), .WIDTH(WIDTH)) n (
                .clk(clk), .rst(rst), // Pipelined
                .x(L6_out_vec),
                .w(w_vec),
                .b(`SLICE16(L7_b, g7)),
                .y(L7_out[g7])
            );
        end
    endgenerate
    wire signed [WIDTH*4-1:0] L7_out_vec = { L7_out[3], L7_out[2], L7_out[1], L7_out[0] };

    // --- L8 ---
    wire signed [15:0] L8_out [0:3];
    genvar g8;
    generate
        for (g8=0; g8<4; g8=g8+1) begin : GEN_L8
            wire signed [WIDTH*4-1:0] w_vec = L8_w[(g8*WIDTH*4) +: (WIDTH*4)];
            l2_neuron #(.N(4), .WIDTH(WIDTH)) n (
                .clk(clk), .rst(rst), // Pipelindo
                .x(L7_out_vec),
                .w(w_vec),
                .b(`SLICE16(L8_b, g8)),
                .y(L8_out[g8])
            );
        end
    endgenerate

    // --- Final Output Assignment ---
    assign out1 = L8_out[0];
    assign out2 = L8_out[1];
    assign out3 = L8_out[2];
    assign out4 = L8_out[3];

`undef SLICE16
endmodule