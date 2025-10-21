// [fir4_a.v] 4-tap FIR filter implementation

module fir4_a (
    input clk,
    input rst,
    input signed [7:0] x_in,
    input signed [7:0] h0, h1, h2, h3,
    output signed [15:0] y_out
);
    reg signed [7:0] x1, x2, x3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x1 <= 0; x2 <= 0; x3 <= 0;
        end else begin
            x1 <= x_in;
            x2 <= x1;
            x3 <= x2;
        end
    end

    wire signed [15:0] m0 = x_in * h0;
    wire signed [15:0] m1 = x1   * h1;
    wire signed [15:0] m2 = x2   * h2;
    wire signed [15:0] m3 = x3   * h3;

    assign y_out = m0 + m1 + m2 + m3;
endmodule