% CNNを使った脳波分類
% 1つの学習データに対して複数の評価データを使用する。
% 1回の実行で複数の学習データを回す。
% 

%% 初期化

clear,close all;

%% データの準備

% データセットのパス
WholeDataSetPath='E:\braindata\experiment_data\jpg';
% 使用するデータセットのフォルダの名前
ExperimentFolder='exp-CWT-pack-color-gaus5-7x2'; % 要変更

% 学習回数
TimesTrainCNN = 200;
miniBatchSize = 16;

%% ネットワークの定義

layers=[
        imageInputLayer([4592 1750 3]); % RGB
        %imageInputLayer([643 246 3]); % RGB
        %imageInputLayer([726 277 3]); % RGB
        %imageInputLayer([781 298 3]); % RGB
        %imageInputLayer([460 175 1]); % グレー
        %imageInputLayer([643 246 1]); % グレー
        %imageInputLayer([726 277 1]); % グレー
        %imageInputLayer([781 298 1]); % グレー
        %imageInputLayer([275 311 3]);
        %imageInputLayer([919 350 3]);
        convolution2dLayer(3,20);
        %leakyReluLayer;
        reluLayer();
        maxPooling2dLayer(2,'Stride',2);
    
        convolution2dLayer(3,30);
        %leakyReluLayer;
        reluLayer();
        maxPooling2dLayer(2,'Stride',2);
    
        convolution2dLayer(3,20);
        %leakyReluLayer;
        reluLayer();
        maxPooling2dLayer(2,'Stride',2);
        
        fullyConnectedLayer(2);
        softmaxLayer();
        classificationLayer();
        ];

%% CNNの学習データの設定
for i=1:7 % 学習データ
%i=1;

% 学習データのパス
TrainDigitDatasetPath=fullfile(WholeDataSetPath,ExperimentFolder,...
    [num2str(i),'-',ExperimentFolder],'train');

%% CNNの学習データ読み込み

% パスの下にあるフォルダの中身をデータストアに登録
% フォルダの名前をラベルにして登録 
TrainDigitDataset = imageDatastore(TrainDigitDatasetPath,...
    'IncludeSubfolders',true,'LabelSource','foldernames');

% 各データストアの数を数える
TrainDigitDataset.countEachLabel 

% 一番少ないデータ数にそろえる
% 各データストアの小さい数字を示す
MinSetCountTrain=min(TrainDigitDataset.countEachLabel{:,2}) 

%% CNNの学習

% GPUの設定
gpuDevice(1);
% 学習の設定
options=trainingOptions('sgdm','MaxEpochs',TimesTrainCNN,...
    'InitialLearnRate',0.001,'MiniBatchSize',miniBatchSize);
% 乱数の種
rng(1);
% CNNの学習
CNNConvnet = trainNetwork(TrainDigitDataset,layers,options);

%% 特徴の可視化

% 畳み込み層

layers = [2 5 8]; % 可視化する層
channels = 1:20; % 表示する特徴の数

for layer=layers
    I=deepDreamImage(convnet,layer,channels,...
        'Verbose',false,'PyramidLevels',1);

    figure
    montage(I)
    name=convnet.Layers(layer).Name;
    title(['Layer ',name,' Features'])
end

% 全結合層

layer = 11;
channels = 1:2;
I = deepDreamImage(convnet,layer,channels,...
    'Verbose',false,'NumIterations',50);

figure
montage(I)
name = convnet.Layers(layer).Name;
title(['Layer ',name,' Features'])

%% CNNの評価データの設定

for j=1:7 % 評価データ
%j=1;
% 評価データのパス
TestDigitDatasetPath=fullfile(WholeDataSetPath,ExperimentFolder,...
    [num2str(j),'-',ExperimentFolder],'test');

%% CNNの評価データの読み込み

% パスの下にあるフォルダの中身をデータストアに登録
% フォルダの名前をラベルにして登録 
TestDigitDataset = imageDatastore(TestDigitDatasetPath,...
    'IncludeSubfolders',true,'LabelSource','foldernames');
% 各データストアの数を数える
TestDigitDataset.countEachLabel 
% 一番少ないデータ数にそろえる
% 各データストアの小さい数字を示す
MinSetCountTest=min(TestDigitDataset.countEachLabel{:,2}) 

%% CNNの評価

% 脳波データの予測
CNNPredictedLabels=classify(CNNConvnet,TestDigitDataset);
% 評価データのラベル
CNNTestLabels=TestDigitDataset.Labels;
% CNNの判別率
CNNAccuracy(i,j)=sum(CNNPredictedLabels == CNNTestLabels)/length(CNNTestLabels);
% CNNの判別率(calc)
CNNAccuracyCalc(i,j)=sum((CNNPredictedLabels == 'calc')&(CNNPredictedLabels == CNNTestLabels)) / sum(CNNTestLabels == 'calc');
% CNNの判別率(move)
CNNAccuracyMove(i,j)=sum((CNNPredictedLabels == 'move')&(CNNPredictedLabels == CNNTestLabels)) / sum(CNNTestLabels == 'move');

