function DisplaySpikes(handles, Type)

global Record

if ~isempty(Record) && isfield(Record.Events, 'EventInd') && ~isempty(Record.Events.EventInd)
    FrameRate = Record.Params.FMS;
    eval(sprintf('EventInd = Record.%s.EventInd;', Type));
    eval(sprintf('IndIn = Record.%s.IndIn;', Type));
    eval(sprintf('IndOut = Record.%s.IndOut;', Type));
    InList = num2str(Record.Trace.T(EventInd(1,IndIn))', '%4.1f');
    OutList = num2str(Record.Trace.T(EventInd(1,IndOut))', '%4.1f');
    EventsExist = 1;
else
    InList = {};
    OutList = {};
    EventsExist = 0;
end

check = 0;
if strcmp(Type, 'Events')
    hIn = handles.listbox_EvntIn;
    hOut = handles.listbox_EvntOut;
    check = 1;
elseif strcmp(Type,'SubEvents')
    hIn = handles.listbox_SbEvntIn;
    hOut = handles.listbox_SbEvntOut;
    check = 1;
end
if check
%     set(hIn, 'Value', 1, 'String', InList);
    set(hIn, 'String', InList);
    if ~isempty(InList)
        set(handles.pushbutton_EvntOut, 'Enable', 'on');
    end
%     set(hOut, 'Value', 1, 'String', OutList);
    set(hOut, 'String', OutList);
    if ~isempty(OutList)
        set(handles.pushbutton_EvntIn, 'Enable', 'on');
    end
    if EventsExist
        SF_PlotSpikes(handles, Type);
    end
end