function SF_PlotManager(handles, AxHandle)

global Plots Experiment Params IDs

axes(AxHandle);
if ~Plots.Flags.Hold
    cla reset;
end
set(gca, 'Position', Plots.Axes.Positions{1});

rand('state', 9895);
C = rand(Experiment.NumGrps,3);
colormap(C);

TypeID = get(handles.popupmenu_PlotType, 'Value');
FeatureID = get(handles.popupmenu_PlotFeatures1, 'Value');
EventType = 'Events';
TypeList = Plots.Types.EventList;
FeatureList = Plots.Features.EventList;
TypeInd = TypeList(TypeID);
Plots.Types.Ind = TypeInd;
TypeFeatureList = intersect(Plots.Types.FeatureList{TypeInd}, FeatureList);
FeatureInd = TypeFeatureList(FeatureID);
Plots.Features.Ind(1) = FeatureInd;
FuncName = Plots.Types.FuncNameList{TypeInd};
ArgStr{1} = Plots.Features.VarList{FeatureInd};
ArgStr{2} = Plots.Features.UnitList{FeatureInd};
if Plots.Types.NumArgList(TypeInd) == 2
    FeatureID = get(handles.popupmenu_PlotFeatures2, 'Value');
    FeatureInd = FeatureList(FeatureID);
    Plots.Features.Ind(2) = FeatureInd;
    ArgStr{3} = Plots.Features.VarList{FeatureInd};
    ArgStr{4} = Plots.Features.UnitList{FeatureInd};
end
Param = [];
ParamList = Plots.Types.ParamList{TypeInd};
for i=1:length(ParamList)
    Param{i} = Params.Analysis.Values(ParamList(i));
end
eval(sprintf('fhandle = @%s;', FuncName));
feval(fhandle, EventType, ArgStr, Param);
set(AxHandle, 'Color', [236 233 216]/256);
