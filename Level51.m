
% --- LEVEL 5.1 ------
duration = 1;                           % 1 second test tone
t = (0:1/fs:duration-1/fs);
freq = 620;

x = sin(2*pi*freq*t);   % pure sine wave
L = length(x);

[~, en, ~] = ...
    auditoryProcessor(x, b, a, k, c0);



% --- E calculations --- 
% Initialistion of Variables
frame_len = 80;                         % 5ms
SPL_min = 10;
SPL_max = 70;

A_min = 10^((SPL_min-96)/20);
A_max = 10^((SPL_max-96)/20);

Emin = zeros(128,1);
Emax = zeros(128,1);

for i = 1:128
    f0 = fp(i);
    t_local = (0:frame_len-1)/fs;

    sine_min = A_min * sin(2*pi*f0*t_local);
    sine_max = A_max * sin(2*pi*f0*t_local);

    % pass through first filter
    y_min = filter(b, a(i, :), sine_min);
    y_max = filter(b, a(i, :), sine_max);

    % spatial diffs (1 then 2)
    d1_min = y_min - [y_min(2:end), 0];             % concatenating 0
    d1_max = y_max - [y_max(2:end), 0];

    d2_min = d1_min - [d1_min(2:end), 0];
    d2_max = d1_max - [d1_max(2:end), 0];

    Emin(i) = mean(abs(d2_min));
    Emax(i) = mean(abs(d2_max));
end


% --- Adaptive Filter --- 
[N_bands_proc, T] = size(en);
num_frames = floor(T / frame_len);
c_adapted = zeros(N_bands_proc, T); 
Q_hist = zeros(N_bands_proc, num_frames); % store Q for plotting

for i = 1:N_bands_proc
    band_signal = en(i,:); 
    band_output = zeros(1, T); 
    filter_state = [0;0]; 
    
    for j = 1:num_frames
        idx1 = (j-1)*frame_len + 1;
        idx2 = j*frame_len;
        frame = band_signal(idx1:idx2);
        
        E_frame = mean(abs(frame));
       
        alpha = (E_frame - Emin(i)) / (Emax(i) - Emin(i));
        alpha = min(max(alpha,0),1);   
        Q_adaptive = QH(i) + alpha*(QL(i) - QH(i));

        Q_hist(i,j) = Q_adaptive;
        
        % Recalculating coefficients for Adaptive Filter
        f_center = fp(i);
        BW_adaptive = f_center / Q_adaptive;
        r  = 1 - (BW_adaptive/fs)*pi;
        th = 2*pi*f_center/fs;
        
        A_den = [1, -2*r*cos(th), r^2];
        ej = exp(-1j*th);
        H_at_peak = 1 ./ (1 - 2*r*cos(th)*ej + (r^2)*(ej.^2));
        A_num = 1 / abs(H_at_peak);
        
        [y_frame, filter_state] = filter(A_num, A_den, ...
            frame, filter_state);
        
        % Storing in band_output
        band_output(idx1:idx2) = y_frame;
    end
    c_adapted(i,:) = band_output;           % 126 by 16000 <- length(x)
end

% Rectification (Half Wave)
c_rect = max(c_adapted, 0);

% Initialising Variables
vn = zeros(size(c_rect));
N_proc_bands = size(c_adapted, 1); 

% This is similar to the auditoryProcessor function
for i = 1:N_proc_bands
    vn(i,1) = (1-co)*c_rect(i,1);
    for n = 2:T
        vn(i,n) = (1-co)*c_rect(i,n) + co*vn(i,n-1);
    end
end


% --- Calculating SPL ---
[~, idx1k] = min(abs(fp - 1026));   % pick ~1.026 kHz filter

% INPUT: x_voice (speech waveform), fs = 16000

SPL = zeros(1, num_frames);

for i = 1:num_frames
    idx1 = (i-1)*frame_len + 1;
    idx2 = i*frame_len;

    frame = x_voice(idx1:idx2);

    A = max(abs(frame));
    A = max(A, 1e-12);

    SPL(i) = 96 + 20*log10(A);
end

% Creating time axis
t_axis = (frame_len/fs)*((1:num_frames)-0.5);

figure;
IHC1 = mean(abs(vn), 2);    % 128×1 vector
IHC2  = mean(abs(en), 2);    % 128×1 vector (what you already had)

plot(1:N, IHC1, 'b', 'LineWidth', 1.5); hold on;
plot(1:N, IHC2,  'r', 'LineWidth', 1.5);

% --- Calculating Pseudo-Spectrograms ---
% Load speech and resample
[x_voice, fs_voice] = audioread('speech.wav');
x_voice = resample(x_voice, fs, fs_voice);
x = x_voice; % Use x for the main signal variable
L = length(x);
T = L;

