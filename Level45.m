
% --- LEVEL 4.5 ------------------------
% FINAL Implementation
% Defining Variables
f0 = fp(10);                                 % 110Hz
num_samples = 2000;
duration = num_samples / fs;                 % time = samples / (sample/time)
time = (0:num_samples-1) / fs; 
x_synthetic = zeros(1, num_samples);

% Generating x_synthetic
for i = 1:9
    frequency = i * f0; 
    amplitude = 1 / (2^(i-1)); 
    
    sinusoid = amplitude * sin(2 * pi * frequency * time);
    
    x_synthetic = x_synthetic + sinusoid;
end

% --- TASK 1 Repeat ------------------------
frame_length = 320;         % 20 ms at 16 kHz
num_frames = floor(length(x_synthetic)/frame_length);
t = (0:length(x_synthetic)-1) / fs;

figure;
subplot 311
plot(t, x_synthetic);
xlim([0 t(end)]);
title('Original Waveform');

subplot 312
plot(t(641:1600), x_synthetic(641:1600));       % Frame 3-5
title("Waveform of Synthetic Signal");          % 6400/320 = 20
xlim([0.04 0.1]);
grid on;

% Plotting lines every 20ms
for i = 1:num_frames
    xline((i-1)*0.02, 'k--', 'LineWidth', 1.5);
end

% Here we can determine fundamental frequency as 1/T = 109.5890Hz = fp(10)




% --- TASK 2 Repeat ------------------------
% LPC
j = lpc(x_synthetic, 12);
est_speech = filter([0 -i(2:end)], 1, x_synthetic);
j = x_synthetic - est_speech;

% num_frames = 6
F0_estimated = zeros(1, num_frames);

for i = 1:num_frames
    idx_start = (i-1)*frame_length + 1;             % 1-320, 321-640...
    idx_end   = i*frame_length;                     % 

    excitation_frame =j(idx_start:idx_end); 
    
    % Input to filter bank
    [~, ~, v_m_output] = ...
        auditoryProcessor(excitation_frame, b, a, k, c0);
    
    % Calculating fundamental frequency for each frame
    filter_energies = sum(v_m_output, 2);
    filter_energies = filter_energies(1:39);        % Restrict to 320Hz
    [~, F0_idx] = max(filter_energies);
    F0_estimated(i) = fp(F0_idx);
end

subplot 313
plot(F0_estimated);
title("Fundamental Frequencies for Each Frame");
xlim([1 6]);
ylim([0 320]);
ylabel("Freq (Hz)");
xlabel("Frames")



% --- TASK 3 Repeat ------------------------
% Spectrum for one 20ms frame
figure;
[~, ~, v_m] = auditoryProcessor(x_synthetic(641:960), b, a, k, c0);
filtered_energies = sum(v_m, 2);
subplot 221
bar(filtered_energies(1:39));
title('Before BP Filter (Frame 3)');
xlim([1 39]);

Wn = [320 7500] / (fs/2);
[b_bp, a_bp] = butter(10, Wn, 'bandpass');
xs_filtered = filter(b_bp, a_bp, x_synthetic);

[~, ~, v_m] = auditoryProcessor(xs_filtered(641:960), b, a, k, c0);
filtered_energies = sum(v_m, 2);
subplot 222
bar(filtered_energies(1:39));
title('After BP Filter (Frame 3)');
xlim([1 39]);

[~, ~, v_m] = auditoryProcessor(x_synthetic(961:1280), b, a, k, c0);
filtered_energies = sum(v_m, 2);
subplot 223
bar(filtered_energies(1:39));
title('Before BP Filter (Frame 4)');
xlim([1 39]);

xs_filtered = filter(b_bp, a_bp, x_synthetic);
[~, ~, v_m] = auditoryProcessor(xs_filtered(961:1280), b, a, k, c0);
filtered_energies = sum(v_m, 2);
subplot 224
bar(filtered_energies(1:39));
title('After BP Filter (Frame 4)');
xlim([1 39]);



% --- TASK 4 Repeat ------------------------
% Creating secondary bandpass coefficients
Wn = [60 400] / (fs/2);
[b_bp, a_bp] = butter(4, Wn, 'bandpass');

% Band Pass
qn = max(xs_filtered, 0);               % Half wave rect. (non-linear)
rn = filter(b_bp, a_bp, qn);            % We are redefining b_bp here

% Magnitude Spectrum of sn (A)
sn = x_synthetic;
mag_sn = fft(sn, 1024);
mag_sn = abs(mag_sn/length(sn));
sn_spectrum = mag_sn(1:1024/2 + 1);
sn_spectrum(2:end-1) = 2 * sn_spectrum(2:end-1);

% Magnitude Spectrum of pn (B)
pn = xs_filtered;
mag_pn = fft(pn, 1024);
mag_pn = abs(mag_pn/length(pn));
pn_spectrum = mag_pn(1:1024/2 + 1);
pn_spectrum(2:end-1) = 2 * pn_spectrum(2:end-1);

% Magnitude Spectrum of qn (C)
mag_qn = fft(qn, 1024);
mag_qn = abs(mag_qn/length(qn));
qn_spectrum = mag_qn(1:1024/2 + 1);
qn_spectrum(2:end-1) = 2 * qn_spectrum(2:end-1);

% Magnitude Spectrum of rn (D)
mag_rn = fft(rn, 1024);
mag_rn = abs(mag_rn/length(rn));
rn_spectrum = mag_rn(1:1024/2 + 1);
rn_spectrum(2:end-1) = 2 * rn_spectrum(2:end-1);

% Magnitude Spectrum of yn (E)
yn = rn + pn;
mag_yn = fft(yn, 1024);
mag_yn = abs(mag_yn/length(yn));
yn_spectrum = mag_yn(1:1024/2 + 1);
yn_spectrum(2:end-1) = 2 * yn_spectrum(2:end-1);


figure;
freq = fs*(0:(1024/2))/1024;

subplot 511
plot(freq, sn_spectrum);
title('s(n)     |      A');
ylabel('Magnitude');

subplot 512
plot(freq, pn_spectrum);
title('p(n)     |      B');
ylabel('Magnitude');

subplot 513
plot(freq, qn_spectrum);
title('q(n)     |      C');
ylabel('Magnitude');

subplot 514
plot(freq, rn_spectrum);
title('r(n)     |      D');
ylabel('Magnitude');

subplot 515
plot(freq, yn_spectrum);
title('y(n)     |      E');
ylabel('Magnitude');

% Passing through LPC
j = lpc(yn, 12);
est_speech = filter([0 -i(2:end)], 1, yn);
j = yn - est_speech;

% soundsc(x, fs);                     % Original Voice
% soundsc(x_filtered, fs);            % Filtered Voice

% You can see that the fundamental frequency has been recovered at 
% 109Hz peak