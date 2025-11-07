`timescale 1ns/1ps

module l2_neuron_tb;
  // --- Parameters ---
  parameter N = 4;
  parameter WIDTH = 8; // Consistent with your l1_neuron_tb
  parameter CLK_PERIOD = 10;

  // --- TB Signals ---
  reg clk;
  reg rst;
  reg signed [N*WIDTH-1:0] x;
  reg signed [N*WIDTH-1:0] w;
  reg signed [WIDTH-1:0]   b;
  wire signed [WIDTH-1:0]  y; // Output is now 16-bit (saturated)

  // --- DUT Instantiation ---
  l2_neuron #(.N(N), .WIDTH(WIDTH)) dut (
    .clk(clk),
    .rst(rst),
    .x(x),
    .w(w),
    .b(b),
    .y(y)
  );

  // --- Clock Generator ---
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // --- Slicer for $monitor (same as your L1 tb) ---
  wire signed [WIDTH-1:0] x0 = x[7:0];
  wire signed [WIDTH-1:0] x1 = x[15:8];
  wire signed [WIDTH-1:0] x2 = x[23:16];
  wire signed [WIDTH-1:0] x3 = x[31:24];
  wire signed [WIDTH-1:0] w0 = w[7:0];
  wire signed [WIDTH-1:0] w1 = w[15:8];
  wire signed [WIDTH-1:0] w2 = w[23:16];
  wire signed [WIDTH-1:0] w3 = w[31:24];

  // --- Test Sequence ---
  initial begin
    $dumpfile("build/l2_neuron_tb.vcd");
    $dumpvars(0, l2_neuron_tb);

    $display("Time\tx0\tx1\tx2\tx3\tw0\tw1\tw2\tw3\tb\t| y (Pipelined)");
    $monitor("%0t\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t| %0d",
      $time,
      x0, x1, x2, x3,
      w0, w1, w2, w3,
      b, y);

    // --- Reset Sequence ---
    rst = 1;
    x = 0;
    w = 0;
    b = 0;
    #(CLK_PERIOD * 2); // Hold reset for 2 cycles
    rst = 0;
    #(CLK_PERIOD);

    // --- Start Pipelined Tests ---
    // Note: Output 'y' will lag input by 2 clock cycles.
    
    // Test 1 (Expected y=0)
    x = {8'd0, 8'd0, 8'd0, 8'd0};
    w = {8'd0, 8'd0, 8'd0, 8'd0};
    b = 8'd0;
    #(CLK_PERIOD); // S1 of Test 1

    // Test 2 (Expected y=15)
    x = {8'd4, 8'd3, 8'd2, 8'd1};
    w = {8'd1, 8'd1, 8'd1, 8'd1};
    b = 8'd5;
    #(CLK_PERIOD); // S2 of Test 1, S1 of Test 2. y=0 (from reset)

    // Test 3 (Expected y=0)
    x = {8'd2, 8'd2, 8'd2, 8'd2};
    w = {-8'd1, -8'd1, -8'd1, -8'd1};
    b = -8'd1;
    #(CLK_PERIOD); // S2 of Test 2, S1 of Test 3. y=0 (Result of Test 1)

    // Test 4 (Expected y=13)
    x = {8'd5, -8'd3, 8'd2, 8'd1};
    w = {8'd2, 8'd2, 8'd2, 8'd2};
    b = 8'd3;
    #(CLK_PERIOD); // S2 of Test 3, S1 of Test 4. y=15 (Result of Test 2)

    // Test 5 (Expected y=17)
    x = {8'd5, -8'd3, 8'd2, 8'd1};
    w = {8'd2, 8'd3, 8'd4, 8'd5};
    b = 8'd3;
    #(CLK_PERIOD); // S2 of Test 4, S1 of Test 5. y=0 (Result of Test 3)

    // Test 6 (Saturation Test: Expected y=127)
    // 10*10 + 10*10 + 10*10 + 10*10 + 0 = 400
    // 400 > 127 (MAX_8BIT_S), so it should saturate.
    x = {8'd10, 8'd10, 8'd10, 8'd10};
    w = {8'd10, 8'd10, 8'd10, 8'd10};
    b = 8'd0;
    #(CLK_PERIOD); // S2 of Test 5, S1 of Test 6. y=13 (Result of Test 4)

    // --- Flush Pipeline ---
    // Apply 2 more cycles with 0 inputs
    x = 0;
    w = 0;
    b = 0;
    #(CLK_PERIOD); // S2 of Test 6, S1 of Flush. y=17 (Result of Test 5)
    
    #(CLK_PERIOD); // S2 of Flush. y=127 (Result of Test 6 - SATURATION)

    #(CLK_PERIOD); // y=0 (Result of Flush)

    #10 $finish;
  end
endmodule