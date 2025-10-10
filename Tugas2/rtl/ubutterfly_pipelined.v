// Pipelined Unified Butterfly (Radix-2 FFT/IFFT)
// Inputs: a, b, w (8-bit signed), s (select: 0=DIT, 1=DIF), clk, rst
// Outputs: outa, outb (16-bit signed)

module ubutterfly_pipelined (
    input clk,
    input rst,
    input signed [7:0] a,
    input signed [7:0] b,
    input signed [7:0] w,
    input s, // Select: 0=DIT, 1=DIF
    output reg signed [15:0] outa,
    output reg signed [15:0] outb
);

    // Stage 1: Add/Sub
    wire signed [7:0] add_ab = a + b;
    wire signed [7:0] sub_ab = a - b;

    // Stage 2: Muxes for pipeline input
    wire signed [7:0] mux1 = s ? add_ab : a;
    wire signed [7:0] mux2 = s ? sub_ab : b;

    // Stage 3: Pipe registers
    reg signed [7:0] pipe1, pipe2;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pipe1 <= 0;
            pipe2 <= 0;
        end else begin
            pipe1 <= mux1;
            pipe2 <= mux2;
        end
    end

    // Stage 4: Multiply
    wire signed [15:0] mult = pipe2 * w;

    // Stage 5: Pipe registers
    reg signed [7:0] pipe3;
    reg signed [15:0] pipe4;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pipe3 <= 0;
            pipe4 <= 0;
        end else begin
            pipe3 <= pipe1;
            pipe4 <= mult;
        end
    end

    // Stage 6: Add/Sub for output
    wire signed [15:0] add_out = pipe3 + pipe4;
    wire signed [15:0] sub_out = pipe3 - pipe4;

    // Stage 7: Output muxes and registers
    wire signed [15:0] mux_outa = s ? pipe3 : add_out;
    wire signed [15:0] mux_outb = s ? pipe4 : sub_out;

    reg signed [15:0] pipe5, pipe6;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pipe5 <= 0;
            pipe6 <= 0;
        end else begin
            pipe5 <= mux_outa;
            pipe6 <= mux_outb;
        end
    end

    // Final outputs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            outa <= 0;
            outb <= 0;
        end else begin
            outa <= pipe5;
            outb <= pipe6;
        end
    end

endmodule