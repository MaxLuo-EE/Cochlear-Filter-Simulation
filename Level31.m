
% --- LEVEL 3.1 ------------------------
input_length = 1024;
impulse = [1 zeros(1,input_length-1)];
s = zeros(128, input_length);
t = (0:length(x)-1)/fs;

% Calculate Gain Factors
for i = 1:128
    sine_wave = sin(2*pi*fp(i)*t);
    filter_output = filter(b, a(i,:), sine_wave);
    k(i) = 1 / max(abs(filter_output));
end

% Calculating Impulse Response
for i = 1:128
    s(i,:) = k(i)*impz(b, a(i,:), input_length);
end

% Calculating impulse response of filter bank
[d, e, ~] = auditoryProcessor(impulse, b, a, k, c0);



% --- Plotting ------------------------
freq = ((0:input_length/2)*fs/input_length);

s_freq = fft(s(84,:), input_length);
s_dB = 20*log10(abs(s_freq(1:input_length/2+1)));
s_dB = s_dB - max(s_dB);

d_freq = fft(d(84,:), input_length);
d_dB = 20*log10(abs(d_freq(1:input_length/2+1)));
d_dB = d_dB - max(d_dB);

e_freq = fft(e(84,:), input_length);
e_dB = 20*log10(abs(e_freq(1:input_length/2+1)));
e_dB = e_dB - max(e_dB);

figure;
hold on
% --- s (no dif) BLUE SOLID
plot(freq, s_dB, 'b-', 'LineWidth', 1);
[~, max_s] = max(s_dB);
xline(freq(max_s), 'b:');

% --- d (1 dif) RED DASHED
plot(freq, d_dB, 'r--', 'LineWidth', 1);
[~, max_d] = max(d_dB);
xline(freq(max_d), 'r:');

% --- e (2 dif) MAGENTA DASH-DOT
plot(freq, e_dB, 'm-.', 'LineWidth', 1);
[~, max_e] = max(e_dB);
xline(freq(max_e), 'm:');

xlabel("Frequency (Hz)");
ylabel("Magnitude (dB)");
ylim([-40 0]);
xlim([1100 2500]);

grid on
hold off



% --- LEVEL 3.2 ------------------------
% Generating 1024 samples of compound sine (discrete)
f1 = fp(60);
f2 = fp(100);
sinu = zeros(1, input_length);

for i = 1:input_length
    sinu(i) = sin(2*pi*f1*i/fs) + sin(2*pi*f2*i/fs);
end

[d, e, v_m] = auditoryProcessor(sinu, b, a, k, c0);

excitation_filtered = zeros(128, length(sinu));
for i = 1:128
    excitation_filtered(i,:) = k(i) * filter(b, a(i,:), sinu); 
end

figure;
subplot 411
plot(1:128, excitation_filtered(:, 900));
xlim([0 125]);
title('Before Spatial D');

subplot 412
plot(1:127, d(:, 900));
xlim([0 125]);
title('One Spatial D (d)');

subplot 413
plot(1:126, e(:, 900));
xlim([0 125]);
title('Two Spatial D (e)');

subplot 414
plot(1:126, v_m(:,900));
xlim([0 125]);
title('Energy (v_m)');



% --- LEVEL 3.3 ------------------------
% Second inner hair cell
T_frame = 0.016;
n_frame = 256;
[num_filters, num_samples] = size(e);

% Step 1: Accumulate for 16 ms and reset
num_frames = floor(num_samples / n_frame);          % 1024/256 = 4
t_frames = (0:num_frames-1)*T_frame;
p = zeros(num_filters, num_frames);

for i = 1:num_frames
    idx_start = (i-1)*n_frame + 1;                  % 1-256, 257-516
    idx_end   = i*n_frame;                          % 1024
    p(:, i) = sum(e(:, idx_start:idx_end), 2);      % accumulate positives
end

% Step 2: Post-filtering
q = zeros(size(p));           % IHC output per frame

for i = 2:num_frames
    q(:, i) = (1 - c0)*p(:, i) + c0*q(:, i-1);
end



% --- LEVEL 3.4 ------------------------
% Final Implementation
% Create a string of 1024 columns
sine_final = zeros(1, input_length);

% Define t in seconds
t  = (0:input_length - 1)/fs;

% 6 frequency input
freqs = [fp(20) fp(40) fp(60) fp(80) fp(100) fp(120)];                       
for i = 1:6
    sine_final = sine_final + sin(2*pi*freqs(i)*t);
end

[d_final, e_m_final, v_m_final] = ...
    auditoryProcessor(sine_final, b, a, k, c0);

% Plotting
figure;
subplot 311
plot(1:126, 20*log10(v_m_final(:,900)));
title('Filter Bank Output');
ylabel('Energy (dB)');
xlim([0 125]);

subplot 312
sine_freq = fft(sine_final(1, :), input_length);
sine_dB = abs(sine_freq(1:input_length/2+1));
plot(freq, sine_dB);
title('Magnitude Plot Input');
ylabel('Amplitude');


% --- Level 3 Questions ---
% Since the output is a envelope signal, the frequency of the envelope is
% much lower (similar to modulation envelope). The hair cell model works by
% considering the energy in each envelope, and thus we can have a lower 
% sampling rate. 
% 
% If the sampling frequency at the output is doubled, then
% the LPF cutoff can also be increased, because the higher sampling 
% frequency allows for more frequencies to be included in the baseband
% without aliasing, allowing for more detail to be captured

% Mapping voice
x = audioread("voice.wav");

% Converting the audio to mono if stereo
if size(x, 2) > 1
    x = x(:, 1);
end

x = x / max(abs(x));        % Normalize amplitude to [-1, 1]
[~, ~, v_m] = auditoryProcessor(x, b, a, k, c0);

subplot 313
plot(1:126, v_m(:,15000));
title('Voice Implementation');
ylabel('Energy');
xlim([1 125]);