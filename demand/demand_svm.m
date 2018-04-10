%%% 判別器の作成
% 学習データから判別器を作成
% 評価データを判別器にかけ平均判別率を求める
% 得られた判別器を保存

% statistics and Machine Learning Toolbox が必要
%% 初期化

clear all;
close all;

%% 初期設定
% プログラムのあるパス
%DPath='/Users/asuka/Program/Brain_Wave/watanabe_EEG';
%DPath='C:\Users\robot\Documents\MATLAB\morotomi\demand\Brain_Wave\watanabe_EEG';
DPath='C:\Users\juyo\Documents\morotomi\Brain_Wave\EEG\watanabe_EEG_2';

% タスク ※要変更
Form=cellstr(['heijo';'gu   ';'choki';'pa   ';]); % i

% データの割り当て
Ldata=400;
Pdata=100;

% 乱数の種
rng(10);

%% 使用するデータの分類

LFeat=[];
LLabel=[]; 
DataTable=[];

% 特徴量LFeatの行数
LRow=0; 
% 特徴量PFeatの行数
PRow=0; 

% 各手の形のループ form
for i=1:4
    % 設定
        % 手の形のフォルダーの中身を確認
        FolderInfo=dir(fullfile(DPath,'feature',char(Form(i)),'*.csv'));
        FLen=length(FolderInfo);
    
        % 二度同じデータを使用しないようにフラグテーブルを作成
        FlagTable=zeros(FLen); 
    
    % 学習データ
    
        % 学習データLdata個分のループ
        count=0;
        while count < Ldata
    
            % 乱数で学習に使う脳波データを選択
            p=randi(FLen);
        
            % 二度同じデータを使用しないようにフラグを確認
            if (FlagTable(p)~=0)
                continue; 
            end
        
            % 大丈夫ならば，その学習データを読み込み
            data=csvread(fullfile(DPath,'feature',char(Form(i)),FolderInfo(p).name));
        
            % フラグ，行数，現在の選択数を更新
            FlagTable(p)=FlagTable(p)+1;
            LRow=LRow+1;
            count=count+1;
        
            % 特徴量LFeat，ラベルLLavel，データ表LDataTableに付け加える
            LFeat(LRow,:)=data;
            LLabel(LRow,1)=i-1; % MATLABの配列が1から始まる
            LDataTable{LRow,1}=FolderInfo(p).name;
    
        end % 学習データ count
   

   % 評価データ
   
        % 評価データPdata個分のループ
        count=0;
        while count < Pdata
    
            % 乱数で評価に使う脳波データを選択
            p=randi(FLen);
        
            % 二度同じデータを使用しないようにフラグを確認
            if (FlagTable(p)~=0)
                continue; 
            end
        
            % 大丈夫ならば，その評価データを読み込み
            data=csvread(fullfile(DPath,'feature',char(Form(i)),FolderInfo(p).name));
        
            % フラグ，行数，現在の選択数を更新
            FlagTable(p)=FlagTable(p)+1;
            PRow=PRow+1;
            count=count+1;
        
            % 特徴量PFeat，ラベルPLavel，データ表PDataTableに付け加える
            PFeat(PRow,:)=data;
            PLabel(PRow,1)=i-1; % MATLABの配列が1から始まる
            PDataTable{PRow,1}=FolderInfo(p).name;
    
        end % 評価データ count
end % i
%% 学習
% 判別器の学習
model=fitcecoc(LFeat,LLabel);

%% 評価
% 評価(予測)
Predict=predict(model,PFeat);

% 判別結果
C = confusionmat(PLabel,Predict)
accuracy=sum(PLabel == Predict)/numel(PLabel);
disp(['判別率:',num2str(accuracy*100),'%'])

%% 保存

mkdir(fullfile(DPath,'model'));
save(fullfile(DPath,'model',[datestr(now,'yy-mm-dd-HH-MM'),'acc',num2str(accuracy),'.mat']),...
    'model','LFeat','LLabel','PFeat','PLabel','LDataTable','PDataTable');