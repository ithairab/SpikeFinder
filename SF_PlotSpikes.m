function SF_PlotSpikes(handles, Type, i)

global Record Params IDs Plots

if Params.Motion.Blind ==0 | IDs.Event.Source==2
    PlotWhatList = get(handles.popupmenu_PlotWhat, 'String');
    PlotWhatID = get(handles.popupmenu_PlotWhat, 'Value');
    switch IDs.Event.Source
        case 1
            if strcmpi(PlotWhatList{PlotWhatID}, 'Ratio')
                R = Record.Trace.R;
            elseif strcmpi(PlotWhatList{PlotWhatID}, 'Fluorescence')
                R = Record.Trace.F;
            end
            Y = Record.Trace.Y;
            C = Record.Trace.C;
        case 2
            C_M = Record.Trace.C_M(2,:);
            C_M = (C_M-min(C_M))/(max(C_M)-min(C_M));
            ylim = get(handles.axes_Ratio, 'YLim');
            R = C_M*(ylim(2)-ylim(1))+ylim(1);
        case 3
            R = Record.Trace.F;
    end
    T = Record.Trace.T * Plots.TimeUnit.Factor(IDs.TimeUnit);
    XLim = Record.Axis.Lim(1:2) * Plots.TimeUnit.Factor(IDs.TimeUnit);
    
    eval(sprintf('EventInd = Record.%s.EventInd;', Type));
    eval(sprintf('IndIn = Record.%s.IndIn;', Type));

    if strcmp(Type, 'Events')
        c = 'r';
    elseif strcmp(Type, 'SubEvents')
        c = 'g';
    end
    clStart = ['*' c];
    clPeak = ['o', c];

    % plotting
    % --------
    if Params.Motion.Blind==0 & IDs.Event.Source==1
        axes(handles.axes_YFP)
        hold on
        plot(T(EventInd(1,IndIn)), Y(EventInd(1,IndIn)), clStart);
        plot(T(EventInd(2,IndIn)), Y(EventInd(2,IndIn)), clPeak);
        axis off
        xlim(XLim)
%         xlim(Record.Axis.Lim(1:2))
        % if Parameters.StimFlag
        %     plot(repmat(Tall(StimStart), 2,1), [-1 1], 'r:')
        %     plot(repmat(Tall(StimEnd), 2,1), [-1 1], 'g:')
        % end

        axes(handles.axes_CFP)
        hold on
        plot(T(EventInd(1,IndIn)), C(EventInd(1,IndIn)), clStart);
        plot(T(EventInd(2,IndIn)), C(EventInd(2,IndIn)), clPeak);
        axis off
        xlim(XLim)
    end
    axes(handles.axes_Ratio)
    hold on
    plot(T(EventInd(1,IndIn)), R(EventInd(1,IndIn)), clStart);
    plot(T(EventInd(2,IndIn)), R(EventInd(2,IndIn)), clPeak);
    if nargin == 3
    %     text(T(EventInd(1,i)), R(EventInd(1,i))-10, '\uparrow', 'HorizontalAlignment', 'Center', 'Color', [0 0 1], 'FontWeight', 'demi')
        text(T(EventInd(2,i)), R(EventInd(2,i)), '\downarrow', 'HorizontalAlignment', 'Center', 'Color', [0 0 1],...
            'VerticalAlignment', 'Bottom', 'FontSize', 14)
    end
    if strcmpi(PlotWhatList{PlotWhatID}, 'Ratio')
        axis([XLim Record.Axis.Lim(3:4)])
    elseif strcmpi(PlotWhatList{PlotWhatID}, 'Fluorescence')
        set(handles.axes_Ratio, 'XLim', XLim)
    end



    % disp(RAmps(SpikeIDs));
    % disp(sprintf('Mean spike amplitude = %2.2f', mean(RAmps(SpikeIDs))));
    % disp(sprintf('Mean spike frequency = %2.2f spikes/min', length(SpikeIDs)/T(end)*60));
    % 
    % Rs = T(Spikes(SpikeIDs,1));
    % Ms = T(MSpikes(:,2));
end