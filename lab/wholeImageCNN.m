% CNN���g�����]�g����
% 1�̊w�K�f�[�^�ɑ΂��ĕ����̕]���f�[�^���g�p����B
% 1��̎��s�ŕ����̊w�K�f�[�^���񂷁B
% 

%% ������

clear,close all;

%% �f�[�^�̏���

% �f�[�^�Z�b�g�̃p�X
WholeDataSetPath='E:\braindata\experiment_data\jpg';
% �g�p����f�[�^�Z�b�g�̃t�H���_�̖��O
ExperimentFolder='exp-CWT-pack-color-gaus5-7x2'; % �v�ύX

% �w�K��
TimesTrainCNN = 200;
miniBatchSize = 16;

%% �l�b�g���[�N�̒�`

layers=[
        imageInputLayer([4592 1750 3]); % RGB
        %imageInputLayer([643 246 3]); % RGB
        %imageInputLayer([726 277 3]); % RGB
        %imageInputLayer([781 298 3]); % RGB
        %imageInputLayer([460 175 1]); % �O���[
        %imageInputLayer([643 246 1]); % �O���[
        %imageInputLayer([726 277 1]); % �O���[
        %imageInputLayer([781 298 1]); % �O���[
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

%% CNN�̊w�K�f�[�^�̐ݒ�
for i=1:7 % �w�K�f�[�^
%i=1;

% �w�K�f�[�^�̃p�X
TrainDigitDatasetPath=fullfile(WholeDataSetPath,ExperimentFolder,...
    [num2str(i),'-',ExperimentFolder],'train');

%% CNN�̊w�K�f�[�^�ǂݍ���

% �p�X�̉��ɂ���t�H���_�̒��g���f�[�^�X�g�A�ɓo�^
% �t�H���_�̖��O�����x���ɂ��ēo�^ 
TrainDigitDataset = imageDatastore(TrainDigitDatasetPath,...
    'IncludeSubfolders',true,'LabelSource','foldernames');

% �e�f�[�^�X�g�A�̐��𐔂���
TrainDigitDataset.countEachLabel 

% ��ԏ��Ȃ��f�[�^���ɂ��낦��
% �e�f�[�^�X�g�A�̏���������������
MinSetCountTrain=min(TrainDigitDataset.countEachLabel{:,2}) 

%% CNN�̊w�K

% GPU�̐ݒ�
gpuDevice(1);
% �w�K�̐ݒ�
options=trainingOptions('sgdm','MaxEpochs',TimesTrainCNN,...
    'InitialLearnRate',0.001,'MiniBatchSize',miniBatchSize);
% �����̎�
rng(1);
% CNN�̊w�K
CNNConvnet = trainNetwork(TrainDigitDataset,layers,options);

%% �����̉���

% ��ݍ��ݑw

layers = [2 5 8]; % ��������w
channels = 1:20; % �\����������̐�

for layer=layers
    I=deepDreamImage(convnet,layer,channels,...
        'Verbose',false,'PyramidLevels',1);

    figure
    montage(I)
    name=convnet.Layers(layer).Name;
    title(['Layer ',name,' Features'])
end

% �S�����w

layer = 11;
channels = 1:2;
I = deepDreamImage(convnet,layer,channels,...
    'Verbose',false,'NumIterations',50);

figure
montage(I)
name = convnet.Layers(layer).Name;
title(['Layer ',name,' Features'])

%% CNN�̕]���f�[�^�̐ݒ�

for j=1:7 % �]���f�[�^
%j=1;
% �]���f�[�^�̃p�X
TestDigitDatasetPath=fullfile(WholeDataSetPath,ExperimentFolder,...
    [num2str(j),'-',ExperimentFolder],'test');

%% CNN�̕]���f�[�^�̓ǂݍ���

% �p�X�̉��ɂ���t�H���_�̒��g���f�[�^�X�g�A�ɓo�^
% �t�H���_�̖��O�����x���ɂ��ēo�^ 
TestDigitDataset = imageDatastore(TestDigitDatasetPath,...
    'IncludeSubfolders',true,'LabelSource','foldernames');
% �e�f�[�^�X�g�A�̐��𐔂���
TestDigitDataset.countEachLabel 
% ��ԏ��Ȃ��f�[�^���ɂ��낦��
% �e�f�[�^�X�g�A�̏���������������
MinSetCountTest=min(TestDigitDataset.countEachLabel{:,2}) 

%% CNN�̕]��

% �]�g�f�[�^�̗\��
CNNPredictedLabels=classify(CNNConvnet,TestDigitDataset);
% �]���f�[�^�̃��x��
CNNTestLabels=TestDigitDataset.Labels;
% CNN�̔��ʗ�
CNNAccuracy(i,j)=sum(CNNPredictedLabels == CNNTestLabels)/length(CNNTestLabels);
% CNN�̔��ʗ�(calc)
CNNAccuracyCalc(i,j)=sum((CNNPredictedLabels == 'calc')&(CNNPredictedLabels == CNNTestLabels)) / sum(CNNTestLabels == 'calc');
% CNN�̔��ʗ�(move)
CNNAccuracyMove(i,j)=sum((CNNPredictedLabels == 'move')&(CNNPredictedLabels == CNNTestLabels)) / sum(CNNTestLabels == 'move');

%disp(['CNN���ސ��x:' num2str(CNNAccuracy(i,j))]);
% �����s�� �c��:�\�������l ����:���x���̒l
%CNNMatrix=confusionmat(CNNPredictedLabels,CNNTestLabels);

%% SVM�̊w�K

featureLayer = 'fc';
% �S�����w�܂ł�CNN
SVMTrainFeatures = activations(CNNConvnet, TrainDigitDataset, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');
% �w�K�f�[�^�̃��x��
SVMTrainLabels = TrainDigitDataset.Labels;
% SVM�̊w�K
SVMClassifier = fitcecoc(SVMTrainFeatures, SVMTrainLabels, ...
    'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'columns');

%% SVM�̕]��

% �S�����w�܂ł�CNN
SVMTestFeatures = activations(CNNConvnet, TestDigitDataset, featureLayer, 'MiniBatchSize',32);
% SVM�ł̗\��
SVMPredictedLabels = predict(SVMClassifier, SVMTestFeatures);
% �]���f�[�^�̃��x��
SVMTestLabels = TestDigitDataset.Labels;

% SVM�̔��ʗ�
SVMAccuracy(i,j)=sum(SVMPredictedLabels == SVMTestLabels)/length(SVMTestLabels);
% SVM�̔��ʗ�(calc)
SVMAccuracyCalc(i,j)=sum((SVMPredictedLabels == 'calc')&(SVMPredictedLabels == SVMTestLabels)) / sum(SVMTestLabels == 'calc');
% SVM�̔��ʗ�(move)
SVMAccuracyMove(i,j)=sum((SVMPredictedLabels == 'move')&(SVMPredictedLabels == SVMTestLabels)) / sum(SVMTestLabels == 'move');

%disp(['SVM���ސ��x:' num2str(SVMAccuracy(i,j))]);
% �����s�� �c��:�\�������l ����:���x���̒l
%SVMMatrix=confusionmat(SVMPredictedLabels,SVMTestLabels) ;

end % j
%% ���ʊ�̕ۑ�

save(fullfile(WholeDataSetPath,ExperimentFolder,...
    [num2str(i),'-',ExperimentFolder],[datestr(now,'yyyymmdd'),'-tr',num2str(TimesTrainCNN),'-CNN_',num2str(CNNAccuracy(i,i)),...
    '-SVM_',num2str(SVMAccuracy(i,i)),'.mat']),'CNNConvnet','SVMClassifier');

end % i
%% ���ʌ��ʂ�\��

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
%% ���ʌ��ʂ�ۑ�

% ���ʌ��ʂ̂��߂̃t�H���_�����
mkdir(fullfile(WholeDataSetPath,ExperimentFolder,'result'))
mkdir(fullfile(WholeDataSetPath,ExperimentFolder,'result',datestr(now,'yy-mm-dd')))

% ���ʌ��ʂ���������
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
