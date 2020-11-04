function SF_BleachCompute

global Record

EventInd = Record.Events.EventInd;
IndIn = Record.Events.IndIn;
NumIndIn = Record.Events.NumIndIn;

T = Record.Trace.T;
R0 = Record.Trace.R0;

IndStart = EventInd(1,IndIn);

if NumIndIn>1
    TStart = T(IndStart)';
    % R0Start = R0(IndStart)';
    R0Start = R0(IndStart)'-min(R0);
elseif NumIndIn==1
    TStart = [T(1); T(IndStart)'];
    R0Start = [R0(1); R0(IndStart)']-min(R0);
else
    TStart = T;
    R0Start = R0;
end
    
[a b] = LinearFit(TStart, log(R0Start));
r0 = exp(b);
TauBl = -1/a;
% RBl = R0/r0 - exp(-T/TauBl);
Record.Params.TauBl = TauBl;
Record.Trace.BL = r0*exp(-T/TauBl);

