function SF_AnalyzeBurstDetect

global Record

h = 0.1; % fraction of spike amplitude for width calculatoin

R = Record.Trace.R;
T = Record.Trace.T;

EventInd = Record.Events.EventInd(:, Record.Events.IndIn);
NumEvents = Record.Events.NumIndIn;

k = 0;
InBurst = 0;
figure(1)
hold off
plot(T,R)
hold on
for i = 1:NumEvents-1
    plot(T(EventInd(2,i)), R(EventInd(2,i)), 'r.')
    if InBurst && R(EventInd(1,i+1)) > hAMP
        Burst{k} = [Burst{k} i];
    else
        InBurst = 0;
        hAMP = R(EventInd(1,i)) + h*(R(EventInd(2,i)) - R(EventInd(1,i)));
        if R(EventInd(1,i+1)) > hAMP
            k = k+1;
            Burst{k} = i;
            InBurst = 1;
        end
    end
end

NumBursts = numel(Burst);
for k = 1:NumBursts
    first = Burst{k}(1);
    last = Burst{k}(end);
    plot(T(EventInd(2,first:last)), R(EventInd(2,first:last)), 'r')
end