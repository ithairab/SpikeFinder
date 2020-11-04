function SF_PlotSuperimpose(handles, T, Y, cStr)

global Record

% plotting
% --------
axes(handles.axes_Ratio)
ylim = get(handles.axes_Ratio, 'YLim');
% hold off
plot(T, Y*(ylim(2)-ylim(1))+ylim(1), cStr);
% hold on
% plot(Record.Trace.T, Record.Trace.R, 'k');
% set(handles.axes_Ratio, 'Color', [236 233 216]/256);
% axis(Spikes.Axis.Lim)
% xlabel('Time (min)')

