%% �J���}���t�B���^
% CSV�t�@�C���̔]�g�f�[�^��ǂݍ��݁C�J���}���t�B���^��������D

%% ������

clear,close all;

%% �ݒ� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%�T���v�����O���g��[Hz]
fs=256;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% �ǂݍ���

% �]�g�f�[�^�̓ǂݍ���
sig=csvread('E:\braindata\csvo\csvo3s\calc\W214\calc-W214-3sec-No10.csv'); % ���̓f�[�^�ǂݍ���
Z=sig(:,3); % ch��I��
len=length(Z); % �������Ƃ�

dt=1/fs;
t=0:dt:3-dt;

%% �t�B���^����
hX=zeros(len,1); % �X�V��̐���l
hXm=zeros(len,1); % �X�V�O�̐���l
P=zeros(len,1); % �X�V��̗\���덷���U
Pm=zeros(len,1); % �X�V�O�̗\���덷���U

Pm(1)=1;

% �����l�̌v�Z
Phi=1;
Q=1;
H=1;
R=1;

% �J���}���t�B���^����
for i=1:len

    % �J���}���Q�C���̍X�V
    K=Pm(i)*transpose(H)*inv(H*Pm(i)+R);
    
    % ����l�̍X�V
    hX(i)=hXm(i)+K*(Z(i)-H*hXm(i));
    
    % �덷���U�̌v�Z
    P(i)=(1-K*H)*Pm(i);
    
    % ����l�̌v�Z
    hX(i+1)=Phi*hX(i);
    Pm(i+1)=Phi*P(i)*transpose(Phi)+Q;
    
end

hX(len+1,:)=[];

%% �O���t

b=25; % �\����

figure;
subplot(3,1,1)
plot(t,Z,'b-');
title('raw')
xlabel('Time [sec]')
ylabel('EEG data [uV]')
ylim([mean(Z)-b mean(Z)+b]);

subplot(3,1,2)
plot(t,hX,'r-');
title('Kalman')
xlabel('Time [sec]')
ylabel('EEG data [uV]')
ylim([mean(hX)-b mean(hX)+b]);

subplot(3,1,3)
plot(t,Z,'b-',t,hX,'r-');
legend('raw','Kalman')
xlabel('Time [sec]')
ylabel('EEG data [uV]')
