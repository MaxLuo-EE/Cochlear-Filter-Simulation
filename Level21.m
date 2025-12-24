%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LEVEL 2.1
% Plotting for ---- Part 1 -----
figure;
subplot 311
[h, t] = impz(b, a(4, :), 10000);
plot([h; zeros(140,1)]);
title('IIR Response (Filter 4)');
xlim([1 1000]);

subplot 312
[h, t] = impz(b, a(64, :), 10000);
plot([h; zeros(140,1)]);
title('IIR Response (Filter 64)');
xlim([1 200]);

subplot 313
[h, t] = impz(b, a(128, :), 10000);
plot([h; zeros(140,1)]);
title('IIR Response (Filter 128)');
xlim([1 35]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
