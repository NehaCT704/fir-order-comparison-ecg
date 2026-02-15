module fir_32nd (
    input clk,
    input reset,
    input signed [15:0] data_in,
    output reg signed [15:0] filtered_output
);

    // 33-tap FIR coefficients converted to Q15
    parameter signed [15:0] h0  = 16'sd2;
    parameter signed [15:0] h1  = 16'sd188;
    parameter signed [15:0] h2  = 16'sd187;
    parameter signed [15:0] h3  = 16'sd876;
    parameter signed [15:0] h4  = 16'sd1327;
    parameter signed [15:0] h5  = 16'sd2048;
    parameter signed [15:0] h6  = 16'sd2767;
    parameter signed [15:0] h7  = 16'sd3398;
    parameter signed [15:0] h8  = 16'sd3855;
    parameter signed [15:0] h9  = 16'sd4097;
    parameter signed [15:0] h10 = 16'sd3855;
    parameter signed [15:0] h11 = 16'sd3398;
    parameter signed [15:0] h12 = 16'sd2767;
    parameter signed [15:0] h13 = 16'sd2048;
    parameter signed [15:0] h14 = 16'sd1329;
    parameter signed [15:0] h15 = 16'sd702;
    parameter signed [15:0] h16 = 16'sd241;
    parameter signed [15:0] h17 = 16'sd2; // symmetric continuation
    parameter signed [15:0] h18 = 16'sd241;
    parameter signed [15:0] h19 = 16'sd702;
    parameter signed [15:0] h20 = 16'sd1329;
    parameter signed [15:0] h21 = 16'sd2048;
    parameter signed [15:0] h22 = 16'sd2767;
    parameter signed [15:0] h23 = 16'sd3398;
    parameter signed [15:0] h24 = 16'sd3855;
    parameter signed [15:0] h25 = 16'sd4097;
    parameter signed [15:0] h26 = 16'sd3855;
    parameter signed [15:0] h27 = 16'sd3398;
    parameter signed [15:0] h28 = 16'sd2767;
    parameter signed [15:0] h29 = 16'sd2048;
    parameter signed [15:0] h30 = 16'sd1329;
    parameter signed [15:0] h31 = 16'sd702;
    parameter signed [15:0] h32 = 16'sd2;

    // Shift registers
    reg signed [15:0] x[0:32];
    reg signed [31:0] acc;

    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 33; i = i + 1)
                x[i] <= 0;
            acc <= 0;
            filtered_output <= 0;
        end else begin
            // Shift input samples
            for (i = 32; i > 0; i = i - 1)
                x[i] <= x[i - 1];
            x[0] <= data_in;

            // Multiply-accumulate operation
            acc <= h0  * x[0]  + h1  * x[1]  + h2  * x[2]  + h3  * x[3] +
                   h4  * x[4]  + h5  * x[5]  + h6  * x[6]  + h7  * x[7] +
                   h8  * x[8]  + h9  * x[9]  + h10 * x[10] + h11 * x[11] +
                   h12 * x[12] + h13 * x[13] + h14 * x[14] + h15 * x[15] +
                   h16 * x[16] + h17 * x[17] + h18 * x[18] + h19 * x[19] +
                   h20 * x[20] + h21 * x[21] + h22 * x[22] + h23 * x[23] +
                   h24 * x[24] + h25 * x[25] + h26 * x[26] + h27 * x[27] +
                   h28 * x[28] + h29 * x[29] + h30 * x[30] + h31 * x[31] +
                   h32 * x[32];

            // Q15 scaling with rounding
            filtered_output <= (acc + (1 <<< 14)) >>> 15;
        end
    end
endmodule
