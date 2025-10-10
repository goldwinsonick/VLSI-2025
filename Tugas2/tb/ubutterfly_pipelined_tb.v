`timescale 1ns/1ps

module ubutterfly_pipelined_tb;
    reg clk, rst;
    reg signed [7:0] a, b, w;
    reg s; // Select: 0 = DIT, 1 = DIF
    wire signed [15:0] outa, outb;

    // Instantiate the DUT
    ubutterfly_pipelined dut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .w(w),
        .s(s),
        .outa(outa),
        .outb(outb)
    );

    // Clock generation (period 10ns)
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/ubutterfly_pipelined_tb.vcd");
        $dumpvars(0, ubutterfly_pipelined_tb);

        $display("Time\ts\ta\tb\tw\t| outa\toutb");
        $monitor("%0t\t%b\t%0d\t%0d\t%0d\t| %0d\t%0d",
            $time, s, a, b, w, outa, outb);

        // Reset
        rst = 1;
        a = 0; b = 0; w = 0; s = 0;
        #12;
        rst = 0;

        // Test 1: DIT mode (s=0)
        // a = 10, b = 2, w = 3
        // outa = a + w*b = 10 + 3*2 = 16
        // outb = a - w*b = 10 - 3*2 = 4
        s = 0; a = 10; b = 2; w = 3;
        #10;

        // Test 2: DIF mode (s=1)
        // a = 10, b = 2, w = 3
        // outa = a + b = 10 + 2 = 12
        // outb = w*(a-b) = 3*(10-2) = 24
        s = 1; a = 10; b = 2; w = 3;
        #10;

        // Test 3: DIT mode, negative values
        // a = -5, b = 4, w = -2
        // outa = -5 + (-2)*4 = -5 + (-8) = -13
        // outb = -5 - (-8) = -5 + 8 = 3
        s = 0; a = -5; b = 4; w = -2;
        #10;

        // Test 4: DIF mode, negative values
        // a = -5, b = 4, w = -2
        // outa = -5 + 4 = -1
        // outb = -2 * (-5 - 4) = -2 * (-9) = 18
        s = 1; a = -5; b = 4; w = -2;
        #10;

        // Test 5: DIT mode, both inputs negative
        // a = -7, b = -3, w = 2
        // outa = -7 + 2*(-3) = -7 + (-6) = -13
        // outb = -7 - (-6) = -7 + 6 = -1
        s = 0; a = -7; b = -3; w = 2;
        #10;

        // Test 6: DIF mode, both inputs negative
        // a = -7, b = -3, w = 2
        // outa = -7 + (-3) = -10
        // outb = 2 * (-7 - (-3)) = 2 * (-4) = -8
        s = 1; a = -7; b = -3; w = 2;
        #10;

        #50 $finish;
    end
endmodule