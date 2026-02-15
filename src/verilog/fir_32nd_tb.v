module fir_32nd_tb;

  localparam integer FILTER_TAPS = 33;

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

  fir_32nd uut (
    .clk(clk),
    .reset(reset),
    .data_in(data_in),
    .filtered_output(filtered_output)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    reset = 1;
    #20;
    reset = 0;
  end

  initial begin
    in_count  = 0;
    out_count = 0;

    infile = $fopen("C:/Users/nihala c t/Desktop/MINI PROJ/project_7_32/project_7_32.srcs/sources_1/new/input_sampless.hex", "r");
    if (infile == 0) begin
      $display("ERROR: Cannot open input_samples.hex");
      $finish;
    end

    outfile = $fopen("C:/Users/nihala c t/Desktop/MINI PROJ/project_7_32/project_7_32.srcs/sources_1/new/filtered_output_32.hex", "w");
    if (outfile == 0) begin
      $display(" ERROR: Cannot open filtered_output_32.hex");
      $fclose(infile);
      $finish;
    end

    data_in = 16'sd0;
    @(negedge reset);
    #20;

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
