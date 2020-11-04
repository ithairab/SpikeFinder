function SF_ExperimentUnSaved(handles)

global Experiment IDs Record

Experiment.Groups(IDs.Group).Group.Records(IDs.Record).Record = Record;
Experiment.Flags.Saved = 0;
set(handles.text_ExperimentFile, 'String', ['*' Experiment.Name]);
set(handles.pushbutton_ExperimentSave, 'ForegroundColor', [1 0 0]);

