function TraceOffline(handles)

global Trace Record

   
Fluo = Trace.Data.Fluo;
if isfield(Trace, 'Subgroup') && isfield(Trace.Subgroup, 'ID')
    ID = Trace.Subgroup.ID;
else
    ID = 1:length(Trace.Data.Fluo(1,:));
end

GoodInd = intersect(find(~isnan(Fluo(1,:))), find(~isnan(Fluo(2,:))));
GoodInd = intersect(GoodInd, ID);

Fluo = Fluo(:,GoodInd);
Record.Trace.FluoRaw = Fluo;
Bgrnd = zeros(size(Fluo));
if isfield(Trace.Data, 'Bgrnd')
    Bgrnd = Trace.Data.Bgrnd(:,GoodInd);
end

if isfield(Trace.Data, 'Tmean')
    Tmean = Trace.Data.Tmean(GoodInd)/60;
    if isfield(Trace.Data, 'Tstamp')
        Tstamp = Trace.Data.Tstamp(GoodInd)/60;
    else
        Tstamp = [];
    end
else
    T = Trace.Data.T(GoodInd)/60;
end
C_M = Trace.ROI.C_M(GoodInd,:);

StimFlag = 0;
Fluo = Fluo - Bgrnd;

% Ratio mode (previously called Dual mode) for cameleon
if ~isfield(Trace, 'Mode') || strcmp(Trace.Mode, 'Ratio') || strcmp(Trace.Mode, 'Dual')
    Bleed = Trace.Param.Bleed;
    Switch = Trace.Param.Switch;
    Ind1 = Switch+1;
    Ind2 = 2-Switch;

    Fluo(Ind1,:) = Fluo(Ind1,:) - Bleed/100*Fluo(Ind2,:);
    F = Fluo(Ind1,:)./Fluo(Ind2,:);
% Difference mode (previously called Single mode) for GCamp
elseif strcmp(Trace.Mode, 'Difference') || strcmp(Trace.Mode, 'Single')
    Ind1 = 1;
    Ind2 = 2;
    F = Fluo(Ind1,:);%-Fluo(Ind2,:);
end

Mov = [0; abs(diff(sqrt(C_M(:,1).^2 + C_M(:,2).^2)))];
MovX = [0; abs(diff(C_M(:,1)))];
MovY = [0; abs(diff(C_M(:,2)))];
dMovX = [0; abs(diff(C_M(:,1)))];
% GdMovX = GaussianSmooth(dMovX,MotionSigma);
if StimFlag
    [StimStart StimEnd NoStimInd] = GetStimInds(Fluo(2,:));
else
    NoStimInd = 1:length(GoodInd);
end

if isfield(Trace.Data, 'Tmean')
    Tmean = Tmean(NoStimInd);
    if isfield(Trace.Data, 'Tstamp')
        Tstamp = Tstamp(NoStimInd);
    else 
        Tstamp = [];
    end
else
    T = T(NoStimInd);
end
if isfield(Trace.Data, 'Tmean')
    Record.Trace.Tmean = Tmean;
    Record.Trace.Tstamp = Tstamp;
    TimeTypes = get(handles.popupmenu_TimeType, 'String');
    TimeType = TimeTypes{get(handles.popupmenu_TimeType, 'Value')};
    if strcmp(TimeType, 'Stamp')
        Record.Trace.T = Tstamp;
    else
        Record.Trace.T = Tmean;
    end
else
    Record.Trace.T = T;
end
T = Record.Trace.T;

Y = (Fluo(Ind1,NoStimInd) - min(Fluo(Ind1,NoStimInd))) / (max(Fluo(Ind1,NoStimInd)) - min(Fluo(Ind1,NoStimInd)));
C = (Fluo(Ind2,NoStimInd) - min(Fluo(Ind2,NoStimInd))) / (max(Fluo(Ind2,NoStimInd)) - min(Fluo(Ind2,NoStimInd))) - 1;
R = (F(NoStimInd)-min(F(NoStimInd)))/min(F(NoStimInd))*100;
F0 = mean(F(NoStimInd(T<=3)));
R0 = (F(NoStimInd)-F0)/F0*100;

M = (Mov(NoStimInd) - min(Mov(NoStimInd))) / (max(Mov(NoStimInd)) - min(Mov(NoStimInd)));
Mx = MovX(NoStimInd);
Mx = (Mx - min(Mx)) / (max(Mx) - min(Mx));
My = MovY(NoStimInd);
My = (My - min(My)) / (max(My) - min(My));
% dMx = GdMovX(NoStimInd);
% dMx = (dMx - min(dMx)) / (max(dMx) - min(dMx));
% MSpikes = GetSpikes( dMx , [1 (2/1000)/55 5 5 ([0.5 0]/1000)/55 1 1] );
C_M = C_M(NoStimInd,:);

Record.Trace.Fluo = Fluo;
Record.Trace.R0 = R0;
Record.Trace.R = R;
Record.Trace.F = F;
Record.Trace.BL = [];
Record.Trace.Y = Y;
Record.Trace.C = C;
Record.Trace.BG = Bgrnd;
Record.Trace.M = [Mx'; My'; M'];
Record.Trace.C_M = C_M';
% Record.Trace.Vabs = dMx';

Record.Axis.Lim0 = [Record.Trace.T(1) Record.Trace.T(end) min(R) max(R)];
Record.Axis.Lim = Record.Axis.Lim0;


