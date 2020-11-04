function SF_Update_RecordInOut(handles)
global Record
if isempty(Record)
    set(handles.pushbutton_RecordInOut, 'String', 'In', 'ForegroundColor', [0 0 0]);
else
    if ~isfield(Record.Flags, 'In') || Record.Flags.In
        set(handles.pushbutton_RecordInOut, 'String', 'In', 'ForegroundColor', [0 1 0]);
    else
        set(handles.pushbutton_RecordInOut, 'String', 'Out', 'ForegroundColor', [1 0 0]);
    end
%     SF_PlotTraces(handles);
end