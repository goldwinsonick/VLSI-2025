// [mac.v] Sequential Multiply-Accumulate module: sum_i(w_i * x_i) + b

module mac #(parameter N=4, WIDTH=8) (
    input clk,                          // Clock signal
    input rst,                          // Synchronous reset
    input start,                        // Start signal
    input signed [N*WIDTH-1:0] x,       // Vector of N signed inputs
    input signed [N*WIDTH-1:0] w,       // Vector of N signed weights
    input signed [WIDTH-1:0] b,         // Signed bias
    output reg done,                    // Done signal (high when finished)
    output reg signed [2*WIDTH+1:0] sum // Output: weighted sum + bias
);

    reg [2:0] count;                // Counter (enough bits for N)
    reg signed [2*WIDTH+1:0] acc;   // Accumulator

    always @(posedge clk) begin
        if (rst) begin
            // Reset state
            count <= 0;
            acc <= 0;
            sum <= 0;
            done <= 0;
        end else if (start) begin
            // Start new MAC operation
            count <= 0;
            acc <= b;
            done <= 0;
        end else if (!done) begin
            // Perform MAC operation (until done)
            acc <= acc + $signed(x[count*WIDTH +: WIDTH]) * $signed(w[count*WIDTH +: WIDTH]);
            count <= count + 1;
            if (count == N-1) begin
                sum <= acc + $signed(x[(N-1)*WIDTH +: WIDTH]) * $signed(w[(N-1)*WIDTH +: WIDTH]);
                done <= 1;
            end
        end
    end

endmodule