function SF_PlotMeanTrace(EventType, ArgStr, Param)

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
            if strcmp(MeasureName, 'TraceStart') || strcmp(MeasureName, 'StartStop') || strcmp(MeasureName, 'MotionOnset') && M(r)
                Record = Group.Records(r).Record;
% temporarily, always use average t (accroding to FPS) due
% to problems with t records
%                 t = Record.Trace.T * Plots.TimeUnit.Factor(IDs.TimeUnit);
                dtt = (Record.Trace.T(end)-Record.Trace.T(1))/(length(Record.Trace.T)-1);
                t = (Record.Trace.T(1):1*dtt:Record.Trace.T(end))*Plots.TimeUnit.Factor(IDs.TimeUnit);
                switch MeasureName
                    case 'TraceStart'
                        AlignID = 1;
                        StrtID = AlignID;
                        StopID = length(t);
                    case 'MotionOnset'
                        AlignID = Record.Motion.StrtInd;
                        StrtID = 1;
                        StopID = length(t);
                    case 'StartStop'
                        AlignID = find(t>=Window,1,'First');
                        StrtID = AlignID;
                        StopID = find(t>=SwitchTime,1,'First');
                end
                if Record.Flags.In || IncOut
                    k = k+1;
                    T{k} = t(StrtID:StopID) - t(AlignID);
            %         ratio{k} = eval(sprintf('Record.Trace.%s', MeasureName));
                    F = Record.Trace.F(StrtID:StopID);
                    switch MeasureName
                        case 'TraceStart'
%                         F0 = mean(F(T{k}<=T{k}(1)+3/Plots.TimeUnit.Factor(IDs.TimeUnit)));
                        F0 = mean(F(T{k}<=T{k}(1)+10/Plots.TimeUnit.Factor(IDs.TimeUnit)));
%                             F0 = min(F);
%                             F0 = F(1);
% F0 = F(find(t>=10,1,'First'));
                        case 'MotionOnset'
                            F0 = mean(Record.Trace.F(AlignID-3:AlignID));
                        case 'StartStop'
                            F0=F(1);
                    end
%                     if isfield(Record.Params, 'BleachCorrect') && ~isempty(Record.Trace.BL)
%                         ratio{k} = Record.Trace.R - Record.Trace.BL;
%                     else
%                         ratio{k} = Record.Trace.R;
%                     end
                    ratio{k} = (F-F0)/F0*100;
% ratio{k} = (F-F0)/max(F-F0);

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
        if strcmp(MeasureName,'StartStop')
            dtPost = MinLenPost / (length(T{MinLenIDPost}));
        else
            dtPost = MinLenPost / (length(T{MinLenIDPost}(AlignID:end)));
        end
        dt = max(dtPre, dtPost);
        X = (-MinLenPre:dt:MinLenPost)';
        R = zeros(length(X), N);
        BW = zeros(length(X), N);
        
        for k=1:N
            % if any(isnan(ratio{k}))
            %     disp(sprintf('%g is NaN', k))
            % end
            R(:,k) = interp1(T{k}, ratio{k}, X,'linear', 'extrap');
%             R(:,k) = R(:,k) - R(1,k);
            BW(R(:,k)>0.5,k) = 1;
        end        

        Rmean = mean(R,2);
        Rvar = var(R,0,2);
        Rsem = sqrt(Rvar/N);

%         plot([X X]', [Rmean+Rsem Rmean-Rsem]', 'Color', [0.7 0.7 0.7])
        bgclr = Plots.Colors.RGB;
        if bgclr(1)<0.3 & bgclr(2)<0.3 & bgclr(3)<0.3
            bgclr = bgclr*2;
        else
            bgclr = bgclr/2;
        end
        if ~any(bgclr)
            bgclr = [0.7 0.7 0.7];
        end
        plot([X X]', [Rmean+Rsem Rmean-Rsem]', 'Color', bgclr*0.5)
        hold on
%         plot(X, Rmean, 'r-', 'LineWidth', 1)
        plot(X, Rmean, 'Color', Plots.Colors.RGB, 'LineWidth', 2);
        YLim = get(gca,'YLim');
%         plot(t(78)*[1 1], YLim, 'k:');
        plot(60*[1 1], YLim, 'k:');
        xlabel(xlabelStr);
    %     ylabel('Ratio Change (percent)');    
        ylabel(UnitName)

        title(sprintf('%s mean trace', Group.Name))
        
% figure(3)
% hold on
% plot(X,Rmean, 'k')
        IDA1 = find(X>=SwitchTime-Window, 1, 'first');
        IDA2 = find(X<=SwitchTime, 1, 'last');
        Rbaseline = R(IDA1:IDA2,1:N);
        rbaseline = reshape(Rbaseline, numel(Rbaseline),1);
        P95 = prctile(rbaseline, 95);
        P5 = prctile(rbaseline, 5);
        MEAN = mean(rbaseline);
        STD = std(rbaseline);
%         plot([X(1) X(end)], [P95 P95], ':k');
%         plot([X(1) X(end)], [P5 P5], ':k');
%         plot([X(1) X(end)],MEAN+ [STD STD], ':r');
%         plot([X(1) X(end)],MEAN+ [-STD -STD], ':r');

% figure(IDs.Group)
% imagesc(R')
% % imagesc(BW');
% set(gca,'YLim',[0.5,20.5]);



        % temporary matrix output of normalized traces
        IDA1 = 1;
        IDA2 = find(X<=10, 1, 'last');

        IDB1 = find(X>=10, 1, 'first');
        IDB2 = find(X<=10+20, 1, 'last');

        Rn = R';
        D = zeros(N,1);
        for k=1:N
            Rn(k,:)= (Rn(k,:)-min(Rn(k,:)))/(max(Rn(k,:))-min(Rn(k,:)));
            D(k) = mean(Rn(k,IDB1:IDB2))/mean(Rn(k,IDA1:IDA2));
        end
        [~ , Di] = sort(D);
        Rns = Rn(Di,:);
        figure
%         imagesc(Rns)
        imagesc(Rn)
        colorbar
%         figure
%         plot(X,Rn)

    end
end
