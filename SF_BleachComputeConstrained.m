function SF_BleachComputeConstrained
% find r0 given that tau is constrained

global Record

EventInd = Record.Events.EventInd;
IndIn = Record.Events.IndIn;

T = Record.Trace.T;
R0 = Record.Trace.R0;

IndStart = EventInd(1,IndIn);
TStart = T(IndStart);
R0Start = R0(IndStart);

TauBl = Record.Params.TauBl;
r0 = (R0Start*(exp(-TStart/TauBl))') / sum(exp(-TStart/TauBl));

Record.Trace.BL = r0*exp(-T/TauBl);

