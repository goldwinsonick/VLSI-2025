`timescale 1ns/1ps

module inv32_tb;
  reg [31:0] a;
  wire [31:0] y;

  inv32 dut (
    .a(a),
    .y(y)
  );

  initial begin
    $dumpfile("build/inv32_tb.vcd");
    $dumpvars(0, inv32_tb);

    $display("Time\t%32s\t| %32s", "a", "y");
    $monitor("%0t\t%b\t| %b", $time, a, y);

    // Test 1: all zeros
    a = 32'b00000000000000000000000000000000; #10; // Expect: all ones
    // Test 2: all ones
    a = 32'b11111111111111111111111111111111; #10; // Expect: all zeros
    // Test 3: alternating bits
    a = 32'b10101010101010101010101010101010; #10; // Expect: 010101...
    // Test 4: lower half ones, upper half zeros
    a = 32'b00000000000000001111111111111111; #10; // Expect: upper half ones, lower half zeros
    // Test 5: random pattern
    a = 32'b11001100110011001100110011001100; #10; // Expect: 001100...

    #10 $finish;
  end
endmodule