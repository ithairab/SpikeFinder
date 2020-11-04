function SF_DisplayParents(handles)

global Record IDs

if ~isempty(Record) && isfield(Record, 'ParentEvents') && ~isempty(Record.ParentEvents.ParentInd)
    ParentList = num2str(Record.Trace.T(Record.ParentEvents.ParentInd(1,:))', '%4.1f');
else
    ParentList = {};
end
set(handles.listbox_ParentEvnts, 'String', ParentList, 'Value', IDs.Parent);

ParentColor = [1 0 0];
if ~isfield(Record.Flags, 'ParentEventsAnalyzed') || (isfield(Record.Flags, 'ParentEventsAnalyzed') && Record.Flags.ParentEventsAnalyzed)
    ParentColor = [0 0 0];
end
set(handles.pushbutton_ParentEvntAnalyze, 'ForeGroundColor', ParentColor);
