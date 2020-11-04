function SF_PlotTriggered(EventType, ArgStr, Param)

global Experiment IDs Plots

prewindow = str2num(char(Param{1}));
postwindow = str2num(char(Param{2}));

TraceName = ArgStr{1};
UnitName = ArgStr{2};

% NumRand = 100; % number of false random starting points per spike

Group = Experiment.Groups(IDs.Group).Group;
min_FrameRate = -1;
NumEvents = 0;
for r = 1:Group.NumRecs
    Record = Group.Records(r).Record;
    if isfield(Record.Params, 'FPS')
        FrameRate = Record.Params.FPS;
    else
        FrameRate = Record.Params.FMS;
    end
    if FrameRate<min_FrameRate || min_FrameRate<0
        min_FrameRate = FrameRate;
    end
    if IDs.Summary.Summation == 2 % event-based summation
        NumIndIn = length(Record.Events.Analyzed.StrtInd);
        NumEvents = NumEvents + NumIndIn;
    end
end

% interpolate all traces to trace with lowest FrameRate (so that to use as
% much recorded information as possible
min_preind = round(prewindow*60*min_FrameRate);
min_postind = round(postwindow*60*min_FrameRate);
min_indw = -min_preind:min_postind;
min_t = min_indw/FrameRate;

if IDs.Summary.Summation == 2 % event-based summation
    Heap = zeros(NumEvents, length(min_indw));
    RandHeap = zeros(NumEvents, length(min_indw));
else % record-based summation
    Heap = zeros(Group.NumRecs, length(min_indw));
    RandHeap = zeros(Group.NumRecs, length(min_indw));
end

% randomly triggered segments are also computed to identify significance
% RandHeap = zeros(NumRand*Group.NumRecs, 1);
Ev2ID = 0;
RcID = 0;
% J = 0;
for r = 1:Group.NumRecs
    RcID=RcID+1;
    Record = Group.Records(r).Record;
    Record.Events.Analyzed.TriggeredPeak = NaN;
    NumIndIn = length(Record.Events.Analyzed.StrtInd);
    if strcmp('R0', TraceName)
        Data = Record.Trace.R0;% - Record.Trace.BL;
    elseif strcmp('R', TraceName)
        Data = Record.Trace.R;
    elseif strcmp('F', TraceName)
        Data = Record.Trace.F;
    elseif strcmp('M1', TraceName)
        Data = Record.Trace.M(1,:);
    elseif strcmp('C_M1', TraceName)
        Data = Record.Trace.C_M(1,:);
    elseif strcmp('C_M2', TraceName)
        Data = Record.Trace.C_M(2,:);
    elseif strcmp('R2', TraceName)
        Record2 = Experiment.Groups(3-IDs.Group).Group.Records(r).Record;
        Data = Record2.Trace.R0;% - Record2.Trace.BL;
    elseif strcmp('M2', TraceName)
        Record2 = Experiment.Groups(3-IDs.Group).Group.Records(r).Record;
        Data = Record2.Trace.M(1,:);
    end
    T = Record.Trace.T;
    if isfield(Record.Params, 'FPS')
        FrameRate = Record.Params.FPS;
    else
        FrameRate = Record.Params.FMS;
    end
    preind = round(prewindow*60*FrameRate);
    postind = round(postwindow*60*FrameRate);
    indw = -preind:postind;
    t = indw/FrameRate;
    StrtInd = Record.Events.Analyzed.StrtInd;
    RandStrtInd = preind+ceil(rand(1,NumIndIn)*(length(T)-(preind+postind+1)));
%     RandOK = 0;
    Ev1ID = 0;
    for i = 1:NumIndIn
        ind = indw+StrtInd(i);
        Randind = indw+RandStrtInd(i);
        if ind(end)<=length(T) && ind(1)>0
%             RandOK = 1;
            Y = Data(ind);
            RandY = Data(Randind);
            Ev1ID = Ev1ID+1;
            Ev2ID = Ev2ID+1;
            Trace = interp1(t,Y,min_t);
            Trace = Trace- Trace(min_preind+1);
            Peak = max(Trace(min_preind+1:end));%-Trace(find(diff(Trace(1:min_preind))>0, 1, 'last'));
            RandTrace = interp1(t,RandY,min_t);
            RandTrace = RandTrace- RandTrace(min_preind+1);
            if IDs.Summary.Summation == 2 % event-based summation
                Heap(Ev2ID,:) = Trace;
                RandHeap(Ev2ID,:) = RandTrace;
            else % record-based summation
                Heap(RcID,:) = Heap(RcID,:) + Trace;
                RandHeap(RcID,:) = RandHeap(RcID,:) + RandTrace;
            end
            Record.Events.Analyzed.StartTriggeredPeak(Ev1ID) = Peak;
        end
    end
    if IDs.Summary.Summation == 1 & Ev1ID>0 % record-based summation
        Heap(RcID,:) = Heap(RcID,:)/Ev1ID;
        RandHeap(RcID,:) = RandHeap(RcID,:)/Ev1ID;
    else
        RcID = RcID-1;
    end
    Experiment.Groups(IDs.Group).Group.Records(r).Record = Record;
%     if RandOK
%         J = J+1;
%         RandInd = round(rand(NumRand,1)*(length(T)-preind-postind))+preind;
%         indsrnd = repmat(indw, NumRand, 1) + repmat(RandInd, 1, length(indw));
%         Yrnd = Data(indsrnd); % Data should be a row vector
%         RandHeap((J-1)*NumRand+1:J*NumRand) = max(Yrnd,[],2);
%     end
end
if IDs.Summary.Summation == 2 % event-based summation
    N = Ev2ID;
else % record-based summation
    N = RcID;
end
Heap = Heap(1:N,:);
RandHeap = RandHeap(1:N,:);
Averaged = mean(Heap);
Var = var(Heap);
SEM = sqrt(Var/size(Heap,1));
ERRtop = Averaged+SEM;
ERRbot = Averaged-SEM;
RandAveraged = mean(RandHeap);

% RandHeap = RandHeap(1:J);
% RandMeanMax = mean(RandHeap);

if Plots.Flags.Hold
    hold on
else
    hold off
end
bgclr = Plots.Colors.RGB;
if bgclr(1)<0.3 & bgclr(2)<0.3 & bgclr(3)<0.3
    bgclr = bgclr*2;
else
    bgclr = bgclr/2;
end
if ~any(bgclr)
    bgclr = [0.7 0.7 0.7];
end

% plot(repmat(min_t, K,1)',Heap')
% hold on

% plot([min_t min_t]', [Averaged+SEM Averaged-SEM]', 'Color', [0.7 0.7 0.7])
% hold on
plot(min_t,RandAveraged, 'Color', [0.7 0.7 0.7], 'LineWidth', 2);
hold on
plot([min_t' min_t']', [ERRtop' ERRbot']', 'Color', bgclr*0.5)
plot(min_t,Averaged, 'Color', Plots.Colors.RGB, 'LineWidth', 2);
% hold on
% % plot([min_t(1) min_t(end)], [RandMin RandMin], 'r:')
% plot([min_t(1) min_t(end)], [RandMeanMax RandMeanMax], 'r:')
grid on
xlabel('Time (seconds)')
ylabel(UnitName)
if IDs.Summary.Summation == 2 % event-based summation
    title(sprintf('%s  N = %2.0f  (n = %2.0f)', Group.Name, Group.NumRecs, Ev2ID));
else % record-based summation
    title(sprintf('%s  N = %2.0f', Group.Name, RcID));
end

