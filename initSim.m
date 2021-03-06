%% model parameters
modelTypeName = {'rigidBody','doubleMassNonColocated','doubleMassColocated'};
modelInfo.mass = [5,20];
modelInfo.fr = 700;
modelInfo.dampRatio = 0.03;
modelInfo.type = modelTypeName{2};
fs = 5000;
Ts = 1/fs;
Gp = createPlantModel(modelInfo);

%% delay factor
delayCount = 1.3;
s = tf('s');
delayModel = exp(-delayCount*Ts*s);
delayModel = pade(delayModel,2);

%% generate plant model with delay
GpWithDelay = Gp * delayModel;
GpDis = c2d(GpWithDelay,Ts,'zoh');


%% ideal feedforward coefficients 
m = modelInfo.mass;
% idealAccCoef = sum(m);
% idealJerkCoef = sum(m) * tau;
% idealSnapCoef = sum(m) * ( 1/wn.^2 + 0.5 * tau.^2);
%%
sigma = 20;%噪声的标准差，单位N
varNoise=sigma*sigma;%注意，白噪声的模块中的Noise Power 需要填成varNoise*Ts
noisePower=varNoise*Ts;
%%
fn = 100;
wn = fn * 2 * pi;
lpFilter = tf(wn*wn,[1,2*0.7*wn,wn*wn]);
% figure;bodeplot(lpFilter);
lpFilter = c2d(lpFilter,1/5000,'tustin');
%%
global currentErrorState;
currentErrorState = ErrorStates.PositiveErrorDown;
global delta;
delta = 0e-6;
global currentMin;
global currentMax;
currentMin = 1e12;
currentMax = -1e12;
global alpha;
alpha = 1;
global alphaCount;
alphaCount = 0;
global alphaBuffer;
% alphaBuffer = [0.1,0.2,0.3,0.462117, 0.761594, 0.905148, 0.964028, 0.986614, 0.995055];
alphaBuffer = [0.1,0.1,0.1,0.2,0.2,0.2,0.3,0.3,0.3,0.4,0.4,0.4,0.5,0.5,0.5,0.6,0.6,0.6];
global deDeltaUpperBound;
deDeltaUpperBound = 1e-3;
global deDeltaLowerBound;
deDeltaLowerBound = 1e-5;


dwellTime = 5;
num = 5;
alphaBuffer = [];
for i = 1:num
    temp = 1 / num * i * ones(dwellTime,1);
    alphaBuffer = [alphaBuffer;temp];
    
end
figure;plot(alphaBuffer);
%%
% alphaBuffer = [0., 0.462117, 0.761594, 0.905148, 0.964028, 0.964028, 0.964028, 0.986614,0.986614,0.986614, 0.995055 , 0.995055, 0.995055, 0.999, 0.999, 0.999];
% % alphaBuffer = alphaBuffer(end:-1:1);
% figure;plot(alphaBuffer);

%%
global alpha1;
global alpha2;
alpha1 = 0.2;
alpha2 = 0.6;
tau = tan(pi / 2 * (alpha2 - alpha1) / (alpha2 + alpha1) );
beta = 1;
global f;
f = @(x) (alpha1 + alpha2) / pi * atan(x-tau) + (alpha2 - alpha1) * 0.5;
figure;
x = linspace(-50,50,10000);
plot(x,f(x));
grid on;
%%

global errorBuffer
errorBuffer = zeros(30,1);
global errorFilter;
errorFilter = designfilt('lowpassiir', 'FilterOrder', 2, 'PassbandFrequency', 50, 'PassbandRipple', 0.1, 'SampleRate', 5000);
%%
filter2 = designfilt('lowpassiir', 'FilterOrder', 2, 'PassbandFrequency', 50, 'PassbandRipple', 0.1, 'SampleRate', 5000);
filter4 = designfilt('lowpassiir', 'FilterOrder', 4, 'PassbandFrequency', 50, 'PassbandRipple', 0.1, 'SampleRate', 5000);
fvtool(filter2,filter4);