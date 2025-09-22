`timescale 1ns/1ps

module neuron_tb;
  parameter N = 4;
  parameter WIDTH = 8;

  reg signed [WIDTH-1:0] x [N-1:0];
  reg signed [WIDTH-1:0] w [N-1:0];
  reg signed [WIDTH-1:0] b;
  wire signed [2*WIDTH+1:0] y;

  neuron #(.N(N), .WIDTH(WIDTH)) dut (
    .x(x),
    .w(w),
    .b(b),
    .y(y)
  );

  integer i;

  initial begin
    $dumpfile("build/neuron_tb.vcd");
    $dumpvars(0, neuron_tb);

    $display("Time\t\t x0\t x1\t x2\t x3\t w0\t w1\t w2\t w3\t b\t | y");
    $monitor("%0t\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t| %0d",
      $time, x[0], x[1], x[2], x[3], w[0], w[1], w[2], w[3], b, y);

    // Test 1: all zeros
    x[0]=0; x[1]=0; x[2]=0; x[3]=0;
    w[0]=0; w[1]=0; w[2]=0; w[3]=0;
    b=0;
    #10; // Expect: 0

    // Test 2: positive inputs and weights, positive bias
    x[0]=1; x[1]=2; x[2]=3; x[3]=4;
    w[0]=1; w[1]=1; w[2]=1; w[3]=1;
    b=5;
    #10; // Expect: 1+2+3+4+5 = 15

    // Test 3: negative weights, negative bias
    x[0]=2; x[1]=2; x[2]=2; x[3]=2;
    w[0]=-1; w[1]=-1; w[2]=-1; w[3]=-1;
    b=-1;
    #10; // Expect: -2-2-2-2-1 = -9 -> ReLU = 0

    // Test 4: mixed values, positive sum
    x[0]=5; x[1]=-3; x[2]=2; x[3]=1;
    w[0]=2; w[1]=2; w[2]=2; w[3]=2;
    b=3;
    #10; // Expect: 10 + (-6) + 4 + 2 + 3 = 13

    // Test 5: mixed values, negative sum
    x[0]=-5; x[1]=3; x[2]=-2; x[3]=1;
    w[0]=2; w[1]=-2; w[2]=2; w[3]=-2;
    b=-3;
    #10; // Expect: -10 + (-6) + (-4) + (-2) -3 = -25 -> ReLU = 0

    #10 $finish;
  end
endmodule