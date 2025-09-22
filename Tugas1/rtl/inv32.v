// [inv32.v] 32-bit 2-input INV.

module inv32 (
    input  wire [31:0] a,
    output wire [31:0] y
);
    assign y = ~a;
endmodule