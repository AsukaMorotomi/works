%データを読み込みフーリエ解析を施しmat形式で保存

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
%MT='calc';
MT='move';
    
%測定場所
%place='RB';
%place='SG';
%place='W214';
place='W318';

%周波数軸の設定
fmin = 4; % グラフに表示する最小周波数
fmax = 30; % グラフに表示する最大周波数
%エネルギー密度スペクトル軸の設定
emin = 0; % エネルギー密度スペクトル軸の最小値
emax = 15; % エネルギー密度スペクトル軸の最大値

%入力データのパス
%input_path=input('入力データのあるディレクトリのパスを入力\n','s');
%input_path=fullfile('C:\Users\robot\Desktop\data',folder_name,['csvo',num2str(interval),'s'],MT,place);
input_path=fullfile('C:\Users\Asuka Morotomi\Documents\Afolder\data',folder_name,['csvo',num2str(interval),'s'],MT,place);


%FFTグラフのパス
%output_path=input('FFTグラフを保存するディレクトリのパスを入力\n','s');
graph_path=fullfile('C:\Users\Asuka Morotomi\Documents\Afolder\data',folder_name,'FFT-graph',MT,place);

%出力データのパス
%output_path=input('matデータを保存するディレクトリのパスを入力\n','s');
output_path=fullfile('C:\Users\Asuka Morotomi\Documents\Afolder\data',folder_name,'FFT-mat',MT,place);

%解析を行うデータの始めの番号を入力
%anly_st=input('解析を行うデータの始めの番号を入力\n');
ftanly_st=1;
%解析を行うデータの終わりの番号を入力
%anly_fn=input('解析を行うデータの終わりの番号を入力\n');
ftanly_fn=821;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dt=1/fs; % サンプルごとの増分時間

ftanly=1;
for ftanly=ftanly_st:ftanly_fn

    sig=csvread(fullfile(input_path,[MT,'-',place,'-',num2str(interval),'sec-No',num2str(ftanly),'.csv'])); % 入力データ読み込み
    %graphfile=[MT,'-',place,'-',num2str(interval),'sec-No',num2str(ftanly)]; % FFTグラフをまとめるフォルダの名前
    %mkdir(fullfile(graph_path,graphfile)); % 出力データをまとめるフォルダを作る
    mat_n=1; %特徴量を1行のベクトルにするため

    for x=3:16  % FTを施す行
        ch=brainwave_num2str(x); % chの名前を取得

        anly_data=sig(:,x); 
        anly_data=anly_data-mean(anly_data); %平均０のデータを入力とする ※この行に%つけたら生データ
        m=length(anly_data);

        y=fft(anly_data,m); %高速フーリエ変換
        
        st=round(fmin*m/fs); % fftでプロットし始める点
        fn=round(fmax*m/fs); % fftでプロットし終わる点
        
        f=(0:m-1)*fs/m; % 周波数のデータ範囲　fs=m*(fs/m)

        power=y.*conj(y)/m; % fftの解に共役複素数をかける

        f=f(st:fn); % 抽出
        power=power(st:fn); % 抽出

        power=power/mean(power); % 0.5～30[Hz]のパワースペクトルの平均で正規化
        
%          % FFTのグラフを保存する

%         %fig=figure; % グラフを表示    
%         fig=figure('visible','off'); % グラフを表示しない
%         p=plot(f,power) %周波数領域の脳波データの表示
%         xlabel('\fontsize{16}Frequency [Hz]');
%         ylabel('\fontsize{16}Energy Spectral Density');
%        % title(['ch:',ch]); % タイトル
%         set(p,'LineWidth',3)
%         xlim([0 30]); % 表示周波数領域の指定
%         ylim([emin emax]); % 表示エネルギー密度スペクトル領域の指定
%         saveas(fig,fullfile(graph_path,graphfile,[MT,'-',place,'-',num2str(interval),'sec-No',num2str(ftanly),'-ch',num2str(x),'.jpg']),'jpeg')
%         close hidden all;
%         clear fig;
%         
        %devn個のパラメータを作る
        sum_p=0;
        q=(fn-st)/devn;
        n_p=0;
        for n=1:devn
            for p=round((n-1)*q)+1:round(n*q)
                if p>fn-st
                    break
                end
                n_p=n_p+1;
                sum_p=sum_p+power(p);
            end
            fft_mat(mat_n)=sum_p/n_p; %1行に特徴量をまとめる．
            mat_n=mat_n+1;
            sum_p=0;
            n_p=0;
        end        
    end

    save(fullfile(output_path,[MT,'-',place,'-',num2str(interval),'sec-No',num2str(ftanly)]),'fft_mat'); % 保存
end