%% カルマンフィルタ
% CSVファイルの脳波データを読み込み，カルマンフィルタをかける．

%% 初期化

clear,close all;

%% 設定 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%サンプリング周波数[Hz]
fs=256;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 読み込み

% 脳波データの読み込み
sig=csvread('E:\braindata\csvo\csvo3s\calc\W214\calc-W214-3sec-No10.csv'); % 入力データ読み込み
Z=sig(:,3); % chを選択
len=length(Z); % 長さをとる

dt=1/fs;
t=0:dt:3-dt;

%% フィルタ処理
hX=zeros(len,1); % 更新後の推定値
hXm=zeros(len,1); % 更新前の推定値
P=zeros(len,1); % 更新後の予測誤差分散
Pm=zeros(len,1); % 更新前の予測誤差分散

Pm(1)=1;

% 初期値の計算
Phi=1;
Q=1;
H=1;
R=1;

% カルマンフィルタ処理
for i=1:len

    % カルマンゲインの更新
    K=Pm(i)*transpose(H)*inv(H*Pm(i)+R);
    
    % 推定値の更新
    hX(i)=hXm(i)+K*(Z(i)-H*hXm(i));
    
    % 誤差分散の計算
    P(i)=(1-K*H)*Pm(i);
    
    % 推定値の計算
    hX(i+1)=Phi*hX(i);
    Pm(i+1)=Phi*P(i)*transpose(Phi)+Q;
    
end

hX(len+1,:)=[];

%% グラフ

b=25; % 表示幅

figure;
subplot(3,1,1)
plot(t,Z,'b-');
title('raw')
xlabel('Time [sec]')
ylabel('EEG data [uV]')
ylim([mean(Z)-b mean(Z)+b]);

subplot(3,1,2)
plot(t,hX,'r-');
title('Kalman')
xlabel('Time [sec]')
ylabel('EEG data [uV]')
ylim([mean(hX)-b mean(hX)+b]);

subplot(3,1,3)
plot(t,Z,'b-',t,hX,'r-');
legend('raw','Kalman')
xlabel('Time [sec]')
ylabel('EEG data [uV]')
