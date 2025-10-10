// [neuron_b.v] Neuron module using mac and relu

module neuron_b #(parameter N=4, WIDTH=8) (
    input clk,                      // Clock signal
    input rst,                      // Synchronous reset
    input start,                    // Start signal
    input signed [N*WIDTH-1:0] x,   // Vector of N signed inputs
    input signed [N*WIDTH-1:0] w,   // Vector of N signed weights
    input signed [WIDTH-1:0] b,     // Signed bias
    output done,                    // Done signal from MAC
    output signed [2*WIDTH+1:0] y   // Output after ReLU activation
);

    wire signed [2*WIDTH+1:0] sum;
    wire mac_done;

    // Instantiate sequential MAC
    mac #(.N(N), .WIDTH(WIDTH)) mac_inst (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x(x),
        .w(w),
        .b(b),
        .done(mac_done),
        .sum(sum)
    );

    // Instantiate ReLU (output width matches MAC output)
    relu #(.WIDTH(2*WIDTH+2)) relu_inst (
        .in(sum),
        .out(y)
    );

    // Pass done signal to top
    assign done = mac_done;

endmodule