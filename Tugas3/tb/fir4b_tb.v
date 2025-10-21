`timescale 1ns/1ps

module fir4b_tb;
    reg clk, rst, start;
    reg signed [7:0] x_in, h0, h1, h2, h3;
    wire signed [15:0] y_out;
    wire done;

    fir4_b dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x_in(x_in),
        .h0(h0), .h1(h1), .h2(h2), .h3(h3),
        .y_out(y_out),
        .done(done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("build/fir4b_tb.vcd");
        $dumpvars(0, fir4b_tb);

        // Set coefficients
        h0 = 1; h1 = 2; h2 = 3; h3 = 4;

        // Reset
        rst = 1; start = 0; x_in = 0;
        #12;
        rst = 0;

        // Input sequence (start pulse tiap data baru)
        x_in = 5;  start = 1; #10; start = 0;
        wait_done();

        x_in = 6;  start = 1; #10; start = 0;
        wait_done();

        x_in = 7;  start = 1; #10; start = 0;
        wait_done();

        x_in = 8;  start = 1; #10; start = 0;
        wait_done();

        x_in = 0;  start = 1; #10; start = 0;
        wait_done();

        #30 $finish;
    end

    // Wait for done signal
    task wait_done;
        begin
            while (!done) @(posedge clk);
            #2;
        end
    endtask
endmodule