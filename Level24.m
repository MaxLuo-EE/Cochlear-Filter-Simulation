%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LEVEL 2.4&5
% Refining Initial Conditions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read Audio
[x, fs] = audioread("music.wav");
x = x(:,1);                                 % mono

p_combined = zeros(length(x) + 318, 128);
p_analysis  = zeros(length(x), 128);

figure;
for i = 1:10:128
    % impulse responses
    [h,~] = impz(b,   a(i,:), 160);
    [g,~] = impz(b_g, a_g(i,:), 160);

    y = conv(h, g);

    % filtering
    p_analysis(:,i) = filter(b, a(i,:), x);
    p_combined(:,i) = conv(x, y);

    % plotting
    [H, w] = freqz(b, a(i,:));
    [H_com, w] = freqz(b_g, a_g(i,:));
    
    subplot 212
    mag_H = 20*log10(abs(H_com));
    plot(w * fs / 2 / pi, mag_H - max(mag_H));
    xlim([0 8000]);
    ylim([-15 0]);
    title('Synthesis Filters');
    hold on;

    subplot 211
    mag_H = 20*log10(abs(H));
    plot(w * fs / 2 / pi, mag_H - max(mag_H));
    xlim([0 8000]);
    ylim([-15 0]);
    title('Analysis Filters');
    hold on;
end

% Summing all the filtered frequencies in p
x_combined = sum(p_combined, 2);
x_analysis = sum(p_analysis, 2);

rms_original = rms(x);

rms_combined = rms(x_combined);
x_combined = x_combined * (rms_original / rms_combined);

rms_analysis = rms(x_analysis);
x_analysis = x_analysis * (rms_original / rms_analysis);



% --- Plotting -------
[H, w] = freqz(b,a(100, :));
[G, wg] = freqz(b_g,a_g(100, :));
[h,~] = impz(b,   a(100,:), 160);
[g,~] = impz(b_g, a_g(100,:), 160);
y = conv(h, g);
figure;

subplot 221
[H_fir_trunc, ~] = freqz(h, 1, NFFT, fs); % Denominator is 1 for FIR
mag_H_fir_trunc = 20 * log10(abs(H_fir_trunc));
plot(w * fs / 2 / pi, mag_H_fir_trunc - max(mag_H_fir_trunc));
title('Magnitude Response of Analysis Filter')
xlim([0 8000]);
ylim([-50 0]);

subplot 222
plot(w * fs / 2 / pi, angle(H));
title('Phase Response of Analysis Filter');
xlabel('Frequency (Hz)');
ylabel('Phase (rad)');

subplot 223
[H_fir_trunc, ~] = freqz(y, 1, NFFT, fs); % Denominator is 1 for FIR
mag_H_fir_trunc = 20 * log10(abs(H_fir_trunc));
plot(w * fs / 2 / pi, mag_H_fir_trunc - max(mag_H_fir_trunc));
title('Magnitude Response of Combined Filters')
xlim([0 8000]);
ylim([-50 0]);

subplot 224
plot(w * fs / 2 / pi, unwrap(angle(H_fir_trunc)));
title('Phase Response of Combined Filters');
xlabel('Frequency (Hz)');
ylabel('Phase (rad)');
xlim([0 8000]);
ylim([-500 0]);


% --- Review ----------
% Playing Audio
% soundsc(x, fs);
% soundsc(x_combined, fs);
% soundsc(x_analysis, fs);

% --- Discussion for Step 3 --- 
% A noticeable sound quality difference is observed in step 3, mainly the
% audio is much more muffled compared to the original one. Some of the
% higher frequencies were also lost.

% Using 300 still produces a muffled output, however, noticeably 
% less frequencies in the higher range are lost in the process

% --- Discussion for Step 4 --- 
% During Step 4, when applying the combined filter onto our signal, a
% significant decrease in volume is observed. This is due to non idealities
% in the methods, and results in many frequencies being lost through the
% two filters. This loss may occur due to truncation of the filters,
% leading to attenuation in the output signal.

% Similarly, when increasing coefficients to 300, a slightly less
% attenuated signal is noticed, however both signals are heavily attenuated
% and is very poor quality.
%%%%%%%%%%%%%%%%%%%%%%%%%%%
