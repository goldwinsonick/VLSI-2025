`timescale 1ns/1ps

module or32_tb;
  reg [31:0] a, b;
  wire [31:0] y;

  or32 dut (
    .a(a),
    .b(b),
    .y(y)
  );

  initial begin
    $dumpfile("build/or32_tb.vcd");
    $dumpvars(0, or32_tb);

    $display("Time\t%32s\t%32s\t| %32s", "a", "b", "y");
    $monitor("%0t\t%b\t%b\t| %b", $time, a, b, y);

    // Test 1: all zeros
    a = 32'b00000000000000000000000000000000;
    b = 32'b00000000000000000000000000000000; #10; // Expect: 0
    // Test 2: all ones
    a = 32'b11111111111111111111111111111111;
    b = 32'b11111111111111111111111111111111; #10; // Expect: all ones
    // Test 3: alternating bits
    a = 32'b10101010101010101010101010101010;
    b = 32'b01010101010101010101010101010101; #10; // Expect: all ones
    // Test 4: lower half ones, upper half zeros
    a = 32'b00000000000000001111111111111111;
    b = 32'b11111111111111110000000000000000; #10; // Expect: all ones
    // Test 5: random pattern
    a = 32'b11001100110011001100110011001100;
    b = 32'b10101010101010101010101010101010; #10; // Expect: 111011...

    #10 $finish;
  end
endmodule