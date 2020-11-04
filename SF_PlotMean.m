function SF_PlotMean(EventType, ArgStr, Param)

global Experiment Plots IDs

TestGroupID = IDs.TestGroup;

MeasureName = ArgStr{1};
UnitName = ArgStr{2};
SF_AnSummary(EventType, MeasureName);

GroupNames = {};
N = Experiment.NumGrps;
ShowInd = [];
for i=1:N
    Group = Experiment.Groups(i).Group;
    if isfield(Group, 'Show') & Group.Show | ~isfield(Group, 'Show')
        ShowInd = [ShowInd i];
    end    
end
N = length(ShowInd);

Alpha = 0.05;
s = 0.4;
k=0;
for i=ShowInd
    k=k+1;
    Group = Experiment.Groups(i).Group;
    GroupNames = [GroupNames Group.Name];
    eval(sprintf('X(k).Data=Group.Summary.%s.%s.Data;', EventType, MeasureName));
    eval(sprintf('X(k).Mean=Group.Summary.%s.%s.Mean;', EventType, MeasureName));
    eval(sprintf('X(k).SEM=Group.Summary.%s.%s.SEM;', EventType, MeasureName));
    eval(sprintf('X(k).CV=Group.Summary.%s.%s.CV;', EventType, MeasureName));
    eval(sprintf('X(k).NumRecs = Group.Summary.%s.NumRecs;', EventType));
    eval(sprintf('X(k).NumEvents = Group.Summary.%s.NumEvents;', EventType));
    X(k).NumData=length(X(k).Data);
end
% Bx = [];
% By = [];
Ex = [1:N; 1:N];
Ey = [];
hold off
k=0;
for i=ShowInd
    k=k+1;
%     Bx = [Bx, [i-s i-s i+s i+s]'];
%     By = [By, [0 X(i).Mean X(i).Mean 0]'];
    fill([k-s k-s k+s k+s]', [0 X(k).Mean X(k).Mean 0]', k)
    Ey = [Ey, [X(k).Mean-X(k).SEM X(k).Mean+X(k).SEM]'];
    hold on
end

% xticklabel_rotate;

% [h p] = ttest2(X(1).Data, X(2).Data, 0.05, 'both', 'unequal');
% title(sprintf('h=%g p=%g (alpha = 0.05)', h, p));
% for i=1:N
% %     text(i,X(i).Mean*0.9,sprintf('CV=%1.1f %g(%g)',X(i).CV,X(i).N, X(i).n),'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
%     text(i,X(i).Mean*0.9,sprintf('%g(%g)',X(i).N, X(i).n),'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
% end
% ylabel(UnitName)
plot(Ex, Ey, 'k', 'LineWidth', 4);

k=0;
for i=ShowInd
    k=k+1;
    plot([k-s k+s], median(X(k).Data)*[1 1], 'k:')
end
if Plots.Flags.Scatter == 1
    k=0;
    for i=ShowInd
        k=k+1;
        xscatter = rand(size(X(k).Data))*s+k-s/2;
        plot(xscatter, X(k).Data, 'ko', 'MarkerSize', 4)
    end
end

DataTotal = [];
GroupTotal = [];
k=0;
for i=ShowInd
    k=k+1;
    Group = Experiment.Groups(i).Group;
    DataTotal = [DataTotal; X(k).Data'];
    GroupTotal = [GroupTotal; repmat({Group.Name}, X(k).NumData, 1)];
    LgndStr{k} = sprintf('%s %g(%g)', Group.Name, X(k).NumRecs, X(k).NumEvents);
%     plot(ones(1,X(i).NumData)*i, X(i).Data, 'o', 'MarkerFaceColor', 0.9*[1 1 1],...
%         'MarkerEdgeColor',0.4*[1 1 1],'MarkerSize',6);
end
set(gca, 'XTick', 1:N, 'XTickLabel', GroupNames, 'XLim', [0.5 N+0.5]);

% for i=1:N
%     plot(ones(1,X(i).NumData)*i, X(i).Data, '.');
% end
legend(LgndStr)
ylabel(UnitName)

if N>1
    [p table stats] = anova1(DataTotal, GroupTotal, 'off');
    % figure(1)
    Compare = multcompare(stats, 'alpha', Alpha, 'ctype', 'bonferroni', 'display', 'off');
    SgnfInd = find(Compare(:,3)>0 | Compare(:,5)<0); % 0 outside of the confidence interval of mean differences
    TestGroupInd1 = intersect(SgnfInd, find(Compare(:,1)==TestGroupID));
    TestGroupInd2 = intersect(SgnfInd, find(Compare(:,2)==TestGroupID));
    ylim = get(gca, 'YLim');
    text(TestGroupID, ylim(2), '\downarrow',...
        'FontSize', 12, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold');
    for i=1:length(TestGroupInd1)
    %     text(Ex(2, Compare(TestGroupInd1(i),2)), Ey(2, Compare(TestGroupInd1(i),2)), '*',...
    %         'FontSize', 20, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontWeight', 'bold');
        text(Compare(TestGroupInd1(i),2), ylim(2), '*',...
            'FontSize', 20, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold');
    end
    for i=1:length(TestGroupInd2)
    %     text(Ex(2, Compare(TestGroupInd2(i),1)), Ey(2, Compare(TestGroupInd2(i),1)), '*',...
    %         'FontSize', 20, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontWeight', 'bold');
        text(Compare(TestGroupInd2(i),1), ylim(2), '*',...
            'FontSize', 20, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold');
    end
    title(sprintf('One-way ANOVA p=%g', p))
end

