// [relu.v] ReLU activation module

module relu #(parameter WIDTH=8) (
    input   signed [WIDTH-1:0] in,   // Input value
    output  signed [WIDTH-1:0] out   // Output after ReLU
);

    reg signed [WIDTH-1:0] relu_out;

    always @* begin
        if (in > 0)
            relu_out = in;
        else
            relu_out = 0;
    end

    assign out = relu_out;

endmodule