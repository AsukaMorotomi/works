%�f�[�^��ǂݍ��݃t�[���G��͂��{��mat�`���ŕۑ�

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
%MT='calc';
MT='move';
    
%����ꏊ
%place='RB';
%place='SG';
%place='W214';
place='W318';

%���g�����̐ݒ�
fmin = 4; % �O���t�ɕ\������ŏ����g��
fmax = 30; % �O���t�ɕ\������ő���g��
%�G�l���M�[���x�X�y�N�g�����̐ݒ�
emin = 0; % �G�l���M�[���x�X�y�N�g�����̍ŏ��l
emax = 15; % �G�l���M�[���x�X�y�N�g�����̍ő�l

%���̓f�[�^�̃p�X
%input_path=input('���̓f�[�^�̂���f�B���N�g���̃p�X�����\n','s');
%input_path=fullfile('C:\Users\robot\Desktop\data',folder_name,['csvo',num2str(interval),'s'],MT,place);
input_path=fullfile('C:\Users\Asuka Morotomi\Documents\Afolder\data',folder_name,['csvo',num2str(interval),'s'],MT,place);


%FFT�O���t�̃p�X
%output_path=input('FFT�O���t��ۑ�����f�B���N�g���̃p�X�����\n','s');
graph_path=fullfile('C:\Users\Asuka Morotomi\Documents\Afolder\data',folder_name,'FFT-graph',MT,place);

%�o�̓f�[�^�̃p�X
%output_path=input('mat�f�[�^��ۑ�����f�B���N�g���̃p�X�����\n','s');
output_path=fullfile('C:\Users\Asuka Morotomi\Documents\Afolder\data',folder_name,'FFT-mat',MT,place);

%��͂��s���f�[�^�̎n�߂̔ԍ������
%anly_st=input('��͂��s���f�[�^�̎n�߂̔ԍ������\n');
ftanly_st=1;
%��͂��s���f�[�^�̏I���̔ԍ������
%anly_fn=input('��͂��s���f�[�^�̏I���̔ԍ������\n');
ftanly_fn=821;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dt=1/fs; % �T���v�����Ƃ̑�������

ftanly=1;
for ftanly=ftanly_st:ftanly_fn

    sig=csvread(fullfile(input_path,[MT,'-',place,'-',num2str(interval),'sec-No',num2str(ftanly),'.csv'])); % ���̓f�[�^�ǂݍ���
    %graphfile=[MT,'-',place,'-',num2str(interval),'sec-No',num2str(ftanly)]; % FFT�O���t���܂Ƃ߂�t�H���_�̖��O
    %mkdir(fullfile(graph_path,graphfile)); % �o�̓f�[�^���܂Ƃ߂�t�H���_�����
    mat_n=1; %�����ʂ�1�s�̃x�N�g���ɂ��邽��

    for x=3:16  % FT���{���s
        ch=brainwave_num2str(x); % ch�̖��O���擾

        anly_data=sig(:,x); 
        anly_data=anly_data-mean(anly_data); %���ςO�̃f�[�^����͂Ƃ��� �����̍s��%�����琶�f�[�^
        m=length(anly_data);

        y=fft(anly_data,m); %�����t�[���G�ϊ�
        
        st=round(fmin*m/fs); % fft�Ńv���b�g���n�߂�_
        fn=round(fmax*m/fs); % fft�Ńv���b�g���I���_
        
        f=(0:m-1)*fs/m; % ���g���̃f�[�^�͈́@fs=m*(fs/m)

        power=y.*conj(y)/m; % fft�̉��ɋ��𕡑f����������

        f=f(st:fn); % ���o
        power=power(st:fn); % ���o

        power=power/mean(power); % 0.5�`30[Hz]�̃p���[�X�y�N�g���̕��ςŐ��K��
        
%          % FFT�̃O���t��ۑ�����

%         %fig=figure; % �O���t��\��    
%         fig=figure('visible','off'); % �O���t��\�����Ȃ�
%         p=plot(f,power) %���g���̈�̔]�g�f�[�^�̕\��
%         xlabel('\fontsize{16}Frequency [Hz]');
%         ylabel('\fontsize{16}Energy Spectral Density');
%        % title(['ch:',ch]); % �^�C�g��
%         set(p,'LineWidth',3)
%         xlim([0 30]); % �\�����g���̈�̎w��
%         ylim([emin emax]); % �\���G�l���M�[���x�X�y�N�g���̈�̎w��
%         saveas(fig,fullfile(graph_path,graphfile,[MT,'-',place,'-',num2str(interval),'sec-No',num2str(ftanly),'-ch',num2str(x),'.jpg']),'jpeg')
%         close hidden all;
%         clear fig;
%         
        %devn�̃p�����[�^�����
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
            fft_mat(mat_n)=sum_p/n_p; %1�s�ɓ����ʂ��܂Ƃ߂�D
            mat_n=mat_n+1;
            sum_p=0;
            n_p=0;
        end        
    end

    save(fullfile(output_path,[MT,'-',place,'-',num2str(interval),'sec-No',num2str(ftanly)]),'fft_mat'); % �ۑ�
end