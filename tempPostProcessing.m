error1 = Err.signals.values;
out1 = out.signals.values;
%%
error2 = Err.signals.values;
out2 = out.signals.values;
time = out.time;
%%
error3 = Err.signals.values;
out3 = out.signals.values;
%%
figure;
plot(time,1e6*error1);
hold on;
plot(time,1e6*error2);
%%
figure;
plot(time,1e6*out1);
hold on;
plot(time,1e6*out2);

%%
figure;
plot(time,1e6*error1);
hold on;
plot(time,1e6*error2);
plot(time,1e6*error3);
%%
figure;
plot(time * 1000,1e6*out1);
hold on;
plot(time * 1000,1e6*out2);
plot(time * 1000,1e6*out3);
xlim([0,20]);
%%
alpha1 = 0.1;
alpha2 = 0.56;
alpha3 = 0.81;
alpha4 = 0.95;
alpha5 = 0.95;
alpha6 = 0.95;
figure;
plot(0:5,[alpha1,alpha2,alpha3,alpha4,alpha5,alpha6])
%%
time = noise.time;
noiseValue = noise.signals.values;
figure;
plot(time,noiseValue,'linewidth',2);
ylabel('\mu m');
xlabel('Ê±¼ä (s)');
grid on;
set(gca,'fontsize',14);
%%
fn = 700;
zeta = 0.06
wn = fn * 2 * pi;
m1 = 5; m2 = 20;
k = wn * wn * m1 * m2 /(m1+m2);
c = 2*zeta*wn*m1 * m2 /(m1+m2);
tempG = tf(1,[c,k]);

Op=bodeoptions;
Op.FreqUnits='Hz';
Op.xlim={[1  500]};
Op.PhaseVisible = 'on';
Op.Grid='on';

figure;
bodeplot(tempG,Op);%%
%%
figure;
subplot(3,1,1);
plot(out.time * 1000,out.signals.values * 1e6,'linewidth',2);
hold on;
plot(out.time * 1000,30 * ones(size(out.time)),'linewidth',1);
xlabel('time (ms)');
ylabel('step response (\mum)');

subplot(3,1,2);
plot(Err.time * 1000,Err.signals.values * 1e6,'linewidth',2);
hold on;
plot(out.time * 1000,zeros(size(out.time)),'linewidth',1);

xlabel('time (ms)');
ylabel('error (\mum)');

subplot(3,1,3);
plot(nonlinearU.time * 1000,nonlinearU.signals.values * 1e6,'linewidth',2);
hold on;
plot(out.time * 1000,zeros(size(out.time)),'linewidth',1);

xlabel('time (ms)');
ylabel('u (\mum)');

%%
e1 = dErr.signals.values;
e2 = lpDe.signals.values;
e3 = filteredDerror.signals.values;
figure;pwelch([e1,e2,e3],1000,500,1000,5000);
%%
errorData =Err.signals.values;
errorData = nonlinearU.signals.values;
num = numel(errorData);
figure;
pwelch(errorData,floor(num),floor(num/8),floor(num),fs);



x = errorData;
Fs = fs;
N = length(x);
xdft = fft(x);
xdft = xdft(1:N/2+1);
psdx = (1/(Fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:Fs/length(x):Fs/2;
figure;
plot(freq,10*log10(psdx))
grid on
title('Periodogram Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')
%%
notchFilter = designfilt('bandstopiir', 'FilterOrder', 4, 'PassbandFrequency1', 500, 'PassbandFrequency2', 550, 'PassbandRipple', 1, 'StopbandAttenuation', 30, 'SampleRate', 5000);
% fvtool(notchFilter);
[b,a] = tf(notchFilter);
notchFilter = tf(b,a,Ts);
figure;bodeplot(notchFilter);
%%
errorData = Err.signals.values;
dErrorData = dErr.signals.values;
index = Err.time < 0.018;
figure;
scatter(errorData(index),dErrorData(index));
hold on;
index = Err.time > 0.018 & Err.time < 0.1;
scatter(errorData(index),dErrorData(index));
%%
errorData = Err.signals.values;
dErrorData = dErr.signals.values;
index = Err.time < 0.018;
figure;
plot(errorData(index).*dErrorData(index));
hold on;
index = Err.time > 0.018 & Err.time < 0.1;
plot(errorData(index).*dErrorData(index));