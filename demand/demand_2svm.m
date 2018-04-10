%%% ���ʊ�̍쐬
% �w�K�f�[�^���画�ʊ���쐬
% �]���f�[�^�𔻕ʊ�ɂ������ϔ��ʗ������߂�
% ����ꂽ���ʊ��ۑ�

% statistics and Machine Learning Toolbox ���K�v
%% ������

clear all;
close all;

%% �����ݒ�
% �v���O�����̂���p�X
%DPath='/Users/asuka/Program/Brain_Wave/watanabe_EEG';
%DPath='C:\Users\robot\Documents\MATLAB\morotomi\demand\Brain_Wave\watanabe_EEG';
%DPath='C:\Users\juyo\Documents\MATLAB\Brain_Wave-master\watanabe_EEG_2';
DPath='C:\Users\juyo\Documents\morotomi\Brain_Wave\EEG\watanabe_EEG_2';

% �^�X�N ���v�ύX
Form=cellstr(['heijo';'gu   ';'choki';'pa   ';]); % i

% �f�[�^�̊��蓖��
Ldata=[1200;400;400;400];
Pdata=[100;100;100;100];

%Ldata=[90;30;30;30];
%Pdata=[30;10;10;10];

% �����̎�
seed=10;
rng(seed);

%% �g�p����f�[�^�̕���

L1Feat=[];
L1Label=[]; 
L2Feat=[];
L2Label=[]; 
PFeat=[];
PLabel=[];

% ������L1Feat�̍s��
L1Row=0; 
% ������L1Feat�̍s��
L2Row=0; 
% ������PFeat�̍s��
PRow=0; 

% �e��̌`�̃��[�v form
for i=1:4
    disp(['�w�K�f�[�^�F',char(Form(i))])
    % �ݒ�
        % ��̌`�̃t�H���_�[�̒��g���m�F
        FolderInfo=dir(fullfile(DPath,'feature',char(Form(i)),'*.csv'));
        FLen=length(FolderInfo);
    
        % ��x�����f�[�^���g�p���Ȃ��悤�Ƀt���O�e�[�u�����쐬
        FlagTable=zeros(FLen); 
    
    % �w�K�f�[�^
    
        % �w�K�f�[�^Ldata���̃��[�v
        count=0;
        while count < Ldata(i)
    
            % �����Ŋw�K�Ɏg���]�g�f�[�^��I��
            p=randi(FLen);
        
            % ��x�����f�[�^���g�p���Ȃ��悤�Ƀt���O���m�F
            if (FlagTable(p)~=0)
                continue; 
            end
        
            % ���v�Ȃ�΁C���̊w�K�f�[�^��ǂݍ���
            data=csvread(fullfile(DPath,'feature',char(Form(i)),FolderInfo(p).name));
        
            % �t���O�C���݂̑I�𐔂��X�V
            FlagTable(p)=FlagTable(p)+1;
            count=count+1;
            
            % �s�����X�V
            L1Row=L1Row+1;
            % �f�[�^�\LDataTable�ɕt��������
            LDataTable{L1Row,1}=FolderInfo(p).name;
            
            %���펞�̏���
            if i==1
                % ���ʊ�1�p
                % ������L1Feat�C���x��L1Lavel�ɕt��������   
                L1Feat(L1Row,:)=data;
                L1Label(L1Row,1)=0; 
            
                % ���ʊ�2�ɂ͎g�p���Ȃ�
            
            
            %����񂯂񎞂̏���
            else
                
                % ���ʊ�1�p
                % ������L1Feat�C���x��L1Lavel�ɕt��������   
                L1Feat(L1Row,:)=data;
                L1Label(L1Row,1)=1; 
            
                % ���ʊ�2�p
                % �s�����X�V
                L2Row=L2Row+1;
                % ������L2Feat�C���x��L2Lavel�ɕt��������   
                L2Feat(L2Row,:)=data;
                L2Label(L2Row,1)=i-1; % MATLAB�̔z��1����n�܂�
                
            end    
        end % �w�K�f�[�^ count
   

   % �]���f�[�^
   
   disp(['�]���f�[�^�F',char(Form(i))])
        % �]���f�[�^Pdata���̃��[�v
        count=0;
        while count < Pdata(i)
    
            % �����ŕ]���Ɏg���]�g�f�[�^��I��
            p=randi(FLen);
        
            % ��x�����f�[�^���g�p���Ȃ��悤�Ƀt���O���m�F
            if (FlagTable(p)~=0)
                continue; 
            end
        
            % ���v�Ȃ�΁C���̕]���f�[�^��ǂݍ���
            data=csvread(fullfile(DPath,'feature',char(Form(i)),FolderInfo(p).name));
        
            % �t���O�C�s���C���݂̑I�𐔂��X�V
            FlagTable(p)=FlagTable(p)+1;
            PRow=PRow+1;
            count=count+1;
        
            % ������PFeat�C���x��PLavel�C�f�[�^�\PDataTable�ɕt��������
            PFeat(PRow,:)=data;
            PLabel(PRow,1)=i-1; % MATLAB�̔z��1����n�܂�
            PDataTable{PRow,1}=FolderInfo(p).name;
    
        end % �]���f�[�^ count
end % i
%% �w�K
disp('�w�K')
% ���ʊ�̊w�K
model1=fitcecoc(L1Feat,L1Label);
model2=fitcecoc(L2Feat,L2Label);

%% �]��
% �]��(�\��)
Predict_sub=predict(model1,PFeat);
% ���ʌ���
PLabel_sub=double(PLabel > 0);
C = confusionmat(PLabel_sub,Predict_sub)
accuracy1=sum(PLabel_sub == Predict_sub)/numel(PLabel_sub);
disp(['���ʗ�:',num2str(accuracy1*100),'%'])

% �]��(�\��)
for j=1:PRow % �]���f�[�^�����[�v
    [Predict1,sc1]=predict(model1,PFeat(j,:)); % ���ʊ�1
    
    % ���펞�̏ꍇ
    if Predict1==0
        Predict(j,1)=Predict1;
        score1(j,:)=sc1;
        score2(j,:)=[0,0,0];
    % ����񂯂񎞂̏ꍇ
    else
        [Predict2,sc2]=predict(model2,PFeat(j,:)); % ���ʊ�2
        
        Predict(j,1)=Predict2;
        score1(j,:)=sc1;
        score2(j,:)=sc2;
    end 
end


% ���ʌ���
C = confusionmat(PLabel,Predict)
accuracy2=sum(PLabel == Predict)/numel(PLabel);
disp(['���ʗ�:',num2str(accuracy2*100),'%'])
disp('�@')
disp('���x���ƐM���x')
disp('       ����   �\���@�@��1:����@ ��1:�����  ��2:�O�[�@��2:�`���L�@��2:�p�[')
disp([PLabel,Predict,score1,score2])

%% �ۑ�

mkdir(fullfile(DPath,'model'));
save(fullfile(DPath,'model',[datestr(now,'yy-mm-dd-HH-MM'),'acc',num2str(accuracy2),'.mat']),...
    'model1','model2','L1Feat','L2Feat','L1Label','L2Label','PFeat','PLabel','LDataTable','PDataTable');