function FindSpikes(Type)

global Record Params IDs Experiment File

R = Record.Trace.R;
Y = Record.Trace.Y;
C = Record.Trace.C;

eval(sprintf('N = numel(Params.%s.Names);', Type));
for i=1:N
    eval(sprintf('VarName = Params.%s.Names{i};', Type));
    eval(sprintf('VarValue = str2num(Params.%s.Values{i});', Type));
    eval(sprintf('%s = %g;', VarName, VarValue));
end

GRatio = GaussianSmooth(R,RatioSigma);
Frames1 = GetSpikes( GRatio , [1 (2/1000)/55 5 5 ([0.5 0]/1000)/55 1 1] )';

% reverse traces for end of spike
% -------------------------------
% IndRV = length(R):-1:1;
% RRV = R(IndRV);
% GRRV = GaussianSmooth(RRV,RatioSigma);
% FramesRV = GetSpikes( GRRV , [1 (2/1000)/55 5 5 ([0.5 0]/1000)/55 1 1] );
% FramesRV(:,1) = IndRV(FramesRV(:,1));
% FramesRV(:,2) = IndRV(FramesRV(:,2));
% FramesRV = FramesRV(size(FramesRV,1):-1:1,:);

% check that YFP and CFP peaks are of opposite signs
% --------------------------------------------------
% YCMinMag = YCThreshold*std(diff(Y))*std(diff(C)); % minimum absolute value of the product of YFP * CFP amplitudes
YCMinMag = YCThreshold*std(Y)*std(C); % minimum absolute value of the product of YFP * CFP amplitudes
YAmps = Y(Frames1(2,:)) - Y(Frames1(1,:));
CAmps = C(Frames1(2,:)) - C(Frames1(1,:));
YCSymID = find((YAmps.*CAmps) < -YCMinMag);
% YAmpsRV = Y(FramesRV(:,2)) - Y(FramesRV(:,1));
% CAmpsRV = C(FramesRV(:,2)) - C(FramesRV(:,1));
% YCSymIDRV = find((YAmpsRV.*CAmpsRV) < -YCMinMag);
% beginning of trace may be distorted due to blurring, so cut that part off
% -------------------------------------------------------------------------
% InLiersID = find(Frames1(:,1)>(2*RatioSigma));
% spike amplitudes larger than 'noise'
% ------------------------------------
RAmps = R(Frames1(2,:)) - R(Frames1(1,:));
% RMagID = find(RAmps > NoiseThreshold*std(diff(R)));
RMagID = find(RAmps > (NoiseThreshold*std(R)));
% RAmpsRV = R(FramesRV(:,2)) - R(FramesRV(:,1));
% RMagIDRV = find(RAmpsRV > NoiseThreshold*std(R));
% combine all criteria
% --------------------
SpikeIDs = intersect(YCSymID, RMagID);
% SpikeIDs = intersect(InLiersID, SpikeIDs);
% SpikeIDsRV = intersect(YCSymIDRV, RMagIDRV);

Frames1 = Frames1(:,SpikeIDs);
% FramesRV = FramesRV(SpikeIDsRV,:);


% figure
% plot(R, 'k')
% hold on
% plot(Frames1(:,1),R(Frames1(:,1)), '*r')
% plot(FramesRV(:,1), R(FramesRV(:,1)), '*g')



% % eliminate end points that precede the first start point
% FramesRV = FramesRV(FramesRV<=Frames1(1,1));
% % eliminate start points that succeed the last end point
% Frames1 = Frames1(Frames1(:,1)>=FramesRV(end),:);
% % keep end points that immediately precede start points
% N0 = size(Frames1, 1);
% j = 0;
% for i=2:N0
%     ind0_next = Frames1(i,1);
%     j = j+1;
%     k = 0;
%     indf = FramesRV(j);
%     while indf < ind0_next 
%         k = k+1;
%         [i j k]
%         indf = FramesRV(j+k);
%     end
%     Keepf(i-1) = FramesRV(j+k-1);
%     j = j+k-1;
% end


% plot(Frames1(:,1),R(Frames1(:,1)), 'or')
% plot(Keepf, R(Keepf), 'og')

eval(sprintf('Record.%s.EventInd = Frames1;', Type));
eval(sprintf('Record.%s.IndIn = 1:length(SpikeIDs);', Type));
eval(sprintf('Record.%s.IndOut = [];', Type));
eval(sprintf('Record.%s.NumIndIn = size(Record.%s.EventInd,2);',Type, Type));

Group = Experiment.Groups(IDs.Group).Group;
Group.Records(IDs.Record).Record = Record;
Experiment.Groups(IDs.Group).Group = Group;
save([File.Exp.Path, File.Exp.Name], '-struct', 'Experiment');
