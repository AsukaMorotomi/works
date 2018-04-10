% �]�g����
% �t�[���G��͂ɂ�蓾��ꂽ�G�l���M�[�X�y�N�g�����x�𕪊����ɕ������������o
% ����ꂽ�����ʂ��g����SVM��p���Ĕ��ʂ��s��
% ����

%% �ݒ�

clear all;
close all;

% �ݒ� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%���g���т̕�����
devn=26;

%�T���v�����O���g��
fs = 256;
%fs=128;

%�f�[�^�̎���[sec]
%interval=input('�f�[�^�̕b��[s]�����\n');
interval=3;

%data�t�H���_���̖��O
folder_name='20170127';
    
%�����^���^�X�N
MT1='calc';
MT2='move';
    
%����ꏊ
%place='RB';
%place='SG';
%place='W214';
%place='W318';

%���̓f�[�^�̃p�X
%input_path=input('���̓f�[�^�̂���f�B���N�g���̃p�X�����\n','s');
%input_path=fullfile('C:\Users\robot\Desktop\data',folder_name,'FFT-mat');
input_path=fullfile('C:\Users\Asuka Morotomi\Documents\Afolder\data',folder_name,'FFT-mat');
                     
%��͂��s���f�[�^�̎n�߂̔ԍ������
%data_st=input('��͂��s���f�[�^�̎n�߂̔ԍ������\n');
data_st=1;
%��͂��s���f�[�^�̏I���̔ԍ������
%data_fn=input('��͂��s���f�[�^�̏I���̔ԍ������\n');
%data_fn=600;
data_fn=300;

%�w�K�Ɨ\��
%�@rem(y+a,6)==0�̎��@�\��
%�@rem(y+a,6)~=0�̎��@�w�K
a=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trx1=0;
trx2=0;
tex1=0;
tex2=0;
%% �w�K

for n_place=1:2 % ����ꏊ2���� ������end
%n_place=1;      % ����ꏊW214�݂̂̏ꍇ
%n_place=2;      % ����ꏊW318�݂̂̏ꍇ
    switch n_place
        case 1
            place='W214';
        case 2
            place='W318';
    end

    % MT1:calc�̊w�K�f�[�^����
    for i=data_st:data_fn
        if rem((i+a),6)~=0
            data = load(fullfile(input_path,MT1,place,[MT1,'-',place,'-',num2str(interval),'sec-No',num2str(i),'.mat']),'-mat');
            trx1=trx1+1;
            MT1_traindata(trx1,:)=[1 data.fft_mat];
        end
    end
    
        % MT2:move�̊w�K�f�[�^����
    for i=data_st:data_fn
        if rem((i+a),6)~=0
            data = load(fullfile(input_path,MT2,place,[MT2,'-',place,'-',num2str(interval),'sec-No',num2str(i),'.mat']),'-mat');
            trx2=trx2+1;
            MT2_traindata(trx2,:)=[2 data.fft_mat];
        end
    end
end % ����ꏊ2����

    model = svmtrain([MT1_traindata(:,1);MT2_traindata(:,1)],...
        [MT1_traindata(:,[2:devn*14+1]);MT2_traindata(:,[2:devn*14+1])],'-t 2 -b 1'); % �w�K
    
    
%% �\��
count_MT1=0;
count_MT2=0;

for n_place=1:2 % ����ꏊ2���� ������end
%n_place=1;      % ����ꏊW214�݂̂̏ꍇ
%n_place=2;      % ����ꏊW318�݂̂̏ꍇ
    switch n_place
        case 1
            place='W214';
        case 2
            place='W318';
    end

    % MT1:calc�̗\���f�[�^����
    for i=data_st:data_fn
        if rem((i+a),6)==0
            data = load(fullfile(input_path,MT1,place,[MT1,'-',place,'-',num2str(interval),'sec-No',num2str(i),'.mat']),'-mat');
            tex1=tex1+1;
            MT1_testdata(tex1,:)=[1 data.fft_mat];
        end
    end
    
    % MT2:move�̗\���f�[�^����
    for i=data_st:data_fn
        if rem((i+a),6)==0
            data = load(fullfile(input_path,MT2,place,[MT2,'-',place,'-',num2str(interval),'sec-No',num2str(i),'.mat']),'-mat');
            tex2=tex2+1;
            MT2_testdata(tex2,:)=[2 data.fft_mat];
        end
    end
end % ����ꏊ2����

    [predicted_label,accuracy,value] = svmpredict([MT1_testdata(:,1);MT2_testdata(:,1)],...
        [MT1_testdata(:,[2:devn*14+1]);MT2_testdata(:,[2:devn*14+1])],model,'-b 1')
    
    accuracy
    
    % MT1�̔��ʐ��x
    for i=1:tex1
        if predicted_label(i)==1
            count_MT1=count_MT1+1;
        end
    end
    accuracyMT1=count_MT1/tex1
    
    % MT2�̔��ʐ��x
    for i=tex1+1:tex1+tex2
        if predicted_label(i)==2
            count_MT2=count_MT2+1;
        end
    end
    accuracyMT2=count_MT2/tex2