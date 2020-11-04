function SF_TraceInvert

global Record

Record.Trace.R = Record.Trace.R * -1;
Record.Trace.F = Record.Trace.F * -1;
Record.Trace.Y = Record.Trace.Y * -1;
Record.Trace.C = Record.Trace.C * -1;
Record.Axis.Lim0(3:4) = Record.Axis.Lim0(4:-1:3) * -1;
Record.Axis.Lim(3:4) = Record.Axis.Lim(4:-1:3) * -1;

% Record.Trace.FluoRaw = Record.Trace.FluoRaw * -1;
% Record.Trace.Fluo = Record.Trace.Fluo * -1;
% Record.Trace.R0 = Record.Trace.R0 * -1;
% Record.Trace.BG = Record.Trace.BG * -1;
