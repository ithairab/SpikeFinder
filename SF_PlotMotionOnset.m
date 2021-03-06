function SF_PlotMotionOnset(EventType, ArgStr, Param)

% averages the Frames number of frames prior to the beginning of motion and
% the Frames number of frames after Delay seconds following the beginning
% of motion and compares them
% patch: if Frames=0, compares average ratio until motion onset with
% average ratio of the time window 'Delay'

global Experiment Plots

    
% TestGroupID = 4; % temporary!!

MeasureName = ArgStr{1};
UnitName = ArgStr{2};
Frames = str2num(char(Param{1}));
Delay = str2num(char(Param{2}));

GroupNames = {};
M = Experiment.NumGrps;
ShowInd = [];
for i=1:M
    Group = Experiment.Groups(i).Group;
    if isfield(Group, 'Show') & Group.Show | ~isfield(Group, 'Show')
        ShowInd = [ShowInd i];
    end    
end

% Alpha = 0.05;
s = 0.4;
for g=1:M
    Group = Experiment.Groups(g).Group;
    if Plots.Flags.IncludeOutRecords
        N = Group.NumRecs;
        IncOut = 1;
    else
        N = Group.NumRecsIn;
        IncOut = 0;
    end
%     StimDiff = nan(1, N);
    Var = nan(1, N);
    k = 0;
    for r=1:Group.NumRecs
        Record = Group.Records(r).Record;
        if ~isfield(Record.Flags, 'In') || Record.Flags.In || IncOut
            if isfield(Record, 'Motion') && isfield(Record.Motion, 'StrtInd') && ~isempty(Record.Motion.StrtInd)
                T = Record.Trace.T * 60;
                Mid = Record.Motion.StrtInd;
                DelayFrames = find(T>T(Mid)+Delay, 1, 'first');
                if Frames==0
                    IDA1 = 1;
                    IDA2 = Mid-1;
                    IDB1 = Mid;
                    IDB2 = DelayFrames;
                else
                    IDA1 = Mid-Frames;
                    IDA2 = Mid-1;
%                     IDB1 = Mid+DelayFrames+1;
%                     IDB2 = Mid+DelayFrames+Frames+1;
                    IDB1 = DelayFrames+1;
                    IDB2 = DelayFrames+Frames+1;
                end
                if ~isempty(DelayFrames) && IDA1>0
                    k = k+1;
                    ratio = Record.Trace.R;
                    % In previous versions there was no Record.Trace.F, but dF can be derived
                    % from Record.Trace.R
                    if isfield(Record.Trace, 'F')
                        Fflag = 1; 
                        F = Record.Trace.F;
                    else
                        Fflag = 0; 
                    end

                    if Fflag
                        F_A = mean(F(IDA1:IDA2));
                        F_B = mean(F(IDB1:IDB2));
                    end

                    R_A = mean(ratio(IDA1:IDA2));
                    R_B = mean(ratio(IDB1:IDB2));

                        if Fflag
            %                 StimDiff(k) = (F_B - F_A) / F_A * 100;
                            Var(k) = (F_B - F_A) / F_A * 100;
                        else
                            % StimDiff can also be derived from R=(F-min(F))/min(F)*100:
            %                 StimDiff(k) = (R_B - R_A) / (R_A + 100) * 100;
                            Var(k) = (R_B - R_A) / (R_A + 100) * 100;
                        end
                end
            end
%=========================================================================
        end
    end
    Var = Var(~isnan(Var));
    eval(sprintf('Experiment.Groups(g).Group.Summary.Events.%s.Data = Var;', MeasureName));
    eval(sprintf('Experiment.Groups(g).Group.Summary.Events.%s.Mean = mean(Var);', MeasureName));
    eval(sprintf('Experiment.Groups(g).Group.Summary.Events.%s.SEM = sqrt(var(Var)/k);', MeasureName));
end


% very temporary ad hoc mix (without going through SF_AnSummary) especially
% because this is not really about events..
k=0;
for g=ShowInd
    k=k+1;
    Group = Experiment.Groups(g).Group;
    GroupNames = [GroupNames Group.Name];
    eval(sprintf('X(k).Data=Group.Summary.%s.%s.Data;', EventType, MeasureName));
    eval(sprintf('X(k).Mean=Group.Summary.%s.%s.Mean;', EventType, MeasureName));
    eval(sprintf('X(k).SEM=Group.Summary.%s.%s.SEM;', EventType, MeasureName));
    X(k).NumRecs = Group.NumRecsIn;
    X(k).NumData=length(X(k).Data);
end
M = length(ShowInd);
Ex = [1:M; 1:M];
Ey = [];
hold off
k=0;
for i=ShowInd
    k=k+1;
    fill([k-s k-s k+s k+s]', [0 X(k).Mean X(k).Mean 0]', k)
    Ey = [Ey, [X(k).Mean-X(k).SEM X(k).Mean+X(k).SEM]'];
    hold on
end
plot(Ex, Ey, 'k', 'LineWidth', 2);

DataTotal = [];
GroupTotal = [];
k=0;
for i=ShowInd
% for i=4:6
    k=k+1;
    Group = Experiment.Groups(i).Group;
    DataTotal = [DataTotal; X(k).Data'];
    GroupTotal = [GroupTotal; repmat({Group.Name}, X(k).NumData, 1)];
    LgndStr{k} = sprintf('%s %g (%g)', Group.Name, X(k).NumRecs, length(X(k).Data));
end
set(gca, 'XTick', 1:M, 'XTickLabel', GroupNames, 'XLim', [0.5 M+0.5]);

legend(LgndStr, 'Location', 'WestOutside')
ylabel(UnitName)

if 0
    [p table stats] = anova1(DataTotal, GroupTotal, 'off');
    % figure(1)
    Compare = multcompare(stats, 'alpha', Alpha, 'ctype', 'bonferroni', 'display', 'off');
    SgnfInd = find(Compare(:,3)>0 | Compare(:,5)<0); % 0 outside of the confidence interval of mean differences
    TestGroupInd1 = intersect(SgnfInd, find(Compare(:,1)==TestGroupID));
    TestGroupInd2 = intersect(SgnfInd, find(Compare(:,2)==TestGroupID));
    ylim = get(gca, 'YLim');
    for i=1:length(TestGroupInd1)
    %     text(Ex(2, Compare(TestGroupInd1(i),2)), Ey(2, Compare(TestGroupInd1(i),2)), '*',...
    %         'FontSize', 20, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontWeight', 'bold');
        text(Compare(TestGroupInd1(i),2), ylim(2), '*',...
            'FontSize', 20, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold');
    end
    for i=1:length(TestGroupInd2)
    %     text(Ex(2, Compare(TestGroupInd2(i),1)), Ey(2, Compare(TestGroupInd2(i),1)), '*',...
    %         'FontSize', 20, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'FontWeight', 'bold');
        text(Compare(TestGroupInd2(i),2), ylim(2), '*',...
            'FontSize', 20, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold');
    end
    title(sprintf('One-way ANOVA p=%g', p))
end

