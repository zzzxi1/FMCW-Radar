clear all; clc; close all;
%% Capon不同的快拍数下的效果
%{
    Capon同DBF都属于波束形成的算法，共同点是都需要构造一个导向矢量，不同点是Capon
    使用的能量估计式为1/（a'*inv(R)*a），而DBF是直接将导向矢量和回波信号相乘。
    按理论来说Capon需要多快拍支持，但是20快拍和100快拍相差不大？不过快拍数继续减少影响就很大了。
    SNR确实对Capon的影响很大，低SNR下效果可能会不太理想，就像这里没法分出两个目标。
%}
%构造阵列
array    = linspace(0,11,12); % 阵元
arraylen = length(array); % 阵元数量
dd       = 0.5; % 间距

%构造目标
theta      = [0 2]; % 两个目标对应的方向角
SNR        = 35;
numstarget = length(theta);

%构造回波信号   两个不同的快拍数
snap1    = 20;
snap2    = 100;
S1       = rand(numstarget,snap1)+1;
signal1  = exp(1i*2*pi*dd*sind(theta).'*array);  signal1 = signal1.'*S1;  signal1 = awgn(signal1,SNR); % 生成快拍数为20时所有阵元的接收信号
S2       = rand(numstarget,snap2)+1;
signal2  = exp(1i*2*pi*dd*sind(theta).'*array);  signal2 = signal2.'*S2;  signal2 = awgn(signal2,SNR); % 生成快拍数为100时所有阵元的接收信号


%分别使用capon测角
theta_scan = linspace(-90,90,1024);
R1 = inv(signal1*signal1'./snap1);   % 信号的协方差阵，快拍数20
R2 = inv(signal2*signal2'./snap2);   % 信号的协方差阵，快拍数100
aa = exp(1i*2*pi*dd*array'*sind(theta_scan));
for ii = 1:length(theta_scan)
    caponresult1(ii) = 1/(abs(aa(:, ii)'*R1*aa(:, ii)));
    caponresult2(ii) = 1/(abs(aa(:, ii)'*R2*aa(:, ii)));
end
caponresult1 = 20*log10(caponresult1./max(caponresult1));
caponresult2 = 20*log10(caponresult2./max(caponresult2));

figure(1);
plot(theta_scan,caponresult1,'k');hold on;plot(theta_scan,caponresult2,'r');hold on;
plot([theta(1),theta(1)],ylim,'m-.');plot([theta(2),theta(2)],ylim,'m-.');
title(['不同快拍数下的Capon与DBF测角仿真结果对比', 'SNR = ',num2str(SNR)]);
xlabel('角度/°');ylabel('幅度/dB');grid on; hold off;
legend('快拍数为20的Capon测角结果','快拍数为100的Capon测角结果','角度真值1','角度真值2');


