function SF_AnalyzePSTH(Group1ID, Group2ID, psthRange, psthBin)

% compare between simultaneously recorded traces in two groups
% compute PSTH based on spike times in both groups
% compute amplitude correlations between spikes in first group and
% interpolated corresponding R changes in second group
% compute ISI histograms
% time arguments in seconds

global Experiment

NumRecs(1) = Experiment.Groups(Group1ID).Group.NumRecs;
NumRecs(2) = Experiment.Groups(Group2ID).Group.NumRecs;

if any(diff(NumRecs))
    errordlg('Not all traces are paired between groups');
else
    GName1 = Experiment.Groups(Group1ID).Group.Name;
    GName2 = Experiment.Groups(Group2ID).Group.Name;
    NumRecs = NumRecs(1);
    EventCount = 0;
    RecordCount = 0;
    Dists = [];
    TotalNumEvents1 = 0;
    j = 0;
    k=0;
    ISI1 = [];
    ISI2 = [];
    for r = 1:NumRecs
        RecordOK = 0;
        Rec1 = Experiment.Groups(Group1ID).Group.Records(r).Record;
        Rec2 = Experiment.Groups(Group2ID).Group.Records(r).Record;
        t1 = Rec1.Trace.T;
        t2 = Rec2.Trace.T;
        y1 = Rec1.Trace.R;
        y2 = Rec2.Trace.R;
        EventInd1 = Rec1.Events.EventInd(:, Rec1.Events.IndIn);
        EventInd2 = Rec2.Events.EventInd(:, Rec2.Events.IndIn);
        ISI1 = [ISI1 diff(t1(EventInd1(2,:)))];
        ISI2 = [ISI2 diff(t2(EventInd2(2,:)))];
        NumEvents1 = Rec1.Events.NumIndIn;
        TotalNumEvents1 = TotalNumEvents1 + NumEvents1;
        NumEvents2 = Rec2.Events.NumIndIn;
figure(1)
subplot(2,1,1)
hold off
plot(t1,y1, 'k', t1(EventInd1(2,:)), y1(EventInd1(2,:)), 'g.')
hold on
subplot(2,1,2)
hold off
plot(t2,y2, 'k', t2(EventInd2(2,:)), y2(EventInd2(2,:)), 'g.')
hold on
        for i = 1:NumEvents1
            peakid1 = EventInd1(2,i);
            startid1 = EventInd1(1,i);
            AMP1 = y1(peakid1) - y1(startid1);
            peakid2 = find(t2>=t1(peakid1),1,'first');
            startid2 = find(t2<=t1(startid1),1,'last');
%             AMP2 = (y2(peakid2)+y2(peakid2-1))/2 - y2(startid2);
            peak2 = interp1(t2(startid2:peakid2), y2(startid2:peakid2), t1(peakid1));
            start2 = interp1(t2(startid2:peakid2), y2(startid2:peakid2), t1(startid1));
            AMP2 = peak2 - start2;
subplot(2,1,1)
plot(t1(peakid1), y1(peakid1), 'bo', t1(startid1), y1(startid1), 'b*')
%             if AMP2>0
                k = k+1;
                Ampl1(k) = AMP1;
                Ampl2(k) = AMP2;
subplot(2,1,2)
plot(t1(peakid1), peak2, 'bo', t1(startid1), start2, 'b*')
%             end
            Dists = [Dists t2(EventInd2(2,:))-t1(peakid1)];
        end
    end
figure(2)
m = ceil(psthRange/psthBin);
range = (m+0.5)*psthBin;
Dists = Dists*60;
NumDists = length(Dists);
Dists = Dists(Dists<=range & Dists>=-range);
x = -m*psthBin:psthBin:m*psthBin;
[n xout] = hist(Dists,x);
% n = n/NumDists*100;
n = n/sum(n)*100;
bar(xout,n,1)
set(gca, 'XLim', [-range range])
xlabel(sprintf('Time between %s and %s spikes (sec)', GName1, GName2));
ylabel('Frequency (%)')
title(sprintf('Peri-Spike Time Histogram %s -> %s (N=%g; n=%g)', GName1, GName2, NumRecs, TotalNumEvents1))


figure(3)
hold off
plot(Ampl1, Ampl2, 'k.')
[R P] = corr(Ampl1', Ampl2');
[a b] = LinearFit(Ampl1, Ampl2);
AmpRatio = Ampl2./Ampl1;
AmpRatioMean = mean(AmpRatio);
AmpRatioSEM = sqrt(var(AmpRatio)/length(AmpRatio));

hold on
plot([min(Ampl1) max(Ampl1)] ,b+a*[min(Ampl1) max(Ampl1)], 'k')
xlabel(sprintf('%s spike amplitude (%% ratio change)', GName1));
ylabel(sprintf('Corresponding amplitude in %s (%% ratio change)', GName2));
title(sprintf('Correlation between %s and %s spike amplitudes n=%g/%g Rho=%g p=%g slope=%g', GName1, GName2, length(Ampl1), TotalNumEvents1, R, P, a));
disp(sprintf('Amp2/Amp1 = %g +- %g', AmpRatioMean, AmpRatioSEM));


figure(4)
ISI1 = ISI1*60;
mx1 = max(ISI1);
ISI2 = ISI2*60;
mx2 = max(ISI2);
mx12 = max([mx1 mx2]);

subplot(2,1,1)
ISI1mean = mean(ISI1);
ISI1std = std(ISI1);
ISI1CV = ISI1std / ISI1mean;
x = 0:mx12;
[n xout] = hist(ISI1);
n = n/sum(n);
% bar(xout, n, 1)
plot([0 xout], [0 n], 'k')
axis([0 x(end) 0 1])
xlabel(sprintf('%s ISI (sec)', GName1))
ylabel('Density')
title(sprintf('%s ISI histogram Mean=%2.2f CV=%2.2f (N=%g; n=%g)', GName1, ISI1mean, ISI1CV, NumRecs, length(ISI1)));

subplot(2,1,2)
ISI2mean = mean(ISI2);
ISI2std = std(ISI2);
ISI2CV = ISI2std / ISI2mean;
% x = 0:mx2;
[n xout] = hist(ISI2);
n = n/sum(n);
% bar(xout, n/sum(n), 1)
plot([0 xout], [0 n], 'k')
axis([0 x(end) 0 1])
xlabel(sprintf('%s ISI (sec)', GName2))
ylabel('Density')
title(sprintf('%s ISI histogram Mean=%2.2f CV=%2.2f (N=%g; n=%g)', GName2, ISI2mean, ISI2CV, NumRecs, length(ISI2)));

end

