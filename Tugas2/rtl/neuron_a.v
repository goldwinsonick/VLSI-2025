// [neuron_a.v] Neuron module with ReLU activation.

module neuron #(parameter N=4, WIDTH=8) (
    input   signed [N*WIDTH-1:0] x, // Vector of N signed inputs
    input   signed [N*WIDTH-1:0] w, // Vector of N signed weights
    input   signed [WIDTH-1:0] b,   // Signed bias
    output  signed [2*WIDTH+1:0] y  // Output after ReLU activation
);

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

    // Assign output
    assign y = relu_out;

endmodule



