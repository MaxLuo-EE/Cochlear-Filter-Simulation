
% --- LEVEL 4.3&4 ------------------------
x = audioread("wewereawaymax.wav");
x = resample(x, 16000, 48000);

% Normalised cut-off frequencies (Wn = f_cut / (fs/2))
Wn = [320 7500] / (fs/2);
[b_bp, a_bp] = butter(10, Wn, 'bandpass');

x_filtered = filter(b_bp, a_bp, x);

% Filter bank
[~, ~, v_m_filtered] = ...
    auditoryProcessor(x_filtered(1281:1600), b, a, k, c0);
filtered_energies = sum(v_m_filtered, 2);

[~, ~, v_m] = auditoryProcessor(x(1281:1600), b, a, k, c0);
filter_energies = sum(v_m, 2);

figure;
subplot 221
bar(filter_energies(1:30));
title('Before BP Filter (Frame 5)');
subplot 222
bar(filtered_energies(1:30));
title('After BP Filter (Frame 5)');

[~, ~, v_m_filtered] = ...
    auditoryProcessor(x_filtered(1601:1920), b, a, k, c0);
filtered_energies = sum(v_m_filtered, 2);

[~, ~, v_m] = auditoryProcessor(x(1601:1920), b, a, k, c0);
filter_energies = sum(v_m, 2);

subplot 223
bar(filter_energies(1:30));
title('Before BP Filter (Frame 6)');
subplot 224
bar(filtered_energies(1:30));
title('After BP Filter (Frame 6)');



% --- LEVEL 4.4 ------------------------

% Creating secondary bandpass coefficients
Wn = [60 400] / (fs/2);
[b_bp, a_bp] = butter(4, Wn, 'bandpass');

% Band Pass
qn = max(x_filtered, 0);                % Half wave rect. (non-linear)
rn = filter(b_bp, a_bp, qn);            % We are redefining b_bp here


% Magnitude Spectrum of sn (A)
sn = x;
mag_sn = fft(sn, 1024);
mag_sn = abs(mag_sn/length(sn));
sn_spectrum = mag_sn(1:1024/2 + 1);
sn_spectrum(2:end-1) = 2 * sn_spectrum(2:end-1);

% Magnitude Spectrum of pn (B)
pn = x_filtered;
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


