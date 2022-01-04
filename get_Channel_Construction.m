function IW = get_Channel_Construction(K, N, design_SNR)
S = 10.^(design_SNR/10);
n = log2(N);
index = n;
n = 2.^(1:index);
w = zeros(n(index));
w(1,1) = exp(-S);
for i=n
    for j=1:i/2
        w(i, 2*j-1) = w(i/2,j)^2;
        w(i, 2*j) = 2*w(i/2,j)-w(i/2,j)^2;
    end
end
IWi = w(N,1:N);
IW = reshape(IWi, [1,N]);