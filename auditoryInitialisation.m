%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LEVEL 2.1
% Defining Initial Conditions
n = 1:128;
input_length = 1024;
NFFT = 1024;

dx = 0.02345275591;
fs = 16000;

% Calculating fp array
fp = 8000*10.^(-0.667*(129 - n)*dx);        % 129 - n = k
Qp = 5 + 5/127*(n - 1);                     % calculating qp linearly

% Calculating Bandwidth
BW = fp./Qp;

% Coefficients
rp = 1 - BW/fs*pi;
theta_p = 2*pi.*fp/fs;

b1 = 2*rp.*cos(theta_p);
b2 = rp.^2;

% Defining Impulse Response
b = [1 0 -1];
b_g = [-1 0 1];

a = [ones(128,1) -b1' b2'];
a_g = [b2' -b1' ones(128,1)];

% Calculating K factors
k = zeros(1, 128);
for i = 1:128
    sine_wave = sin(2*pi*fp(i)*t);
    filter_output = filter(b, a(i,:), sine_wave);
    k(i) = 1 / max(abs(filter_output));
end

% Defining Cutoff Frequency
fc = 30;
c0 = exp(-2*pi*fc/fs);