%学習データ用
%Polymate miniで保存されたcsvファイルを読み込み
%バンドパスフィルタを適用，保存(filtered_data)．
%フーリエ解析，特徴量の形に変形し保存(feature)．

%% 設定 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % フォルダ設定
    % analysisフォルダのパス
    %dataset_path='C:\Users\robot\Documents\MATLAB\morotomi\demand\Brain_Wave\watanabe_EEG';
    %dataset_path='C:\Users\juyo\Documents\morotomi\Brain_Wave\EEG\watanabe_EEG_2';
    dataset_path='/Users/asuka/Program/demand/Brain_Wave/EEG/watanabe_EEG_2';

    % 判別するじゃんけんの形
    form=cellstr(['heijo';'gu   ';'choki';'pa   ';]); % i

    % FFTパラメータ
    % サンプリング周波数
    fs = 500;
    % 使用する最小周波数
    fmin = 4; 
    % 使用する最大周波数
    fmax = 30; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    % featureフォルダの作成
    if exist(fullfile(dataset_path,'feature'))==0
        mkdir(fullfile(dataset_path,'feature'));
    end
    
    % filtered_data_divフォルダの作成
    if exist(fullfile(dataset_path,'filtered_data'))==0
        mkdir(fullfile(dataset_path,'filtered_data'));
    end
    
    % FFTの時間差分
    dt=1/fs;
    
    % バターワースフィルタ設計
    [B1,A1] = butter(4,[fmin/(fs/2) fmax/(fs/2)]);

    % じゃんけん４種類のループ
    for i=1:4 % form

        % featureのじゃんけんの形の出力フォルダの作成
        if exist(fullfile(dataset_path,'feature',char(form(i))))==0
            mkdir(fullfile(dataset_path,'feature',char(form(i))));
        end
        
        % filtered_data_divのじゃんけんの形の出力フォルダの作成
        if exist(fullfile(dataset_path,'filtered_data',char(form(i))))==0
            mkdir(fullfile(dataset_path,'filtered_data',char(form(i))));
        end
        
        % 入力フォルダの中身の読み込み
        FolderInfo=dir(fullfile(dataset_path,'raw_data_div',char(form(i)),'*.csv')); % j

        % 入力フォルダの中身の数を確認
        % 中身の数分ループを回す
        for j=1:length(FolderInfo) % FolderInfo
            % ファイル読み込み
            sig=csvread(fullfile(dataset_path,'raw_data_div',char(form(i)),FolderInfo(j).name),1,0);
            % 4ch分の脳波データの読み込み
            % 1行のオフセット
            
            % (バターワース)バンドパスフィルタの適用
            % 下の行をコメントアウトすると生データ 
            %%{
            sig = filter(B1, A1, sig);
            
            % ファイル名を分割
            feat_name=strsplit(FolderInfo(j).name,'raw'); 
            % 保存
            csvwrite(fullfile(dataset_path,'filtered_data',char(form(i)),['filter',char(feat_name(2))]),sig);
            %}
%% フーリエ解析
            % ファイル毎にfeatを初期化
            feat=[];
            for ch=1:4 % 脳波データ4ch分
                raw_eeg=sig(:,ch);% 時系列脳波データ読み込み
                % 平均０のデータを入力とする ※この下の行に%つけたら生データ
                raw_eeg=raw_eeg-mean(raw_eeg); 
    
                len=length(raw_eeg); % データ点数
                st=round(fmin*len/fs)+1; % fftでプロットし始める点
                fn=round(fmax*len/fs)+1; % fftでプロットし終わる点

                freq=(0:len-1)*fs/len; % 周波数のデータ範囲
                fft_eeg=fft(raw_eeg,len); % 高速フーリエ変換
                %共役複素数をかけてルートをとってパワースペクトルに変換
                freq_eeg=sqrt(fft_eeg.*conj(fft_eeg)/len); 
    
                freq=freq(st:fn); % 抽出
                freq_eeg=freq_eeg(st:fn); % 抽出

                % グラフ表示　
                %{ 
                %この上の行の%を2つにするとグラフを表示
                fig=figure;
                plot(freq,freq_eeg)
    
                xlabel('Frequency [Hz]');
                ylabel('Power Spectrum ');
                title(['ch:',num2str(ch)]);
                xlim([0 30]); % 表示周波数領域の指定
                %}
        
                % 得られた特徴量を一つにまとめる
                feat=[feat;freq_eeg];
            end
            feat=transpose(feat);
            % ファイル名を分割
            feat_name=strsplit(FolderInfo(j).name,'raw');
            % 保存
            csvwrite(fullfile(dataset_path,'feature',char(form(i)),['feature',char(feat_name(2))]),feat);
        end
    end
