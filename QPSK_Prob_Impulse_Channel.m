function [y, impulse_index] = QPSK_Prob_Impulse_Channel(x_psk, noise_power, impulse_prob)
    y = zeros(length(x_psk),1);
	impulse_index = [];
    for i = 1:length(x_psk)       % codewords_symbols
        dice = rand;
        if dice <= impulse_prob   % add impulse
			impulse_index(end+1) = i;
            IGR = 100;
            impulse_power = noise_power .* IGR;
            normal_pdf = randn + 1i*randn;
            impulse = sqrt(impulse_power/2) .* normal_pdf; 
            y(i) = x_psk(i) + impulse;
        else                      % add AWGN
            normal_pdf = randn + 1i*randn;
            awgn = sqrt(noise_power/2) .* normal_pdf; 
            y(i) = x_psk(i) + awgn;
        end
    end
    % disp('** impulse_index')
    % disp(impulse_index)
end
