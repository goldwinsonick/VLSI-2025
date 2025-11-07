// l3_gan.v - Serial GAN using 1 neuron (with WAIT state after each neuron)
// FIXED: padding for neuron_x for N < 4 (pad MSB, not LSB)

module l3_gan (
    input               clk,
    input               rst,
    input               start,           // Start signal
    input  signed [15:0] x1,
    input  signed [15:0] x2,
    input  signed [15:0] x3,
    input  signed [15:0] x4,

    // All weights and biases for 18 neurons (L1-L8)
    input  signed [16*4*4-1:0] L1_w,     // 4 neurons, 4 inputs each
    input  signed [16*4-1:0]   L1_b,
    input  signed [16*2*4-1:0] L2_w,     // 2 neurons, 4 inputs each
    input  signed [16*2-1:0]   L2_b,
    input  signed [16*1*2-1:0] L3_w,     // 1 neuron, 2 inputs
    input  signed [16*1-1:0]   L3_b,
    input  signed [16*1*1-1:0] L4_w,     // 1 neuron, 1 input
    input  signed [16*1-1:0]   L4_b,
    input  signed [16*1*1-1:0] L5_w,     // 1 neuron, 1 input
    input  signed [16*1-1:0]   L5_b,
    input  signed [16*2*1-1:0] L6_w,     // 2 neurons, 1 input each
    input  signed [16*2-1:0]   L6_b,
    input  signed [16*4*2-1:0] L7_w,     // 4 neurons, 2 inputs each
    input  signed [16*4-1:0]   L7_b,
    input  signed [16*4*4-1:0] L8_w,     // 4 neurons, 4 inputs each
    input  signed [16*4-1:0]   L8_b,

    output reg signed [15:0] out1,
    output reg signed [15:0] out2,
    output reg signed [15:0] out3,
    output reg signed [15:0] out4,
    output reg               done        // High when all outputs valid
);

    // Intermediate signals for each neuron output
    reg signed [15:0] L1_1_out, L1_2_out, L1_3_out, L1_4_out;
    reg signed [15:0] L2_1_out, L2_2_out;
    reg signed [15:0] L3_1_out;
    reg signed [15:0] L4_1_out;
    reg signed [15:0] L5_1_out;
    reg signed [15:0] L6_1_out, L6_2_out;
    reg signed [15:0] L7_1_out, L7_2_out, L7_3_out, L7_4_out;
    reg signed [15:0] L8_1_out, L8_2_out, L8_3_out, L8_4_out;

    // FSM state
    reg [5:0] state;
    localparam S_IDLE=0,
               S_L1_1=1, S_W1_1=2, S_L1_2=3, S_W1_2=4, S_L1_3=5, S_W1_3=6, S_L1_4=7, S_W1_4=8,
               S_L2_1=9, S_W2_1=10, S_L2_2=11, S_W2_2=12,
               S_L3_1=13, S_W3_1=14,
               S_L4_1=15, S_W4_1=16,
               S_L5_1=17, S_W5_1=18,
               S_L6_1=19, S_W6_1=20, S_L6_2=21, S_W6_2=22,
               S_L7_1=23, S_W7_1=24, S_L7_2=25, S_W7_2=26, S_L7_3=27, S_W7_3=28, S_L7_4=29, S_W7_4=30,
               S_L8_1=31, S_W8_1=32, S_L8_2=33, S_W8_2=34, S_L8_3=35, S_W8_3=36, S_L8_4=37, S_W8_4=38,
               S_OUT=39, S_DONE=40;

    // Neuron input/output wires
    reg  signed [63:0] neuron_x; // max 4 inputs × 16 bits
    reg  signed [63:0] neuron_w;
    reg  signed [15:0] neuron_b;
    wire signed [15:0] neuron_y;

    // Instantiate single neuron (always N=4, pad x/w if needed)
    l3_neuron #(.N(4), .WIDTH(16)) neuron_inst (
        .x(neuron_x),
        .w(neuron_w),
        .b(neuron_b),
        .y(neuron_y)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= S_IDLE;
            done     <= 0;
            out1     <= 0;
            out2     <= 0;
            out3     <= 0;
            out4     <= 0;
            // Clear all intermediate outputs
            L1_1_out <= 0; L1_2_out <= 0; L1_3_out <= 0; L1_4_out <= 0;
            L2_1_out <= 0; L2_2_out <= 0;
            L3_1_out <= 0;
            L4_1_out <= 0;
            L5_1_out <= 0;
            L6_1_out <= 0; L6_2_out <= 0;
            L7_1_out <= 0; L7_2_out <= 0; L7_3_out <= 0; L7_4_out <= 0;
            L8_1_out <= 0; L8_2_out <= 0; L8_3_out <= 0; L8_4_out <= 0;
        end else begin
            case (state)
                S_IDLE: begin
                    done <= 0;
                    if (start) state <= S_L1_1;
                end

                // ---------------- L1_1: Neuron 1 of Layer 1 ----------------
                S_L1_1: begin
                    neuron_x <= {x4, x3, x2, x1};
                    neuron_w <= L1_w[0*64 +: 64];
                    neuron_b <= L1_b[0*16 +: 16];
                    state    <= S_W1_1;
                end
                S_W1_1: begin
                    L1_1_out <= neuron_y;
                    state    <= S_L1_2;
                end

                // ---------------- L1_2: Neuron 2 of Layer 1 ----------------
                S_L1_2: begin
                    neuron_x <= {x4, x3, x2, x1};
                    neuron_w <= L1_w[1*64 +: 64];
                    neuron_b <= L1_b[1*16 +: 16];
                    state    <= S_W1_2;
                end
                S_W1_2: begin
                    L1_2_out <= neuron_y;
                    state    <= S_L1_3;
                end

                // ---------------- L1_3: Neuron 3 of Layer 1 ----------------
                S_L1_3: begin
                    neuron_x <= {x4, x3, x2, x1};
                    neuron_w <= L1_w[2*64 +: 64];
                    neuron_b <= L1_b[2*16 +: 16];
                    state    <= S_W1_3;
                end
                S_W1_3: begin
                    L1_3_out <= neuron_y;
                    state    <= S_L1_4;
                end

                // ---------------- L1_4: Neuron 4 of Layer 1 ----------------
                S_L1_4: begin
                    neuron_x <= {x4, x3, x2, x1};
                    neuron_w <= L1_w[3*64 +: 64];
                    neuron_b <= L1_b[3*16 +: 16];
                    state    <= S_W1_4;
                end
                S_W1_4: begin
                    L1_4_out <= neuron_y;
                    state    <= S_L2_1;
                end

                // ---------------- L2_1: Neuron 1 of Layer 2 ----------------
                S_L2_1: begin
                    neuron_x <= {L1_4_out, L1_3_out, L1_2_out, L1_1_out};
                    neuron_w <= L2_w[0*64 +: 64];
                    neuron_b <= L2_b[0*16 +: 16];
                    state    <= S_W2_1;
                end
                S_W2_1: begin
                    L2_1_out <= neuron_y;
                    state    <= S_L2_2;
                end

                // ---------------- L2_2: Neuron 2 of Layer 2 ----------------
                S_L2_2: begin
                    neuron_x <= {L1_4_out, L1_3_out, L1_2_out, L1_1_out};
                    neuron_w <= L2_w[1*64 +: 64];
                    neuron_b <= L2_b[1*16 +: 16];
                    state    <= S_W2_2;
                end
                S_W2_2: begin
                    L2_2_out <= neuron_y;
                    state    <= S_L3_1;
                end

                // ---------------- L3_1: Neuron 1 of Layer 3 ----------------
                S_L3_1: begin
                    neuron_x <= {32'b0, L2_2_out, L2_1_out}; // FIXED: pad MSB
                    neuron_w <= L3_w;
                    neuron_b <= L3_b;
                    state    <= S_W3_1;
                end
                S_W3_1: begin
                    L3_1_out <= neuron_y;
                    state    <= S_L4_1;
                end

                // ---------------- L4_1: Neuron 1 of Layer 4 ----------------
                S_L4_1: begin
                    neuron_x <= {48'b0, L3_1_out}; // FIXED: pad MSB
                    neuron_w <= L4_w;
                    neuron_b <= L4_b;
                    state    <= S_W4_1;
                end
                S_W4_1: begin
                    L4_1_out <= neuron_y;
                    state    <= S_L5_1;
                end

                // ---------------- L5_1: Neuron 1 of Layer 5 ----------------
                S_L5_1: begin
                    neuron_x <= {48'b0, L4_1_out}; // FIXED: pad MSB
                    neuron_w <= L5_w;
                    neuron_b <= L5_b;
                    state    <= S_W5_1;
                end
                S_W5_1: begin
                    L5_1_out <= neuron_y;
                    state    <= S_L6_1;
                end

                // ---------------- L6_1: Neuron 1 of Layer 6 ----------------
                S_L6_1: begin
                    neuron_x <= {48'b0, L5_1_out}; // FIXED: pad MSB
                    neuron_w <= L6_w[0*16 +: 16];
                    neuron_b <= L6_b[0*16 +: 16];
                    state    <= S_W6_1;
                end
                S_W6_1: begin
                    L6_1_out <= neuron_y;
                    state    <= S_L6_2;
                end

                // ---------------- L6_2: Neuron 2 of Layer 6 ----------------
                S_L6_2: begin
                    neuron_x <= {48'b0, L5_1_out}; // FIXED: pad MSB
                    neuron_w <= L6_w[1*16 +: 16];
                    neuron_b <= L6_b[1*16 +: 16];
                    state    <= S_W6_2;
                end
                S_W6_2: begin
                    L6_2_out <= neuron_y;
                    state    <= S_L7_1;
                end

                // ---------------- L7_1: Neuron 1 of Layer 7 ----------------
                S_L7_1: begin
                    neuron_x <= {32'b0, L6_2_out, L6_1_out}; // FIXED: pad MSB
                    neuron_w <= L7_w[0*32 +: 32];
                    neuron_b <= L7_b[0*16 +: 16];
                    state    <= S_W7_1;
                end
                S_W7_1: begin
                    L7_1_out <= neuron_y;
                    state    <= S_L7_2;
                end

                // ---------------- L7_2: Neuron 2 of Layer 7 ----------------
                S_L7_2: begin
                    neuron_x <= {32'b0, L6_2_out, L6_1_out}; // FIXED: pad MSB
                    neuron_w <= L7_w[1*32 +: 32];
                    neuron_b <= L7_b[1*16 +: 16];
                    state    <= S_W7_2;
                end
                S_W7_2: begin
                    L7_2_out <= neuron_y;
                    state    <= S_L7_3;
                end

                // ---------------- L7_3: Neuron 3 of Layer 7 ----------------
                S_L7_3: begin
                    neuron_x <= {32'b0, L6_2_out, L6_1_out}; // FIXED: pad MSB
                    neuron_w <= L7_w[2*32 +: 32];
                    neuron_b <= L7_b[2*16 +: 16];
                    state    <= S_W7_3;
                end
                S_W7_3: begin
                    L7_3_out <= neuron_y;
                    state    <= S_L7_4;
                end

                // ---------------- L7_4: Neuron 4 of Layer 7 ----------------
                S_L7_4: begin
                    neuron_x <= {32'b0, L6_2_out, L6_1_out}; // FIXED: pad MSB
                    neuron_w <= L7_w[3*32 +: 32];
                    neuron_b <= L7_b[3*16 +: 16];
                    state    <= S_W7_4;
                end
                S_W7_4: begin
                    L7_4_out <= neuron_y;
                    state    <= S_L8_1;
                end

                // ---------------- L8_1: Neuron 1 of Layer 8 ----------------
                S_L8_1: begin
                    neuron_x <= {L7_4_out, L7_3_out, L7_2_out, L7_1_out};
                    neuron_w <= L8_w[0*64 +: 64];
                    neuron_b <= L8_b[0*16 +: 16];
                    state    <= S_W8_1;
                end
                S_W8_1: begin
                    L8_1_out <= neuron_y;
                    state    <= S_L8_2;
                end

                // ---------------- L8_2: Neuron 2 of Layer 8 ----------------
                S_L8_2: begin
                    neuron_x <= {L7_4_out, L7_3_out, L7_2_out, L7_1_out};
                    neuron_w <= L8_w[1*64 +: 64];
                    neuron_b <= L8_b[1*16 +: 16];
                    state    <= S_W8_2;
                end
                S_W8_2: begin
                    L8_2_out <= neuron_y;
                    state    <= S_L8_3;
                end

                // ---------------- L8_3: Neuron 3 of Layer 8 ----------------
                S_L8_3: begin
                    neuron_x <= {L7_4_out, L7_3_out, L7_2_out, L7_1_out};
                    neuron_w <= L8_w[2*64 +: 64];
                    neuron_b <= L8_b[2*16 +: 16];
                    state    <= S_W8_3;
                end
                S_W8_3: begin
                    L8_3_out <= neuron_y;
                    state    <= S_L8_4;
                end

                // ---------------- L8_4: Neuron 4 of Layer 8 ----------------
                S_L8_4: begin
                    neuron_x <= {L7_4_out, L7_3_out, L7_2_out, L7_1_out};
                    neuron_w <= L8_w[3*64 +: 64];
                    neuron_b <= L8_b[3*16 +: 16];
                    state    <= S_W8_4;
                end
                S_W8_4: begin
                    L8_4_out <= neuron_y;
                    state    <= S_OUT;
                end

                S_OUT: begin
                    out1 <= L8_1_out;
                    out2 <= L8_2_out;
                    out3 <= L8_3_out;
                    out4 <= L8_4_out;
                    done <= 1;
                    state <= S_DONE;
                end

                S_DONE: begin
                    done  <= 1;
                    if (!start)
                        state <= S_IDLE;
                end
            endcase
        end
    end

endmodule