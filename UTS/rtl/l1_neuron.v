// l1_neuron.v - Neuron Combinational

module l1_neuron #(parameter N=4, WIDTH=8) (
    input   signed [N*WIDTH-1:0] x,     // Vector of N inputs
    input   signed [N*WIDTH-1:0] w,     // Vector of N weights
    input   signed [WIDTH-1:0]   b,     // Bias
    output  signed [2*WIDTH+1:0] y      // Output
);

    localparam ACC_WIDTH = 2*WIDTH + 1;
    localparam MAX_BIT_S = {1'b0, {(WIDTH-1){1'b1}}};

    integer i;
    reg signed [2*WIDTH+1:0] sum;       // Accumulator for weighted sum + bias
    reg signed [2*WIDTH+1:0] relu_out;  // Output after ReLU

    always @* begin
        // Initialize sum with bias
        sum = b;
        // Perform parallel multiply and accumulate
        for (i = 0; i < N; i = i + 1) begin
            // Extract each input and weight, multiply, and accumulate
            sum = sum + 
                $signed(x[i*WIDTH +: WIDTH]) * 
                $signed(w[i*WIDTH +: WIDTH]);
        end

        // ReLU activation: output is sum if sum > 0, else 0
        if (sum > 0)
            relu_out = sum;
        else
            relu_out = 0;
    end

    // Saturate output
    assign y = (relu_out > MAX_BIT_S) ? MAX_BIT_S : relu_out[WIDTH-1:0];

endmodule

