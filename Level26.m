% --- LEVEL 2.6: Subband Denoising using Gain Control (Corrected) ---

[x, fs] = audioread('noise10dB.wav');
x = x(:,1);   
frame_length = 320;         % 20 ms at 16 kHz
num_frames = floor(length(x)/frame_length);
mu = 0.5;
N_bands = 128;

frames = zeros(frame_length, num_frames);
for i = 1:num_frames
    idx_start = (i-1)*frame_length + 1;
    idx_end   = i*frame_length;
    frames(:,i) = x(idx_start:idx_end);
end

% Summing Noise for 10 frames
N_noise_frames = 10;
subband_noise_power = zeros(N_bands, 1);


for m = 1:N_bands 
    noise_energy_sum = 0;
    for i = 1:N_noise_frames
        subband_signal_frame = k(m) * filter(b, a(m,:), frames(:, i)); 
        
        noise_energy_sum = noise_energy_sum + mean(subband_signal_frame.^2);
    end
    % Average power over 10 frames
    subband_noise_power(m) = noise_energy_sum / N_noise_frames; 
end
sigma2_wm = subband_noise_power;

% Denoising
reconstructed_signal = zeros(length(x), 1);

for i = 1:num_frames
    current_frame = frames(:, i);
    
    subband_signals = zeros(N_bands, frame_length); 
    total_subband_power = zeros(N_bands, 1); 
    
    for m = 1:N_bands
        subband_signals(m, :) = k(m) * filter(b, a(m, :), current_frame);
        
        % Calculate total subband power (σ²sm)
        total_subband_power(m) = mean(subband_signals(m, :).^2);
    end
    
    sigma2_sm = total_subband_power; 
    
    % Clean Speech Power Estimation
    sigma2_ym = max(sigma2_sm - sigma2_wm, 0); 
    
    % Calculating gain
    adaptive_gain_Km = sigma2_ym ./ (sigma2_ym + mu * sigma2_wm);
    adaptive_gain_Km = min(max(adaptive_gain_Km, 0), 1);
    reconstructed_frame = zeros(frame_length, 1);
    
    % Synthesis (Summation)
    for m = 1:N_bands
        enhanced_subband = adaptive_gain_Km(m) * subband_signals(m, :)';
        reconstructed_frame = reconstructed_frame + enhanced_subband; 
    end
    
    % Reconstruction
    idx_start = (i-1)*frame_length + 1; 
    idx_end   = i*frame_length;
    reconstructed_signal(idx_start:idx_end) = reconstructed_frame;
end

% Normalise
reconstructed_signal = reconstructed_signal / ...
    max(abs(reconstructed_signal)) * max(abs(x));

% soundsc(x, fs);
soundsc(reconstructed_signal, fs);