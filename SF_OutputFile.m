function SF_OutputFile(handles)

global Experiment Plots

N = Experiment.NumGrps;
TypeID = get(handles.popupmenu_PlotType, 'Value');
FeatureID = get(handles.popupmenu_PlotFeatures1, 'Value');
EventType = 'Events';
TypeList = Plots.Types.EventList;
FeatureList = Plots.Features.EventList;
TypeInd = TypeList(TypeID);
TypeFeatureList = intersect(Plots.Types.FeatureList{TypeInd}, FeatureList);
FeatureInd = TypeFeatureList(FeatureID);
MeasureName = Plots.Features.VarList{FeatureInd};

[pathstr name] = fileparts(Experiment.Name);
FileName = sprintf('%s-%s-%s-%s.txt', name, EventType, MeasureName, date);
[FileName path] = uiputfile('*.txt', 'Output file', FileName);
fid = fopen(fullfile(path, FileName), 'w');
for i=1:N
    Group = Experiment.Groups(i).Group;
    eval(sprintf('Data=Group.Summary.%s.%s.Data;', EventType, MeasureName));
    fprintf(fid, '%s ', Group.Name);
    fprintf(fid, '%f ', Data);
    fprintf(fid, '\n');
end
fclose(fid);
