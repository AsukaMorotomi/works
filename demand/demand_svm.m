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
DPath='C:\Users\juyo\Documents\morotomi\Brain_Wave\EEG\watanabe_EEG_2';

% �^�X�N ���v�ύX
Form=cellstr(['heijo';'gu   ';'choki';'pa   ';]); % i

% �f�[�^�̊��蓖��
Ldata=400;
Pdata=100;

% �����̎�
rng(10);

%% �g�p����f�[�^�̕���

LFeat=[];
LLabel=[]; 
DataTable=[];

% ������LFeat�̍s��
LRow=0; 
% ������PFeat�̍s��
PRow=0; 

% �e��̌`�̃��[�v form
for i=1:4
    % �ݒ�
        % ��̌`�̃t�H���_�[�̒��g���m�F
        FolderInfo=dir(fullfile(DPath,'feature',char(Form(i)),'*.csv'));
        FLen=length(FolderInfo);
    
        % ��x�����f�[�^���g�p���Ȃ��悤�Ƀt���O�e�[�u�����쐬
        FlagTable=zeros(FLen); 
    
    % �w�K�f�[�^
    
        % �w�K�f�[�^Ldata���̃��[�v
        count=0;
        while count < Ldata
    
            % �����Ŋw�K�Ɏg���]�g�f�[�^��I��
            p=randi(FLen);
        
            % ��x�����f�[�^���g�p���Ȃ��悤�Ƀt���O���m�F
            if (FlagTable(p)~=0)
                continue; 
            end
        
            % ���v�Ȃ�΁C���̊w�K�f�[�^��ǂݍ���
            data=csvread(fullfile(DPath,'feature',char(Form(i)),FolderInfo(p).name));
        
            % �t���O�C�s���C���݂̑I�𐔂��X�V
            FlagTable(p)=FlagTable(p)+1;
            LRow=LRow+1;
            count=count+1;
        
            % ������LFeat�C���x��LLavel�C�f�[�^�\LDataTable�ɕt��������
            LFeat(LRow,:)=data;
            LLabel(LRow,1)=i-1; % MATLAB�̔z��1����n�܂�
            LDataTable{LRow,1}=FolderInfo(p).name;
    
        end % �w�K�f�[�^ count
   

   % �]���f�[�^
   
        % �]���f�[�^Pdata���̃��[�v
        count=0;
        while count < Pdata
    
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
% ���ʊ�̊w�K
model=fitcecoc(LFeat,LLabel);

%% �]��
% �]��(�\��)
Predict=predict(model,PFeat);

% ���ʌ���
C = confusionmat(PLabel,Predict)
accuracy=sum(PLabel == Predict)/numel(PLabel);
disp(['���ʗ�:',num2str(accuracy*100),'%'])

%% �ۑ�

mkdir(fullfile(DPath,'model'));
save(fullfile(DPath,'model',[datestr(now,'yy-mm-dd-HH-MM'),'acc',num2str(accuracy),'.mat']),...
    'model','LFeat','LLabel','PFeat','PLabel','LDataTable','PDataTable');