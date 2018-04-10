% ウェーブレット解析による脳波データの画像化（14ch）
% csvo?sフォルダからデータを読み込み，CWTフォルダの中にフォルダを作りその中に14枚のデータを保存
% 動く

%% 設定 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%サンプリング周波数
fs = 256;
%fs=128;

%データの時間[sec]
interval=3;

%dataフォルダ内の名前
%folder_name='20170127';
    
%メンタルタスク
MT=cellstr(['calc';'move']); % i
%MT='calc';
%MT='move';
    
%測定場所
place=cellstr(['W318 ';'W214 ';'SG   ';'RB   ';'W214n']); % j
%place='RB';
%place='SG';
%place='W214';
%place='W318';
%place='W214n';

%マザーウェーブレット
waven = 'gaus5'; % ガウシアンウェーブレット関数
%waven = 'haar'; % ハールウェーブレット関数
%waven = 'gaus1'; % メキシカンハットウェーブレット関数

%周波数軸の設定
fmin = 4; % グラフに表示する最小周波数
fmax = 30; % グラフに表示する最大周波数
%色軸の設定
cmin = -10; % 色軸の最小値
cmax = 10; % 色軸の最大値
%色の設定
color='color';
%color='gray';

%入力データのパス
%input_path=input('入力データのあるディレクトリのパスを入力\n','s');
%input_path=fullfile('C:\Users\Asuka Morotomi\Documents\Afolder\data',folder_name,['csvo',num2str(interval),'s'],MT,place);
%input_path=fullfile('C:\Users\robot\Documents\Afolder\data',folder_name,['csvo',num2str(interval),'s'],MT,place);
input_path=fullfile('E:\braindata',['csvo',num2str(interval),'s']);

%出力データのパス
%output_path=input('CWTの画像データを保存するディレクトリのパスを入力\n','s');
%output_path=fullfile('C:\Users\Asuka Morotomi\Documents\Afolder\data',folder_name,'CWT-separate',['CWT-',color],MT,place);
%output_path=fullfile('C:\Users\robot\Documents\Afolder\data',folder_name,'CWT-separate',['CWT-',color],MT,place);
output_path=fullfile('E:\braindata','CWT-separate',['CWT-separate-',color,'-',waven]);
%output_path=fullfile('C:\Users\robot\Desktop',['CWT-separate-',color,'-',waven]);
%出力データのフォルダ作成
mkdir(output_path);

% 処理
dt = 1/fs;
scalef = 1:1:fs; % スケールファクタ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:2 % MT
    %i=1;
%出力フォルダを作成    
mkdir(fullfile(output_path,char(MT(i))));

for j=1:5 % place
    %j=1;
%出力フォルダを作成
mkdir(fullfile(output_path,char(MT(i)),char(place(j))));

%解析を行うデータの始めの番号を入力
anly_st=1;
%解析を行うデータの終わりの番号を入力
%anly_fn=1;
anly_fn=length(ls(fullfile(input_path,char(MT(i)),char(place(j)))))-2;


for anly=anly_st:anly_fn % データ数

    % 元ファイルの読み込み
    sig=csvread(fullfile(input_path,char(MT(i)),char(place(j)),[char(MT(i)),'-',char(place(j)),'-',...
        num2str(interval),'sec-No',num2str(anly),'.csv'])); % 入力データ読み込み
    % データ長
    [m,n]=size(sig);
    % 時系列データ
    t= 0:dt:dt*(m-1);
    % 出力データをまとめるフォルダの名前
    outputfile=[char(MT(i)),'-',char(place(j)),'-',num2str(interval),'sec-No',num2str(anly)];
    % 出力データをまとめるフォルダを作る
    mkdir(fullfile(output_path,char(MT(i)),char(place(j)),outputfile));
    
    for x=3:16  % WTを施す行 脳波チャネル
        %ch=brainwave_num2str(x); % chの名前を取得
        %連続ウェーブレット変換
        [cfs,f] = cwt(sig(:,x),scalef,waven,dt); 
    
        % ウェーブレット係数の二乗
        %args = {t,f,abs(cfs).^2}; 
        % ウェーブレット係数の自然対数
        args = {t,f,log(abs(cfs))}; 
        % 画面表示しない
        figure('visible','off');
        % surfグラフ
        fig=surf(args{:},'edgecolor','none');
        % 真上から見る
        view(0,90);

        %axis tight; % 数値あり
        axis off;    % 数値なし
        shading interp; % シェーディングタイプ interp
        colormap(parula(128)); % カラーマップ parula 128色を使用
        %colormap(gray(128)); % カラーマップ gray 128色を使用
        %h = colorbar; % 色軸有
        %h.Label.String = 'ln(abs(coefficient))'; % 色軸ラベル　
        %xlabel('Time'); ylabel('Hz'); % x軸y軸ラベル
        %title(['ch:',ch,' mw:',waven]); % タイトル
        ylim([fmin fmax]); % 表示周波数領域の指定
        %xlim([5 30]); %　表示時間領域の指定
        caxis([cmin,cmax]); % 色軸の最小値，最大値

        ax = gca;
        ax.Position= [0 0 1 1];%余白を無くす処理

        %saveas(fig,fullfile(output_path,char(MT(i)),char(place(j)),...
        %    outputfile,[char(MT(i)),'-',char(place(j)),'-',num2str(interval),'sec-No',num2str(anly),'-ch',num2str(x),'.jpg']),'jpeg')
        saveas(fig,fullfile(output_path,char(MT(i)),char(place(j)),...
            outputfile,[char(MT(i)),'-',char(place(j)),'-',num2str(interval),'sec-No',num2str(anly),'-ch',num2str(x),'.bmp']),'bmp')
        
        close all hidden;
        clear fig,args,ax,cfs;

    end %ch
        clear sig,m,n,t,outputfile;
end % anly

end % place
end % MT