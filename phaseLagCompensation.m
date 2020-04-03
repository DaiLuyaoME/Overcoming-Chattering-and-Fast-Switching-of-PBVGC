f1 = 1;
f2 = 100;
w1 = f1 * 2 * pi;
w2 = f2 * 2 * pi;
w = logspace(log10(w1),log10(w2),1000);
%%
[mag,phase,wout] = bode(lpFilter,w);
phase = squeeze(phase);
figure;plot(phase);
timeDelay = phase * pi / 180 ./wout;
figure;semilogx(wout/2/pi,timeDelay);
% disp(mean(timeDelay)/Ts);
%%
timeLeadSamples = abs(mean(timeDelay)/Ts);
z = tf('z',Ts);
timeLeadTf = 1 + timeLeadSamples * (1-z^-1);
% timeLeadTf = 1 + timeLeadSamples * (1-z^-1) + 0.5 * timeLeadSamples * (timeLeadSamples + 1) * (1 - z^-1)^2;
%%
figure;
h = bodeplot(lpFilter,lpFilter*timeLeadTf);
p = getoptions(h); 
p.PhaseMatching = 'on'; 
p.PhaseMatchingFreq = 1; 
p.PhaseMatchingValue = 0;
setoptions(h,p);
%%
highpassFilter = designfilt('highpassiir', 'StopbandFrequency', 400, 'PassbandFrequency', 500, 'StopbandAttenuation', 60, 'PassbandRipple', 1, 'SampleRate', 5000);
highpassFilter = designfilt('highpassiir', 'FilterOrder', 4, 'PassbandFrequency', 500, 'PassbandRipple', 1, 'SampleRate', 5000);
fvtool(highpassFilter);
SOS = highpassFilter.Coefficients;
[b,a] = sos2tf(SOS);
[b,a] = tf(highpassFilter);
figure;bodeplot(tf(b,a,Ts));
%%
delayCoef = ceil(timeLeadSamples) - timeLeadSamples;
