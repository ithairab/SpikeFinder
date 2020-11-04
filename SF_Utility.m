function SF_Utility

% change a value for all records in all groups
global Experiment Record IDs

NumGrps = Experiment.NumGrps;
for Gi = 1:NumGrps
    Group = Experiment.Groups(Gi).Group;
    NumRecs = Group.NumRecs;
    for Ri = 1:NumRecs
        Rec = Group.Records(Ri).Record;
        % =================================================================
        % value to change:
        Rec.Events.Analyzed.PeakInd = Rec.Events.Analyzed.PeakInd-1;
        Rec.Events.EventInd(2,Rec.Events.IndIn) = Rec.Events.Analyzed.PeakInd;
        % =================================================================
        Experiment.Groups(Gi).Group.Records(Ri).Record = Rec;
        if IDs.Group==Gi && IDs.Record==Ri
            Record = Rec;
        end
    end
end
% don't forget to save the experiment