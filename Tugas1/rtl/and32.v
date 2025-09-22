// [and32.v] 32-bit 2-input AND.

module and32 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] y
);
    assign y = a & b;
endmodule