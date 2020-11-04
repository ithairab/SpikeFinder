function SF_PlotCorrelation(EventType, ArgStr, Param)

global Experiment IDs

MeasureName1 = ArgStr{1};
UnitName1 = ArgStr{2};
MeasureName2 = ArgStr{3};
UnitName2 = ArgStr{4};

Y1 = [];
Y2 = [];
Group = Experiment.Groups(IDs.Group).Group;
for j = 1:Group.NumRecs
    Record = Group.Records(j).Record;
    eval(sprintf('y1 = Record.%s.Analyzed.%s;', EventType, MeasureName1));
    eval(sprintf('y2 = Record.%s.Analyzed.%s;', EventType, MeasureName2));
    if strcmp('ISI', MeasureName1)
        y2 = y2(1:end-1);
    elseif strcmp('ISI', MeasureName2)
        y1 = y1(1:end-1);
    end
    notnan1 = find(~isnan(y1));
    notnan2 = find(~isnan(y2));
    notnan = intersect(notnan1, notnan2);
    Y1 = [Y1 y1(notnan)];
    Y2 = [Y2 y2(notnan)];
end
[R P] = corr(Y1', Y2');
hold off
plot(Y1, Y2, 'k.')
xlabel(UnitName1)
ylabel(UnitName2)
title(sprintf('r = %2.1f (p = %g)', R, P));