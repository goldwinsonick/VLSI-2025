// [xor32.v] 32-bit 2-input XOR.

module xor32 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] y
);
    assign y = a ^ b;
endmodule