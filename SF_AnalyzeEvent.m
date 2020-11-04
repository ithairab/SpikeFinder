function SF_AnalyzeEvent(handles, i)

global Record

EventInd = Record.Events.EventInd;
IndIn = Record.Events.IndIn;
NumEvents = length(IndIn);
T = Record.Trace.T;
F = Record.Trace.F;

StrtID = Record.Events.Analyzed.StrtInd(i);
PeakID = Record.Events.Analyzed.PeakInd(i);
ind = StrtID:PeakID; % start to end
f = F(ind);
t = T(ind);
ampstrt0 = (f(end) - f(1))/f(1)*100; % ratio change relative to start of spike
dt0 = 60*(t(end)-t(1)); % time from spike start to spike peak in sec
Record.Events.Analyzed.AmpStrt0(i) = ampstrt0;
Record.Events.Analyzed.ClimbRate(i) = ampstrt0 / dt0;
if i<NumEvents
    StrtNxtID = Record.Events.Analyzed.StrtInd(i+1);
    Record.Events.Analyzed.ISI(i) = T(StrtNxtID)-T(StrtID);
end
