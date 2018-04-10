% 設計したバンドパスフィルタが正常か確認するプログラム
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% パラメータ設定
filtDim = 4;
fmin = 4;
fmax = 30;
fs = 500;

%% フィルターの設定
[B,A] = butter(filtDim,[fmin/(fs/2) fmax/(fs/2)]); % バンドパスフィルタ
%[B,A] = butter(filtDim,fmax/(fs/2)); % ローパスフィルタ

f1=figure
freqz(B,A)

%% フィルターの適用
sig=csvread('/Users/asuka/Program/demand/Brain_Wave/EEG/watanabe_EEG_2/raw_data_div/gu/raw_gu_001_1_0.csv',1,0);

sigf = filter(B, A, sig);

t=1:256;

f2=figure;

for i=1:4
    subplot(2,2,i)
    plot(t,sig(:,i),t,sigf(:,i))
    legend('フィルタ無し','フィルタ有り')
    ylim([-150 150])
    title([num2str(i),'ch'])
end
