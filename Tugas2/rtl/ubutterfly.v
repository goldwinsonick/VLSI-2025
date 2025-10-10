// Unified Butterfly (combinational, radix-2 FFT/IFFT)
// Implements the internal mux structure as shown in the diagram.
// Inputs: a, b, w (8-bit signed), s (select: 0=DIT, 1=DIF)
// Outputs: out_a, out_b (16-bit signed)

module ubutterfly (
    input signed [7:0] a,       // Input a
    input signed [7:0] b,       // Input b
    input signed [7:0] w,       // Twiddle factor w
    input s,                    // Select: 0=DIT, 1=DIF
    output signed [15:0] out_a, // Output a (16-bit)
    output signed [15:0] out_b  // Output b (16-bit)
);

    // 1: Addition and subtraction of inputs
    wire signed [7:0] add_ab = a + b;
    wire signed [7:0] sub_ab = a - b;

    // 2: Mux to select input for multiplication
    wire signed [7:0] mux_b_for_mult = s ? sub_ab : b;

    // Stage 3: Multiplication with twiddle factor
    wire signed [15:0] mult = w * mux_b_for_mult;

    // Stage 4: Mux to select input for final addition
    wire signed [15:0] mux_a_for_add = s ? add_ab : a;

    // Stage 5: Final outputs using muxes
    assign out_a = mux_a_for_add + (s ? 16'd0 : mult); // DIT: a + w*b, DIF: a + b
    assign out_b = (s ? mult : (a - mult));            // DIT: a - w*b, DIF: w*(a-b)

endmodule