function SF_PlotCrossCorr(EventType, ArgStr, Param)

global Experiment IDs

w_t = str2num(char(Param{1}));
alpha = str2num(char(Param{2}));

Record = Experiment.Groups(1).Group.Records(IDs.Record).Record;
FrameRate = Record.Params.FMS;
w = round(w_t*60*FrameRate);
x = Record.Trace.R;

Record = Experiment.Groups(2).Group.Records(IDs.Record).Record;
y = Record.Trace.R;

Nx = length(x);
Ny = length(y);
N = max([Nx,Ny]);
if size(x,1)==1
    x = x';
end
if size(y,1)==1
    y = y';
end
% if N>Nx
%     x(Nx+1:N) = 0;
% elseif N>Ny
%     y(Ny+1:N) = 0;
% end
zr = round(N/2);
window = (-w:w)+zr;
C=zeros(1,N-2*w);
P=zeros(1,N-2*w);
ind = (1:N-2*w)+w-zr;
t = ind/FrameRate;
for i=1:(N-2*w)
    [C(i) P(i)] = corr(x(window),y(i:i+2*w));
end
sigind = find(P<alpha);
hold off
plot(t,C,'k');
hold on
plot(t(sigind),C(sigind), 'r.')
grid on
