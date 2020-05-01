%%
errorData = Err.signals.values;
clear errorDataFiltered;
num = numel(errorData);
for i = 181:num
    filteredError = filtfiltYao(errorFilter,errorData(i-30 : i));
    errorDataFiltered(i-180) = filteredError(end);
end
% tempFiltered = filter(errorFilter,errorData);
temp = [errorData(181:num),errorDataFiltered'];
figure;
plot(temp);
%%
moment1 = ( temp(1:end-1,1) .* diff(temp(:,1)) ) > 0;
moment2 = ( temp(1:end-1,2) .* diff(temp(:,2)) ) > 0;
figure;plot(moment1);
hold on;
plot(moment2);
%%
