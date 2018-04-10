% 脳波判別
% フーリエ解析により得られたエネルギースペクトル密度を分割個数に分割し特徴抽出
% 得られた特徴量を使ってSVMを用いて判別を行う
% 動く

%% 設定

clear all;
close all;

% 設定 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%周波数帯の分割個数
devn=26;

%サンプリング周波数
fs = 256;
%fs=128;

%データの時間[sec]
%interval=input('データの秒数[s]を入力\n');
interval=3;

%dataフォルダ内の名前
folder_name='20170127';
    
%メンタルタスク
MT1='calc';
MT2='move';
    
%測定場所
%place='RB';
%place='SG';
%place='W214';
%place='W318';

%入力データのパス
%input_path=input('入力データのあるディレクトリのパスを入力\n','s');
%input_path=fullfile('C:\Users\robot\Desktop\data',folder_name,'FFT-mat');
input_path=fullfile('C:\Users\Asuka Morotomi\Documents\Afolder\data',folder_name,'FFT-mat');
                     
%解析を行うデータの始めの番号を入力
%data_st=input('解析を行うデータの始めの番号を入力\n');
data_st=1;
%解析を行うデータの終わりの番号を入力
%data_fn=input('解析を行うデータの終わりの番号を入力\n');
%data_fn=600;
data_fn=300;

%学習と予測
%　rem(y+a,6)==0の時　予測
%　rem(y+a,6)~=0の時　学習
a=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trx1=0;
trx2=0;
tex1=0;
tex2=0;
%% 学習

for n_place=1:2 % 測定場所2ヶ所 ※下のend
%n_place=1;      % 測定場所W214のみの場合
%n_place=2;      % 測定場所W318のみの場合
    switch n_place
        case 1
            place='W214';
        case 2
            place='W318';
    end

    % MT1:calcの学習データ準備
    for i=data_st:data_fn
        if rem((i+a),6)~=0
            data = load(fullfile(input_path,MT1,place,[MT1,'-',place,'-',num2str(interval),'sec-No',num2str(i),'.mat']),'-mat');
            trx1=trx1+1;
            MT1_traindata(trx1,:)=[1 data.fft_mat];
        end
    end
    
        % MT2:moveの学習データ準備
    for i=data_st:data_fn
        if rem((i+a),6)~=0
            data = load(fullfile(input_path,MT2,place,[MT2,'-',place,'-',num2str(interval),'sec-No',num2str(i),'.mat']),'-mat');
            trx2=trx2+1;
            MT2_traindata(trx2,:)=[2 data.fft_mat];
        end
    end
end % 測定場所2ヶ所

    model = svmtrain([MT1_traindata(:,1);MT2_traindata(:,1)],...
        [MT1_traindata(:,[2:devn*14+1]);MT2_traindata(:,[2:devn*14+1])],'-t 2 -b 1'); % 学習
    
    
%% 予測
count_MT1=0;
count_MT2=0;

for n_place=1:2 % 測定場所2ヶ所 ※下のend
%n_place=1;      % 測定場所W214のみの場合
%n_place=2;      % 測定場所W318のみの場合
    switch n_place
        case 1
            place='W214';
        case 2
            place='W318';
    end

    % MT1:calcの予測データ準備
    for i=data_st:data_fn
        if rem((i+a),6)==0
            data = load(fullfile(input_path,MT1,place,[MT1,'-',place,'-',num2str(interval),'sec-No',num2str(i),'.mat']),'-mat');
            tex1=tex1+1;
            MT1_testdata(tex1,:)=[1 data.fft_mat];
        end
    end
    
    % MT2:moveの予測データ準備
    for i=data_st:data_fn
        if rem((i+a),6)==0
            data = load(fullfile(input_path,MT2,place,[MT2,'-',place,'-',num2str(interval),'sec-No',num2str(i),'.mat']),'-mat');
            tex2=tex2+1;
            MT2_testdata(tex2,:)=[2 data.fft_mat];
        end
    end
end % 測定場所2ヶ所

    [predicted_label,accuracy,value] = svmpredict([MT1_testdata(:,1);MT2_testdata(:,1)],...
        [MT1_testdata(:,[2:devn*14+1]);MT2_testdata(:,[2:devn*14+1])],model,'-b 1')
    
    accuracy
    
    % MT1の判別精度
    for i=1:tex1
        if predicted_label(i)==1
            count_MT1=count_MT1+1;
        end
    end
    accuracyMT1=count_MT1/tex1
    
    % MT2の判別精度
    for i=tex1+1:tex1+tex2
        if predicted_label(i)==2
            count_MT2=count_MT2+1;
        end
    end
    accuracyMT2=count_MT2/tex2