% Passing through filter bank
[~, en, ~] = auditoryProcessor(x, b, a, k, c0);
[N_bands_proc, ~] = size(en);
num_frames = floor(L / frame_len);
freq_hz = fp(1:N_bands_proc) / 1000; % Center Frequencies in kHz (for plotting)

% --- Adaptive Filter (A_m(z)) ---
c_adapted = zeros(N_bands_proc, T); 
filter_states_adaptive = zeros(N_bands_proc, 2); 

for m = 1:N_bands_proc
    band_signal = en(m,:); 
    band_output = zeros(1, T); 
    
    for j = 1:num_frames
        idx1 = (j-1)*frame_len + 1;
        idx2 = j*frame_len;
        frame = band_signal(idx1:idx2);
        
        E_frame = mean(abs(frame));

        if Emax(m) == Emin(m)
            Q_adaptive = QL(m);                 
        else
            alpha = (E_frame - Emin(m)) / (Emax(m) - Emin(m));
            alpha = min(max(alpha,0),1);   
            Q_adaptive = QH(m) + alpha*(QL(m) - QH(m));
        end
        
        % Recompute Filter 
        f_center = fp(m);
        BW = f_center / Q_adaptive;
        r  = 1 - (BW/fs)*pi;
        th = 2*pi*f_center/fs;
        A_den = [1, -2*r*cos(th), r^2];
        ej = exp(-1j*th);
        H_at_peak = 1 ./ (1 - 2*r*cos(th)*ej + (r^2)*(ej.^2));
        A_num = 1 / abs(H_at_peak); 
        
        % Apply Adaptive Filter
        [y_frame, filter_states_adaptive(m, :)] = filter(A_num, A_den, ...
            frame, filter_states_adaptive(m, :));
        band_output(idx1:idx2) = y_frame;
    end
    c_adapted(m,:) = band_output;
end

% --- IHC Model for Adaptive-Q ---
c_rect_adaptive = max(c_adapted, 0);
fc = 30; 
co = exp(-2*pi*fc/fs); 
vn_adaptive = zeros(size(c_rect_adaptive));

for m = 1:N_bands_proc
    vn_adaptive(m,1) = (1-co)*c_rect_adaptive(m,1);
    for n = 2:T
        vn_adaptive(m,n) = (1-co)*c_rect_adaptive(m,n) +...
            co*vn_adaptive(m,n-1);
    end
end

%
% --- Fixed Low-Q Filter ---
c_passive = zeros(N_bands_proc, T); 
filter_states_passive = zeros(N_bands_proc, 2); 

