module fir_8th_tb;

  localparam integer FILTER_TAPS = 9;  // 8th order → 9 taps

  reg clk;
  reg reset;
  reg signed [15:0] data_in;
  wire signed [15:0] filtered_output;

  integer infile, outfile;
  integer r;
  integer temp;
  integer in_count;
  integer out_count;
  integer i = 0;

  // DUT Instance
  fir_8th uut (
      .clk(clk),
      .reset(reset),
      .data_in(data_in),
      .filtered_output(filtered_output)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Reset
  initial begin
    reset = 1;
    #20;
    reset = 0;
  end

  // Main stimulus
  initial begin
    in_count  = 0;
    out_count = 0;
#10;
data_in = 16'h1234;
@(posedge clk);
@(posedge clk);
$display("FILTER TEST = %h", filtered_output);

    // FIXED FILE PATH (Vivado requires \\ on Windows)
    infile = $fopen("C:/Users/nihala c t/Desktop/MINI PROJ/project_6_8th_order/project_6_8th_order.srcs/sources_1/new/input_sampless.hex", "r");
    $display("DEBUG: infile handle = %0d", infile);

    //infile = $fopen("C:/Users/\"nihala c t\"/Desktop/project_6_8th_order/project_6.srcs/sources_1/new/input_sampless.hex", "r");

    if (infile == 0) begin
      $display("ERROR: Cannot open input_sampless.hex");
      $finish;
    end
    outfile = $fopen("C:/Users/nihala c t/Desktop/MINI PROJ/project_6_8th_order/filtered_output8.hex", "w");

    //outfile = $fopen("C:\\Users\\nihala c t\\Desktop\\project_6_8th_order\\filtered_output8.hex", "w");
    if (outfile == 0) begin
      $display("ERROR: Cannot open filtered_output8.hex");
      $fclose(infile);
      $finish;
    end

    data_in = 16'sd0;

    // DO NOT USE @(negedge reset) - causes deadlock
    // Wait few stable clock cycles instead
    @(posedge clk);
    @(posedge clk);

    #10;
    $display("Starting to read input file and run 8th-order FIR...");

    // Read + feed samples
    while (!$feof(infile)) begin

      r = $fscanf(infile, "%h", temp);

      if (r == 1) begin
        data_in = temp[15:0];
        in_count = in_count + 1;

        @(posedge clk);
        @(posedge clk);  // allow FIR to compute

        $fdisplay(outfile, "%h", filtered_output);
        out_count = out_count + 1;

        $display("Time=%0t | Input=%h | Filtered=%h",
                 $time, data_in, filtered_output);
      end
    end

    // Flush pipeline (8th order → 9 taps → 8 extra outputs)
    for (i = 0; i < (FILTER_TAPS - 1); i = i + 1) begin
      @(posedge clk);
      $fdisplay(outfile, "%h", filtered_output);
      out_count = out_count + 1;
    end

    $fclose(infile);
    $fclose(outfile);

    $display("====================================");
    $display("  ✔ Done.");
    $display("  ✔ Input samples read     = %0d", in_count);
    $display("  ✔ Output samples written = %0d", out_count);
    $display("  ✔ Output saved to file.");
    $display("====================================");

    #50;
    $finish;
  end

endmodule
