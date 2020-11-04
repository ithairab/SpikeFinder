function SF_AnalyzeSubEvents(handles)

global Record

% SubEvents
SubEventInd = Record.SubEvents.EventInd;
IndIn = Record.SubEvents.IndIn;
T = Record.Trace.T;
R0 = Record.Trace.R0;
BL = Record.Trace.BL;
TAmp = T(SubEventInd(2, IndIn));
% Events
NumEvents = Record.Events.NumIndIn;
StrtInd = Record.Events.Analyzed.StrtInd;
EndInd = Record.Events.Analyzed.EndInd;

for i=1:NumEvents
    ind = find(TAmp>T(StrtInd(i)) & TAmp<T(EndInd(i)));
    Record.SubEvents.Analyzed.Parent(ind) = i;
    Record.SubEvents.Analyzed.ISI(ind(1:end-1)) = diff(TAmp(ind));
end
Record.SubEvents.Analyzed.Amp = R0(SubEventInd(2, IndIn)) - BL(SubEventInd(2, IndIn));
