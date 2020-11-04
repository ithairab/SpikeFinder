function SF_AnalyzedShow(handles)

global Record

NumEvents = Record.Events.NumIndIn;
T = Record.Trace.T;
R = Record.Trace.R;
Analyzed = Record.Events.Analyzed;

axes(handles.axes_Ratio)
hold on

for i = 1:NumEvents
    ind_strt = Record.Events.Analyzed.StrtInd(i);
    Half1T = Analyzed.HalfT(1,i);
    Half2T = Analyzed.HalfT(2,i);
    Half1ID = Analyzed.HalfID(1,i);
    Half2ID = Analyzed.HalfID(2,i);
    HalfR = Analyzed.HalfR(i);
    ind_end = Analyzed.EndInd(i);
    if ~isnan(Half1T) && ~isnan(Half2T)
        plot([Half1T Half2T], HalfR*[1 1], 'r');
    end
    plot(T(ind_strt), R(ind_strt), 'hr','MarkerSize', 8);
    plot(T(ind_end), R(ind_end), '+r');
    ind = ind_strt:Half1ID;
    a = Analyzed.ExpRise(1,i);
    b = Analyzed.ExpRise(2,i);
    RStart = R(ind_strt);
    t = T(ind);
    r_fit = exp(b+a*t)+RStart;
    plot(t, r_fit, 'r');
    ind = Half2ID:ind_end;
    a = Analyzed.ExpDecay(1,i);
    b = Analyzed.ExpDecay(2,i);
    REnd = R(ind_end);
    t = T(ind);
    r_fit = exp(b+a*t)+REnd;
    plot(t, r_fit, 'r');
end
