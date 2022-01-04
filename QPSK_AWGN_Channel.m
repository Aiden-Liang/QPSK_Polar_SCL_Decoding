function [y, impulse_index] = QPSK_AWGN_Channel(x_psk, noise_power)
    y = zeros(length(x_psk),1);
    impulse_index = 0;
    for i = 1:length(x_psk)
        normal_pdf = randn + 1i*randn;
        awgn = sqrt(noise_power/2) .* normal_pdf; 
        y(i) = x_psk(i) + awgn;
    end
end
