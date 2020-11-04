function SF_AnalyzeBaseLine

global Record Params

N = numel(Params.Events.Names);
for i=1:N
    eval(sprintf('%s = %s;', Params.Events.Names{i}, Params.Events.Values{i}));
end

window = 100;

P = 30; % percentile
a = 1; % derivative stds 

% IndIn = Record.Events.IndIn;
% EventInd = Record.Events.EventInd(:,IndIn);
EventInd = Record.Events.EventInd;
% NumEvents = length(IndIn);
NumEvents = length(EventInd);

R = Record.Trace.R;
T = Record.Trace.T;
if NumFrames>1
    R = GaussianSmooth(R,NumFrames)';
end

dRdT = [0 diff(R)./diff(T)];
STD = std(dRdT(~isnan(dRdT)));
Thresh = DerivThreshold*STD;

SubThreshInd = find(dRdT<Thresh);


figure(1)
clf
plot(T,R)
hold on

for i = 1:NumEvents-1
    ind = EventInd(2,i):EventInd(1,i+1);
    BLstart = ind(find(dRdT(ind)<-Thresh,1,'last'));
    BLind = BLstart:EventInd(1,i+1);
    plot(T(BLind),R(BLind),'r.')
end


% StartID = 1;
% StartID = find(T>10,1,'first');
% EndID = length(R);
% 
% detR = detrend(R(StartID:EndID));
% Ind = intersect(find(dRdT<a*STD), find(detR<prctile(detR, P))+StartID-1);
% 
% figure(1)
% clf
% plot(T,R)
% hold on
% plot(T(Ind), R(Ind), 'r.')