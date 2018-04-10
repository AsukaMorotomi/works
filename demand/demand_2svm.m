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
%DPath='C:\Users\juyo\Documents\MATLAB\Brain_Wave-master\watanabe_EEG_2';
DPath='C:\Users\juyo\Documents\morotomi\Brain_Wave\EEG\watanabe_EEG_2';

% タスク ※要変更
Form=cellstr(['heijo';'gu   ';'choki';'pa   ';]); % i

% データの割り当て
Ldata=[1200;400;400;400];
Pdata=[100;100;100;100];

%Ldata=[90;30;30;30];
%Pdata=[30;10;10;10];

% 乱数の種
seed=10;
rng(seed);

%% 使用するデータの分類

L1Feat=[];
L1Label=[]; 
L2Feat=[];
L2Label=[]; 
PFeat=[];
PLabel=[];

% 特徴量L1Featの行数
L1Row=0; 
% 特徴量L1Featの行数
L2Row=0; 
% 特徴量PFeatの行数
PRow=0; 

% 各手の形のループ form
for i=1:4
    disp(['学習データ：',char(Form(i))])
    % 設定
        % 手の形のフォルダーの中身を確認
        FolderInfo=dir(fullfile(DPath,'feature',char(Form(i)),'*.csv'));
        FLen=length(FolderInfo);
    
        % 二度同じデータを使用しないようにフラグテーブルを作成
        FlagTable=zeros(FLen); 
    
    % 学習データ
    
        % 学習データLdata個分のループ
        count=0;
        while count < Ldata(i)
    
            % 乱数で学習に使う脳波データを選択
            p=randi(FLen);
        
            % 二度同じデータを使用しないようにフラグを確認
            if (FlagTable(p)~=0)
                continue; 
            end
        
            % 大丈夫ならば，その学習データを読み込み
            data=csvread(fullfile(DPath,'feature',char(Form(i)),FolderInfo(p).name));
        
            % フラグ，現在の選択数を更新
            FlagTable(p)=FlagTable(p)+1;
            count=count+1;
            
            % 行数を更新
            L1Row=L1Row+1;
            % データ表LDataTableに付け加える
            LDataTable{L1Row,1}=FolderInfo(p).name;
            
            %平常時の処理
            if i==1
                % 判別器1用
                % 特徴量L1Feat，ラベルL1Lavelに付け加える   
                L1Feat(L1Row,:)=data;
                L1Label(L1Row,1)=0; 
            
                % 判別器2には使用しない
            
            
            %じゃんけん時の処理
            else
                
                % 判別器1用
                % 特徴量L1Feat，ラベルL1Lavelに付け加える   
                L1Feat(L1Row,:)=data;
                L1Label(L1Row,1)=1; 
            
                % 判別器2用
                % 行数を更新
                L2Row=L2Row+1;
                % 特徴量L2Feat，ラベルL2Lavelに付け加える   
                L2Feat(L2Row,:)=data;
                L2Label(L2Row,1)=i-1; % MATLABの配列が1から始まる
                
            end    
        end % 学習データ count
   

   % 評価データ
   
   disp(['評価データ：',char(Form(i))])
        % 評価データPdata個分のループ
        count=0;
        while count < Pdata(i)
    
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
disp('学習')
% 判別器の学習
model1=fitcecoc(L1Feat,L1Label);
model2=fitcecoc(L2Feat,L2Label);

%% 評価
% 評価(予測)
Predict_sub=predict(model1,PFeat);
% 判別結果
PLabel_sub=double(PLabel > 0);
C = confusionmat(PLabel_sub,Predict_sub)
accuracy1=sum(PLabel_sub == Predict_sub)/numel(PLabel_sub);
disp(['判別率:',num2str(accuracy1*100),'%'])

% 評価(予測)
for j=1:PRow % 評価データ分ループ
    [Predict1,sc1]=predict(model1,PFeat(j,:)); % 判別器1
    
    % 平常時の場合
    if Predict1==0
        Predict(j,1)=Predict1;
        score1(j,:)=sc1;
        score2(j,:)=[0,0,0];
    % じゃんけん時の場合
    else
        [Predict2,sc2]=predict(model2,PFeat(j,:)); % 判別器2
        
        Predict(j,1)=Predict2;
        score1(j,:)=sc1;
        score2(j,:)=sc2;
    end 
end


% 判別結果
C = confusionmat(PLabel,Predict)
accuracy2=sum(PLabel == Predict)/numel(PLabel);
disp(['判別率:',num2str(accuracy2*100),'%'])
disp('　')
disp('ラベルと信頼度')
disp('       正解   予測　　判1:平常　 判1:じゃん  判2:グー　判2:チョキ　判2:パー')
disp([PLabel,Predict,score1,score2])

%% 保存

mkdir(fullfile(DPath,'model'));
save(fullfile(DPath,'model',[datestr(now,'yy-mm-dd-HH-MM'),'acc',num2str(accuracy2),'.mat']),...
    'model1','model2','L1Feat','L2Feat','L1Label','L2Label','PFeat','PLabel','LDataTable','PDataTable');