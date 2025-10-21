// [fir4_b.v] 4-tap FIR filter implementation with hardware sharing

module fir4_b (
    input clk,
    input rst,
    input start,
    input signed [7:0] x_in,
    input signed [7:0] h0, h1, h2, h3,
    output reg signed [15:0] y_out,
    output reg done
);
    reg signed [7:0] xreg [0:3];
    reg signed [7:0] hreg [0:3];
    reg [1:0] idx;
    reg signed [15:0] acc;
    reg busy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            xreg[0] <= 0; xreg[1] <= 0; xreg[2] <= 0; xreg[3] <= 0;
            hreg[0] <= 0; hreg[1] <= 0; hreg[2] <= 0; hreg[3] <= 0;
            idx <= 0; acc <= 0; y_out <= 0; done <= 0; busy <= 0;
        end else if (start && !busy) begin
            // Shift register input
            xreg[3] <= xreg[2];
            xreg[2] <= xreg[1];
            xreg[1] <= xreg[0];
            xreg[0] <= x_in;
            // Load coefficients
            hreg[0] <= h0; hreg[1] <= h1; hreg[2] <= h2; hreg[3] <= h3;
            idx <= 0;
            acc <= 0;
            done <= 0;
            busy <= 1;
        end else if (busy) begin
            acc <= acc + xreg[idx] * hreg[idx];
            if (idx == 3) begin
                y_out <= acc + xreg[3] * hreg[3];
                done <= 1;
                busy <= 0;
            end
            idx <= idx + 1;
        end else begin
            done <= 0;
        end
    end
endmodule