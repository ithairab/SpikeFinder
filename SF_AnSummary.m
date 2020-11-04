function SF_AnSummary(Type, MeasureName)

global Experiment IDs Params
for k = 1:Experiment.NumGrps
    Group = Experiment.Groups(k).Group;
    if isfield(Group, 'Show') & Group.Show | ~isfield(Group, 'Show')
        eval(sprintf('Group.Summary.%s.NumRecs = 0;', Type));
        eval(sprintf('Group.Summary.%s.NumEvents = 0;', Type));
        eval(sprintf('Group.Summary.%s.%s.Data = [];', Type, MeasureName));
        for i = 1:Group.NumRecs
            FlagName = sprintf('%sAnalyzed', Type);
            if isfield(Group.Records(i).Record.Flags, FlagName)
                eval(sprintf('ok = Group.Records(i).Record.Flags.%sAnalyzed;', Type));
                if ok
                    Record = Group.Records(i).Record;
                    FuncName = Params.Summary.FuncNames{1}{IDs.Summary.Parents};
                    eval(sprintf('fhandle = @%s;', FuncName));
                    Data = feval(fhandle, Record, MeasureName);
                    if ~isempty(Data)
                        eval(sprintf('Group.Summary.%s.NumEvents = Group.Summary.%s.NumEvents+length(Data);', Type, Type));
                        eval(sprintf('Group.Summary.%s.NumRecs = Group.Summary.%s.NumRecs+1;', Type, Type));
                        if IDs.Summary.Summation==1
                            Data = mean(Data);
                        end
                        eval(sprintf('Group.Summary.%s.%s.Data = [Group.Summary.%s.%s.Data Data];',...
                            Type, MeasureName, Type, MeasureName));
                    end
                end
            end
        end
        cmd = sprintf('Group.Summary.%s.%s.Mean = mean(Group.Summary.%s.%s.Data);', Type, MeasureName, Type, MeasureName);
        eval(cmd);
        cmd = sprintf('Group.Summary.%s.%s.STD = std(Group.Summary.%s.%s.Data);', Type, MeasureName, Type, MeasureName);
        eval(cmd);
        cmd = sprintf('Group.Summary.%s.%s.SEM = Group.Summary.%s.%s.STD/sqrt(length(Group.Summary.%s.%s.Data));',...
            Type, MeasureName, Type, MeasureName, Type, MeasureName);
        eval(cmd);
        cmd = sprintf('Group.Summary.%s.%s.CV = Group.Summary.%s.%s.STD/Group.Summary.%s.%s.Mean;',...
            Type, MeasureName, Type, MeasureName, Type, MeasureName);
        eval(cmd);
        Experiment.Groups(k).Group = Group;
    end
end


% ===================================================
% Specific functions for various event type summaries
% ===================================================
% =========================================================================

% All events
function Data = SF_AnSummaryAll(Record, MeasureName)
global IDs Experiment
Analyzed = Record.Events.Analyzed;
if ~isempty(Record.Events.IndIn)
    EventIndIn = Record.Events.EventInd(1,Record.Events.IndIn);
else
    EventIndIn = [];
end
Ind = 1:Record.Events.NumIndIn;
AmpSepSbtrct = 0;
switch IDs.Summary.Separator
    case 2
        if isfield(Record, 'SeparatorID') && ~isempty(Record.SeparatorID)
            Ind = find(EventIndIn<Record.SeparatorID);
            if isfield(Experiment.Flags, 'SeparatorSubtract') && Experiment.Flags.SeparatorSubtract
                AmpSepSbtrct = Record.Trace.R(Record.SeparatorID);
            end
        else
            Ind = [];
        end
    case 3
        if isfield(Record, 'SeparatorID') && ~isempty(Record.SeparatorID)
            Ind = find(EventIndIn>Record.SeparatorID);
        end
end
eval(sprintf('AnInd = find(~isnan(Analyzed.%s));', MeasureName));
AnInd = intersect(Ind, AnInd);
eval(sprintf('Data = Analyzed.%s(AnInd);', MeasureName)); 
if strmatch(MeasureName, 'AmpAbs')
    Data = Data - AmpSepSbtrct;
end

% =========================================================================

% Only parent events
function Data = SF_AnSummaryParents(Record, MeasureName)
global IDs
Data = [];
if isfield(Record, 'ParentEvents') && isfield(Record.ParentEvents, 'Analyzed') && ~isempty(Record.ParentEvents.Analyzed)
    Analyzed = Record.ParentEvents.Analyzed;
    ParentInd = Record.ParentEvents.ParentInd(1,:);
    NumParents = Record.ParentEvents.NumParents;
    Ind = 1:NumParents;
    switch IDs.Summary.Separator
        case 2
            if isfield(Record, 'SeparatorID') && ~isempty(Record.SeparatorID)
                Ind = find(ParentInd<Record.SeparatorID);
            else
                Ind = [];
            end
        case 3
            if isfield(Record, 'SeparatorID') && ~isempty(Record.SeparatorID)
                Ind = find(ParentInd>Record.SeparatorID);
            end
    end
    eval(sprintf('AnInd = find(~isnan(Analyzed.%s));', MeasureName));
    AnInd = intersect(Ind, AnInd);
    eval(sprintf('Data = Analyzed.%s(AnInd);', MeasureName)); 
end

% =========================================================================

% Only child events of parent events
function Data = SF_AnSummaryChildren(Record, MeasureName)
global IDs
Data = [];
if isfield(Record, 'ParentEvents')
    Analyzed = Record.Events.Analyzed;
    NumParents = Record.ParentEvents.NumParents;
    for i = 1:NumParents
        ChildInd = Record.ParentEvents.ChildInd{i};
        NumChild = length(ChildInd);
        if strcmp(MeasureName, 'ISI')
            if ChildInd(end) == Record.Events.NumIndIn
                ChildInd = ChildInd(1:end-1);
                NumChild = NumChild-1;
            end
            Ind = 1:NumChild-1;
        else
            Ind = 1:NumChild;
        end
        ChildEventInd = Record.Events.EventInd(1,Record.Events.IndIn(ChildInd));
        switch IDs.Summary.Separator
            case 2
                if isfield(Record, 'SeparatorID') && ~isempty(Record.SeparatorID)
                    Ind = Ind(ChildEventInd(Ind)<Record.SeparatorID);
                else
                    Ind = [];
                end
            case 3
                if isfield(Record, 'SeparatorID') && ~isempty(Record.SeparatorID)
                    Ind = Ind(ChildEventInd(Ind)>Record.SeparatorID);
                end
        end

        eval(sprintf('AnInd = find(~isnan(Analyzed.%s(ChildInd)));', MeasureName));
        AnInd = intersect(Ind, AnInd);
        eval(sprintf('Data = [Data Analyzed.%s(ChildInd(AnInd))];', MeasureName)); 
    end
end
