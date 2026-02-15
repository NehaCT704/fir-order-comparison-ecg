module fir_16th_tb;

  localparam integer FILTER_TAPS = 17; // 16th order → 17 taps

  reg clk;
  reg reset;
  reg signed [15:0] data_in;
  wire signed [15:0] filtered_output;

  integer infile, outfile;
  integer r;
  integer temp;
  integer in_count;
  integer out_count;
  integer i=0;

  // DUT
  fir_filter uut (
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

    infile = $fopen("C:/Users/nihala c t/Desktop/MINI PROJ/project_4/project_4.srcs/sources_1/new/input_sampless.hex", "r");
    if (infile == 0) begin
      $display(" ERROR: Cannot open input_samples.hex");
      $finish;
    end

    outfile = $fopen("C:/Users/nihala c t/Desktop/MINI PROJ/project_5/filtered_outputt16.hex", "w");
    if (outfile == 0) begin
      $display("ERROR: Cannot open filtered_output.hex");
      $fclose(infile);
      $finish;
    end

    data_in = 16'sd0;
    @(negedge reset);
    #20;

    $display(" Starting to read input file and run filter...");

    while (!$feof(infile)) begin
      r = $fscanf(infile, " %h", temp);
      if (r == 1) begin
        data_in = temp[15:0];
        in_count = in_count + 1;

        @(posedge clk);
        @(posedge clk);

        $fdisplay(outfile, "%h", filtered_output);
        out_count = out_count + 1;

        $display("Time=%0t | Input=%h | Filtered=%h", $time, data_in, filtered_output);
      end
    end

    // Flush pipeline
    for (i = 0; i < (FILTER_TAPS - 1); i = i + 1) begin
      @(posedge clk);
      $fdisplay(outfile, "%h", filtered_output);
      out_count = out_count + 1;
    end

    $fclose(infile);
    $fclose(outfile);

    $display(" Done. Input samples read  = %0d", in_count);
    $display(" Done. Output samples written = %0d", out_count);
    $display(" Filtered output saved to file.");

    #100;
    $finish;
  end

endmodule
