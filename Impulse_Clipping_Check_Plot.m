% impulse noise plot
rSig = rSig';
Time = 1:length(rSig);
stem(Time, abs(rSig), '-o', 'LineWidth',1.5);
xlabel('Time (Transmission-symbols)')  % x轴坐标描述
ylabel('Amplitude')        % y轴坐标描述
legend('Prob=0.01,  SNR=10-dB');   %右上角标注
grid on
title('After Clipping, Noise(impulse + AWGN) Amplitude')

% clip_signal
% rmoutliers(abs(rSig))