%disp(['CNN分類精度:' num2str(CNNAccuracy(i,j))]);
% 混合行列 縦軸:予測した値 横軸:ラベルの値
%CNNMatrix=confusionmat(CNNPredictedLabels,CNNTestLabels);

%% SVMの学習

featureLayer = 'fc';
% 全結合層までのCNN
SVMTrainFeatures = activations(CNNConvnet, TrainDigitDataset, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');
% 学習データのラベル
SVMTrainLabels = TrainDigitDataset.Labels;
% SVMの学習
SVMClassifier = fitcecoc(SVMTrainFeatures, SVMTrainLabels, ...
    'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'columns');

%% SVMの評価

% 全結合層までのCNN
SVMTestFeatures = activations(CNNConvnet, TestDigitDataset, featureLayer, 'MiniBatchSize',32);
% SVMでの予測
SVMPredictedLabels = predict(SVMClassifier, SVMTestFeatures);
% 評価データのラベル
SVMTestLabels = TestDigitDataset.Labels;

% SVMの判別率
SVMAccuracy(i,j)=sum(SVMPredictedLabels == SVMTestLabels)/length(SVMTestLabels);
% SVMの判別率(calc)
SVMAccuracyCalc(i,j)=sum((SVMPredictedLabels == 'calc')&(SVMPredictedLabels == SVMTestLabels)) / sum(SVMTestLabels == 'calc');
% SVMの判別率(move)
SVMAccuracyMove(i,j)=sum((SVMPredictedLabels == 'move')&(SVMPredictedLabels == SVMTestLabels)) / sum(SVMTestLabels == 'move');

%disp(['SVM分類精度:' num2str(SVMAccuracy(i,j))]);
% 混合行列 縦軸:予測した値 横軸:ラベルの値
%SVMMatrix=confusionmat(SVMPredictedLabels,SVMTestLabels) ;

end % j
%% 判別器の保存

save(fullfile(WholeDataSetPath,ExperimentFolder,...
    [num2str(i),'-',ExperimentFolder],[datestr(now,'yyyymmdd'),'-tr',num2str(TimesTrainCNN),'-CNN_',num2str(CNNAccuracy(i,i)),...
    '-SVM_',num2str(SVMAccuracy(i,i)),'.mat']),'CNNConvnet','SVMClassifier');

end % i
%% 判別結果を表示

TCNNA = array2table(CNNAccuracy,...
    'VariableNames',{'p1','p2','p3','p4','p5','p6','p7'},...
    'RowNames',{'l1','l2','l3','l4','l5','l6','l7'})

TCNNC = array2table(CNNAccuracyCalc,...
    'VariableNames',{'p1','p2','p3','p4','p5','p6','p7'},...
    'RowNames',{'l1','l2','l3','l4','l5','l6','l7'})

TCNNM = array2table(CNNAccuracyMove,...
    'VariableNames',{'p1','p2','p3','p4','p5','p6','p7'},...
    'RowNames',{'l1','l2','l3','l4','l5','l6','l7'})

TSVMA = array2table(SVMAccuracy,...
    'VariableNames',{'p1','p2','p3','p4','p5','p6','p7'},...
    'RowNames',{'l1','l2','l3','l4','l5','l6','l7'})

TSVMC = array2table(SVMAccuracyCalc,...
    'VariableNames',{'p1','p2','p3','p4','p5','p6','p7'},...
    'RowNames',{'l1','l2','l3','l4','l5','l6','l7'})

TSVMM = array2table(SVMAccuracyMove,...
    'VariableNames',{'p1','p2','p3','p4','p5','p6','p7'},...
    'RowNames',{'l1','l2','l3','l4','l5','l6','l7'})
%% 判別結果を保存

% 判別結果のためのフォルダを作る
mkdir(fullfile(WholeDataSetPath,ExperimentFolder,'result'))
mkdir(fullfile(WholeDataSetPath,ExperimentFolder,'result',datestr(now,'yy-mm-dd')))

% 判別結果を書き込む
writetable(TCNNA,...
    fullfile(WholeDataSetPath,ExperimentFolder,'result',datestr(now,'yy-mm-dd'),'CNNAccuracy.csv'),'WriteRowNames',true);
writetable(TCNNC,...
    fullfile(WholeDataSetPath,ExperimentFolder,'result',datestr(now,'yy-mm-dd'),'CNNAccuracyCalc.csv'),'WriteRowNames',true);
writetable(TCNNM,...
    fullfile(WholeDataSetPath,ExperimentFolder,'result',datestr(now,'yy-mm-dd'),'CNNAccuracyMove.csv'),'WriteRowNames',true);
writetable(TSVMA,...
    fullfile(WholeDataSetPath,ExperimentFolder,'result',datestr(now,'yy-mm-dd'),'SVMAccuracy.csv'),'WriteRowNames',true);
writetable(TSVMC,...
    fullfile(WholeDataSetPath,ExperimentFolder,'result',datestr(now,'yy-mm-dd'),'SVMAccuracyCalc.csv'),'WriteRowNames',true);
writetable(TSVMM,...
    fullfile(WholeDataSetPath,ExperimentFolder,'result',datestr(now,'yy-mm-dd'),'SVMAccuracyMove.csv'),'WriteRowNames',true);
