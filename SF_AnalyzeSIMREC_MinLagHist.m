function SF_AnalyzeSIMREC_MinLagHist(Group1ID, Group2ID, Window, Bin, Sign)

% compare between simultaneously recorded traces in two groups

% compute amplitude correlations between spikes in first group and
% interpolated corresponding R changes in second group
% as well as Group2/Group1 average amplitude ratio

% discard any postsynaptic amplitudes that are within 95% of the
% distribution of random postsynaptic amplitudes

global Experiment

NumRecs(1) = Experiment.Groups(Group1ID).Group.NumRecs;
NumRecs(2) = Experiment.Groups(Group2ID).Group.NumRecs;

if any(diff(NumRecs))
    errordlg('Not all traces are paired between groups');
else
    Lags = [];
    MinLag = [];
    GName1 = Experiment.Groups(Group1ID).Group.Name;
    GName2 = Experiment.Groups(Group2ID).Group.Name;
    NumRecs = NumRecs(1);
    TotalNumEvents1 = 0;
    InNumEvents1 = 0;
    for r = 1:NumRecs
        Rec1 = Experiment.Groups(Group1ID).Group.Records(r).Record;
        Rec2 = Experiment.Groups(Group2ID).Group.Records(r).Record;
        t1 = Rec1.Trace.T';
        t2 = Rec2.Trace.T';
        r1 = Rec1.Trace.R';
        r2 = Rec2.Trace.R';
        OutT1 = []; % non-allowable segments from to
        if isfield(Rec1, 'ParentEvents')
            OutT1 = t1(Rec1.ParentEvents.ParentInd);
        end
        if isfield(Rec1, 'SeparatorID') && Rec1.SeparatorID>0
            % assuming there are no parents left of the separation marker
            OutT1 = [[t1(1); t1(Rec1.SeparatorID)] OutT1];
        end
        if isfield(Rec1.Events, 'Analyzed') && isfield(Rec2.Events, 'Analyzed')
            Analyzed1 = Rec1.Events.Analyzed;
            Analyzed2 = Rec2.Events.Analyzed;
            NumEvents1 = Rec1.Events.NumIndIn;
            TotalNumEvents1 = TotalNumEvents1 + NumEvents1;
            for i = 1:NumEvents1
                StartID1 = Analyzed1.StrtInd(i);
                EndID1 = Analyzed1.EndInd(i);
                OK1 = 1;
                NumOut = size(OutT1,2);
                for s=1:NumOut
                    cond1 = t1(StartID1)>OutT1(1,s) & t1(StartID1)<OutT1(2,s);
                    cond2 = t1(EndID1)>OutT1(1,s) & t1(EndID1)<OutT1(2,s);
                    cond3 = OutT1(1,s)>t1(StartID1) & OutT1(1,s)<t1(EndID1);
                    cond4 = OutT1(2,s)>t1(StartID1) & OutT1(2,s)<t1(EndID1);
                    if cond1 | cond2 | cond3 | cond4
                        OK1 = 0;
                        break;
                    end
                end
                % Minimum delay analysis
                % ----------------------
%                 if OK1
                    lags = (t2(Analyzed2.StrtInd)-t1(StartID1))*60;
                    if Sign>0
                        lagind = find(lags>=0);
                    elseif Sign<0
                        lagind = find(lags<=0);
                    else
                        lagind = 1:length(lags);
                    end
                    [minlag minlagid] = min(abs(lags(lagind)));
                    minlag = lags(lagind(minlagid));
                    MinLag = [MinLag minlag];
                    InNumEvents1 = InNumEvents1+1;
%                 end
            end
        end
    end

    figure(1)
    hold off
    X = Bin/2:Bin:Window;
    if Sign<0
        X = -X(end:-1:1);
    elseif Sign==0
        X = [-X(end:-1:1) X];
    end
    WinMinLag = MinLag(MinLag<=Window & MinLag>=-Window);
    count = hist(WinMinLag,X);
    bar(X,count/InNumEvents1*100);
    title(sprintf('Minimum lag histogram %s -> %s (n=%g/%g)', GName1, GName2, length(WinMinLag), InNumEvents1))
    xlabel('Lag (sec)')
    ylabel('Frequency (%)')
    grid on
end

