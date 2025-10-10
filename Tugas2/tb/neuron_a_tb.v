`timescale 1ns/1ps

module neuron_a_tb;
  parameter N = 4;
  parameter WIDTH = 8;

  reg signed [N*WIDTH-1:0] x;
  reg signed [N*WIDTH-1:0] w;
  reg signed [WIDTH-1:0] b;
  wire signed [2*WIDTH+1:0] y;

  neuron #(.N(N), .WIDTH(WIDTH)) dut (
    .x(x),
    .w(w),
    .b(b),
    .y(y)
  );

  // Intermediate wires for signed display
  wire signed [WIDTH-1:0] x0 = x[7:0];
  wire signed [WIDTH-1:0] x1 = x[15:8];
  wire signed [WIDTH-1:0] x2 = x[23:16];
  wire signed [WIDTH-1:0] x3 = x[31:24];
  wire signed [WIDTH-1:0] w0 = w[7:0];
  wire signed [WIDTH-1:0] w1 = w[15:8];
  wire signed [WIDTH-1:0] w2 = w[23:16];
  wire signed [WIDTH-1:0] w3 = w[31:24];

  initial begin
    $dumpfile("build/neuron_a_tb.vcd");
    $dumpvars(0, neuron_a_tb);

    $display("Time\tx0\tx1\tx2\tx3\tw0\tw1\tw2\tw3\tb\t| y");
    $monitor("%0t\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t| %0d",
      $time,
      x0, x1, x2, x3,
      w0, w1, w2, w3,
      b, y);

    // Test 1
    // x = {0, 0, 0, 0}
    // w = {0, 0, 0, 0}
    // b = 0
    // y = (0*0) + (0*0) + (0*0) + (0*0) + 0 = 0
    // y = ReLU(0) = 0
    x = {8'd0, 8'd0, 8'd0, 8'd0};
    w = {8'd0, 8'd0, 8'd0, 8'd0};
    b = 8'd0;
    #10;

    // Test 2
    // x = {4, 3, 2, 1}
    // w = {1, 1, 1, 1}
    // b = 5
    // y = (4*1) + (3*1) + (2*1) + (1*1) + 5 = 4 + 3 + 2 + 1 + 5 = 15
    // y = ReLU(15) = 15
    x = {8'd4, 8'd3, 8'd2, 8'd1};
    w = {8'd1, 8'd1, 8'd1, 8'd1};
    b = 8'd5;
    #10;

    // Test 3
    // x = {2, 2, 2, 2}
    // w = {-1, -1, -1, -1}
    // b = -1
    // y = (2*-1) + (2*-1) + (2*-1) + (2*-1) + (-1) = -2 -2 -2 -2 -1 = -9
    // y = ReLU(-9) = 0
    x = {8'd2, 8'd2, 8'd2, 8'd2};
    w = {-8'd1, -8'd1, -8'd1, -8'd1};
    b = -8'd1;
    #10;

    // Test 4
    // x = {5, -3, 2, 1}
    // w = {2, 2, 2, 2}
    // b = 3
    // y = (5*2) + (-3*2) + (2*2) + (1*2) + 3 = 10 + (-6) + 4 + 2 + 3 = 13
    // y = ReLU(13) = 13
    x = {8'd5, -8'd3, 8'd2, 8'd1};
    w = {8'd2, 8'd2, 8'd2, 8'd2};
    b = 8'd3;
    #10;

    // Test 5
    // x = {5, -3, 2, 1}
    // w = {2, 3, 4, 5}
    // b = 3
    // y = (5*2) + (-3*3) + (2*4) + (1*5) + 3 = 10 + (-9) + 8 + 5 + 3 = 17
    // y = ReLU(17) = 17
    x = {8'd5, -8'd3, 8'd2, 8'd1};
    w = {8'd2, 8'd3, 8'd4, 8'd5};
    b = 8'd3;
    #10;


    #10 $finish;
  end
endmodule