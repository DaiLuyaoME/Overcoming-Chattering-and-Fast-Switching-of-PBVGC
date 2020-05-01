function y = filterYao(b,a,data)

inBuffer = zeros(size(b));
outBuffer = zeros(size(a));
num = numel(data);
y = zeros(size(data));
n = max(numel(a),numel(b));
z = zeros(n,1);
% z = [0,0.1,0.3];
zi = zeros(n-1,1);
%zi = [0.1,0.3];

%% type 1



% for i = 1:num
%    x = data(i);
%    temp = 0;
%    inBuffer(1) = x;
%    for j = 1:numel(b)
%       temp = temp + b(j) * inBuffer(j); 
%    end
%    inBuffer = circshift(inBuffer,1);
%    for j = 2:numel(a)
%       temp = -1*a(j)*outBuffer(j) + temp; 
%    end
%     outBuffer(1) = temp;
%     outBuffer = circshift(outBuffer,1);
%     y(i) = temp;
% end

%% type 2

% for i = 1:num
%     temp = data(i);
%    for j = 2:numel(a)
%        temp = temp  - a(j)*z(j);
%    end
%     
%    z(1) = temp;
% 
%    for j = 1:numel(b)
%       y(i) =  y(i) + b(j) * z(j);
%    end
%           z = circshift(z,1);
%     
%     
% end
%% type 2 transpose
for i = 1:num
    y(i) = b(1) * data(i) + zi(1);
    for j = 1:numel(zi)-1
       zi(j) = -a(j+1) * y(i) + b(j+1) * data(i) + zi(j+1); 
        
    end
    zi(end) = -a(end) * y(i) + b(end) * data(i);
    
end


end
