outBuffer = [outBuffer,out.signals.values];
%%
num = size(outBuffer,1);
tempTime = ((1:num) - 1) * 1/5000;
figure;
plot(tempTime * 1000,outBuffer(:,1:3) * 1e6);
%%
figure;
plot(out.time,out.signals.values * 1e6,'linewidth',2);
hold on;
plot(out.time,ones(size(out.time)) * 30);
ylabel('step response (\mum)');
xlabel('time (s)');
set(gca,'fontsize',16);
%%
temp = filtfiltYao(errorFilter,Err.signals.values);
figure;
plot(Err.time,[Err.signals.values,temp]);
%%
temp = Err.signals.values * 1e6;
temp = temp(1:end);
[b,a] = tf(errorFilter);
zi = [0.1,0.3];
temp1 = filter(b,a,temp,zi);
temp2 = filterYao(b,a,temp);
figure;
plot([temp1,temp2]);
