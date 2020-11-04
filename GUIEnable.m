function GUIEnable(handles, GUIList, State)

% GUIList is a list of strings {'tag1', 'tag2'} of gui tags
% State is a vector of 0 and 1 or a scalar 0 or 1 to apply to all gui
% elements

N = numel(GUIList);
if length(State) < N
    State = ones(1,N) * State(1);
end
for i=1:N
    if isfield(handles, GUIList{i})
        eval(sprintf('h = handles.%s;', GUIList{i}));
        state = 'off';
        if State(i)
            state = 'on';
        end
        set(h, 'Enable', state);
    end
end
