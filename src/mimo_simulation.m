clc;                    % Clear the command window
clear variables;        % Clear all variables from the workspace
close all;              % Close all figure windows

% === Initialization ===
% Seed the random number generator for reproducibility
rng(0);

% === System Parameters ===
% Number of random bits to transmit
ndata = 1000; 

% Modulation order (QAM)
mod_order = 4; 

% Generate random symbols (0 to mod_order-1) as input bits
input_bits = randi([0 mod_order-1], ndata, 1); 

% Modulate the input symbols using 4-QAM
modulated_data = qammod(input_bits, mod_order);

% Define an 8x8 MIMO channel matrix with random coefficients
% Channel coefficients are modeled as independent complex Gaussian variables
h = (randn(8, 8) + 1j * randn(8, 8)) / sqrt(2);

% Signal-to-Noise Ratio (SNR) values in dB for simulation
snr_values = 0:2:20; 

% Initialize arrays to store Bit Error Rates (BER) for each decoder
ber_mmse = zeros(length(snr_values), 1);
ber_zf = zeros(length(snr_values), 1);
ber_zf_sic = zeros(length(snr_values), 1);
ber_mld = zeros(length(snr_values), 1);

% Display a message indicating the start of the simulation
disp("Starting simulation of 8x8 MIMO system...");

% === Simulation Loop for Different SNR Values ===
for idx = 1:length(snr_values)
    % Current SNR value in dB
    snr = snr_values(idx);
    disp(['Processing SNR = ', num2str(snr), ' dB...']); % Log progress

    % Convert SNR from dB to linear scale and calculate noise power
    noise_power = 10^(-snr/10); 

    % Initialize error counters for each decoder
    error_count_mmse = 0;
    error_count_zf = 0;
    error_count_zf_sic = 0;
    error_count_mld = 0;

    % Process symbols in blocks of 8 for 8x8 MIMO
    for k = 1:(ndata / 8)
        % === Transmission of Symbols ===
        % Extract a block of 8 symbols from the modulated data
        transmitted_block = modulated_data(8*(k-1) + (1:8)); 

        % Add complex Gaussian noise to simulate channel impairment
        noise = sqrt(noise_power/2) * (randn(8, 1) + 1j * randn(8, 1)); 

        % Compute received symbols as the product of the channel matrix and transmitted symbols
        % with added noise
        received_symbols = h * transmitted_block + noise;

        % === MMSE Decoding ===
        % Compute the MMSE equalizer matrix
        h_mmse = h' * h + noise_power * eye(8); % Regularized channel matrix
        mmse_decoder = inv(h_mmse) * h';       % MMSE decoder matrix

        % Apply MMSE equalizer to received symbols
        estimated_symbols_mmse = mmse_decoder * received_symbols; 

        % Demodulate the estimated symbols to recover transmitted data
        decoded_symbols_mmse = qamdemod(estimated_symbols_mmse, mod_order);

        % === Zero-Forcing (ZF) Decoding ===
        % Compute the ZF equalizer (pseudo-inverse of the channel matrix)
        zf_decoder = pinv(h); 

        % Apply ZF equalizer to received symbols
        estimated_symbols_zf = zf_decoder * received_symbols; 

        % Demodulate the ZF-decoded symbols
        decoded_symbols_zf = qamdemod(estimated_symbols_zf, mod_order);

        % === ZF-SIC Decoding ===
        % Initialize variables for ZF-SIC
        estimated_symbols_zf_sic = zeros(8, 1);
        residual_signal = received_symbols;   % Residual signal to decode
        h_sic = h;                            % Copy channel matrix for SIC

        % Perform successive interference cancellation
        for i = 1:8
            % Compute pseudo-inverse for the remaining layers
            h_inv_sic = pinv(h_sic); 

            % Estimate the current layer
            temp_est = h_inv_sic * residual_signal; 

            % Demodulate the current symbol
            estimated_symbols_zf_sic(i) = qamdemod(temp_est(i), mod_order); 

            % Subtract the contribution of the decoded symbol from residual
            residual_signal = residual_signal - h_sic(:, i) * ...
                              qammod(estimated_symbols_zf_sic(i), mod_order);

            % Eliminate the used column from the channel matrix
            h_sic(:, i) = 0; 
        end

        % Assign the demodulated symbols to the final decoded array
        decoded_symbols_zf_sic = estimated_symbols_zf_sic;

        % === Maximum Likelihood Detection (MLD) ===
        % Generate all possible combinations of QAM symbols
        candidates = qammod(0:mod_order-1, mod_order); 
        best_distance = Inf; % Initialize the best distance metric
        best_candidate = zeros(8, 1); % Initialize the best candidate vector

        % Iterate over all possible combinations of transmitted symbols
        for candidate_idx = 1:mod_order^8
            % Generate a candidate symbol vector
            candidate_indices = mod(floor((candidate_idx-1) ./ (mod_order.^(0:7)')), mod_order) + 1;
            candidate_symbols = candidates(candidate_indices).'; 

            % Compute the Euclidean distance between received symbols and
            % candidate symbols
            distance = norm(received_symbols - h * candidate_symbols)^2;

            % Update the best candidate if the distance is smaller
            if distance < best_distance
                best_distance = distance;
                best_candidate = candidate_symbols;
            end
        end

        % Demodulate the MLD-decoded symbols
        decoded_symbols_mld = qamdemod(best_candidate, mod_order);

        % === Error Counting ===
        % Extract the indices of the transmitted symbols for comparison
        input_idx = 8*(k-1) + (1:8); 

        % Count the number of symbol errors for each decoder
        error_count_mmse = error_count_mmse + sum(decoded_symbols_mmse ~= input_bits(input_idx));
        error_count_zf = error_count_zf + sum(decoded_symbols_zf ~= input_bits(input_idx));
        error_count_zf_sic = error_count_zf_sic + sum(decoded_symbols_zf_sic ~= input_bits(input_idx));
        error_count_mld = error_count_mld + sum(decoded_symbols_mld ~= input_bits(input_idx));
    end

    % === Calculate BER ===
    ber_mmse(idx) = error_count_mmse / ndata;
    ber_zf(idx) = error_count_zf / ndata;
    ber_zf_sic(idx) = error_count_zf_sic / ndata;
    ber_mld(idx) = error_count_mld / ndata;

    % Log the results for the current SNR value
    fprintf('SNR: %d dB | BER (MMSE): %.5f | BER (ZF): %.5f | BER (ZF-SIC): %.5f | BER (MLD): %.5f\n', ...
            snr, ber_mmse(idx), ber_zf(idx), ber_zf_sic(idx), ber_mld(idx));
end

% === Plot Results ===
figure;
semilogy(snr_values, ber_mmse, '-o', 'LineWidth', 2);
hold on;
semilogy(snr_values, ber_zf, '-s', 'LineWidth', 2);
semilogy(snr_values, ber_zf_sic, '-^', 'LineWidth', 2);
semilogy(snr_values, ber_mld, '-x', 'LineWidth', 2);
grid on;
disp(snr_values);
disp(ber_mmse);
disp(ber_zf);
disp(ber_zf_sic);
disp(ber_mld);

title('Performance of 8x8 MIMO STBC with Various Decoders');
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
legend('MMSE', 'ZF', 'ZF-SIC', 'MLD');

disp("Simulation complete! Check the graph for results.");
