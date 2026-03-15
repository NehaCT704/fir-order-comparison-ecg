%% MATLAB Script to Compare Input and Output of FIR Filters (4, 8, 16, 32 Order)

%% --- Configuration ---
filter_orders  = [4, 8, 16, 32];
input_files    = {'input_samples.hex', 'input_sampless.hex', 'input_sampless.hex', 'input_sampless.hex'};
output_files   = {'filtered_output1.hex', 'filtered_output8.hex', 'filtered_outputt16.hex', 'filtered_output_32.hex'};
zoom_range_max = 500;

%% --- Main Loop ---
for i = 1:length(filter_orders)

    order       = filter_orders(i);
    input_data  = read_hex_file(input_files{i});
    output_data = read_hex_file(output_files{i});
    num_samples = min(length(input_data), length(output_data));
    zoom_range  = min(zoom_range_max, num_samples);

    % --- Plot 1: Full Signal Comparison ---
    figure('Name', sprintf('%dth Order FIR - Full Signal', order));

    subplot(2,1,1);
    plot(input_data(1:num_samples), 'b');
    xlabel('Sample Index');
    ylabel('Amplitude');
    title(sprintf('%dth Order FIR — Input Signal (%d Samples)', order, num_samples));
    grid on;

    subplot(2,1,2);
    plot(output_data(1:num_samples), 'r');
    xlabel('Sample Index');
    ylabel('Amplitude');
    title(sprintf('%dth Order FIR — Filtered Output', order));
    grid on;

    sgtitle(sprintf('%dth Order FIR Filter: Full Signal Comparison', order));

    % --- Plot 2: Zoomed-In View ---
    figure('Name', sprintf('%dth Order FIR - Zoomed', order));

    subplot(2,1,1);
    plot(input_data(1:zoom_range), 'b');
    xlabel('Sample Index');
    ylabel('Amplitude');
    title(sprintf('%dth Order FIR — Input Signal (First %d Samples)', order, zoom_range));
    grid on;

    subplot(2,1,2);
    plot(output_data(1:zoom_range), 'r');
    xlabel('Sample Index');
    ylabel('Amplitude');
    title(sprintf('%dth Order FIR — Filtered Output (Zoomed)', order));
    grid on;

    sgtitle(sprintf('%dth Order FIR Filter: Zoomed-In View', order));

end

%% --- Function to Read HEX File ---
function data = read_hex_file(file_path)
    fid = fopen(file_path, 'r');
    if fid == -1
        error('Cannot open file: %s', file_path);
    end
    data = [];
    while ~feof(fid)
        line = strtrim(fgetl(fid));
        if ~isempty(line)
            value = hex2dec(line);
            if value >= 2^15       % Convert to signed 16-bit
                value = value - 2^16;
            end
            data = [data; value];
        end
    end
    fclose(fid);
end
