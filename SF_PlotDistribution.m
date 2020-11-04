function SF_PlotDistribution(EventType, ArgStr, Param)

global Experiment

rand('state', 9895);
C = rand(Experiment.NumGrps,3);
colormap(C);

MeasureName = ArgStr{1};
UnitName = ArgStr{2};
nbins = str2num(char(Param{1}));
SF_AnSummary(EventType, MeasureName);

N = Experiment.NumGrps;
ShowInd = [];
for i=1:N
    Group = Experiment.Groups(i).Group;
    if isfield(Group, 'Show') & Group.Show | ~isfield(Group, 'Show')
        ShowInd = [ShowInd i];
    end    
end
N = length(ShowInd);

s = 0.4;
maxData = 0;
for i=ShowInd
    Group = Experiment.Groups(i).Group;
    eval(sprintf('X(i).Data=Group.Summary.%s.%s.Data;', EventType, MeasureName));
%     X(i).N = Group.NumRecs;
%     eval(sprintf('X(i).n=length(Group.Summary.%s.%s.Data);', EventType, MeasureName));
    eval(sprintf('X(i).NumRecs = Group.Summary.%s.NumRecs;', EventType));
    eval(sprintf('X(i).NumEvents = Group.Summary.%s.NumEvents;', EventType));
    mx = max(X(i).Data);
    if mx > maxData
        maxData = mx;
    end
end
b = maxData/(2*double(nbins));
xhist = b:2*b:maxData;

hold off
for i=ShowInd
    Group = Experiment.Groups(i).Group;
    [X(i).nhist X(i).xhist] = hist(X(i).Data, xhist);
    X(i).fhist = X(i).nhist/sum(X(i).nhist);
    LgndStr{i} = sprintf('%s %g(%g)', Group.Name, X(i).NumRecs, X(i).NumEvents);
    plot([X(i).xhist(1) X(i).xhist X(i).xhist(end)], [0 X(i).fhist 0], 'Color', C(i,:), 'LineWidth', 2);
    hold on
end
[h p] = kstest2(X(1).Data, X(2).Data);
title(sprintf('h=%g p=%g (alpha = 0.05)', h, p));
legend(LgndStr)
xlabel(UnitName)
ylabel('Frequency')


