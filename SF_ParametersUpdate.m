function check = SF_ParametersUpdate(handles, Type)

global Params Experiment Record IDs
check = 1;
eval(sprintf('N = numel(Params.%s.Names);', Type));
for i=1:N
    eval(sprintf('tag = Params.%s.Tags{i};', Type));
    if isfield(handles, tag)
        eval(sprintf('h = handles.%s;', tag));
        strvalue = get(h, 'String');
        v = str2double(char(strvalue));
        checkstr = eval(sprintf('Params.%s.Cond{i}', Type));
        cond = eval(sprintf(checkstr, v));
        if cond
            eval(sprintf('Params.%s.Values{i} = strvalue;', Type));
        else
            check = 0;
            eval(sprintf('strvalue = Params.%s.Values{i};', Type));
            set(h, 'String', strvalue);
            break;
        end
    end
end
if check && ~isempty(Experiment)
    if strcmp('Events', Type) || strcmp('SubEvents', Type)
        eval(sprintf('Record.%s.Params = Params.%s;', Type, Type));
        if ~isempty(Record)
            Experiment.Groups(IDs.Group).Group.Records(IDs.Record).Record = Record;
        end
    end
    SF_ExperimentUnSaved(handles);
end
