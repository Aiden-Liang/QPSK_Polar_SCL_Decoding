clear;
clc;
K = 11;
N = 64;
R = K/N;
%% Channel Construction & Frozen bit (only for long code)
design_SNR = 0 +10*log10(R);
IW = get_Channel_Construction(K, N, design_SNR);                         % 子信道的信道容量
[info_bit_idx, frozen_bits] = get_info_and_frozen_location(IW, N, K);    % 分别表示信息位的下标和冻结位的位置

%% Encoder
G = 1;
F = [1 0;1 1];
for j = 1:log2(N) 
    G = kron(G,F);
end                                                      % G 表示最终的生成矩阵
List = [1, 2, 4];
qAry = log2(2);                                          % Normalized Signal
EBN0 = [0, 1, 2, 3, 4, 5];            % 信噪比的范围
countCycles = zeros(length(List),length(EBN0)) ;         % 不同码率和信噪比时所运行的帧数
FER = zeros(length(List),length(EBN0)) ;                 % 误帧率
BER = zeros(length(List),length(EBN0)) ;                 % 误码率
bpskMod = comm.BPSKModulator;                            % 使用BPSK调制
qpskMod = comm.QPSKModulator('BitInput', true) ;         % 使用 QPSK 调制
Frames = 1000;                                           % 总帧数
batch = 1;                                               % Batch size
imp_prob = 0.001;                                         % impulse probability

%% Simulation
for Len = 1:length(List)
    L = List(Len);
    disp('# List:');
    disp(L);
    for time = 1:length(EBN0)
        EbNo = EBN0(time);
        error_Frames = 0;
        error_Bits = 0;
        correct = 0;
        
        %% AWGN channel  & Noise Power 
        % EsNo = EbNo + 10*log10(qAry);
        % snrdB = EsNo + 10*log10(R);
        noiseVar = 1./10.^(EbNo/10); 
        noiseVar = noiseVar * 2;
        
        chan = comm.AWGNChannel('NoiseMethod','Variance','Variance',noiseVar);
        bpskDemod = comm.BPSKDemodulator('DecisionMethod','Approximate log-likelihood ratio','Variance',noiseVar);
        qpskDemod = comm.QPSKDemodulator('BitOutput',true ,'DecisionMethod','Approximate log-likelihood ratio','Variance',noiseVar);
        Frames_errors = 0;
        Batch_total_bits = 0;
        Error_counter = 0;
        
         %% Batch Data Generator :
        while (Frames_errors <= 5500 & Error_counter <= 1100)     % Error control Threshold
            Error_counter = Error_counter +1;
            disp("# Error_counter : " + num2str(Error_counter));
            disp("--------------------------------------------------");
            for num = 1: (Frames/batch)  % each batchs
                disp("**No_of_batch : " + num2str(num) + " **");
                % info_bit = randi([0,1],1,K);     % 获取随机的比特信息
                batch_data = binornd(1, 0.5, batch, K);
                % batch_data = ~batch_data;
                % Mini-Batch each codewords decoding : iter
                for iter = 1: batch      % batch each codewords
                    % disp("**No_of_iteration : " + num2str(iter) + " **");
                    info_bit = batch_data(iter,:);
                    % 将信息序列存储到数组before_code_bit中
                    before_code_bit = zeros(1,N);
                    before_code_bit(info_bit_idx(:)) = info_bit(:);
                    S = polar_encode(N, before_code_bit);          % 极化码编码
                    % frozen_bits_flag = frozen_bits';         
                    % 开始调制
                    mod = qpskMod(S');
                    % rSig = chan(mod);
                    [rSig, impulse_index] = QPSK_Prob_Impulse_Channel(mod, noiseVar, imp_prob);
                    clip_signal = BG_Impulse_Clipper(rSig, noiseVar, imp_prob);  % Clipper
                    % stop
                    rxLLR = qpskDemod(clip_signal);   % Clipping
                    llr = rxLLR;
                    [dec_list] = SCL_CRCdecoder_llr(L, N, llr, noiseVar, info_bit_idx, G);
                    after_decode_bit = dec_list(:,1)';
                    % 解码之后的序列
                    % after_decode_bit 
                    % disp("**info_bit :         [ " + num2str(info_bit) + " ]");
                    % disp("**after_decode_bit : [ " + num2str(after_decode_bit) + " ]");
                    codeword_errors = sum(info_bit ~= after_decode_bit);
                    % disp("**word_wrong_bits : " + num2str(codeword_errors));
                    Frames_errors = Frames_errors + codeword_errors;
                    disp("**Cumulative_error_bits : " + num2str(Frames_errors));
                    Batch_total_bits = Batch_total_bits + K;
                    disp("**Cumulative_total_bits : " + num2str(Batch_total_bits) + " **");
                    disp("--------------------------------------------------");
                    if (Frames_errors > 5500), break; end
                end
                % if batch_sum_errors > 5500 : leave loop
                if (Frames_errors > 5500), break; end
            end
            continue   % if error bits not enough: keep decoding
        end
        FER(Len,time) = Frames_errors ./ Batch_total_bits;
        disp('# BER:');
        disp(FER);
    end
end
%% Plot BER
semilogy(EBN0,FER(1,:),'-*b',EBN0,FER(2,:),'-^r',EBN0,FER(3,:),'-sg',EBN0,FER(4,:),'-om');
xlabel('EBN0(dB)')  %x轴坐标描述
ylabel('FER') %y轴坐标描述
legend('SCL List=1（SC）','SCL List=2','SCL List=4','SCL List=8');   %右上角标注
grid on
title('SCL decode N=256 R=0.5')