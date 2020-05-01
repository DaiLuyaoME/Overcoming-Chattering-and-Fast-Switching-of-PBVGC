fileID = fopen('coefData.txt','w');
[B,A] = tf(errorFilter);
controllerOrder = max(5,numel(A)) + 1;
A = [A,zeros(1,controllerOrder-numel(A))]; 
B = [B,zeros(1,controllerOrder-numel(B))]; 


fprintf(fileID,'{ %.12f, ',A(1));
for i = 2: (numel(A)-1)
    fprintf(fileID,'%.12f, ',A(i));
end
fprintf(fileID,'%.12f }\n',A(end));

fprintf(fileID,'{ %.12f, ',B(1));
for i = 2: (numel(B)-1)
    fprintf(fileID,'%.12f, ',B(i));
end
fprintf(fileID,'%.12f }',B(end));
fclose(fileID);