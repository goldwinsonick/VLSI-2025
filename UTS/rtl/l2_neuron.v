// l2_neuron.v - Pipelined Neuron (2-Stage)

module l2_neuron #(parameter N=4, WIDTH=16) (
    // --- Global Ports ---
    input clk,
    input rst,                 // Synchronous, active-high reset

    // --- Data Ports ---
    input  signed [N*WIDTH-1:0] x, // Vector of N inputs
    input  signed [N*WIDTH-1:0] w, // Vector of N weights
    input  signed [WIDTH-1:0]   b, // Bias
    output signed [WIDTH-1:0]   y  // Pipelined Output (Saturated 16-bit)
);

    localparam ACC_WIDTH   = 2*WIDTH + 1;
    localparam MAX_16BIT_S = {1'b0, {(WIDTH-1){1'b1}}}; // 16'h7FFF

    // --- Pipeline Registers (S1 -> S2) ---
    reg signed [ACC_WIDTH:0] mult_pipe [0:N-1]; // Multiplier results
    reg signed [WIDTH-1:0]   b_pipe;            // Bias register

    // --- Output Register (S2 -> Output) ---
    reg signed [WIDTH-1:0]   y_reg;

    // --- Internal Wires ---
    wire signed [ACC_WIDTH:0] s1_mult_results [N-1:0];
    wire signed [ACC_WIDTH:0] s2_sum;
    wire signed [ACC_WIDTH:0] s2_relu_out;
    wire signed [WIDTH-1:0]   s2_final_y;

    // --- Loop Variables ---
    integer i;
    genvar g1;

    // --- STAGE 1 LOGIC (Combinational: Multipliers) ---
    generate
        for (g1 = 0; g1 < N; g1 = g1 + 1) begin : GEN_MULT
            assign s1_mult_results[g1] = $signed(x[g1*WIDTH +: WIDTH]) * $signed(w[g1*WIDTH +: WIDTH]);
        end
    endgenerate

    // --- STAGE 2 LOGIC (Combinational: Adder + ReLU + Saturate) ---
    
    // 1. Adder Tree
    reg signed [ACC_WIDTH:0] s2_sum_comb;
    always @* begin
        s2_sum_comb = b_pipe; // Start with bias from register
        // Use 'integer i' for this behavioral loop
        for (i = 0; i < N; i = i + 1) begin
            s2_sum_comb = s2_sum_comb + mult_pipe[i];
        end
    end
    assign s2_sum = s2_sum_comb;

    // 2. ReLU
    assign s2_relu_out = (s2_sum > 0) ? s2_sum : 0;

    // 3. Saturate to 16-bit
    assign s2_final_y = (s2_relu_out > MAX_16BIT_S) ? MAX_16BIT_S 
                                                   : s2_relu_out[WIDTH-1:0];


    // --- PIPELINE REGISTER LOGIC ---
    always @(posedge clk) begin
        if (rst) begin
            // Reset all registers
            // Use 'integer i' for this behavioral loop
            for (i = 0; i < N; i = i + 1) begin
                mult_pipe[i] <= 'sd0;
            end
            b_pipe <= 'sd0;
            y_reg  <= 'sd0;
        end else begin
            // --- S1 -> S2 Registers ---
            // Latch S1 results and bias
            // Use 'integer i' for this behavioral loop
            for (i = 0; i < N; i = i + 1) begin
                mult_pipe[i] <= s1_mult_results[i];
            end
            b_pipe <= b;

            // --- S2 -> Output Register ---
            // Latch S2 result
            y_reg <= s2_final_y;
        end
    end

    // Assign final output from register
    assign y = y_reg;

endmodule