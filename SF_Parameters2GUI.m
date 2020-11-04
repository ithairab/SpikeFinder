function SF_Parameters2GUI(handles, Type)

global Params
eval(sprintf('N = numel(Params.%s.Names);', Type));
for i=1:N
    eval(sprintf('tag = Params.%s.Tags{i};', Type));
    if isfield(handles, tag)
        eval(sprintf('h = handles.%s;', tag));
        eval(sprintf('strvalue = Params.%s.Values{i};', Type));
        set(h, 'String', strvalue);
    end
end
