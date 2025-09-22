// [neuron.v] Neuron module with ReLU activation.

module neuron #(
    parameter N = 4,
    parameter WIDTH = 8
)(
    input  wire signed [WIDTH-1:0] x [N-1:0], // inputs
    input  wire signed [WIDTH-1:0] w [N-1:0], // weights
    input  wire signed [WIDTH-1:0] b,         // bias
    output wire signed [2*WIDTH+1:0] y        // output (optimal: 2*WIDTH+2 bits)
);

    // Sum of products
    wire signed [2*WIDTH-1:0] prod [N-1:0];
    wire signed [2*WIDTH+1:0] sum;

    assign prod[0] = x[0] * w[0];
    assign prod[1] = x[1] * w[1];
    assign prod[2] = x[2] * w[2];
    assign prod[3] = x[3] * w[3];

    assign sum = prod[0] + prod[1] + prod[2] + prod[3] + b;

    // ReLU activation
    assign y = (sum > 0) ? sum : 0;

endmodule