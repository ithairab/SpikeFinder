function SF_RecordRetrieve(handles)

global Record Experiment IDs Params

if IDs.Group
    Group = Experiment.Groups(IDs.Group).Group;
else
    Group = [];
end
EventColor = [1 0 0];
IDs.Parent = 1;
if ~isempty(Group) && Group.NumRecs
    Record = Group.Records(IDs.Record).Record;
    Params.Events = Record.Events.Params;
    SF_Parameters2GUI(handles, 'Events');
TimeTypes = get(handles.popupmenu_TimeType, 'String');
TimeType = TimeTypes{get(handles.popupmenu_TimeType, 'Value')};
if strcmp(TimeType, 'Stamp')
    Record.Trace.T = Record.Trace.Tstamp;
else
    Record.Trace.T = Record.Trace.Tmean;
end
    SF_PlotTraces(handles);
    set(handles.listbox_RecordIn, 'Value', IDs.Record, 'String', Group.RecordList);
    set(handles.pushbutton_RecordRemove, 'Enable', 'on');
    set(handles.uipanel_Record, 'Title', sprintf('Record %g/%g Analyzed %g', IDs.Record, Group.NumRecs, Group.NumAnalyzed));
    set(handles.listbox_EvntIn, 'Value', 1);
    set(handles.listbox_EvntOut, 'Value', 1);
    set(handles.listbox_ParentEvnts, 'Value', 1);
    if ~isfield(Record.Flags, 'Invert')
        Record.Flags.Invert = 0;
    end
    if isfield(Record.Params,'BleachCorrect') && ~isempty(Record.Trace.BL)
        set(handles.radiobutton_BleachCorrect,'Value',Record.Params.BleachCorrect);
    else
        set(handles.radiobutton_BleachCorrect,'Value',0);
    end
    set(handles.checkbox_RecordInvert,'Value', Record.Flags.Invert);
    NumIndIn = 0; NumIndOut = 0;
    if isfield(Record.Events, 'NumIndIn')
        NumIndIn = Record.Events.NumIndIn;
    end
    if isfield(Record.Events, 'IndOut')
        NumIndOut = length(Record.Events.IndOut);
    end
    state = logical([NumIndIn NumIndOut]);
    DisplaySpikes(handles, 'Events');
    SF_DisplayParents(handles);
    if Record.Flags.EventsAnalyzed
        EventColor = [0 0 0];
    end
    if isfield(Record.Events, 'SourceID') && IDs.Event.Source ~= Record.Events.SourceID
        SF_AnalyzeSpikeDetect;
%         IDs.Event.Source = Record.Events.SourceID;
%         set(handles.popupmenu_EventSource, 'Value', IDs.Event.Source);
    end
else
    Record = [];
    axes(handles.axes_YFP)
    cla
    axes(handles.axes_CFP)
    cla
    axes(handles.axes_Ratio)
    cla   
    axis off
    state = zeros(1,2);
    set(handles.listbox_RecordIn, 'String', {});
    set(handles.listbox_EvntIn, 'String', {}, 'Value', 1);
    set(handles.listbox_EvntOut, 'String', {}, 'Value', 1);
    set(handles.listbox_ParentEvnts, 'String', {}, 'Value', 1);
    set(handles.pushbutton_RecordRemove, 'Enable', 'off');
    set(handles.uipanel_Record, 'Title', 'Record');
    set(handles.checkbox_RecordInvert,'Value', 0);
end
GUIList = {'pushbutton_EvntOut', 'pushbutton_EvntIn'};
GUIEnable(handles, GUIList, state);
set(handles.pushbutton_EventsAnalyze, 'ForegroundColor', EventColor);
SF_Update_RecordInOut(handles);
