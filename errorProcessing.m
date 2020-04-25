global errorFilter;
errorData = Err.signals.values;
errorFilter = designfilt('lowpassiir', 'FilterOrder', 2, 'PassbandFrequency', 50, 'PassbandRipple', 1, 'SampleRate', 5000);
filteredError = filtfilt(errorFilter,errorData);
figure;
plot([errorData,filteredError]);
%%
fn = 50;
wn = 2 * pi * 50;
zeta = 0.7;
lp = tf(wn*wn,[1,2*wn*zeta,wn*wn]);
figure;bodeplot(lp);
lpDis = c2d(lp,1/5000,'tustin');
[b,a] = tfdata(lpDis,'v');
%%
tempError = errorData(80:180);
tempErrorFiltered = filtfilt(errorFilter,tempError);
figure;
plot([tempError,tempErrorFiltered]);
%%
x = alphaCount.signals.values;
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
ylabel('Power/Frequency (dB/Hz)');
%%
errorData = Err.signals.values;
errorBuffer = zeros(30,1);
errorDataFiltered = zeros(size(errorData));
num = numel(errorData);
for i = 1:num
    errorBuffer = circshift(errorBuffer,-1);
    errorBuffer(end) = errorData(i);
%     filteredError = filtfilt(errorFilter,errorBuffer);
    filteredError = filtfiltYao(errorFilter,errorBuffer);
    errorDataFiltered(i) = filteredError(end);
%     errorBuffer(end) = filteredError(end);
    
end
figure;
plot([errorData,errorDataFiltered]);
%%
temp = filtfilt(errorFilter,errorData);
figure;
plot([errorData,temp]);
%%
temp = filter(errorFilter,errorData);
temp = temp(end:-1:1);
temp = filter(errorFilter,temp);
temp = temp(end:-1:1);
figure;
plot([errorData,temp]);
%%
temp = filtfiltYao(errorFilter,errorData(1:180));
[b,a] = tf(errorFilter);
temp2 = filtfilt(b,a,errorData(1:180));
figure;
plot([errorData(1:180),temp,temp2]);
%%
temp = filtfiltYao(errorFilter,errorData(1:180));
figure;
plot([errorData(1:180),temp]);