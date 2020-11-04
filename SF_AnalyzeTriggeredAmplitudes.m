function SF_AnalyzeTriggeredAmplitudes(TriggerGroupID, TargetGroupID)

% computes the max to min difference in the Target group trace within
% each spike time window of the Trigger group

global Experiment

NumRecs(1) = Experiment.Groups(TriggerGroupID).Group.NumRecs;
NumRecs(2) = Experiment.Groups(TargetGroupID).Group.NumRecs;

if any(diff(NumRecs))
    errordlg('Not all traces are paired between groups');
else
    NumRecs = NumRecs(1);
    EventCount = 0;
    RecordCount = 0;
    for r = 1:NumRecs
% r=1;
        RecordOK = 0;
        Rec1 = Experiment.Groups(TriggerGroupID).Group.Records(r).Record;
        Rec2 = Experiment.Groups(TargetGroupID).Group.Records(r).Record;
        t1 = Rec1.Trace.T;
        t2 = Rec2.Trace.T;
        y1 = Rec1.Trace.R;
        y2 = Rec2.Trace.R;
        EventInd = Rec1.Events.EventInd(:, Rec1.Events.IndIn);
        NumEvents = Rec1.Events.NumIndIn;
        start2peak = EventInd(2,:) - EventInd(1,:);
        for i = 1:NumEvents
            % window width is double the start to peak time
%             window1 = EventInd(1,i):EventInd(2,i)+start2peak(i);
            window1 = EventInd(1,i):EventInd(2,i);
            if window1(end)<=length(y1)
                startind2 = find(t2<=t1(window1(1)),1,'last');
                endind2 = find(t2>=t1(window1(end)),1,'first');
                if ~isempty(endind2) && ~isempty(startind2)
                    RecordOK = 1;
                    window2 = startind2:endind2;
%                     Amp1(EventCount) = max(y1(window1)) - min(y1(window1));
%                     Amp2(EventCount) = max(y2(window2)) - min(y2(window2));
                    AMP1 = y1(EventInd(2,i)) - y1(EventInd(1,i));
                    AMP2 = y2(startind2) - y2(endind2);
                    if AMP2>0
                        EventCount = EventCount+1;
                        Amp1(EventCount)=AMP1;
                        Amp2(EventCount)=AMP2;
                    end
%                     figure(2)
%                     hold off
%                     plot(t1,y1,'k', t1(window1),y1(window1),'r')
%                     plot(t2,y2,'b', t2(window2),y2(window2),'r')
                    
                end
            end
        end
        if RecordOK
            RecordCount = RecordCount+1;
        end
    end
end

figure(1)
clf
plot(Amp1, Amp2, 'k.')

[R P] = corr(Amp1', Amp2')
[a b] = LinearFit(Amp1, Amp2);

hold on
plot(Amp1,b+a*Amp1)
