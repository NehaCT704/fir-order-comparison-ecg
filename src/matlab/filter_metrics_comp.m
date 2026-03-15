%% ----------- File Names -----------
inputFile   = 'input_samples.hex';
out4File    = 'filtered_output1.hex';
out8File    = 'filtered_output8.hex';
out16File   = 'filtered_outputt16.hex';
out32File   = 'filtered_output_32.hex';

WORD_BITS = 16;
Q_FRAC = 15;
Fs = 360;

%% ----------- Read files -----------
raw_u  = readHexFileFlexible(inputFile);
o4_u   = readHexFileFlexible(out4File);
o8_u   = readHexFileFlexible(out8File);
o16_u  = readHexFileFlexible(out16File);
o32_u  = readHexFileFlexible(out32File);

raw  = double(hex_to_signed(raw_u,  WORD_BITS)) / 2^Q_FRAC;
y4   = double(hex_to_signed(o4_u,   WORD_BITS)) / 2^Q_FRAC;
y8   = double(hex_to_signed(o8_u,   WORD_BITS)) / 2^Q_FRAC;
y16  = double(hex_to_signed(o16_u,  WORD_BITS)) / 2^Q_FRAC;
y32  = double(hex_to_signed(o32_u,  WORD_BITS)) / 2^Q_FRAC;

% Match length
N = min([length(raw), length(y4), length(y8), length(y16), length(y32)]);
raw = raw(1:N); y4 = y4(1:N); y8 = y8(1:N); y16 = y16(1:N); y32 = y32(1:N);

%% ----------- Compute Metrics (input vs filtered) -----------
pairs = {
    '4th Order',  raw, y4
    '8th Order',  raw, y8
    '16th Order', raw, y16
    '32nd Order', raw, y32
};

results = [];

fprintf("\n Input vs Filtered Output Metrics\n");
fprintf("Filter        RMSE        MSE        PRD(%%)    Corr    SNR(dB)\n");
fprintf("------------------------------------------------------------------\n");

for k = 1:size(pairs,1)

    fname = pairs{k,1};
    x = pairs{k,2};
    y = pairs{k,3};

    [rmse, mse, prd, cc, snrdb] = compute_metrics(x, y);

    fprintf('%-12s  %8.6f  %8.6f  %8.2f   %7.4f   %7.3f\n', ...
        fname, rmse, mse, prd, cc, snrdb);

    results = [results; {fname, rmse, mse, prd, cc, snrdb}];

end

T = cell2table(results, ...
    'VariableNames', {'Filter','RMSE','MSE','PRD_percent','CorrCoeff','SNR_dB'});

writetable(T,'input_vs_filter_metrics.csv');
disp('Saved: input_vs_filter_metrics.csv');

%% ----------- PLOT 1: Input vs All Filter Outputs -----------
t = (0:N-1)/Fs;

figure;
plot(t, raw, 'k', 'LineWidth', 1.4); hold on;
plot(t, y4, 'LineWidth', 1.1);
plot(t, y8, 'LineWidth', 1.1);
plot(t, y16, 'LineWidth', 1.1);
plot(t, y32, 'LineWidth', 1.3);
grid on;
title('Input vs All FIR Filter Outputs');
xlabel('Time (s)'); ylabel('Amplitude');
legend('Input','4th','8th','16th','32nd');






%% ----------- Helper functions -----------

function nums = readHexFileFlexible(filename)
    txt = readlines(filename); arr=[];
    for i=1:numel(txt)
        s = strtrim(txt(i));
        if s==""; continue; end
        parts = split(s, {',',' ','\t'});
        for p = parts'
            tok = char(strtrim(p));
            if isempty(tok), continue; end
            if startsWith(tok,'0x','IgnoreCase',true), tok = tok(3:end); end
            tok = regexprep(tok,'[^0-9A-Fa-f]','');
            if isempty(tok), continue; end
            arr(end+1) = hex2dec(tok);
        end
    end
    nums = arr(:);
end

function s = hex_to_signed(vec,bits)
    MAX = 2^bits;
    HALF = 2^(bits-1);
    vec = double(vec);
    vec = mod(vec,MAX);
    s = vec;
    idx = vec >= HALF;
    s(idx) = s(idx) - MAX;
    s = int32(s);
