function SF_AnalyzeEventTrigger(prewindow, postwindow)

% time arguments in seconds

global Experiment IDs

Group = Experiment.Groups(IDs.Group).Group;
max_FrameRate = 0;
NumEvents = 0;
for j = 1:Group.NumRecs
    Record = Group.Records(j).Record;
    FrameRate = Record.Params.FMS;
    if FrameRate>max_FrameRate
        max_FrameRate = FrameRate;
    end
    NumEvents = NumEvents + Record.Events.NumIndIn;
end
% interpolate all traces to trace with highest FrameRate
max_preind = round(prewindow*60*max_FrameRate);
max_postind = round(postwindow*60*max_FrameRate);
max_indw = -max_preind:max_postind;
max_t = max_indw/FrameRate;
Heap = zeros(NumEvents, length(max_indw));
k = 0;
for j = 1:Group.NumRecs
    Record = Group.Records(j).Record;
    T = Record.Trace.T;
    FrameRate = Record.Params.FMS;
    preind = round(prewindow*60*FrameRate);
    postind = round(postwindow*60*FrameRate);
    indw = -preind:postind;
    t = indw/FrameRate;
    StrtInd = Record.Events.Analyzed.StrtInd;
    for i = 1:Record.Events.NumIndIn
        ind = indw+StrtInd(i);
        if (ind(end)<=length(T))
            k = k+1;
            Y = Record.Trace.R0(ind) - Record.Trace.BL(ind);
            Y = Record.Trace.M(1,ind);
            Heap(k,:) = interp1(t,Y,max_t);
        end
    end
end
K = k;
Heap = Heap(1:K,:);
Averaged = mean(Heap);
figure(2)
hold off
% plot(repmat(max_t, K,1)',Heap')
% hold on
plot(max_t,Averaged, 'k', 'LineWidth', 2);
grid on
xlabel('Time (seconds)')
title(sprintf('%s  N = %2.0f  (n = %2.0f)', Group.Name, Group.NumRecs, K));

