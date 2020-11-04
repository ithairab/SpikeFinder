function SF_PlotTraces(handles)

global Record Plots Experiment IDs Params

% plotting
% --------

T = Record.Trace.T * Plots.TimeUnit.Factor(IDs.TimeUnit);
xlabelStr = sprintf('Time (%s)', Plots.TimeUnit.List{IDs.TimeUnit});
XLim = Record.Axis.Lim(1:2) * Plots.TimeUnit.Factor(IDs.TimeUnit);
if Params.Motion.Blind == 0

    axes(handles.axes_YFP)
    hold off
    plot(T, Record.Trace.Y, 'y', 'LineWidth', 6)
    hold on
    plot(T, Record.Trace.Y, 'k')
    axis off
    xlim(XLim)
    % if Parameters.StimFlag
    %     plot(repmat(Tall(StimStart), 2,1), [-1 1], 'r:')
    %     plot(repmat(Tall(StimEnd), 2,1), [-1 1], 'g:')
    % end

    axes(handles.axes_CFP)
    hold off
    plot(T, Record.Trace.C, 'c', 'LineWidth', 6)
    hold on
    plot(T, Record.Trace.C, 'k')
    axis off
    xlim(XLim)

    axes(handles.axes_Ratio)
    if Plots.Ratio.Hold
        hold on
        C = Plots.Colors.RGB;
    else
        hold off
        C = [0 0 0];
    end
    if isfield(Record, 'SeparatorID') && ~isempty(Record.SeparatorID)
       plot(T(Record.SeparatorID)*[1 1], [Record.Axis.Lim(3) Record.Axis.Lim(4)], 'k:');
        hold on
    end
    if isfield(Record, 'ParentEvents') && ~isempty(Record.ParentEvents.ParentInd)
        y1 = Record.Axis.Lim(3);
        y2 = Record.Axis.Lim(4);
        for i = 1:Record.ParentEvents.NumParents
            x1 = T(Record.ParentEvents.ParentInd(1,i));
            x2 = T(Record.ParentEvents.ParentInd(2,i));
            if i == IDs.Parent
                ParentC = [0.8 0.8 0.8];
            else
                ParentC = [1 1 1];
            end
            fill([x1 x1 x2 x2], [y1 y2 y2 y1], ParentC)
            hold on
            if isfield(Record.ParentEvents, 'Analyzed') && isfield(Record.ParentEvents.Analyzed, 'HalfT')
                HalfR = Record.ParentEvents.Analyzed.HalfR(i);
                HalfT = Record.ParentEvents.Analyzed.HalfT(:,i);
                plot([HalfT(1) HalfT(2)], HalfR*[1 1], 'b');
            end
        end
    end
    PlotWhatList = get(handles.popupmenu_PlotWhat, 'String');
    PlotWhatID = get(handles.popupmenu_PlotWhat, 'Value');
    if strcmpi(PlotWhatList{PlotWhatID}, 'Ratio')
        plot(T, Record.Trace.R, 'Color', C);
    elseif strcmpi(PlotWhatList{PlotWhatID}, 'Fluorescence')
        plot(T, Record.Trace.F, 'Color', C);
    end
    % plot(T*60, Record.Trace.R, 'Color', C);
    hold on
%     plot([1/6 1/6], [Record.Axis.Lim(2) Record.Axis.Lim(2)+Record.Axis.Lim(4)], 'k:');
%     plot(T(78)*[1 1], [Record.Axis.Lim(3) Record.Axis.Lim(3)+Record.Axis.Lim(4)], 'k:');
%     plot(9.2*[1 1], [Record.Axis.Lim(3) Record.Axis.Lim(3)+Record.Axis.Lim(4)], 'k:');
    if ~isempty(Record.Trace.BL) && ~Record.Flags.BleachCorrect
        plot(T, Record.Trace.BL, 'k:')
    end 
    if ~isfield(Record.Flags, 'In') || Record.Flags.In
        set(handles.axes_Ratio, 'Color', [236 233 216]/256);
    else
        set(handles.axes_Ratio, 'Color', [0.8 0.8 0.8])
    end
    if strcmpi(PlotWhatList{PlotWhatID}, 'Ratio')
        axis([XLim Record.Axis.Lim(3:4)])
    elseif strcmpi(PlotWhatList{PlotWhatID}, 'Fluorescence')
        set(handles.axes_Ratio, 'XLim', XLim)
    end
    % LIM = Record.Axis.Lim;
    % LIM(1:2)=LIM(1:2)*60;
    % axis(LIM)
    xlabel(xlabelStr)
    ylabel('Ratio change (%)')
    % xlabel('Time (sec)')
    % if Parameters.StimFlag
    %     hold on
    %     plot(repmat(Tall(StimStart), 2,1), get(hratio, 'ylim'), 'r:')
    %     plot(repmat(Tall(StimEnd), 2,1), get(hratio, 'ylim'), 'g:')
    %     hold off
    % end
else
    axes(handles.axes_Ratio); cla;
    axes(handles.axes_YFP); cla;
    axes(handles.axes_CFP); cla;
end

if Params.Motion.Detect == 1
    axes(handles.axes_Ratio)
%     SF_PlotSuperimpose(handles, Record.Trace.M(1,:), 'b');
    C_M2 = Record.Trace.M(2,:);
    SF_PlotSuperimpose(handles, T, (C_M2-min(C_M2))/(max(C_M2)-min(C_M2)), 'b');
%     C_M1 = Record.Trace.M(1,:);
%     SF_PlotSuperimpose(handles, (C_M1-min(C_M1))/(max(C_M1)-min(C_M1)), 'g');
end

if isfield(Record, 'Motion') && isfield(Record.Motion, 'StrtInd')
    axes(handles.axes_Ratio)
    plot(T(Record.Motion.StrtInd)*[1 1], [Record.Axis.Lim(3) Record.Axis.Lim(4)], 'r:');
    hold on
end

if isfield(Record, 'Manual') && isfield(Record.Manual, 'PeakInd')
    axes(handles.axes_Ratio)
    plot(T(Record.Manual.PeakInd)*[1 1], [Record.Axis.Lim(3) Record.Axis.Lim(4)], 'g:');
    hold on
end
