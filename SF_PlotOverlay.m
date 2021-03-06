function SF_PlotMeanOverlay(EventType, ArgStr, Param)

% plot mean trace and SEM assuming that traces are of identical time length

global Experiment IDs Plots

MeasureName = ArgStr{1};
UnitName = ArgStr{2};
Window = str2num(char(Param{1}));
SwitchTime = str2num(char(Param{2}));

xlabelStr = sprintf('Time (%s)', Plots.TimeUnit.List{IDs.TimeUnit});

if Experiment.NumGrps>0

    Group = Experiment.Groups(IDs.Group).Group;
    
    if Plots.Flags.IncludeOutRecords
        N = Group.NumRecs;
        IncOut = 1;
    else
        if isfield(Group, 'NumRecsIn')
            N = Group.NumRecsIn;
        else
            N = Group.NumRecs;
        end
        IncOut = 0;
    end
    
    for r=1:Group.NumRecs
        Record = Group.Records(r).Record;
        if ~isfield(Record.Flags, 'In')
            Group.Records(r).Record.Flags.In = 1;
        end
    end
    
    if strcmp(MeasureName, 'MotionOnset')
        M = zeros(Group.NumRecs,1);
        k = 0;
        for r=1:Group.NumRecs
            Record = Group.Records(r).Record;
            if Record.Flags.In || IncOut
                if isfield(Record, 'Motion') && isfield(Record.Motion, 'StrtInd') && ~isempty(Record.Motion.StrtInd)
                    k=k+1;
                    M(r) = 1;
                end
            end
        end
        N = k;
    end
    
    if N>0
        ratio = cell(N,1);
        T = cell(N,1);

        MinLenPre = NaN;
        MinLenPost = NaN;
        MinLenIDPost = 0;
        k = 0;
        for r=1:Group.NumRecs
            if strcmp(MeasureName, 'TraceStart') || strcmp(MeasureName, 'MotionOnset') && M(r)
                Record = Group.Records(r).Record;
                t = Record.Trace.T * Plots.TimeUnit.Factor(IDs.TimeUnit);
                if strcmp(MeasureName, 'TraceStart')
                    AlignID = 1;
                    StrtID = AlignID;
                elseif strcmp(MeasureName, 'MotionOnset')
                    AlignID = Record.Motion.StrtInd;
                    StrtID = 1;
                end
                if Record.Flags.In || IncOut
                    k = k+1;
                    T{k} = t(StrtID:end) - t(AlignID);
            %         ratio{k} = eval(sprintf('Record.Trace.%s', MeasureName));
                    F = Record.Trace.F(StrtID:end);
                    if strcmp(MeasureName, 'TraceStart')
                        F0 = mean(F(T{k}<=T{k}(1)+3));
                    elseif strcmp(MeasureName, 'MotionOnset')
                        F0 = mean(Record.Trace.F(AlignID-3:AlignID));
                    end
                    ratio{k} = (F-F0)/F0*100;
                    if isnan(MinLenPre) || ~isnan(MinLenPre) && -T{k}(1)<MinLenPre
                        MinLenPre = -T{k}(1);
                    end   
                    if isnan(MinLenPost) || ~isnan(MinLenPost) && T{k}(end)<MinLenPost
                        MinLenPost = T{k}(end);
                        MinLenIDPost = k;
                    end   
                end
            end
        end
        
        % choose common dt as the larger of the trace with the shortest
        % start-to-alignment point interval and the trace with the shortest
        % alignment point-to-end interval
        dtPre = MinLenPre /(AlignID-1);
        dtPost = MinLenPost / (length(T{MinLenIDPost}(AlignID:end)));
        dt = max(dtPre, dtPost);
        X = [-MinLenPre:dt:MinLenPost]';
        R = zeros(length(X), N);

        for k=1:N
            % if any(isnan(ratio{k}))
            %     disp(sprintf('%g is NaN', k))
            % end
            R(:,k) = interp1(T{k}, ratio{k}, X,'linear', 'extrap');
            R(:,k) = R(:,k) - R(1,k);
        end        
        
        Xall = repmat(X, 1, N);
        plot(Xall, R)
%         Rmean = mean(R,2);
%         Rvar = var(R,0,2);
%         Rsem = sqrt(Rvar/N);
% 
%         bgclr = Plots.Colors.RGB;
%         if bgclr(1)<0.3 & bgclr(2)<0.3 & bgclr(3)<0.3
%             bgclr = bgclr*2;
%         else
%             bgclr = bgclr/2;
%         end
%         if ~any(bgclr)
%             bgclr = [0.7 0.7 0.7];
%         end
%         plot([X X]', [Rmean+Rsem Rmean-Rsem]', 'Color', bgclr*0.5)
%         hold on
%         plot(X, Rmean, 'Color', Plots.Colors.RGB, 'LineWidth', 2);
%         YLim = get(gca,'YLim');
%         plot(9.2*[1 1], YLim, 'k:');
        xlabel(xlabelStr);
        ylabel(UnitName)

        title(sprintf('%s mean trace', Group.Name))
        

    end
end
