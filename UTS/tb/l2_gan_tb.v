`timescale 1ns/1ps

module l2_gan_tb;

  parameter CLK_PERIOD = 10; // 10ns = 100MHz

  // --- Clock and Reset ---
  reg clk;
  reg rst;

  // --- Inputs (same as l1_gan_tb) ---
  reg  signed [15:0] x1, x2, x3, x4;
  reg  signed [16*4*4-1:0] L1_w;
  reg  signed [16*4-1:0]   L1_b;
  reg  signed [16*2*4-1:0] L2_w;
  reg  signed [16*2-1:0]   L2_b;
  reg  signed [16*1*2-1:0] L3_w;
  reg  signed [16*1-1:0]   L3_b;
  reg  signed [16*1*1-1:0] L4_w;
  reg  signed [16*1-1:0]   L4_b;
  reg  signed [16*1*1-1:0] L5_w;
  reg  signed [16*1-1:0]   L5_b;
  reg  signed [16*2*1-1:0] L6_w;
  reg  signed [16*2-1:0]   L6_b;
  reg  signed [16*4*2-1:0] L7_w;
  reg  signed [16*4-1:0]   L7_b;
  reg  signed [16*4*4-1:0] L8_w;
  reg  signed [16*4-1:0]   L8_b;

  // --- Outputs (same as l1_gan_tb) ---
  wire signed [15:0] out1, out2, out3, out4;

  // --- DUT Instantiation ---
  l2_gan dut (
    .clk(clk),
    .rst(rst),
    .x1(x1), .x2(x2), .x3(x3), .x4(x4),
    .L1_w(L1_w), .L1_b(L1_b),
    .L2_w(L2_w), .L2_b(L2_b),
    .L3_w(L3_w), .L3_b(L3_b),
    .L4_w(L4_w), .L4_b(L4_b),
    .L5_w(L5_w), .L5_b(L5_b),
    .L6_w(L6_w), .L6_b(L6_b),
    .L7_w(L7_w), .L7_b(L7_b),
    .L8_w(L8_w), .L8_b(L8_b),
    .out1(out1), .out2(out2), .out3(out3), .out4(out4)
  );

  // --- Clock Generator ---
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // --- Test Sequence ---
  initial begin
    $dumpfile("build/l2_gan_tb.vcd");
    $dumpvars(0, l2_gan_tb);

    // --- Reset Phase ---
    rst = 1;
    // Initialize all inputs to 0 during reset
    x1 = 0; x2 = 0; x3 = 0; x4 = 0;
    L1_w = 0; L1_b = 0;
    L2_w = 0; L2_b = 0;
    L3_w = 0; L3_b = 0;
    L4_w = 0; L4_b = 0;
    L5_w = 0; L5_b = 0;
    L6_w = 0; L6_b = 0;
    L7_w = 0; L7_b = 0;
    L8_w = 0; L8_b = 0;
    #(CLK_PERIOD * 2); // Hold reset
    rst = 0;
    #(CLK_PERIOD); // Release reset

    // --- Apply Test Vectors ---
    // (Copied directly from l1_gan_tb)
    
    // Inputs
    x1 = 16'sd0;
    x2 = 16'sd1;
    x3 = 16'sd1;
    x4 = 16'sd0;

    // L1
    L1_w = {
      -16'sd8   , -16'sd4   ,  16'sd12  ,  16'sd18,  // (w44 w34 w24 w14)
      -16'sd17  , -16'sd15  , -16'sd3   ,  16'sd3 ,  // (w43 w33 w23 w13)
      -16'sd9   , -16'sd6   ,  16'sd16  ,  16'sd21,  // (w42 w32 w22 w12)
      -16'sd16  ,  16'sd5   , -16'sd3   ,  16'sd6    // (w41 w31 w21 w11)
    };
    L1_b = { -16'sd1, 16'sd2, 16'sd0, 16'sd1 };    // (b4,b3,b2,b1)

    // L2
    L2_w = {
       16'sd15  ,  16'sd9  ,  16'sd14  , -16'sd14,  // (w42 w32 w22 w12)
       16'sd15  ,  16'sd8  ,  16'sd14  ,  16'sd4    // (w41 w31 w21 w11)
    };
    L2_b = { 16'sd4, 16'sd1 };                     // (b2,b1)

    // L3
    L3_w = { 16'sd6, 16'sd14 };                     // (w21 w11)
    L3_b =  16'sd5;                                 // (b1)

    // L4
    L4_w = 16'sd7;                                  // (w11)
    L4_b = 16'sd10;                                 // (b1)

    // L5
    L5_w =  16'sd1;                                 // (w11)
    L5_b = -16'sd4;                                 // (b1)

    // L6
    L6_w = { 16'sd14, -16'sd8 };                     // (w12 w11)
    L6_b = { 16'sd0 ,  16'sd20 };                    // (b2  b1)

    // L7
    L7_w = {
       16'sd15 , 16'sd15,                           // (w24 w14)
       16'sd9  , 16'sd8 ,                           // (w23 w13)
       16'sd14 , 16'sd14,                           // (w22 w12)
      -16'sd14 , 16'sd4                            // (w21 w11)
    };
    L7_b = { 16'sd2, 16'sd1, 16'sd3, 16'sd5 };     // (b4,b3,b2,b1)

    // L8
    L8_w = {
       16'sd12 ,  16'sd7 , -16'sd7 , -16'sd7,       // (w44 w34 w24 w14)
        16'sd4 , -16'sd5,  16'sd11,  16'sd10,       // (w43 w33 w23 w13)
       16'sd17 , -16'sd15, -16'sd6 , -16'sd7,       // (w42 w32 w22 w12)
        16'sd1 ,  16'sd10,  16'sd9 ,  16'sd11       // (w41 w31 w21 w11)
    };
    L8_b = { -16'sd10, 16'sd10, 16'sd10, -16'sd10 }; // (b4,b3,b2,b1)

    // --- Wait for Pipeline to Fill ---
    // Total latency = 8 layers * 2 cycles/layer = 16 cycles.
    // We will wait 20 cycles just to be safe.
    #(CLK_PERIOD * 20);

    // --- Check Output ---
    // The output should be the same as L1, just delayed
    $display("Pipelined OUT (at time %0t): %0d %0d %0d %0d",
             $time, out1, out2, out3, out4);

    #(CLK_PERIOD * 2);
    $finish;
  end

endmodule