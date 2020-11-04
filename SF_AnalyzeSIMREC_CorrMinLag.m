function SF_AnalyzeSIMREC_CorrMinLag(Group1ID, Group2ID, LimitLeft, LimitRight)

% correlate between spikes that are within a limited minimum lag one from
% the other (e.g. loop ALM spikes and consider only proximal AVA spikes)

% group 1 should be e.g. ALM and group 2 e.g. AVA (the one with parents etc.)

global Experiment

NumRecs(1) = Experiment.Groups(Group1ID).Group.NumRecs;
NumRecs(2) = Experiment.Groups(Group2ID).Group.NumRecs;

if any(diff(NumRecs))
    errordlg('Not all traces are paired between groups');
else
    Amp1 = [];
    Amp2 = [];
    GName1 = Experiment.Groups(Group1ID).Group.Name;
    GName2 = Experiment.Groups(Group2ID).Group.Name;
    NumRecs = NumRecs(1);
    TotalNumEvents1 = 0;
    TimeParents = 0; % total time of parents
    TimeInSeparator = 0; % total time > separator
    NumEventsInParents = 0;
    for r = 1:NumRecs
        Rec1 = Experiment.Groups(Group1ID).Group.Records(r).Record;
        Rec2 = Experiment.Groups(Group2ID).Group.Records(r).Record;
        t1 = Rec1.Trace.T';
        t2 = Rec2.Trace.T';
        r1 = Rec1.Trace.R';
        r2 = Rec2.Trace.R';
        OutT2 = []; % non-allowable segments from to
        if isfield(Rec2, 'ParentEvents')
            OutPT2 = t2(Rec2.ParentEvents.ParentInd);
            TimeParents = TimeParents + sum(OutPT2(2,:)-OutPT2(1,:));
            OutT2 = OutPT2;
        end
        if isfield(Rec2, 'SeparatorID') && Rec2.SeparatorID>0
            % assuming there are no parents left of the separation marker
            OutT2 = [[t2(1); t2(Rec2.SeparatorID)] OutT2];
            TimeInSeparator = TimeInSeparator + t2(end)-t2(Rec2.SeparatorID);
        else
            TimeInSeparator = TimeInSeparator + t2(end)-t2(1);
        end
        Analyzed1 = Rec1.Events.Analyzed;
        Analyzed2 = Rec2.Events.Analyzed;
        NumEvents1 = Rec1.Events.NumIndIn;
        TotalNumEvents1 = TotalNumEvents1 + NumEvents1;
        for i = 1:NumEvents1 % loop group1 spikes
            PeakID1 = Analyzed1.PeakInd(i);
            EndID1 = Analyzed1.EndInd(i);
            StartID1 = Analyzed1.StrtInd(i);
            OK1 = 1;
            NumOut = size(OutT2,2);
            for s=1:NumOut
                % check if group1 spike falls within a restricted segment
                cond1 = t1(StartID1)>OutT2(1,s) & t1(StartID1)<OutT2(2,s);
                cond2 = t1(EndID1)>OutT2(1,s) & t1(EndID1)<OutT2(2,s);
                cond3 = OutT2(1,s)>t1(StartID1) & OutT2(1,s)<t1(EndID1);
                cond4 = OutT2(2,s)>t1(StartID1) & OutT2(2,s)<t1(EndID1);
                if cond1 | cond2 | cond3 | cond4
                    OK1 = 0;
                    break;
                end
            end
            NumOut = size(OutPT2,2);
            for s=1:NumOut
                % check if group1 spike falls within a parent segment
                cond1 = t1(StartID1)>OutPT2(1,s) & t1(StartID1)<OutPT2(2,s);
                cond2 = t1(EndID1)>OutPT2(1,s) & t1(EndID1)<OutPT2(2,s);
                cond3 = OutPT2(1,s)>t1(StartID1) & OutPT2(1,s)<t1(EndID1);
                cond4 = OutPT2(2,s)>t1(StartID1) & OutPT2(2,s)<t1(EndID1);
                if cond1 | cond2 | cond3 | cond4
                    NumEventsInParents = NumEventsInParents+1;
                    break;
                end
            end
            % Minimum lag analysis
            % --------------------
            if OK1
                lags = (t2(Analyzed2.StrtInd)-t1(StartID1))*60;
                [minlag minlagid] = min(abs(lags));
                if minlag<LimitRight & minlag>LimitLeft
                    Amp2 = [Amp2 Analyzed2.AmpStrt(minlagid)];
                    Amp1 = [Amp1 Analyzed1.AmpStrt(i)];
% figure(2)
% hold off
% plot(t1,r1,'r')
% hold on
% plot(t2,r2, 'k')
% plot(t2(Analyzed2.StrtInd(minlagid)), r2(Analyzed2.StrtInd(minlagid)), 'g*')
% plot(t1(StartID1),r1(StartID1), 'r*')
% input(sprintf('r %g i %g', r, i))
                end
            end
        end
    end

    [R P] = corr(Amp1', Amp2');
    [a b] = LinearFit(Amp1, Amp2);
    AmpRatio = Amp2./Amp1;
    AmpRatioMean = mean(AmpRatio);
    AmpRatioSEM = sqrt(var(AmpRatio)/length(AmpRatio));
    
    figure(1)
    hold off
    plot(Amp1, Amp2, 'k.')
    hold on
    plot([min(Amp1) max(Amp1)] ,b+a*[min(Amp1) max(Amp1)], 'k')
    title(sprintf('%s/%s spike amplitudes n=%g/%g(N=%g) Rho=%g p=%g slope=%g',...
        GName2, GName1, length(Amp1), TotalNumEvents1, NumRecs, R, P, a));
%     axis equal
    XLim = get(gca, 'XLim');
    XLim(1) = 0;
    YLim = get(gca, 'YLim');
    YLim(1) = 0;
    set(gca, 'XLim', XLim, 'YLim', YLim);
    
    disp(sprintf('Amp2/Amp1 = %g +- %g', AmpRatioMean, AmpRatioSEM));
    disp(sprintf('fraction %s spikes within parent %3.2f; fraction parent time %3.2f', GName1, NumEventsInParents/TotalNumEvents1, TimeParents/TimeInSeparator));
end

