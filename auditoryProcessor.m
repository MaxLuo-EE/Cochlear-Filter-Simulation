function [d, e, v_m] = auditoryProcessor(input_signal, b, a, k, c0)
    
    excitation_filtered = zeros(128, length(input_signal));
    for i = 1:128
        excitation_filtered(i,:) = k(i) * filter(b, a(i,:), input_signal); 
    end

    % --- 2. First Spatial Differentiation (d) ---
    d = excitation_filtered(1:end-1, :) - excitation_filtered(2:end, :);

    % --- 3. Second Spatial Differentiation (e) ---
    e = d(1:end-1, :) - d(2:end, :);
    
    % --- 4. Inner Hair Cell (IHC) Model (v_m) ---
    e_m = max(e, 0); % Half-wave rectification
    v_m = zeros(size(e_m));
    
    % First-order
    for n = 1:size(e_m, 1)           % loop through filters (rows)
        for i = 2:size(e_m, 2)       % loop through time (columns)
            v_m(n, i) = (1 - c0) * e_m(n, i) + c0 * v_m(n, i - 1);
        end
    end
end