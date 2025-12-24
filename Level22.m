
% --- LEVEL 2.2 ------------------------
% Plotting for ---- Filter 45 -----
figure;
m = 45; 
[H, w] = freqz(b,a(m, :));
[h, t] = impz(b,a(m, :), 160);
L = 160;

subplot 221
[h_iir, t] = impz(b, a(45, :), 10000);
plot(h_iir);
title('IIR Impulse Response (Filter 45)');
xlim([0 300]);

subplot 222
plot([h; zeros(140,1)]);
title('FIR Impulse Response (Filter 45)');
xlim([0 300]);

subplot 223
mag_H = 20*log10(abs(H));
plot(w * fs / 2 / pi, mag_H - max(mag_H));
title('Magnitude Response (Filter 45)');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0 2500]);
ylim([-30 0]);
hold on

NFFT = length(w); 
impulse = [1; zeros(159, 1)]; % Impulse signal of length L
h_fir = filter(b, a(m,:), impulse); 

% Mag Response FIR
[H_fir_trunc, ~] = freqz(h_fir, 1, NFFT, fs); % Denominator is 1 for FIR

mag_H_fir_trunc = 20 * log10(abs(H_fir_trunc));
plot(w * fs / 2 / pi, mag_H_fir_trunc - max(mag_H_fir_trunc), 'g--');

legend('Original IIR Response', ['Truncated FIR (L=', num2str(L), ')']);
hold off

subplot 224
plot(w * fs / 2 / pi, angle(H));
title('Phase Response of (Filter 45)');
xlabel('Frequency (Hz)');
ylabel('Phase (rad)');

% Plotting for ---- Filter 65 -----
figure;
m = 65; 
[H, w] = freqz(b,a(m, :));
[h, t] = impz(b,a(m, :), 160);

subplot 221
[h_iir, t] = impz(b, a(45, :), 10000);
plot(h_iir);
title('IIR Impulse Response (Filter 65)');
xlim([0 300]);

subplot 222
plot([h; zeros(140,1)]);
title('FIR Impulse Response (Filter 65)');
xlim([0 300]);

subplot 223
mag_H = 20*log10(abs(H));
plot(w * fs / 2 / pi, mag_H - max(mag_H));
title('Magnitude Response (Filter 65)');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0 2500]);
ylim([-30 0]);
hold on

NFFT = length(w); 
impulse = [1; zeros(159, 1)]; % Impulse signal of length L
h_fir = filter(b, a(m,:), impulse); 

% Mag Response FIR
[H_fir_trunc, ~] = freqz(h_fir, 1, NFFT, fs); % Denominator is 1 for FIR

mag_H_fir_trunc = 20 * log10(abs(H_fir_trunc));
plot(w * fs / 2 / pi, mag_H_fir_trunc - max(mag_H_fir_trunc), 'g--');

legend('Original IIR Response', ['Truncated FIR (L=', num2str(L), ')']);
hold off

subplot 224
plot(w * fs / 2 / pi, angle(H));
title('Phase Response of (Filter 65)');
xlabel('Frequency (Hz)');
ylabel('Phase (rad)');

% Plotting the Mag Responses together
figure;

plot(w * fs / 2 / pi, mag_H - max(mag_H));
title('Magnitude Response (Filter 65)');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0 2500]);
ylim([-30 0]);
hold on
plot(w * fs / 2 / pi, mag_H_fir_trunc - max(mag_H_fir_trunc), 'g--');

m = 45; 
[H, w] = freqz(b,a(m, :));
[h, t] = impz(b,a(m, :), 160);

mag_H = 20*log10(abs(H));
plot(w * fs / 2 / pi, mag_H - max(mag_H));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0 2500]);
ylim([-30 0]);
hold on

NFFT = length(w); 
impulse = [1; zeros(159, 1)]; % Impulse signal of length L
h_fir = filter(b, a(m,:), impulse); 

% Mag Response FIR
[H_fir_trunc, ~] = freqz(h_fir, 1, NFFT, fs); % Denominator is 1 for FIR

mag_H_fir_trunc = 20 * log10(abs(H_fir_trunc));
plot(w * fs / 2 / pi, mag_H_fir_trunc - max(mag_H_fir_trunc), 'g--');

legend('IIR (Filter 65)', ['FIR (Filter 65) (L=', num2str(L), ')'], ...
    'IIR (Filter 45)', ['FIR (Filter 45) (L=', num2str(L), ')']);

hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%