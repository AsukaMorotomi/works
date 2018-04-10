% �݌v�����o���h�p�X�t�B���^�����킩�m�F����v���O����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% �p�����[�^�ݒ�
filtDim = 4;
fmin = 4;
fmax = 30;
fs = 500;

%% �t�B���^�[�̐ݒ�
[B,A] = butter(filtDim,[fmin/(fs/2) fmax/(fs/2)]); % �o���h�p�X�t�B���^
%[B,A] = butter(filtDim,fmax/(fs/2)); % ���[�p�X�t�B���^

f1=figure
freqz(B,A)

%% �t�B���^�[�̓K�p
sig=csvread('/Users/asuka/Program/demand/Brain_Wave/EEG/watanabe_EEG_2/raw_data_div/gu/raw_gu_001_1_0.csv',1,0);

sigf = filter(B, A, sig);

t=1:256;

f2=figure;

for i=1:4
    subplot(2,2,i)
    plot(t,sig(:,i),t,sigf(:,i))
    legend('�t�B���^����','�t�B���^�L��')
    ylim([-150 150])
    title([num2str(i),'ch'])
end
