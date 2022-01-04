function noise_signal = BG_Impulse_Clipper(noise_signal, noise_power, impulse_prob)   % noise_signal is complex
    prob = impulse_prob;
	G_prob = (1 - prob);    % Gaussian probability
	G_var = noise_power/2;
	Ln = log((prob/G_prob)*sqrt(2.*pi.*G_var));
	clip_th = sqrt(-2.*G_var.*Ln);
    
    % disp('clip_th')
    % disp(clip_th)
    real_bit = real(noise_signal);
    imag_bit = imag(noise_signal);
    for i = 1:length(noise_signal)
        % real part
        if abs(real_bit(i)) > clip_th
            new_real = clip_th * sign(real_bit(i));
        else
            new_real = real_bit(i);
        end
        % imag part
        if abs(imag_bit(i)) > clip_th
            new_imag = clip_th * sign(imag_bit(i));
        else
            new_imag = imag_bit(i);
        end
        noise_signal(i) = new_real + 1i * new_imag;  
    end
end
