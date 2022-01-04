% semilogy(EBN0,FER(1,:),'-o',EBN0,FER(2,:),'-.o',EBN0,FER(3,:),'-.o',EBN0,FER(4,:),'-.o', 'LineWidth',1.5);
semilogy(EBN0,FER(1,:),'-o',EBN0,FER(2,:),'-.o',EBN0,FER(3,:),'-.o', 'LineWidth',1.5);
xlabel('Eb/No(dB)', 'FontSize',15)  %x轴坐标描述
ylabel('BER', 'FontSize',15) %y轴坐标描述
legend('K=11, N=64, List = 1 (SCD)', 'K=11, N=64, List = 2', 'K=11, N=64, List = 4', 'K=11, N=64, List = 8', 'FontSize',14);   %右上角标注
grid on
title('BG-impulse-SCL,  Prob=0.001,  Random-data,  1200W-bits', 'FontSize',15)