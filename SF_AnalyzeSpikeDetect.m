function SF_AnalyzeSpikeDetect

global Record Params IDs

N = numel(Params.Events.Names);
for i=1:N
    eval(sprintf('%s = %s;', Params.Events.Names{i}, Params.Events.Values{i}));
end

switch IDs.Event.Source
    case 1
%         R = Record.Trace.M(3,:)';
        R = Record.Trace.R;
    case 2
        R = Record.Trace.C_M(2,:);
    case 3
        R = Record.Trace.F;
end
T = Record.Trace.T;
Y = Record.Trace.Y;
C = Record.Trace.C;

if NumFrames>1
    R = GaussianSmooth(R,NumFrames)';
end

dRdT = diff(R)./diff(T);
Thresh = DerivThreshold*std(dRdT(~isnan(dRdT)));

% spike initiation first point where derivative surpasses threshold
StartInd = [];
PeakInd = [];
PassedSpikeInd = [];
ThreshInd = find(dRdT>Thresh);

if ~isempty(ThreshInd)
    ThreshIndCont = diff(ThreshInd);
    ThreshIndContFirst = find(ThreshIndCont>1)+1;
    StartInd = ThreshInd([1 ThreshIndContFirst]);

    % spike peak first negative dervative point after spike initiation
    NegInd = find(dRdT<0);
    NumStart = length(StartInd);
    PeakInd = zeros(1,NumStart);
    for i=1:NumStart
        ind = find(NegInd>StartInd(i), 1, 'first');
    %     ind = find(dRdT(StartInd(i):end)<0, 1, 'first');
        if ~isempty(ind)
            if i>1 && StartInd(i)>PeakInd(i-1) % make sure there are no multiple spike for a single peak
                PeakInd(i) = NegInd(ind(1));
            end
        end
    end
    % eliminate spikes for which a peak has not been found (e.g. cut out at end of trace)
    StartInd = StartInd(PeakInd>0);
    PeakInd = PeakInd(PeakInd>0);

    % spike amplitudes larger than 'noise'
    % ------------------------------------
    RAmps = R(PeakInd) - R(StartInd);
    RMagInd = find(RAmps > (NoiseThreshold*std(R)));
    switch IDs.Event.Source
        case 1
            % check that YFP and CFP peaks are of opposite signs and of above noise magnitude
            % -------------------------------------------------------------------------------
            if YCThreshold>0
                YCMinMag = YCThreshold*std(Y)*std(C); % minimum absolute value of the product of YFP * CFP amplitudes
                YAmps = Y(PeakInd) - Y(StartInd);
                CAmps = C(PeakInd) - C(StartInd);
                YCRecipInd = find((YAmps.*CAmps) < -YCMinMag);
            else
                YCRecipInd = 1:length(StartInd);
            end
        case 2
            % check that motion amplitude is larger than a specified percent of the frame height
            if YCThreshold>0 & isfield(Record.Params, 'Resolution') & ~isempty(Record.Params.Resolution)
                MAmps = R(PeakInd) - R(StartInd);
                MinAmp = YCThreshold/100*Record.Params.Resolution(1);
                YCRecipInd = find(MAmps > MinAmp);
            else
                YCRecipInd = 1:length(StartInd);
            end
        case 3
            YCRecipInd = 1:length(StartInd);
    end
    % combine all criteria
    % --------------------
    PassedSpikeInd = intersect(YCRecipInd, RMagInd);
end

Record.Events.EventInd = [StartInd; PeakInd];
Record.Events.IndIn = PassedSpikeInd;
Record.Events.IndOut = setdiff(1:length(StartInd),PassedSpikeInd);
Record.Events.NumIndIn = length(PassedSpikeInd);
Record.Events.SourceID = IDs.Event.Source;

% SF_ExperimentUnSaved(handles);



% figure(1)
% clf
% plot(T(2:end),dRdT)
% % plot(T,R)
% hold on
% plot([T(2) T(end)], [Thresh Thresh], 'r')
% plot([T(2) T(end)], [0 0], 'g')
% plot(T(StartInd), dRdT(StartInd), 'r.')
% plot(T(PeakInd), dRdT(PeakInd), 'g.')
% % plot(T(StartInd), R(StartInd), 'r.')
% % plot(T(PeakInd), R(PeakInd), 'g.')
