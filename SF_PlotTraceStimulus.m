function SF_PlotTraceStimulus(EventType, ArgStr, Param)

% a specific plot for the stimuls regime off1-on-off2 (30 sec each)
% takes the first Window sec of off2 and subtracts is from on

global Experiment Plots IDs

    
TestGroupID = IDs.TestGroup;


MeasureName = ArgStr{1};
UnitName = ArgStr{2};
Window = str2num(char(Param{1}));
SwitchTime = str2num(char(Param{2}));

GroupNames = {};
M = Experiment.NumGrps;
ShowInd = [];
for i=1:M
    Group = Experiment.Groups(i).Group;
    if isfield(Group, 'Show') & Group.Show | ~isfield(Group, 'Show')
        ShowInd = [ShowInd i];
    end    
end

Alpha = 0.05;
s = 0.4;
for g=1:M
    Group = Experiment.Groups(g).Group;
    if Plots.Flags.IncludeOutRecords
        N = Group.NumRecs;
        IncOut = 1;
    else
        if isfield(Group, 'NumRecsIn')
            N = Group.NumRecsIn;
        else
            N = Group.NumRecs;
        end
        IncOut = 0;
    end
%     StimDiff = nan(1, N);
    Var = nan(1, N);
    k = 0;
    RecInd{g}=1:Group.NumRecs;
    for r=1:Group.NumRecs
        Record = Group.Records(r).Record;
        if ~isfield(Record.Flags, 'In') || Record.Flags.In || IncOut
            k = k+1;
            % temporarily, always use average t (accroding to FPS) due
            % to problems with t records
%             T = Record.Trace.T * 60;
dtt = (Record.Trace.T(end)-Record.Trace.T(1))/(length(Record.Trace.T)-1);
T = (Record.Trace.T(1):1*dtt:Record.Trace.T(end))*Plots.TimeUnit.Factor(IDs.TimeUnit);
            ratio = Record.Trace.R; % ratio change!
            % In previous versions there was no Record.Trace.F, but dF can be derived
            % from Record.Trace.R
            if isfield(Record.Trace, 'F')
                Fflag = 1; 
                F = Record.Trace.F; % pure ratio (or single channel fluorescnes in difference mode)
% normalize singal to lie between 0 and 1
% F = F-min(F);
% F = F/max(F);
            else
                Fflag = 0; 
            end
            IDA1 = find(T>=SwitchTime-Window, 1, 'first');
            IDA2 = find(T<=SwitchTime, 1, 'last');

            IDB1 = find(T>=SwitchTime, 1, 'first');
            IDB2 = find(T<=SwitchTime+Window, 1, 'last');
            
%             % temporary, compute last 10 sec compared to first 10 sec
%             IDB1 = find(T>=T(end)-Window, 1, 'first');
%             IDB2 = length(T);

%             % temporary, compute last 20 sec compared to first 10 sec
%             IDB1 = find(T>=T(end)-20, 1, 'first');
%             IDB2 = length(T);

            if Fflag
                F_A = mean(F(IDA1:IDA2));
                F_B = mean(F(IDB1:IDB2));
            end

            R_A = mean(ratio(IDA1:IDA2));
            R_B = mean(ratio(IDB1:IDB2));

            switch MeasureName
                case 'StimDiff'
                    if Fflag
        %                 StimDiff(k) = (F_B - F_A) / F_A * 100;
                        Var(k) = (F_B - F_A) / F_A * 100;
                    else
                        % StimDiff can also be derived from R=(F-min(F))/min(F)*100:
        %                 StimDiff(k) = (R_B - R_A) / (R_A + 100) * 100;
                        Var(k) = (R_B - R_A) / (R_A + 100) * 100;
                    end
            %         StimDiff(r) = R_B-R_A;
                case 'R_0'
                    Var(k) = R_A;
                case 'F1_0'
                    Var(k) = F_A;
            end
%=========================================================================
        else
            RecInd{g}(k+1:end) = RecInd{g}(k+1:end)-1;
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
    if isfield(Group, 'NumRecsIn')
        X(k).NumRecs = Group.NumRecsIn;
    else
        X(k).NumRecs = Group.NumRecs;
    end
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
plot([0 k+0.5], [0 0], 'k')
plot(Ex, Ey, 'k', 'LineWidth', 2);
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
        if i==IDs.Group
            j = IDs.Record;
            if Experiment.Groups(IDs.Group).Group.Records(j).Record.Flags.In
                plot(xscatter(RecInd{i}(j)), X(k).Data(RecInd{i}(j)), 'ro', 'MarkerSize', 4)   
            end
        end
    end
end

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

if M>1
    [P table stats] = anova1(DataTotal, GroupTotal, 'off');
    Compare = multcompare(stats, 'alpha', Alpha, 'ctype', 'bonferroni', 'display', 'off');
    SgnfInd = find(Compare(:,3)>0 | Compare(:,5)<0); % 0 outside of the confidence interval of mean differences
    TestGroupInd1 = intersect(SgnfInd, find(Compare(:,1)==TestGroupID));
    TestGroupInd2 = intersect(SgnfInd, find(Compare(:,2)==TestGroupID));
    ylim = get(gca, 'YLim');
    text(TestGroupID, ylim(2), '\downarrow',...
        'FontSize', 12, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold');
    for i=1:length(TestGroupInd1)
        text(Compare(TestGroupInd1(i),2), ylim(2), '*',...
            'FontSize', 20, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold');
    end
    for i=1:length(TestGroupInd2)
        text(Compare(TestGroupInd2(i),1), ylim(2), '*',...
            'FontSize', 20, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold');
    end
    for g=ShowInd
        if g~=TestGroupID
            [h p] =ttest2(Experiment.Groups(TestGroupID).Group.Summary.Events.StimDiff.Data,Experiment.Groups(g).Group.Summary.Events.StimDiff.Data);
            text(g,ylim(2)*1.075, num2str(p),...
            'FontSize', 7, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold');
        end
    end
%     title(sprintf('One-way ANOVA p=%g', P))

end

