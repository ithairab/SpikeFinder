function SF_AnalyzeParents

global Record

if isfield(Record, 'ParentEvents') && ~isempty(Record.ParentEvents.ParentInd)
    T = Record.Trace.T;
    R = Record.Trace.R;
    NumParents = Record.ParentEvents.NumParents;
    Record.ParentEvents.Analyzed.PeakID = nan(1, NumParents);
    Record.ParentEvents.Analyzed.AmpAbs = nan(1, NumParents);
    Record.ParentEvents.Analyzed.AmpStrt = nan(1, NumParents);
    Record.ParentEvents.Analyzed.HalfR = nan(1, NumParents);
    Record.ParentEvents.Analyzed.HalfT = nan(2, NumParents);
    Record.ParentEvents.Analyzed.WidthHalf = nan(1, NumParents);
    Record.ParentEvents.Analyzed.Width = nan(1, NumParents-1);
    Record.ParentEvents.Analyzed.AreaHalf = nan(1, NumParents-1);
    Record.ParentEvents.Analyzed.ISI = nan(1, NumParents-1);
    for i = 1:NumParents
        StrtID = Record.ParentEvents.ParentInd(1,i);
        EndID = Record.ParentEvents.ParentInd(2,i);
        ChildInd = Record.ParentEvents.ChildInd{i};
        PeakFirstID = Record.Events.Analyzed.PeakInd(ChildInd(1));
        % absolute (peak) amplitude and peak index
        % ----------------------------------------
        [AmpAbs AmpID] = max(R(Record.Events.Analyzed.PeakInd(ChildInd)));
        Record.ParentEvents.Analyzed.PeakID(i) = Record.Events.Analyzed.PeakInd(ChildInd(AmpID));
        Record.ParentEvents.Analyzed.AmpAbs(i) = AmpAbs;
        % amplitude relative to start
        % ---------------------------
        AmpStrt = AmpAbs - R(StrtID);
        Record.ParentEvents.Analyzed.AmpStrt(i) = AmpStrt;
        % Width
        % -----
        Record.ParentEvents.Analyzed.Width(i) = T(EndID) - T(StrtID);
        % half width (interpolate start and end half width indices)
        % ---------------------------------------------------------
        Rhalf = (R(StrtID) + R(PeakFirstID))/2; % half maximum of first child's peak!
        Record.ParentEvents.Analyzed.HalfR(i) = Rhalf;
        Ind = StrtID:length(R);
        Half1id = find(R(Ind)>Rhalf, 1, 'first');
        Ind = StrtID + (0:Half1id-1);
        Half1T = interp1(R(Ind), T(Ind), Rhalf);
        Record.ParentEvents.Analyzed.HalfT(1,i) = Half1T;
        Ind = StrtID:EndID;
        Half2id = find(R(Ind)>Rhalf, 1, 'last');
        Ind = StrtID+Half2id-1 + [0 1];
        Half2T = interp1(R(Ind), T(Ind), Rhalf);
        Record.ParentEvents.Analyzed.HalfT(2,i) = Half2T;
        Record.ParentEvents.Analyzed.WidthHalf(i) = Half2T - Half1T;
        % Half Area (Area under curve along half width relative to start point)
        % ---------------------------------------------------------------------
        Ind = StrtID-1 + (Half1id:Half2id); % internal to the interpolated half points
        dT = diff([Half1T T(Ind) Half2T]);
        Height = [Rhalf R(Ind)] - R(StrtID);
        AreaRect = dT*Height';
        dR = [R(Ind(1))-Rhalf R(Ind(2:end))-R(Ind(1:end-1)) Rhalf-R(Ind(end))];
        AreaTrngl = dT*dR'/2;
        Record.ParentEvents.Analyzed.AreaHalf(i) = AreaRect + AreaTrngl;
        % ISI
        % ---
        if i<NumParents
            Record.ParentEvents.Analyzed.ISI(i) = T(Record.ParentEvents.ParentInd(1,i+1)) - T(StrtID);
        end
    end
end


