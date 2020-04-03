function y = filtfiltYao(dataFilter,data)
% [b,a] = tf(dataFilter);
% tempLength = max(length(a),length(b))-1;
% z0 = (1:tempLength) / tempLength * data(1);
% temp = filter(b,a,data);
% temp = temp(end:-1:1);
% z0 = (1:tempLength) / tempLength  * temp(1);
% temp = filter(b,a,temp);
% y = temp(end:-1:1);
% % figure;
% % plot([errorData,temp]);
[b,a] = tf(dataFilter);
    if isrow(data) && ~(numel(size(data))>2)
        xCol = data.';
    else
        xCol = data;
    end
[Npts,Nchans] = size(xCol);
[b2,a2,zi,nfact,L] = getCoeffsAndInitialConditions(b,a,Npts);
yCol = ffOneChanCat(b2,a2,xCol,zi,nfact,L);
y = yCol;
end

function [b1,a1,zi,nfact,L] = getCoeffsAndInitialConditions(b,a,Npts)
b1 = b(:);
a1 = a(:);
nb = numel(b);
na = numel(a);
nfilt = max(nb,na);
nfact = max(1,3*(nfilt-1));  % length of edge transients
L = 1;
% input data too short
coder.internal.errorIf(Npts <= nfact(1,1),'signal:filtfilt:InvalidDimensionsDataShortForFiltOrder', nfact(1,1));

% Zero pad shorter coefficient vector as needed
if nb < nfilt
    b1 = [b1; zeros(nfilt-nb,1)];
elseif na < nfilt
    a1 = [a1; zeros(nfilt-na,1)];
end

% Compute initial conditions to remove DC offset at beginning and end of
% filtered sequence.  Use sparse matrix to solve linear system for initial
% conditions zi, which is the vector of states for the filter b(z)/a(z) in
% the state-space formulation of the filter.
if nfilt>1
    rows = [1:nfilt-1, 2:nfilt-1, 1:nfilt-2];
    cols = [ones(1,nfilt-1), 2:nfilt-1, 2:nfilt-1];
    vals = [1+a1(2,1), a1(3:nfilt,1).', ones(1,nfilt-2), -ones(1,nfilt-2)];
    rhs  = b1(2:nfilt,1) - b1(1,1)*a1(2:nfilt,1);
    zi   = sparse(rows,cols,vals) \ rhs;
    % The non-sparse solution to zi may be computed using:
    %      zi = ( eye(nfilt-1) - [-a(2:nfilt), [eye(nfilt-2); ...
    %                                           zeros(1,nfilt-2)]] ) \ ...
    %          ( b(2:nfilt) - b(1)*a(2:nfilt) );
else
    zi = zeros(0,1);
end
end


function yout = ffOneChanCat(b,a,y,zi,nfact,L)

coder.varsize('yout');
yout = y;
for ii=1:L
    % Single channel, data explicitly concatenated into one vector
    ytemp = [2*yout(1,1)-yout(nfact(1,1)+1:-1:2,1); yout(:,1); 2*yout(end,1)-yout(end-1:-1:end-nfact(1,1),1)];
    
    % filter, reverse data, filter again, and reverse data again
    ytemp = filter(b(:,ii),a(:,ii),ytemp(:,1),zi(:,ii)*ytemp(1,1));
    ytemp = ytemp(end:-1:1,1);
    ytemp = filter(b(:,ii),a(:,ii),ytemp(:,1),zi(:,ii)*ytemp(1,1));
    
    % retain reversed central section of y
    yout = ytemp(end-nfact(1,1):-1:nfact(1,1)+1,1);
end

end