
% --- LEVEL 4.1&2 ------------------------
x = audioread("wewereawaymax.wav");
x = resample(x, 16000, 48000);

% Converting the audio to mono if stereo
if size(x, 2) > 1
    x = x(:, 1);
end
x = x / max(abs(x));        % Normalize amplitude to [-1, 1]

frame_length = 320;         % 20 ms at 16 kHz
num_frames = floor(length(x)/frame_length);
t = (0:length(x)-1) / fs;

figure;
subplot 411
plot(t(6401:7680), x(6401:7680));               % Frame 20-23
title("Waveform of Recorded Speech");           % 6400/320 = 20
xlim([0.40 0.46]);
grid on;

% Plotting lines every 20ms
for i = 1:num_frames
    xline((i-1)*0.02, 'k--', 'LineWidth', 1.5);
end

frame1 = x(6401:6720);          % first frame
frame2 = x(6721:7040);          % second frame

subplot 412
t1 = (6401:6720)/fs;
plot(t1, frame1);
xlabel("Time (s)");
ylabel("Amplitude");
title("20 ms Speech Frame");
grid on;

subplot 413
t2 = (6721:7040)/fs;
plot(t2, frame2);
xlabel("Time (s)");
ylabel("Amplitude");
title("20 ms Speech Frame");
grid on;

% Here, the calculated fundamental frequency is 110.3753Hz by subtracting
% the peaks and calculating period.


% Passing through LPC
j = lpc(x, 12);
est_speech = filter([0 -i(2:end)], 1, x);
j = x - est_speech;

% Computing for one 20ms frame
excitation_frame =j(3521:3840);                     % Frame 11      
[~, ~, v_m_output] = ...
        auditoryProcessor(excitation_frame, b, a, k, c0);
filtered_energies = sum(v_m_output, 2);

% There are 51 frames
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

subplot 414
bar(F0_estimated);
title("Fundamental Frequencies for Each Frame");
xlim([1 51]);
ylim([0 320]);
ylabel("Freq (Hz)");
xlabel("Frames")

figure;
% Original Signal
subplot 211
plot(t, x);
xlim([0 1]);

% One 20ms frame
subplot 212
bar(filtered_energies(1:30));