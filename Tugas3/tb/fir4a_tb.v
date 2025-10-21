`timescale 1ns/1ps

module fir4a_tb;
    reg clk, rst;
    reg signed [7:0] x_in, h0, h1, h2, h3;
    wire signed [15:0] y_out;

    fir4_a dut (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .h0(h0), .h1(h1), .h2(h2), .h3(h3),
        .y_out(y_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/fir4a_tb.vcd");
        $dumpvars(0, fir4a_tb);

        // Set coefficients
        h0 = 1; h1 = 2; h2 = 3; h3 = 4;

        // Reset
        rst = 1; x_in = 0;
        #12;
        rst = 0;

        // Input sequence and expected output:
        // y[n] = h0*x[n] + h1*x[n-1] + h2*x[n-2] + h3*x[n-3]
        // -------------------------------------------------
        // Cycle | x_in | x[n] | x[n-1] | x[n-2] | x[n-3] | y_out (expected)
        //   1   |  5   |  5   |   0    |   0    |   0    | 5
        //   2   |  6   |  6   |   5    |   0    |   0    | 16
        //   3   |  7   |  7   |   6    |   5    |   0    | 34
        //   4   |  8   |  8   |   7    |   6    |   5    | 60
        //   5   |  0   |  0   |   8    |   7    |   6    | 61

        // Change input at each rising edge
        @(negedge clk); x_in = 5;  // y_out = 5
        @(negedge clk); x_in = 6;  // y_out = 16
        @(negedge clk); x_in = 7;  // y_out = 34
        @(negedge clk); x_in = 8;  // y_out = 60
        @(negedge clk); x_in = 0;  // y_out = 61

        // Hold input to see output settle
        repeat(5) @(negedge clk);

        $finish;
    end
endmodule