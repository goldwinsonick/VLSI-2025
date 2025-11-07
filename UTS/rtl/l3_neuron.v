// l3_neuron.v - Combinational Neuron (N=4)

module l3_neuron #(
    parameter N     = 4,
    parameter WIDTH = 16
) (
    // All ports are combinational
    input  signed [N*WIDTH-1:0] x, // Vector of N inputs
    input  signed [N*WIDTH-1:0] w, // Vector of N weights
    input  signed [WIDTH-1:0]   b, // Bias
    output signed [WIDTH-1:0]   y  // Final 16-bit output (ReLU + Saturated)
);

    localparam ACC_WIDTH   = 2*WIDTH + 1;               // 33-bit
    localparam MAX_16BIT_S = {1'b0, {(WIDTH-1){1'b1}}}; // 16'h7FFF

    integer i;
    reg signed [ACC_WIDTH:0] sum;
    reg signed [WIDTH-1:0]   y_out;

    always @* begin
        // 1. Perform MAC
        sum = b;
        for (i = 0; i < N; i = i + 1) begin
            sum = sum + $signed(x[i*WIDTH +: WIDTH]) * $signed(w[i*WIDTH +: WIDTH]);
        end

        // 2. Perform ReLU and Saturate
        if (sum <= 0) begin
            y_out = 0; // ReLU
        end else if (sum > MAX_16BIT_S) begin
            y_out = MAX_16BIT_S; // Saturate
        end else begin
            y_out = sum[WIDTH-1:0]; // Pass through
        end
    end

    assign y = y_out;

endmodule