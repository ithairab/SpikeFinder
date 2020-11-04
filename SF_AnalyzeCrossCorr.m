function SF_AnalyzeCrossCorr(Gnums, VarNames, lagt)

% average cross correlation between paired variables (VarNames{1} and VarNames{2}
% in groups Gnums(1) and Gnums(2)

global Experiment

NumRecs = zeros(2,1);
for g = 1:2
    group = Experiment.Groups(Gnums(g)).Group;
    NumRecs(g) = group.NumRecs;
end
if any(diff(NumRecs))
    errordlg('Not all traces are paired between groups');
else
    NumRecs = NumRecs(1);
    dTs = zeros(NumRecs,1);
    StrtEndTlags = zeros(NumRecs,2);
    k = 0;
    k2 = 0;
    for r = 1:NumRecs
        t1 = Experiment.Groups(Gnums(1)).Group.Records(r).Record.Trace.T;
        t2 = Experiment.Groups(Gnums(2)).Group.Records(r).Record.Trace.T;
        eval(sprintf('y1 = Experiment.Groups(Gnums(1)).Group.Records(r).Record.Trace.%s;', VarNames{1}));
        eval(sprintf('y2 = Experiment.Groups(Gnums(2)).Group.Records(r).Record.Trace.%s;', VarNames{2}));
        ind1 = find(~isnan(y1));
        y1 = y1(ind1);
        t1 = t1(ind1);
        ind2 = find(~isnan(y2));
        y2 = y2(ind2);
        t2 = t2(ind2);
        Duration = min([t1(end)-t1(1), t2(end)-t2(1)]);
        if Duration>lagt
            k=k+1;
            DurOK(k) = r;
            [Tlags{k} CCs{k}] = CrossCorr(t1, y1, t2, y2, lagt);
            dTs(r) = Tlags{k}(2)-Tlags{k}(1);
            StrtEndTlags(r,:) = [Tlags{k}(1), Tlags{k}(end)];
        end
    end
    dT = min(dTs(DurOK));
    maxStrt = max(StrtEndTlags(DurOK,1));
    minEnd = min(StrtEndTlags(DurOK,2));
    Tlag = maxStrt+dT:dT:minEnd-dT;
    CC = zeros(k, length(Tlag));
    for r = 1:k
        CC(r,:) = interp1(Tlags{r}, CCs{r}, Tlag);
    end
    CCMean = mean(CC, 1);
    [maxCC maxlagID] = max(CCMean);
    disp(sprintf('lag = %2.1f sec', Tlag(maxlagID)*60))
    disp(sprintf('R = %2.3f +- %2.3f', mean(CC(:,maxlagID)), std(CC(:,maxlagID))/sqrt(k)))
    
    
    figure(1)
    clf
    % plot(repmat(Tlag', 1, k), CC')
    hold on
    plot(Tlag, CCMean,'k');
    grid on
end

