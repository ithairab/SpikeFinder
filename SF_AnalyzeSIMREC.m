function SF_AnalyzeSIMREC(Group1ID, Group2ID)

% compare between simultaneously recorded traces in two groups

% compute amplitude correlations between spikes in first group and
% interpolated corresponding R changes in second group
% as well as Group2/Group1 average amplitude ratio

% discard any postsynaptic amplitudes that are within 95% of the
% distribution of random postsynaptic amplitudes

global Experiment

alpha = 0.05; % criterion for accepting a postsynaptic spike

NumRecs(1) = Experiment.Groups(Group1ID).Group.NumRecs;
NumRecs(2) = Experiment.Groups(Group2ID).Group.NumRecs;

if any(diff(NumRecs))
    errordlg('Not all traces are paired between groups');
else
    AmplIn1 = [];
    AmplIn2 = [];
    AmplOut1 = [];
    AmplOut2 = [];
    GName1 = Experiment.Groups(Group1ID).Group.Name;
    GName2 = Experiment.Groups(Group2ID).Group.Name;
    NumRecs = NumRecs(1);
    TotalNumEvents1 = 0;
    kin = 0;
    kout = 0;
    j=0;
    for r = 1:NumRecs
        Rec1 = Experiment.Groups(Group1ID).Group.Records(r).Record;
        Rec2 = Experiment.Groups(Group2ID).Group.Records(r).Record;
        t1 = Rec1.Trace.T;
        t2 = Rec2.Trace.T;
        r1 = Rec1.Trace.R;
        r2 = Rec2.Trace.R;
        GlobalInd2 = 1:length(t2);
        if isfield(Rec2, 'ParentEvents')
            for p=1:Rec2.ParentEvents.NumParents
                ParentInd2 = Rec2.ParentEvents.ParentInd(1,p):Rec2.ParentEvents.ParentInd(2,p);
                GlobalInd2 = setdiff(GlobalInd2,ParentInd2);
            end
        end
        if isfield(Rec2, 'SeparatorID') && Rec2.SeparatorID>0
            GlobalInd2 = setdiff(GlobalInd2, 1:Rec2.SeparatorID);
        end
        Analyzed1 = Rec1.Events.Analyzed;
        Analyzed2 = Rec2.Events.Analyzed;
        NumEvents1 = Rec1.Events.NumIndIn;
        TotalNumEvents1 = TotalNumEvents1 + NumEvents1;
        for i = 1:NumEvents1
            PeakID1 = Analyzed1.PeakInd(i);
            EndID1 = Analyzed1.EndInd(i);
            StartID1 = Analyzed1.StrtInd(i);
            AMP1 = r1(PeakID1) - r1(StartID1);
            PeakID2 = find(t2>=t1(PeakID1),1,'first');
            EndID2 = find(t2>=t1(EndID1),1,'first');
            StartID2 = find(t2<=t1(StartID1),1,'last');
            
            InTF = ismember(StartID2:PeakID2, GlobalInd2);
            if all(InTF)
                
                % compute distance between group 1 spike peak and max R of
                % corresponding group 2 segment
                [Max2 MaxID2] = max(r2(StartID2:EndID2));
                MaxID2 = MaxID2+StartID2-1;
                j=j+1;
                dT(j) = t2(MaxID2) - t1(PeakID1);

                PeakIDDist = Analyzed2.PeakInd - PeakID1;
                PeakProx2ID = Analyzed2.PeakInd(PeakIDDist<=2 & PeakIDDist>=-2);
                if ~isempty(PeakProx2ID)
                    PeakT2 = t2(PeakProx2ID(end));
                    PeakT1 = t1(PeakID1);
                    PeakR2 = r2(PeakProx2ID(end));
                    PeakR1 = r1(PeakID1);
                    disp(sprintf('Record %g Event time %g dt=%g sec R1=%g R2/R1=%g', r, PeakT2, (PeakT2-PeakT1)*60, PeakR2,PeakR2/PeakR1));
                end