% Same as above
for m = 1:N_bands_proc
    band_signal = en(m,:); 
    band_output = zeros(1, T); 
    
    % Use the fixed low Q (QL) for the entire duration
    Q_fixed = QL(m);
    
    % Recompute Filter (A_m(z) fixed
    f_center = fp(m);
    BW = f_center / Q_fixed;
    r  = 1 - (BW/fs)*pi;
    th = 2*pi*f_center/fs;
    A_den = [1, -2*r*cos(th), r^2];
    ej = exp(-1j*th);
    H_at_peak = 1 ./ (1 - 2*r*cos(th)*ej + (r^2)*(ej.^2));
    A_num = 1 / abs(H_at_peak); 
    
    % Apply Fixed Filter
    [y_all, filter_states_passive(m, :)] = filter(A_num, A_den, band_signal, filter_states_passive(m, :));
    c_passive(m,:) = y_all;
end

% --- IHC Model for Passive-Q ---
c_rect_passive = max(c_passive, 0);
vn_passive = zeros(size(c_rect_passive));

for m = 1:N_bands_proc
    vn_passive(m,1) = (1-co)*c_rect_passive(m,1);
    for n = 2:T
        vn_passive(m,n) = (1-co)*c_rect_passive(m,n) + co*vn_passive(m,n-1);
    end
end

% --- Plotting --- 
% Calculate the energy of the IHC output (vn) per frame
frame_energy_passive = zeros(N_bands_proc, num_frames);
frame_energy_adaptive = zeros(N_bands_proc, num_frames);

for j = 1:num_frames
    idx1 = (j-1)*frame_len + 1;
    idx2 = j*frame_len;
    
    frame_energy_passive(:, j) = mean(vn_passive(:, idx1:idx2).^2, 2);
    frame_energy_adaptive(:, j) = mean(vn_adaptive(:, idx1:idx2).^2, 2);
end

% Selecting Relevant values
THRESHOLD = 5e-7; 

figure;
subplot 121
% Plotting the Passive Model
[freq_indices_P, frame_indices_P] = find(frame_energy_passive > ...
    THRESHOLD);
% freq -> kHz
freq_khz_P = freq_hz(freq_indices_P);
scatter(frame_indices_P, freq_khz_P, 10, 'filled'); % 10 is marker size
title('Low-Q (Passive) Model');
xlabel('Frame number');
ylabel('Frequency (kHz)');
ylim([0, 8]);
xlim([0, num_frames]);
set(gca, 'FontSize', 10);
set(gca, 'YTick', 0:1:8);

subplot 122
% Plotting the Adaptive Model
[freq_indices_A, frame_indices_A] = find(frame_energy_adaptive > ...
    THRESHOLD);
freq_khz_A = freq_hz(freq_indices_A);
scatter(frame_indices_A, freq_khz_A, 10, 'filled'); % 10 is marker size
title('Adaptive-Q Model');
xlabel('Frame number');
ylabel('Frequency (kHz)');
ylim([0, 8]);
xlim([0, num_frames]);
set(gca, 'FontSize', 10);
set(gca, 'YTick', 0:1:8);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. Parameters for the Q Control Test
f_test = 1026;         % Target frequency (1.026 kHz)
total_duration = 0.25; % Total time for the signal (250 ms)
t_test = (0:1/fs:total_duration-1/fs);
num_samples_test = length(t_test);

% Define the 5 SPL steps: 0, 25, 50, 75, 100 dB
spl_levels = [0, 25, 50, 75, 100];
num_steps = length(spl_levels);
step_duration = total_duration / num_steps; 

x_test = zeros(1, num_samples_test);
step_start_idx = 1;

% 2. Generate Stepped Input Signal
for step = 1:num_steps
    spl_db = spl_levels(step);
    % Amplitude (A) calculation: A = 10^((SPL-96)/20)
    amplitude = 10^((spl_db - 96) / 20);
    
    step_end_time = step * step_duration;
    step_end_idx = round(step_end_time * fs);
    
    % Safety check for the last step
    if step == num_steps
        step_end_idx = num_samples_test;
    end
    
    step_t = t_test(step_start_idx:step_end_idx);
    step_signal = amplitude * sin(2 * pi * f_test * step_t);
    
    x_test(step_start_idx:step_end_idx) = step_signal;
    step_start_idx = step_end_idx + 1;
end

% 3. Run Stepped Signal through the First Filter Bank
[~, en_test, ~] = auditoryProcessor(x_test, b, a, k, c0);
[N_bands_proc_test, T_test] = size(en_test);
num_frames_test = floor(T_test / frame_len);

% Find the index for the 1.026 kHz test frequency
[~, test_band_idx] = min(abs(fp - f_test));

% 4. Calculate Q History for the Test Band
Q_hist_test = zeros(1, num_frames_test);
E_min_m = Emin(test_band_idx);
E_max_m = Emax(test_band_idx);
band_signal = en_test(test_band_idx,:);

for j = 1:num_frames_test
    idx1 = (j-1)*frame_len + 1;
    idx2 = j*frame_len;
    frame = band_signal(idx1:idx2);
    
    E_frame = mean(abs(frame));
    
    if E_max_m == E_min_m
        Q_adaptive = QL(test_band_idx);
    else
        % Linear interpolation: Q_H (low E) to Q_L (high E)
        alpha = (E_frame - E_min_m) / (E_max_m - E_min_m);
        alpha = min(max(alpha,0),1);
        Q_adaptive = QH(test_band_idx) + alpha*(QL(test_band_idx) - QH(test_band_idx));
    end
    Q_hist_test(j) = Q_adaptive;
end

% --- Plotting the Results --- 
figure;
% Time vector for plotting Q_hist steps (aligned to start/end of frame)
frame_times = (1:num_frames_test) * frame_len / fs;

subplot 121
% Normalise
A_100dB = 10^((100 - 96) / 20); 
x_norm_to_100dB = x_test / A_100dB; 

% Plotting
plot(t_test, x_norm_to_100dB * 100, 'b', 'LineWidth', 1);
title(sprintf('Input signal\nFrequency=%.3f kHz', f_test/1000));
xlabel('Time (s)');
ylabel('Magnitude (dB SPL)');

% Set Y-axis to match the requested dB SPL steps
ylim([-100, 100]);
yticks([-100, -50, 0, 50, 100]); 
xlim([0, total_duration]);
grid on;

% --- Second Plot ---
subplot 122

% Use stairs to create the stepped plot appearance
stairs([0, frame_times], [Q_hist_test(1), Q_hist_test], 'b', 'LineWidth', 2);
title(sprintf('Q variation for %.3f kHz filter', fp(test_band_idx)/1000));
xlabel('Time (s)');
ylabel('Q factor');

% Set Y-axis to match the requested Q factor steps
ylim([3, 13]); 
yticks([3, 5, 7, 9, 11, 13]); % Ensures even steps (matching the slide)
xlim([0, total_duration]);
grid on;
