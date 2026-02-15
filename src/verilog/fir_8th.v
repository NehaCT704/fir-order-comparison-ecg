module fir_8th (
    input  wire clk,
    input  wire reset,
    input  wire signed [15:0] data_in,
    output reg  signed [15:0] filtered_output
);

    reg signed [15:0] x[0:8];   // 9-tap delay line

    // Coeffs (Q15)
    localparam signed [15:0] h0 = 16'sd1;
    localparam signed [15:0] h1 = 16'sd248;
    localparam signed [15:0] h2 = 16'sd2480;
    localparam signed [15:0] h3 = 16'sd7941;
    localparam signed [15:0] h4 = 16'sd11399;
    localparam signed [15:0] h5 = 16'sd7941;
    localparam signed [15:0] h6 = 16'sd2480;
    localparam signed [15:0] h7 = 16'sd248;
    localparam signed [15:0] h8 = 16'sd1;

    reg signed [31:0] acc;

    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 9; i = i + 1)
                x[i] <= 0;
            acc <= 0;
            filtered_output <= 0;

        end else begin
            // Shift input samples
            for (i = 8; i > 0; i = i - 1)
                x[i] <= x[i - 1];
            x[0] <= data_in;

            // Sequential MAC (same style as 16-tap version)
            acc <= (h0 * x[0]) + (h1 * x[1]) + (h2 * x[2]) +
                   (h3 * x[3]) + (h4 * x[4]) + (h5 * x[5]) +
                   (h6 * x[6]) + (h7 * x[7]) + (h8 * x[8]);

            // Q15 output
            filtered_output <= (acc + (1 << 14)) >>> 15;
        end
    end

endmodule
