`timescale 1ns/1ps

module ubetterfly_tb;
    reg signed [7:0] a, b, w;
    reg s; // Select: 0 = DIT, 1 = DIF
    wire signed [15:0] out_a, out_b;

    // Instantiate the DUT
    ubutterfly dut (
        .a(a),
        .b(b),
        .w(w),
        .s(s),
        .out_a(out_a),
        .out_b(out_b)
    );

    initial begin
        $dumpfile("build/ubetterfly_tb.vcd");
        $dumpvars(0, ubetterfly_tb);

        $display("Time\ts\ta\tb\tw\t| out_a\tout_b");
        $monitor("%0t\t%b\t%0d\t%0d\t%0d\t| %0d\t%0d",
            $time, s, a, b, w, out_a, out_b);

        // Test 1: DIT mode (s=0)
        // a = 10, b = 2, w = 3
        // out_a = a + w*b = 10 + 3*2 = 16
        // out_b = a - w*b = 10 - 3*2 = 4
        s = 0; a = 10; b = 2; w = 3;
        #10;

        // Test 2: DIF mode (s=1)
        // a = 10, b = 2, w = 3
        // out_a = a + b = 10 + 2 = 12
        // out_b = w*(a-b) = 3*(10-2) = 24
        s = 1; a = 10; b = 2; w = 3;
        #10;

        // Test 3: DIT mode, negative values
        // a = -5, b = 4, w = -2
        // out_a = -5 + (-2)*4 = -5 + (-8) = -13
        // out_b = -5 - (-8) = -5 + 8 = 3
        s = 0; a = -5; b = 4; w = -2;
        #10;

        // Test 4: DIF mode, negative values
        // a = -5, b = 4, w = -2
        // out_a = -5 + 4 = -1
        // out_b = -2 * (-5 - 4) = -2 * (-9) = 18
        s = 1; a = -5; b = 4; w = -2;
        #10;

        // Test 5: DIT mode, both inputs negative
        // a = -7, b = -3, w = 2
        // out_a = -7 + 2*(-3) = -7 + (-6) = -13
        // out_b = -7 - (-6) = -7 + 6 = -1
        s = 0; a = -7; b = -3; w = 2;
        #10;

        // Test 6: DIF mode, both inputs negative
        // a = -7, b = -3, w = 2
        // out_a = -7 + (-3) = -10
        // out_b = 2 * (-7 - (-3)) = 2 * (-4) = -8
        s = 1; a = -7; b = -3; w = 2;
        #10;

        #10 $finish;
    end
endmodule