%                 Seg2Len = 2*(PeakID2-StartID2)+1;
%                 Seg2Ind = repmat(1:Seg2Len, length(t2)-Seg2Len+1, 1);
%                 Seg2Ind = Seg2Ind + repmat((0:length(t2)-Seg2Len)',1,Seg2Len);
%                 [AllMax2 AllMaxID2] = max(r2(Seg2Ind), [], 2);
%                 AllMaxID2 = AllMaxID2+(1:length(t2)-EndID2+StartID2)'-1;
%                 dTAll = t2(AllMaxID2) - t2((1:length(t2)-EndID2+StartID2)') + t1(StartID1) - t1(PeakID1);


                Peak2 = interp1(t2(StartID2:PeakID2), r2(StartID2:PeakID2), t1(PeakID1));
                Start2 = interp1(t2(StartID2:PeakID2), r2(StartID2:PeakID2), t1(StartID1));
%                 AMP2 = Peak2 - Start2;
                AMP2 = Max2 - Start2;

                dID = PeakID2-StartID2+1; % number of indices between event's start and peak
                AllAMP2 = r2(dID:end) - r2(1:(end-dID+1)); % compute all possible postsynaptic amplitudes
                Amp2Crit = prctile(AllAMP2, (1-alpha)*100);


%                 if AMP2 > Amp2Crit
                    kin = kin+1;
                    AmplIn1(kin) = AMP1;
                    AmplIn2(kin) = AMP2;
                    c='g';
%                 else
%                     kout = kout+1;
%                     AmplOut1(kout) = AMP1;
%                     AmplOut2(kout) = AMP2;
%                     c='r';
%                 end
% disp(sprintf('record %g event %g', r, i))
% figure(3)
% hold off
% plot(t2,r2,'b')
% hold on
% plot(t1(StartID1-5:PeakID1+5), r1(StartID1-5:PeakID1+5),'k:')
% plot(t1(StartID1:PeakID1), r1(StartID1:PeakID1),'k')
% plot(t2(StartID2-5:PeakID2+5), r2(StartID2-5:PeakID2+5),[c ':'])
% plot(t2(StartID2:PeakID2), r2(StartID2:PeakID2),c)
% plot([t1(StartID1) t1(PeakID1)], [Start2 Peak2],[c '.'])
% %                 hist(AllAMP2,100)
% input('continue')
            end
        end
    end

    figure(1)
    hold off
    plot(AmplIn1, AmplIn2, 'k.')
    hold on
    plot(AmplOut1, AmplOut2, 'r.')
    [R P] = corr(AmplIn1', AmplIn2');
    [a b] = LinearFit(AmplIn1, AmplIn2);
    AmpInRatio = AmplIn2./AmplIn1;
    AmpInRatioMean = mean(AmpInRatio);
    AmpInRatioSEM = sqrt(var(AmpInRatio)/length(AmpInRatio));
    AmpAllRatio = [AmplIn2 AmplOut2] ./ [AmplIn1 AmplOut1];
    AmpAllRatioMean = mean(AmpAllRatio);
    AmpAllRatioSEM = sqrt(var(AmpAllRatio)/length(AmpAllRatio));

    plot([min(AmplIn1) max(AmplIn1)] ,b+a*[min(AmplIn1) max(AmplIn1)], 'k')
    xlabel(sprintf('%s spike amplitude (%% ratio change)', GName1));
    ylabel(sprintf('Corresponding amplitude in %s (%% ratio change)', GName2));
    title(sprintf('%s/%s spike amplitudes n=%g/%g(%g) Rho=%g p=%g slope=%g',...
        GName1, GName2, length(AmplIn1), TotalNumEvents1, NumRecs, R, P, a));
    disp(sprintf('Good: Amp2/Amp1 = %g +- %g', AmpInRatioMean, AmpInRatioSEM));
    disp(sprintf(' All: Amp2/Amp1 = %g +- %g', AmpAllRatioMean, AmpAllRatioSEM));
    
%     figure(2)
%     hold off
%     hist(dT,100);
end

