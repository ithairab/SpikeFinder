function TraceCompatabilize

global Trace
% version <2 to >2

% CMP = exist('Compat', 'var');
CMP = isfield(Trace, 'Compat');
if ~CMP
    Trace.Param.Switch = Trace.Switch;
    Trace.Data.Fluo = Trace.Fluo;
    Trace.Data.T = Trace.T;
    Trace.ROI.C_M = Trace.C_M;
    Trace.Param.FMS = Trace.FMS;
end
if ~isfield(Trace.Param, 'Comment')
    Trace.Param.Comment = '';
end
