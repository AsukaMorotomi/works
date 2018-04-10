% �E�F�[�u���b�g��͂ɂ��]�g�f�[�^�̉摜���i14ch�j
% csvo?s�t�H���_����f�[�^��ǂݍ��݁CCWT�t�H���_�̒��Ƀt�H���_����肻�̒���14���̃f�[�^��ۑ�
% ����

%% �ݒ� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�T���v�����O���g��
fs = 256;
%fs=128;

%�f�[�^�̎���[sec]
interval=3;

%data�t�H���_���̖��O
%folder_name='20170127';
    
%�����^���^�X�N
MT=cellstr(['calc';'move']); % i
%MT='calc';
%MT='move';
    
%����ꏊ
place=cellstr(['W318 ';'W214 ';'SG   ';'RB   ';'W214n']); % j
%place='RB';
%place='SG';
%place='W214';
%place='W318';
%place='W214n';

%�}�U�[�E�F�[�u���b�g
waven = 'gaus5'; % �K�E�V�A���E�F�[�u���b�g�֐�
%waven = 'haar'; % �n�[���E�F�[�u���b�g�֐�
%waven = 'gaus1'; % ���L�V�J���n�b�g�E�F�[�u���b�g�֐�

%���g�����̐ݒ�
fmin = 4; % �O���t�ɕ\������ŏ����g��
fmax = 30; % �O���t�ɕ\������ő���g��
%�F���̐ݒ�
cmin = -10; % �F���̍ŏ��l
cmax = 10; % �F���̍ő�l
%�F�̐ݒ�
color='color';
%color='gray';

%���̓f�[�^�̃p�X
%input_path=input('���̓f�[�^�̂���f�B���N�g���̃p�X�����\n','s');
%input_path=fullfile('C:\Users\Asuka Morotomi\Documents\Afolder\data',folder_name,['csvo',num2str(interval),'s'],MT,place);
%input_path=fullfile('C:\Users\robot\Documents\Afolder\data',folder_name,['csvo',num2str(interval),'s'],MT,place);
input_path=fullfile('E:\braindata',['csvo',num2str(interval),'s']);

%�o�̓f�[�^�̃p�X
%output_path=input('CWT�̉摜�f�[�^��ۑ�����f�B���N�g���̃p�X�����\n','s');
%output_path=fullfile('C:\Users\Asuka Morotomi\Documents\Afolder\data',folder_name,'CWT-separate',['CWT-',color],MT,place);
%output_path=fullfile('C:\Users\robot\Documents\Afolder\data',folder_name,'CWT-separate',['CWT-',color],MT,place);
output_path=fullfile('E:\braindata','CWT-separate',['CWT-separate-',color,'-',waven]);
%output_path=fullfile('C:\Users\robot\Desktop',['CWT-separate-',color,'-',waven]);
%�o�̓f�[�^�̃t�H���_�쐬
mkdir(output_path);

% ����
dt = 1/fs;
scalef = 1:1:fs; % �X�P�[���t�@�N�^
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:2 % MT
    %i=1;
%�o�̓t�H���_���쐬    
mkdir(fullfile(output_path,char(MT(i))));

for j=1:5 % place
    %j=1;
%�o�̓t�H���_���쐬
mkdir(fullfile(output_path,char(MT(i)),char(place(j))));

%��͂��s���f�[�^�̎n�߂̔ԍ������
anly_st=1;
%��͂��s���f�[�^�̏I���̔ԍ������
%anly_fn=1;
anly_fn=length(ls(fullfile(input_path,char(MT(i)),char(place(j)))))-2;


for anly=anly_st:anly_fn % �f�[�^��

    % ���t�@�C���̓ǂݍ���
    sig=csvread(fullfile(input_path,char(MT(i)),char(place(j)),[char(MT(i)),'-',char(place(j)),'-',...
        num2str(interval),'sec-No',num2str(anly),'.csv'])); % ���̓f�[�^�ǂݍ���
    % �f�[�^��
    [m,n]=size(sig);
    % ���n��f�[�^
    t= 0:dt:dt*(m-1);
    % �o�̓f�[�^���܂Ƃ߂�t�H���_�̖��O
    outputfile=[char(MT(i)),'-',char(place(j)),'-',num2str(interval),'sec-No',num2str(anly)];
    % �o�̓f�[�^���܂Ƃ߂�t�H���_�����
    mkdir(fullfile(output_path,char(MT(i)),char(place(j)),outputfile));
    
    for x=3:16  % WT���{���s �]�g�`���l��
        %ch=brainwave_num2str(x); % ch�̖��O���擾
        %�A���E�F�[�u���b�g�ϊ�
        [cfs,f] = cwt(sig(:,x),scalef,waven,dt); 
    
        % �E�F�[�u���b�g�W���̓��
        %args = {t,f,abs(cfs).^2}; 
        % �E�F�[�u���b�g�W���̎��R�ΐ�
        args = {t,f,log(abs(cfs))}; 
        % ��ʕ\�����Ȃ�
        figure('visible','off');
        % surf�O���t
        fig=surf(args{:},'edgecolor','none');
        % �^�ォ�猩��
        view(0,90);

        %axis tight; % ���l����
        axis off;    % ���l�Ȃ�
        shading interp; % �V�F�[�f�B���O�^�C�v interp
        colormap(parula(128)); % �J���[�}�b�v parula 128�F���g�p
        %colormap(gray(128)); % �J���[�}�b�v gray 128�F���g�p
        %h = colorbar; % �F���L
        %h.Label.String = 'ln(abs(coefficient))'; % �F�����x���@
        %xlabel('Time'); ylabel('Hz'); % x��y�����x��
        %title(['ch:',ch,' mw:',waven]); % �^�C�g��
        ylim([fmin fmax]); % �\�����g���̈�̎w��
        %xlim([5 30]); %�@�\�����ԗ̈�̎w��
        caxis([cmin,cmax]); % �F���̍ŏ��l�C�ő�l

        ax = gca;
        ax.Position= [0 0 1 1];%�]���𖳂�������

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