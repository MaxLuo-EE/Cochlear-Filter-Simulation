%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LEVEL 2.3
% Graphing
for n = 1:10:128
    % Plotting Magnitude Response
    [H, w] = freqz(b,a(n, :));
    mag_H = 20*log10(abs(H));
    plot(w * fs / 2 / pi, mag_H - max(mag_H));
    xlim([0 8000]);
    ylim([-15 0]);
    hold on;
end

figure;
m = 72; 
[H, w] = freqz(b,a(m, :));
[h, t] = impz(b,a(m, :), 160);
mag_H = 20*log10(abs(H));
plot(w * fs / 2 / pi, mag_H - max(mag_H));
title('Magnitude Response (Filter 72)');
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
