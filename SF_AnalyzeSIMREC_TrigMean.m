function SF_AnalyzeSIMREC_TrigMean(Group1ID, Group2ID, Window, Bin)

% spike-trigger average


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
    Heap1 = [];
    Heap2 = [];
    GName1 = Experiment.Groups(Group1ID).Group.Name;
    GName2 = Experiment.Groups(Group2ID).Group.Name;
    NumRecs = NumRecs(1);
    TotalNumEvents1 = 0;
    WinT = -Window:Bin:Window;
    for r = 1:NumRecs
        Rec1 = Experiment.Groups(Group1ID).Group.Records(r).Record;
        Rec2 = Experiment.Groups(Group2ID).Group.Records(r).Record;
        t1 = Rec1.Trace.T';
        t2 = Rec2.Trace.T';
        r1 = Rec1.Trace.R';
        r2 = Rec2.Trace.R';
        OutT2 = []; % non-allowable segments from to
        if isfield(Rec2, 'ParentEvents')
            OutT2 = t2(Rec2.ParentEvents.ParentInd);
        end
        if isfield(Rec2, 'SeparatorID') && Rec2.SeparatorID>0
            % assuming there are no parents left of the separation marker
            OutT2 = [[t2(1); t2(Rec2.SeparatorID)] OutT2];
        end
        Analyzed1 = Rec1.Events.Analyzed;
        Analyzed2 = Rec2.Events.Analyzed;
        NumEvents1 = Rec1.Events.NumIndIn;
        TotalNumEvents1 = TotalNumEvents1 + NumEvents1;
        for i = 1:NumEvents1
            PeakID1 = Analyzed1.PeakInd(i);
            EndID1 = Analyzed1.EndInd(i);
            StartID1 = Analyzed1.StrtInd(i);
            wintL = t1(PeakID1)-Window;
            wintR = t1(PeakID1)+Window;
            OK2 = 1;
            NumOut = size(OutT2,2);
            for s=1:NumOut
                cond1 = wintL>OutT2(1,s) & wintL<OutT2(2,s);
                cond2 = wintR>OutT2(1,s) & wintR<OutT2(2,s);
                cond3 = OutT2(1,s)>wintL & OutT2(1,s)<wintR;
                cond4 = OutT2(2,s)>wintL & OutT2(2,s)<wintR;
                if cond1 | cond2 | cond3 | cond4
                    OK2 = 0;
                    break;
                end
            end
            % Spike-triggered average
            % -----------------------
            if wintL>t1(1) & wintR<t1(end)
                intrpR1 = interp1(t1, r1, WinT+t1(PeakID1));
                Heap1 = [Heap1; intrpR1];
                if OK2
                    intrpR2 = interp1(t2, r2, WinT+t1(PeakID1));
                    Heap2 = [Heap2; intrpR2];
% figure(2)
% hold off
% plot(t2,r2, 'k')
% hold on
% plot(WinT+t1(PeakID1), intrpR2, 'r')
% plot(t1(PeakID1), r1(PeakID1), 'r*')
% input('')
                end
            end
        end
    end

    figure(1)
    hold off
    Heap1Mean = mean(Heap1);
    MxHeap1Mean = max(Heap1Mean);
    MnHeap1Mean = min(Heap1Mean);
    NormHeap1Mean = (Heap1Mean - MnHeap1Mean) / (MxHeap1Mean - MnHeap1Mean);
    Heap2Mean = mean(Heap2);
    NormHeap2Mean = (Heap2Mean - MnHeap1Mean) / (MxHeap1Mean - MnHeap1Mean);
    NormHeap2Mean = NormHeap2Mean - min(NormHeap2Mean);
    Heap1SEM = sqrt(var(Heap1)/size(Heap1,1));
    plot(WinT, NormHeap1Mean, 'k','LineWidth',2)
    hold on
%     plot(WinT, Heap2)
    plot(WinT, NormHeap2Mean, 'b','LineWidth',2)
%     plot(WinT, Heap1Mean+Heap1SEM, 'k:')
%     plot(WinT, Heap1Mean-Heap1SEM, 'k:')
    xlabel('Time (sec)')
    ylabel(sprintf('%s-normalized ratio change (%c)', GName1, '%'))
    title(sprintf('%s-triggered average ratio change (n=%g,%g)', GName1, size(Heap1,1), size(Heap2,1)))
    legend({sprintf('%s', GName1), sprintf('%s', GName2)})
    grid on
end

