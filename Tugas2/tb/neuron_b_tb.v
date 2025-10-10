`timescale 1ns/1ps

module neuron_b_tb;
  parameter N = 4;
  parameter WIDTH = 8;

  reg clk;
  reg rst;
  reg start;
  reg signed [N*WIDTH-1:0] x;
  reg signed [N*WIDTH-1:0] w;
  reg signed [WIDTH-1:0] b;
  wire done;
  wire signed [2*WIDTH+1:0] y;

  // Instantiate DUT
  neuron_b #(.N(N), .WIDTH(WIDTH)) dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .x(x),
    .w(w),
    .b(b),
    .done(done),
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

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("build/neuron_b_tb.vcd");
    $dumpvars(0, neuron_b_tb);

    $display("Time\tdone\tx0\tx1\tx2\tx3\tw0\tw1\tw2\tw3\tb\t| y");
    $monitor("%0t\t%b\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t| %0d",
      $time,
      done,
      x0, x1, x2, x3,
      w0, w1, w2, w3,
      b, y);

    // Reset
    rst = 1; start = 0;
    x = 0; w = 0; b = 0;
    #12; // Hold reset for a bit
    rst = 0;

    // Test 1
    // x = {0, 0, 0, 0}
    // w = {0, 0, 0, 0}
    // b = 0
    // y = (0*0) + (0*0) + (0*0) + (0*0) + 0 = 0
    // y = ReLU(0) = 0
    x = {8'd0, 8'd0, 8'd0, 8'd0};
    w = {8'd0, 8'd0, 8'd0, 8'd0};
    b = 8'd0;
    start = 1; #10; start = 0;
    wait_done();

    // Test 2
    // x = {4, 3, 2, 1}
    // w = {1, 1, 1, 1}
    // b = 5
    // y = (4*1) + (3*1) + (2*1) + (1*1) + 5 = 15
    // y = ReLU(15) = 15
    x = {8'd4, 8'd3, 8'd2, 8'd1};
    w = {8'd1, 8'd1, 8'd1, 8'd1};
    b = 8'd5;
    start = 1; #10; start = 0;
    wait_done();

    // Test 3
    // x = {2, 2, 2, 2}
    // w = {-1, -1, -1, -1}
    // b = -1
    // y = (2*-1) + (2*-1) + (2*-1) + (2*-1) + (-1) = -9
    // y = ReLU(-9) = 0
    x = {8'd2, 8'd2, 8'd2, 8'd2};
    w = {-8'd1, -8'd1, -8'd1, -8'd1};
    b = -8'd1;
    start = 1; #10; start = 0;
    wait_done();

    // Test 4
    // x = {5, -3, 2, 1}
    // w = {2, 2, 2, 2}
    // b = 3
    // y = (5*2) + (-3*2) + (2*2) + (1*2) + 3 = 13
    // y = ReLU(13) = 13
    x = {8'd5, -8'd3, 8'd2, 8'd1};
    w = {8'd2, 8'd2, 8'd2, 8'd2};
    b = 8'd3;
    start = 1; #10; start = 0;
    wait_done();

    // Test 5
    // x = {5, -3, 2, 1}
    // w = {2, 3, 4, 5}
    // b = 3
    // y = (5*2) + (-3*3) + (2*4) + (1*5) + 3 = 17
    // y = ReLU(17) = 17
    x = {8'd5, -8'd3, 8'd2, 8'd1};
    w = {8'd2, 8'd3, 8'd4, 8'd5};
    b = 8'd3;
    start = 1; #10; start = 0;
    wait_done();

    #20 $finish;
  end

  // Wait for done signal
  task wait_done;
    begin
      while (!done) @(posedge clk);
      #10; // Wait a bit to observe output
    end
  endtask

endmodule