x = randn(10000,1);

x1 = x(1:5000);
x2 = x(5001:end);
b = [2,3];
a = [1,0.2];
[y1,zf] = filter(b,a,x1);
[y3] = filterYao(b,a,x1);
y2 = filter(b,a,x2,zf);
y4 = filterYao(b,a,x2);
figure;plot([y2,y4]);