function SF_RawTraceDataFile

global Experiment Plots

[~, name] = fileparts(Experiment.Name);
FileName = sprintf('%s-RawTraceData-%s.txt', name, date);
[FileName, path] = uiputfile('*.txt', 'Output file', FileName);
if ischar(FileName)
    fid = fopen(fullfile(path, FileName), 'w');

    if Plots.Flags.IncludeOutRecords
        IncOut = 1;
    else
        IncOut = 0;
    end
    for g = 1:Experiment.NumGrps
        Group = Experiment.Groups(g).Group;
        fprintf(fid, '%s (Time,Ratio change)\n', Group.Name);
        for r=1:Group.NumRecs
            Record = Group.Records(r).Record;
            if ~isfield(Record.Flags, 'In')
                Group.Records(r).Record.Flags.In = 1;
            end
        end
        for r=1:Group.NumRecs
            Record = Group.Records(r).Record;
            if Record.Flags.In || IncOut
                T = Record.Trace.T*60;
                F = Record.Trace.F;
                F0 = mean(F(T<=T(1)+3));
                R = (F-F0)/F0*100;
    %             fprintf(fid, 'T(sec) ');
                fprintf(fid, '%g ', T);
                fprintf(fid, '\n');
    %             fprintf(fid, 'R ');
                fprintf(fid, '%g ', R);
                fprintf(fid, '\n');
            end
        end
    end
    fclose(fid);
end