end

function [rmse, mse, prd, cc, snrdb] = compute_metrics(x, y)
    e = x - y;
    mse   = mean(e.^2);
    rmse  = sqrt(mse);
    prd   = 100 * sqrt(sum(e.^2)/sum(x.^2));
    C = corrcoef(x,y); cc = C(1,2);
    snrdb = 10*log10(mean(x.^2)/mean(e.^2));
end
%% ----------- PLOT METRICS as Waveforms / Bar Graphs (robust) -----------
orders = [4 8 16 32];

% Helper to convert table column to numeric row vector robustly
toNumeric = @(col) ...
    ( isnumeric(col)             .* (col(:)') ) + ...
    ( iscell(col)                .* (cell2mat(col(:)') ) ) + ...
    ( isstring(col) | ischar(col) .* (str2double(cellstr(col(:)')) ) );

% Safer implementation (works with numeric column, cell of numeric, cell of strings, string arrays)
function v = tableColToVec(tbl, name)
    col = tbl.(name);
    if isnumeric(col)
        v = col(:)';                      % already numeric vector
    elseif iscell(col)
        % cell may contain numeric scalars or chars
        try
            v = cell2mat(col(:))';       % cell of numbers
        catch
            % convert each element to double (handles numeric string as well)
            v = zeros(1,numel(col));
            for ii = 1:numel(col)
                if isnumeric(col{ii})
                    v(ii) = double(col{ii});
                elseif isstring(col{ii}) || ischar(col{ii})
                    v(ii) = str2double(col{ii});
                else
                    error('Unsupported cell content type');
                end
            end
        end
    elseif isstring(col) || ischar(col)
        v = str2double(cellstr(col(:)))';
    else
        error('Unsupported table column type for %s', name);
    end
end

% Convert each metric column to numeric vectors
try
    RMSE_vals = tableColToVec(T, 'RMSE');
    MSE_vals  = tableColToVec(T, 'MSE');
    PRD_vals  = tableColToVec(T, 'PRD_percent');
    CC_vals   = tableColToVec(T, 'CorrCoeff');
    SNR_vals  = tableColToVec(T, 'SNR_dB');
catch ME
    warning('Failed converting table columns: %s\nAttempting fallback conversion...', ME.message);
    % fallback: try converting each row using cell2mat if possible
    RMSE_vals = double(cellfun(@(c) c, T.RMSE, 'UniformOutput', true));
    MSE_vals  = double(cellfun(@(c) c, T.MSE,  'UniformOutput', true));
    PRD_vals  = double(cellfun(@(c) c, T.PRD_percent, 'UniformOutput', true));
    CC_vals   = double(cellfun(@(c) c, T.CorrCoeff, 'UniformOutput', true));
    SNR_vals  = double(cellfun(@(c) c, T.SNR_dB, 'UniformOutput', true));
end

% Print types for quick debugging
fprintf('Data types: RMSE(%s), MSE(%s), PRD(%s), CC(%s), SNR(%s)\n', ...
    class(RMSE_vals), class(MSE_vals), class(PRD_vals), class(CC_vals), class(SNR_vals));



%% ----------- BAR PLOTS WITH CATEGORICAL AXIS (compact spacing) -----------

orderLabels = categorical({'4th','8th','16th','32nd'});
orderLabels = reordercats(orderLabels, {'4th','8th','16th','32nd'});

figure;
sgtitle('Filter Metrics Comparison ');

subplot(3,2,1);
bar(orderLabels, RMSE_vals);
title('RMSE'); ylabel('RMSE'); grid on;

subplot(3,2,2);
bar(orderLabels, MSE_vals);
title('MSE'); ylabel('MSE'); grid on;

subplot(3,2,3);
bar(orderLabels, PRD_vals);
title('PRD (%)'); ylabel('PRD (%)'); grid on;

subplot(3,2,4);
bar(orderLabels, CC_vals);
title('Correlation Coeff.'); ylabel('Correlation'); grid on;

subplot(3,2,5);
bar(orderLabels, SNR_vals);
title('SNR (dB)'); ylabel('SNR (dB)'); grid on;
