module fir_4th (
    input clk,
    input reset,
    input signed [15:0] data_in,
    output reg signed [15:0] filtered_output
);

    // 5-tap symmetric FIR coefficients (Q15 scaled)
    // Corresponding to [0, 0.25, 0.5, 0.25, 0]
    parameter signed [15:0] h0 = 16'sd1153;
    parameter signed [15:0] h1 = 16'sd7925;
    parameter signed [15:0] h2 = 16'sd14758;
    parameter signed [15:0] h3 = 16'sd7925;
    parameter signed [15:0] h4 = 16'sd1153;

    
    // Shift registers for input samples
    reg signed [15:0] x0, x1, x2, x3, x4;

    // 32-bit accumulator to hold multiply-accumulate result
    reg signed [31:0] acc;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x0 <= 0; x1 <= 0; x2 <= 0; x3 <= 0; x4 <= 0;
            acc <= 0;
            filtered_output <= 0;
        end else begin
            // Shift input samples
            x4 <= x3;
            x3 <= x2;
            x2 <= x1;
            x1 <= x0;
            x0 <= data_in;

            // Multiply-accumulate operation
            acc <= (h0 * x0) + (h1 * x1) + (h2 * x2) + (h3 * x3) + (h4 * x4);

            // Correct Q15 scaling: divide by 2^15
            // Optional rounding added for better accuracy
            filtered_output <= (acc + (1 <<< 14)) >>> 15;
        end
    end
endmodule


