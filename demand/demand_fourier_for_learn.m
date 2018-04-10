%�w�K�f�[�^�p
%Polymate mini�ŕۑ����ꂽcsv�t�@�C����ǂݍ���
%�o���h�p�X�t�B���^��K�p�C�ۑ�(filtered_data)�D
%�t�[���G��́C�����ʂ̌`�ɕό`���ۑ�(feature)�D

%% �ݒ� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % �t�H���_�ݒ�
    % analysis�t�H���_�̃p�X
    %dataset_path='C:\Users\robot\Documents\MATLAB\morotomi\demand\Brain_Wave\watanabe_EEG';
    %dataset_path='C:\Users\juyo\Documents\morotomi\Brain_Wave\EEG\watanabe_EEG_2';
    dataset_path='/Users/asuka/Program/demand/Brain_Wave/EEG/watanabe_EEG_2';

    % ���ʂ��邶��񂯂�̌`
    form=cellstr(['heijo';'gu   ';'choki';'pa   ';]); % i

    % FFT�p�����[�^
    % �T���v�����O���g��
    fs = 500;
    % �g�p����ŏ����g��
    fmin = 4; 
    % �g�p����ő���g��
    fmax = 30; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
    % feature�t�H���_�̍쐬
    if exist(fullfile(dataset_path,'feature'))==0
        mkdir(fullfile(dataset_path,'feature'));
    end
    
    % filtered_data_div�t�H���_�̍쐬
    if exist(fullfile(dataset_path,'filtered_data'))==0
        mkdir(fullfile(dataset_path,'filtered_data'));
    end
    
    % FFT�̎��ԍ���
    dt=1/fs;
    
    % �o�^�[���[�X�t�B���^�݌v
    [B1,A1] = butter(4,[fmin/(fs/2) fmax/(fs/2)]);

    % ����񂯂�S��ނ̃��[�v
    for i=1:4 % form

        % feature�̂���񂯂�̌`�̏o�̓t�H���_�̍쐬
        if exist(fullfile(dataset_path,'feature',char(form(i))))==0
            mkdir(fullfile(dataset_path,'feature',char(form(i))));
        end
        
        % filtered_data_div�̂���񂯂�̌`�̏o�̓t�H���_�̍쐬
        if exist(fullfile(dataset_path,'filtered_data',char(form(i))))==0
            mkdir(fullfile(dataset_path,'filtered_data',char(form(i))));
        end
        
        % ���̓t�H���_�̒��g�̓ǂݍ���
        FolderInfo=dir(fullfile(dataset_path,'raw_data_div',char(form(i)),'*.csv')); % j

        % ���̓t�H���_�̒��g�̐����m�F
        % ���g�̐������[�v����
        for j=1:length(FolderInfo) % FolderInfo
            % �t�@�C���ǂݍ���
            sig=csvread(fullfile(dataset_path,'raw_data_div',char(form(i)),FolderInfo(j).name),1,0);
            % 4ch���̔]�g�f�[�^�̓ǂݍ���
            % 1�s�̃I�t�Z�b�g
            
            % (�o�^�[���[�X)�o���h�p�X�t�B���^�̓K�p
            % ���̍s���R�����g�A�E�g����Ɛ��f�[�^ 
            %%{
            sig = filter(B1, A1, sig);
            
            % �t�@�C�����𕪊�
            feat_name=strsplit(FolderInfo(j).name,'raw'); 
            % �ۑ�
            csvwrite(fullfile(dataset_path,'filtered_data',char(form(i)),['filter',char(feat_name(2))]),sig);
            %}
%% �t�[���G���
            % �t�@�C������feat��������
            feat=[];
            for ch=1:4 % �]�g�f�[�^4ch��
                raw_eeg=sig(:,ch);% ���n��]�g�f�[�^�ǂݍ���
                % ���ςO�̃f�[�^����͂Ƃ��� �����̉��̍s��%�����琶�f�[�^
                raw_eeg=raw_eeg-mean(raw_eeg); 
    
                len=length(raw_eeg); % �f�[�^�_��
                st=round(fmin*len/fs)+1; % fft�Ńv���b�g���n�߂�_
                fn=round(fmax*len/fs)+1; % fft�Ńv���b�g���I���_

                freq=(0:len-1)*fs/len; % ���g���̃f�[�^�͈�
                fft_eeg=fft(raw_eeg,len); % �����t�[���G�ϊ�
                %���𕡑f���������ă��[�g���Ƃ��ăp���[�X�y�N�g���ɕϊ�
                freq_eeg=sqrt(fft_eeg.*conj(fft_eeg)/len); 
    
                freq=freq(st:fn); % ���o
                freq_eeg=freq_eeg(st:fn); % ���o

                % �O���t�\���@
                %{ 
                %���̏�̍s��%��2�ɂ���ƃO���t��\��
                fig=figure;
                plot(freq,freq_eeg)
    
                xlabel('Frequency [Hz]');
                ylabel('Power Spectrum ');
                title(['ch:',num2str(ch)]);
                xlim([0 30]); % �\�����g���̈�̎w��
                %}
        
                % ����ꂽ�����ʂ���ɂ܂Ƃ߂�
                feat=[feat;freq_eeg];
            end
            feat=transpose(feat);
            % �t�@�C�����𕪊�
            feat_name=strsplit(FolderInfo(j).name,'raw');
            % �ۑ�
            csvwrite(fullfile(dataset_path,'feature',char(form(i)),['feature',char(feat_name(2))]),feat);
        end
    end
