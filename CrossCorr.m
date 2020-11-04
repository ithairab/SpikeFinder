function [Tlag CC P] = CrossCorr(t1, y1, t2, y2, lagt)

dT1 = mean(diff(t1));
dT2 = mean(diff(t2));
dT = min([dT1 dT2]);

maxStrt = max([t1(1), t2(1)]);
minEnd = min([t1(end), t2(end)]);

T = maxStrt+dT:dT:minEnd-dT;
N = length(T);
Y1 = interp1(t1, y1, T);
Y2 = interp1(t2, y2, T);

lagind = round(lagt/dT);
CC = zeros(1, 2*lagind+1); % cross-correlations
P = ones(1, 2*lagind+1); % p-values
Tlag = (-lagind:lagind)*dT;

% Y2 positive lag after Y1 (delayed effect of Y1 on Y2)
ind = 1:N-lagind;
for i=0:lagind
    [CC(lagind+1+i) P(lagind+1+i)] = corr(Y1(ind)', Y2(ind+i)');
end
% Y2 negative lag after Y1 (delayed effect of Y2 on Y1)
for i=-lagind:-1
    [CC(lagind+1+i) P(lagind+1+i)] = corr(Y2(ind)', Y1(ind-i)');
end

% correlation coefficient between y1 and y2 at lag with maximum correlation
% zerolagID = lagind+1;
% [mxcorr mxlagID] = max(CC);
% lagID = mxlagID - zerolagID;
% if lagID>=0
%     RR = corrcoef(Y1(1:N-lagID), Y2(1+lagID:N));
% else
%     RR = corrcoef(Y2(1:N+lagID), Y1(1-lagID:N));
% end
% R = RR(1,2);

