%%
% accCoef = accCoefLast;
% jerkCoef = jerkCoefLast;
% snapCoef = snapCoefLast;

accCoef = 25;
jerkCoef = 0.0090;
snapCoef = 2.415e-6 + 4.5094e-07;

% accCoef = 25;
% jerkCoef = 0;
% snapCoef = 0;



trajParameters.dis = 0.06;
trajParameters.vel = 0.4;
trajParameters.acc = 15; 
trajParameters.jerk = 1200;
trajParameters.snap = 200000;
global alpha;
alpha =  0.6;

sim('main',[0 0.22]);