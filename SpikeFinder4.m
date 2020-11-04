function varargout = SpikeFinder4(varargin)
% SPIKEFINDER4 M-file for SpikeFinder4.fig
%      SPIKEFINDER4, by itself, creates a new SPIKEFINDER4 or raises the existing
%      singleton*.
%
%      H = SPIKEFINDER4 returns the handle to a new SPIKEFINDER4 or the handle to
%      the existing singleton*.
%
%      SPIKEFINDER4('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPIKEFINDER4.M with the given input arguments.
%
%      SPIKEFINDER4('Property','Value',...) creates a new SPIKEFINDER4 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SpikeFinder2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SpikeFinder4_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SpikeFinder4

% Last Modified by GUIDE v2.5 12-Nov-2015 12:18:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SpikeFinder4_OpeningFcn, ...
                   'gui_OutputFcn',  @SpikeFinder4_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SpikeFinder4 is made visible.
function SpikeFinder4_OpeningFcn(hObject, eventdata, handles, varargin)
global Trace File Params Experiment IDs Record Plots ClipBoard
Trace = [];
File = [];
IDs.Group = 0;
IDs.Record = 0;
IDs.Parent = 1;
IDs.Summary.Parents = 1;
IDs.Summary.Separator = 1;
IDs.Summary.Summation = 1;
IDs.Event.Source = 3;
IDs.TimeUnit = 1;
IDs.TestGroup = 0;
File.Home = fileparts(which('SpikeFinder4'));
ClipBoard.Group = [];
% -------------------------------------------------------------------------
params = load(fullfile(File.Home, 'SF_Parameters.mat'));
Params = [];
Params.NumTypes = 0;
Params.Types = {'Events', 'Analysis'};
Params.NumTypes = numel(Params.Types);
% -------------------------------------------------------------------------
Params.Motion.Detect = 0;
Params.Motion.Blind = 0;
% -------------------------------------------------------------------------
Params.Events.Names = {'NumFrames', 'DerivThreshold','YCThreshold','NoiseThreshold'};
Params.Events.Values = params.Events.Values;
Params.Events.Type = {'String', 'String', 'String', 'String'};
Params.Events.Cond = {'%g>=0', '%g>=0','%g>=0','%g>=0'};
Params.Events.Tags = {'edit_EvntNumFrames','edit_EvntDerivThresh','edit_EvntYCThresh','edit_EvntNoiseThresh'};
Params.Events.NumParams = numel(Params.Events.Names);
Params.Events.SourceList = {'Ratio' 'Y Motion' 'Single'};
% -------------------------------------------------------------------------
Params.Analysis.NumParams = 0;
Params.Analysis.Names = {'NBins', 'PreWindow', 'PostWindow' 'Window' 'alpha' 'SwitchTime' 'Frames' 'Delay'};
Params.Analysis.Values = params.Analysis.Values;
Params.Analysis.Type = {'String', 'String', 'String' 'String' 'String' 'String' 'String' 'String'};
Params.Analysis.Cond = {'%g>0', '%g>0', '%g>0' '%g>0' '%g>0' '%g>0' '%g>=0' '%g>0'};
Params.Analysis.NumParams = numel(Params.Analysis.Names);
% -------------------------------------------------------------------------
SF_Parameters2GUI(handles, 'Events');
set(handles.popupmenu_Separator, 'String', {'Off' 'Pre' 'Post'}, 'Value', IDs.Summary.Separator);
% -------------------------------------------------------------------------
set(handles.popupmenu_ParentEvntSelect, 'String', {'All' 'Parent' 'Child'}, 'Value', IDs.Summary.Parents);
Params.Summary.Names = {'EventType'}; % Summary parameters
Params.Summary.Type = {'Value'};
Params.Summary.Tags = {'popupmenu_ParentEvntSelect'};
Params.Summary.FuncNames = {{'SF_AnSummaryAll', 'SF_AnSummaryParents', 'SF_AnSummaryChildren'}};
Params.Summary.NumParams = numel(Params.Summary.Names);
% -------------------------------------------------------------------------
set(handles.popupmenu_EventSource, 'String', Params.Events.SourceList, 'Value', IDs.Event.Source);
% -------------------------------------------------------------------------
set(handles.popupmenu_PlotWhat, 'String', {'Ratio', 'Fluorescence'}, 'Value', 1);
% -------------------------------------------------------------------------
set(handles.popupmenu_Summation, 'String', {'Record' 'Event'});
% -------------------------------------------------------------------------
set(handles.popupmenu_TimeType, 'String', {'Stamp' 'Mean'}, 'Value', 2);
Experiment = [];
axes(handles.axes_YFP)
axis off
axes(handles.axes_CFP)
axis off
GUIList = {'pushbutton_GroupNew','pushbutton_GroupDelete', 'edit_GroupRename',...
    'pushbutton_RecordLoad', 'RecordRemove'};
GUIEnable(handles, GUIList, 0);
set(handles.edit_GroupRename, 'enable', 'on'); % temporary
% GUIList = {'pushbutton_BleachCompute', 'radiobutton_BleachCorrect', 'edit_TauBleach', ...
%     'text_TauBleach'};
% GUIEnable(handles, GUIList, 0);
% GUIList = {'pushbutton_EventsAnalyze', 'pushbutton_ShowAnalyzed', 'pushbutton_EditStart', ...
%     'pushbutton_EditEnd'};
% GUIEnable(handles, GUIList, 0);
Record = [];
set(handles.radiobutton_BleachCorrect, 'Value', 0);
Plots.Flags.IncludeOutRecords = 0;
set(handles.radiobutton_IncludeOutRecords, 'Value', Plots.Flags.IncludeOutRecords);
Plots.Flags.Hold = 0;
Plots.Flags.Scatter = 0;
Plots.Ratio.Hold = 0;
Plots.Colors.RGB = [0 0 0];
Plots.Types.Ind = 1;
% Plots.Types.FeatureList = {[1:6 28 13 8 21 22 24 25 26 27] [1:6 8] [1:6 8] [9:12 29 20 23] 11 [17 18] 14:16 18 19}; % list of relevant features for each plot type
Plots.Types.FeatureList = {[3 28 8 21 22 24 25 26 27] [3 8 20] [1:6 8] [9:12 29 20 23] 11 [17 18 30] 17 14:16 18 19}; % list of relevant features for each plot type
Plots.Types.EventList = 1:9; % plot types for Events
% Plots.Types.ParentEventList = 1:2; % plot types for ParentEvents
Plots.Types.NameList = {'Mean' 'Distribution' 'Correlation' 'Triggered' 'XCorr' 'Mean Trace' 'Overlay'...
    'Stimulus Difference' 'Motion Onset' 'Manual Start/Peak'};
Plots.Types.FuncNameList = {'SF_PlotMean' 'SF_PlotDistribution' 'SF_PlotCorrelation' 'SF_PlotTriggered' ...
    'SF_PlotCrossCorr' 'SF_PlotMeanTrace' 'SF_PlotOverlay' 'SF_PlotTraceStimulus' 'SF_PlotMotionOnset' 'SF_PlotManualStartPeak'};
Plots.Types.NumArgList = [1 1 2 1 1 1 1 1 1 1]; % number of features that need to be chosen
Plots.Types.ParamList = {[] 1 [] [2 3] [4 5] [4 6] [4 6] [4 6] [7 8] 7}; % corresponding to Params.Analysis parameters
Plots.Features.Ind = [1 1];
% Plots.Features.EventList = [1:3 5:11]; % plot features for Events
% Plots.Features.ParentEventList = [1 4 7]; % plot features for ParentEvents
Plots.Features.EventList = 1:30; % plot features for Events
Plots.Features.NameList = {'Amplitude (Abs)' 'Amplitude (Start)' 'Amplitude (Start0)' 'Quarter Width' 'Half Width' 'Area' 'Tau Rise'...
    'ISI' 'Ratio Change' 'X Motion' 'Neuron2 R' 'Neuron2 Mx' 'Half Area' 'Stim Diff' 'R_0' 'F1_0' 'TraceStart' 'MotionOnset'...
    'Start vs Peak' 'Y2Ratio' 'Event Frequency' 'Start-Triggered Peak' 'Y2X' 'Peak-Triggered Ratio' 'rand' 'mean' 'CorrRatioYmotion'...
    'Climb Rate' 'Y Motion' 'StartStop'};
Plots.Features.VarList = {'AmpAbs' 'AmpStrt' 'AmpStrt0' 'QuarterWidth' 'WidthHalf' 'Area' 'TauRise' 'ISI' 'R0', 'M1'...
    'R2' 'M2' 'AreaHalf' 'StimDiff' 'R_0' 'F1_0' 'TraceStart' 'MotionOnset' 'StartVSPeak', 'R' 'EventFrequency'...
    'StartTriggeredPeak' 'C_M1' 'PeakTriggeredRatio' 'RandPeakTriggeredRatio' 'MeanPeakTriggeredRatio' 'CorrRatioYmotion'...
    'ClimbRate' 'C_M2' 'StartStop'};
Plots.Features.UnitList = {'Amplitude (% ratio change)' 'Amplitude (% ratio change)' 'Amplitude (% ratio change)' 'Qrtr Width (min)'...
    'Half Width (min)' 'Area (% change * min)' 'Tau Rise (min)' 'ISI (min)' 'Ratio Change (%)' 'A.U.'...
    'Ratio Change (%)' 'A.U.' 'Half Area (% change * min)' 'Ratio difference' 'Ratio' 'AU' 'Ratio difference'...
    'Ratio difference' 'Ratio difference' 'Amplitude (% ratio change)' 'Frequency (#/min)' 'Ratio difference' 'X motion'...
    'Ratio (%change)' 'Ratio' 'Ratio', 'Rho' '%/sec' 'pixels' 'Ratio Difference'};
set(handles.popupmenu_PlotType, 'String', Plots.Types.NameList, 'Value', Plots.Types.Ind);
set(handles.radiobutton_PlotScatter, 'Value', Plots.Flags.Scatter);
Plots.TimeUnit.List = {'sec' 'min'};
Plots.TimeUnit.Factor = [60 1];
set(handles.popupmenu_TimeUnits, 'String', Plots.TimeUnit.List, 'Value', IDs.TimeUnit);
popupmenu_PlotType_Callback(handles.popupmenu_PlotType, eventdata, handles);
% -------------------------------------------------------------------------
Plots.Axes.Handles = {'axes_Analyzed'};
for i=1:numel(Plots.Axes.Handles)
    PropertyStr = 'Position';
    eval(sprintf('Plots.Axes.Positions{i} = get(handles.%s, PropertyStr);', Plots.Axes.Handles{i}));
end


% Choose default command line output for SpikeFinder4
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SpikeFinder4 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SpikeFinder4_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% ========================================================================

% Experiment Management
% ---------------------

function pushbutton_ExperimentNew_Callback(hObject, eventdata, handles)
global Experiment File IDs Params
OK = 1;
if ~isempty(Experiment) && isfield(Experiment, 'Flags') && isfield(Experiment.Flags, 'Saved') && ~Experiment.Flags.Saved
    button = questdlg('Previous experiment not saved, load anyway?', 'Save previous experiment');
    if ~strcmp('Yes', button)
        OK = 0;
    end
end
if OK
    [File.Exp.Name, File.Exp.Path] = uiputfile('*.mat', 'Select a file name for the new experiment');
    if File.Exp.Name ~= 0
        cd(File.Exp.Path);
        Experiment = [];
        Experiment.Name = File.Exp.Name;
        Experiment.NumGrps = 0;
        Experiment.GroupList = {};
        Experiment.Groups = [];
        IDs.Group = 0;
        IDs.Record = 0;
        set(handles.text_ExperimentFile, 'String', Experiment.Name);
        params = load(fullfile(File.Home, 'SF_Parameters.mat'));
        for i=1:Params.NumTypes
            eval(sprintf('Params.%s.Values = params.%s.Values;', Params.Types{i}, Params.Types{i}));
        end
        SF_Parameters2GUI(handles,'Events');
        GUIList = {'pushbutton_GroupNew','pushbutton_GroupDelete','pushbutton_RecordLoad','pushbutton_RecordRemove'};
        State = [1 0 0 0];
        GUIEnable(handles,GUIList,State);
        set(handles.listbox_Groups, 'String', Experiment.GroupList);
        IDs.TestGroup = 1;
        set(handles.popupmenu_Group2Test, 'Visible', 'off');
        set(handles.text_Group2Test, 'Visible', 'off');
        File.Plot.Path = File.Exp.Path;
        SF_RecordRetrieve(handles);
        Experiment.Flags.Saved = 1;
        save([File.Exp.Path, File.Exp.Name], '-struct', 'Experiment');
    end
end

function pushbutton_ExperimentLoad_Callback(hObject, eventdata, handles)
global Experiment File IDs
OK = 1;
if ~isempty(Experiment) && isfield(Experiment, 'Flags') && isfield(Experiment.Flags, 'Saved') && ~Experiment.Flags.Saved
    button = questdlg('Previous experiment not saved, load anyway?', 'Save previous experiment');
    if ~strcmp('Yes', button)
        OK = 0;
    end
end
if OK
    [File.Exp.Name, File.Exp.Path] = uigetfile('*.mat', 'Select experiment file');
    if File.Exp.Name ~= 0
        Exp = load(fullfile(File.Exp.Path, File.Exp.Name));
        cd(File.Exp.Path);
        if isfield(Exp,'Name') && isfield(Exp,'NumGrps') && isfield(Exp,'Groups')
            Experiment = Exp;
            Experiment.Name = File.Exp.Name;
            File.Plot.Path = File.Exp.Path;
            set(handles.text_ExperimentFile, 'String', Experiment.Name);
            set(handles.pushbutton_GroupNew, 'Enable', 'on');
            set(handles.listbox_Groups, 'String', Experiment.GroupList);
            if Experiment.NumGrps
                IDs.Group = 1;
                Group = Experiment.Groups(IDs.Group).Group;
                set(handles.listbox_Groups, 'Value', 1);
                set(handles.pushbutton_GroupDelete, 'Enable', 'on');
                set(handles.pushbutton_RecordLoad, 'Enable', 'on');
                IDs.TestGroup = 1;
                set(handles.popupmenu_Group2Test, 'Visible', 'on');
                set(handles.text_Group2Test, 'Visible', 'on');
                set(handles.popupmenu_Group2Test, 'Value', IDs.TestGroup, 'String', Experiment.GroupList);
               if Group.NumRecs
                    IDs.Record = 1;
    %                 GUIList = {'pushbutton_EventsAnalyze', 'pushbutton_ShowAnalyzed', 'pushbutton_EditStart', ...
    %                     'pushbutton_EditEnd'};
    %                 GUIEnable(handles, GUIList, 1);
                end
                SF_RecordRetrieve(handles);
            else
                set(handles.popupmenu_Group2Test, 'Visible', 'off');
                set(handles.text_Group2Test, 'Visible', 'off');
            end
        end
    end
end

function pushbutton_ExperimentSave_Callback(hObject, eventdata, handles)
global Experiment IDs Record File
set(handles.text_ExperimentFile, 'String', 'Please wait, saving experiment..');
pause(0.1);
Group = Experiment.Groups(IDs.Group).Group;
Group.Records(IDs.Record).Record = Record;
Experiment.Groups(IDs.Group).Group = Group;
Experiment.Flags.Saved = 1;
save([File.Exp.Path, File.Exp.Name], '-struct', 'Experiment');
set(handles.text_ExperimentFile, 'String', Experiment.Name);
set(hObject, 'ForegroundColor', [0 0 0]);

function pushbutton_ExperimentSaveAs_Callback(hObject, eventdata, handles)
global Experiment File
if isfield(File, 'Exp')
    [File.Exp.Name, File.Exp.Path] = uiputfile('*.mat', 'Save experiment as', File.Exp.Name);
    if File.Exp.Name ~= 0
        Experiment.Name = File.Exp.Name;
        save([File.Exp.Path, File.Exp.Name], '-struct', 'Experiment');
        set(handles.text_ExperimentFile, 'String', Experiment.Name);
        File.Plot.Path = File.Exp.Path;
    end
end

function Exp_Callback(hObject, eventdata, handles)

% loop records and update counters
% currently only in/out records
function ExpUpdate_Callback(hObject, eventdata, handles)
global Experiment
for g=1:Experiment.NumGrps
    Group = Experiment.Groups(g).Group;
    Group.NumRecsIn = 0;
    for r=1:Group.NumRecs
        Record = Group.Records(r).Record;
        Group.NumRecsIn = Group.NumRecsIn+Record.Flags.In;
    end
    Experiment.Groups(g).Group = Group;
end
SF_ExperimentUnSaved(handles);

% ========================================================================

% Group Management
% ----------------

function pushbutton_GroupNew_Callback(hObject, eventdata, handles)
global Experiment IDs File
if File.Exp.Name ~= 0
    Experiment.NumGrps = Experiment.NumGrps+1;
    IDs.Group = Experiment.NumGrps;
    Group = [];
    Group.Name = num2str(Experiment.NumGrps);
    Group.NumRecs = 0;
    Group.NumRecsIn = 0;
    Group.NumAnalyzed = 0;
    Group.RecordList = {};
    Group.Records = [];
    Group.Summary = [];
    Group.Show = 1;
    set(handles.radiobutton_GroupShow, 'Value', 1);
    Experiment.GroupList(IDs.Group) = {Group.Name};
    Experiment.Groups(IDs.Group).Group = Group;
    set(handles.popupmenu_Group2Test, 'Visible', 'on');
    set(handles.text_Group2Test, 'Visible', 'on');
    set(handles.popupmenu_Group2Test, 'Value', IDs.TestGroup, 'String', Experiment.GroupList);
    set(handles.listbox_Groups, 'String', Experiment.GroupList, 'Value', IDs.Group);
    set(handles.pushbutton_GroupDelete, 'Enable', 'on');
    set(handles.edit_GroupRename, 'Enable', 'on');
    SF_RecordRetrieve(handles);
    set(handles.pushbutton_RecordLoad, 'Enable', 'on');
    save([File.Exp.Path, File.Exp.Name], '-struct', 'Experiment');
end

function pushbutton_GroupDelete_Callback(hObject, eventdata, handles)
global Experiment IDs File
Confirm = questdlg('Are you sure you want to delete the group?');
if strcmp(upper(Confirm), 'YES')
    IDs.Group = get(handles.listbox_Groups, 'Value');
    Experiment.NumGrps = Experiment.NumGrps-1;
    if ~Experiment.NumGrps
        Experiment.GroupList = {};
        Experiment.Groups = [];
        set(handles.pushbutton_GroupDelete, 'Enable', 'off');
        set(handles.edit_GroupRename, 'Enable', 'off');
    else
        if IDs.Group <= Experiment.NumGrps
            for j = IDs.Group:Experiment.NumGrps
                Experiment.GroupList{j} = Experiment.GroupList{j+1};
                Experiment.Groups(j).Group = Experiment.Groups(j+1).Group;
            end
        else
            IDs.Group = Experiment.NumGrps;
        end
        Experiment.GroupList = Experiment.GroupList(1:Experiment.NumGrps);
        Experiment.Groups = Experiment.Groups(1:Experiment.NumGrps);
        IDs.Record = 1;
        set(handles.popupmenu_Group2Test, 'Visible', 'on');
        set(handles.text_Group2Test, 'Visible', 'on');
        IDs.TestGroup = 1;
        set(handles.popupmenu_Group2Test, 'Value', IDs.TestGroup, 'String', Experiment.GroupList);
        SF_RecordRetrieve(handles);
    end
    set(handles.listbox_Groups, 'String', Experiment.GroupList, 'Value', IDs.Group);
    if isfield(Experiment.Groups(IDs.Group).Group, 'Show')
        show = Experiment.Groups(IDs.Group).Group.Show;
    else
        show = 1;
    end
    set(handles.radiobutton_GroupShow, 'Value', show);
    save([File.Exp.Path, File.Exp.Name], '-struct', 'Experiment');
end

function listbox_Groups_Callback(hObject, eventdata, handles)
global Experiment IDs Plots
IDs.Group = get(handles.listbox_Groups, 'Value');
if isfield(Experiment.Groups(IDs.Group).Group, 'Show')
    show = Experiment.Groups(IDs.Group).Group.Show;
else
    show = 1;
    Experiment.Groups(IDs.Group).Group.Show = show;
end
set(handles.radiobutton_GroupShow, 'Value', show);
if Plots.Ratio.Hold
    IDs.Record = Plots.Ratio.RecordID;
else
    IDs.Record = 1;
end
SF_RecordRetrieve(handles);
function listbox_Groups_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_GroupRename_Callback(hObject, eventdata, handles)
global Experiment IDs File
if Experiment.NumGrps
    IDs.Group = get(handles.listbox_Groups, 'Value');
    newname = get(hObject, 'String');
    Experiment.Groups(IDs.Group).Group.Name = newname;
    Experiment.GroupList{IDs.Group} = newname;
    set(handles.listbox_Groups, 'String', Experiment.GroupList);
    set(handles.popupmenu_Group2Test, 'Value', IDs.TestGroup, 'String', Experiment.GroupList);
    save([File.Exp.Path, File.Exp.Name], '-struct', 'Experiment');
end
set(hObject, 'String', 'Rename');
function edit_GroupRename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton_GroupUp_Callback(hObject, eventdata, handles)
global Experiment IDs File
if Experiment.NumGrps
    if IDs.Group>1
        Group = Experiment.Groups(IDs.Group).Group;
        Experiment.Groups(IDs.Group).Group = Experiment.Groups(IDs.Group-1).Group;
        Experiment.GroupList{IDs.Group} = Experiment.Groups(IDs.Group-1).Group.Name;
        IDs.Group = IDs.Group-1;
        Experiment.Groups(IDs.Group).Group = Group;
        Experiment.GroupList{IDs.Group} = Group.Name;
        set(handles.listbox_Groups, 'Value', IDs.Group, 'String', Experiment.GroupList);
        save([File.Exp.Path, File.Exp.Name], '-struct', 'Experiment');
    end
end

function pushbutton_GroupDown_Callback(hObject, eventdata, handles)
global Experiment IDs File
if Experiment.NumGrps
    if IDs.Group<Experiment.NumGrps
        Group = Experiment.Groups(IDs.Group).Group;
        Experiment.Groups(IDs.Group).Group = Experiment.Groups(IDs.Group+1).Group;
        Experiment.GroupList{IDs.Group} = Experiment.Groups(IDs.Group+1).Group.Name;
        IDs.Group = IDs.Group+1;
        Experiment.Groups(IDs.Group).Group = Group;
        Experiment.GroupList{IDs.Group} = Group.Name;
        set(handles.listbox_Groups, 'Value', IDs.Group, 'String', Experiment.GroupList);
        save([File.Exp.Path, File.Exp.Name], '-struct', 'Experiment');
    end
end


function radiobutton_GroupShow_Callback(hObject, eventdata, handles)
global Experiment IDs File
show = get(hObject, 'Value');
Experiment.Groups(IDs.Group).Group.Show = show;
save([File.Exp.Path, File.Exp.Name], '-struct', 'Experiment');

% copy a group for insertion in another group (load first experiment, copy
% desired group, load second experiment and insert the group into a
% selected group from the second experiment)
function pushbutton_GroupCopy_Callback(hObject, eventdata, handles)
global ClipBoard IDs Experiment
ClipBoard.Experiment.Name = Experiment.Name;
ClipBoard.Group = Experiment.Groups(IDs.Group).Group;
MessageStr = sprintf('Copied ''%s'': ''%s''', ClipBoard.Experiment.Name, ClipBoard.Group.Name);
msgbox(MessageStr);

function pushbutton_GroupInsert_Callback(hObject, eventdata, handles)
global ClipBoard IDs Experiment Record
if ~isempty(ClipBoard.Group)
    SelectedGroup = Experiment.Groups(IDs.Group).Group;
    CopiedGroupName = ClipBoard.Group.Name;
    SelectedGroupName = SelectedGroup.Name;
    CheckStr = sprintf('Are you sure you want to insert copied group (''%s'': ''%s'') into selected group (''%s'')?', ClipBoard.Experiment.Name, CopiedGroupName, SelectedGroupName); 
    Check = questdlg(CheckStr, 'Group Insertion', 'Yes', 'No', 'Yes');
    if strcmp(Check,'Yes')
        for i=1:ClipBoard.Group.NumRecs
        	j=SelectedGroup.NumRecs+i;
            SelectedGroup.RecordList{j} = ClipBoard.Group.RecordList{i};
            if isempty(SelectedGroup.Records)
                SelectedGroup.Records = ClipBoard.Group.Records(i);
            else
                SelectedGroup.Records(j) = ClipBoard.Group.Records(i);
            end
        end
        SelectedGroup.NumRecs = SelectedGroup.NumRecs + ClipBoard.Group.NumRecs;
        SelectedGroup.NumRecsIn = SelectedGroup.NumRecsIn + ClipBoard.Group.NumRecsIn; 
        SelectedGroup.NumAnalyzed = SelectedGroup.NumAnalyzed + ClipBoard.Group.NumAnalyzed;
    Experiment.Groups(IDs.Group).Group = SelectedGroup;
    Record = SelectedGroup.Records(IDs.Record).Record;
    SF_ExperimentUnSaved(handles);
    SF_RecordRetrieve(handles);
    end
else
    errordlg('No group copied');
end
% ========================================================================

% Record Management
% -----------------

function pushbutton_RecordLoad_Callback(hObject, eventdata, handles)
Type = 'Trace';
RecordLoad_Manager(handles, Type);

function RecordLoad_Manager(handles, Type)
global File
button = questdlg('Load single trace or batch?','Load type','Single','Batch','Single');
if strcmp(button, 'Single')
    [File.Trace.Name, File.Trace.Path] = uigetfile('*.mat', 'Select Trace data file');
    OK = RecordLoad(handles, Type);
    if ~OK
        errordlg(sprintf('"%s" already exists in the record list!', File.Trace.Name),'Attempt to add an existing record');
    end
else
    Reload = 0;
    BatchPath = uigetdir;
    if BatchPath ~= 0
        File.Trace.Path = BatchPath;
        BatchDir = dir([BatchPath, filesep, '*.mat']);
        BatchList = {BatchDir.name};
        NumTraces = numel(BatchList);
        for i = 1:NumTraces
            File.Trace.Name = BatchList{i};
            OK = RecordLoad(handles, Type);
            if ~OK
                Reload = 1;
            end
        end        
    end
    if Reload
        errordlg('At least one record in the batch already exists in the record list and was thus not reloaded!');
    end
end

    
function OK = RecordLoad(handles, Type)
global File Trace Record Params IDs Experiment
OK = 1;
if File.Trace.Name ~= 0
    Group = Experiment.Groups(IDs.Group).Group;
    check = strmatch(File.Trace.Name, Group.RecordList);
    if isempty(check)
        cd(File.Trace.Path);
        if strcmp(Type, 'Trace')
            Trace = load(fullfile(File.Trace.Path, File.Trace.Name));
            TraceCompatabilize;
            Record = [];
            Record.Name = File.Trace.Name;
            Record.Flags.BleachCorrect = get(handles.radiobutton_BleachCorrect, 'Value');
            Record.Flags.EventsAnalyzed = 0;
            Record.Flags.ParentEventsAnalyzed = 0;
            Record.Flags.In = 1;
            Record.Flags.Invert = 0;
            Record.Params = Trace.Param;
            TraceOffline(handles);
            Record.Events.Params = Params.Events;
        else
            Record = load(fullfile(File.Trace.Path, File.Trace.Name));
        end
        Group.NumRecs = Group.NumRecs + 1;
        Group.NumRecsIn = Group.NumRecsIn + 1;
        IDs.Record = Group.NumRecs;
        Group.RecordList(IDs.Record) = {Record.Name};
        Group.Records(IDs.Record).Record = Record;
        [Group.RecordList, indsrt] = sort(Group.RecordList);
        Group.Records = Group.Records(indsrt);
        [srt indsrtind] = sort(indsrt); % just for finding new record location
        IDs.Record = indsrtind(Group.NumRecs);
        SF_PlotTraces(handles);
        Group.Records(IDs.Record).Record = Record;
        Experiment.Groups(IDs.Group).Group = Group;
        SF_AnalyzeSpikeDetect;
        SF_ExperimentUnSaved(handles);
        SF_RecordRetrieve(handles);
    else
        OK = 0;
    end
end


function pushbutton_RecordRemove_Callback(hObject, eventdata, handles)
global Experiment IDs File Record
Confirm = '';
Group = Experiment.Groups(IDs.Group).Group;
if Group.NumRecs
    Confirm = questdlg('Are you sure you want to remove this record?');
end
if strcmp(upper(Confirm), 'YES')
    IDs.Record = get(handles.listbox_RecordIn, 'Value');
    Group.NumRecs = Group.NumRecs-1;
    Group.NumRecsIn = Group.NumRecsIn-1;
    if ~Group.NumRecs
        Group.RecordList = {};
        Group.Records = [];
        Group.NumAnalyzed = 0;
        set(handles.pushbutton_RecordRemove, 'Enable', 'off');
    else
        if IDs.Record <= Group.NumRecs
            for j = IDs.Record:Group.NumRecs
                Group.RecordList{j} = Group.RecordList{j+1};
                Group.Records(j).Record = Group.Records(j+1).Record;
            end
        else
            IDs.Record = Group.NumRecs;
        end
        if Record.Flags.EventsAnalyzed
            Group.NumAnalyzed = Group.NumAnalyzed-1;
        end
        Group.RecordList = Group.RecordList(1:Group.NumRecs);
        Group.Records = Group.Records(1:Group.NumRecs);
%         if ~isempty(Record.Trace.BL)
%             set(handles.pushbutton_EventsAnalyze, 'Enable', 'on');
%         else
%             set(handles.pushbutton_EventsAnalyze, 'Enable', 'off');
%         end
    end
    Experiment.Groups(IDs.Group).Group = Group;
    SF_RecordRetrieve(handles);
    save([File.Exp.Path, File.Exp.Name], '-struct', 'Experiment');
end

function listbox_RecordIn_Callback(hObject, eventdata, handles)
global IDs Experiment
indrec = get(handles.listbox_RecordIn, 'Value');
if ~isempty(indrec) && indrec<=Experiment.Groups(IDs.Group).Group.NumRecs
    Group = Experiment.Groups(IDs.Group).Group;
    IDs.Record = indrec;
    SF_RecordRetrieve(handles);
%     if ~isempty(Record.Trace.BL)
%         set(handles.pushbutton_EventsAnalyze, 'Enable', 'on');
%     else
%         set(handles.pushbutton_EventsAnalyze, 'Enable', 'off');
%     end
%     set(handles.uipanel_Record, 'Title', sprintf('Record %g/%g Analyzed %g', IDs.Record, Group.NumRecs, Group.NumAnalyzed));
else
    set(hObject, 'Value', IDs.Record);
end
function listbox_RecordIn_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_RecordInOut_Callback(hObject, eventdata, handles)
global Experiment IDs File Record
if isfield(Record.Flags, 'In')
    In = Record.Flags.In;
else
    In = 1;
end
if isfield(Experiment.Groups(IDs.Group).Group, 'NumRecsIn')
    NumRecsIn = Experiment.Groups(IDs.Group).Group.NumRecsIn;
else
    NumRecsIn = Experiment.Groups(IDs.Group).Group.NumRecs;
end
if In
    In = 0;
    NumRecsIn = NumRecsIn - 1;
else
    In = 1;
    NumRecsIn = NumRecsIn + 1;
end
Record.Flags.In = In;
Experiment.Groups(IDs.Group).Group.Records(IDs.Record).Record = Record;
Experiment.Groups(IDs.Group).Group.NumRecsIn = NumRecsIn;
SF_Update_RecordInOut(handles)
SF_ExperimentUnSaved(handles);
SF_PlotTraces(handles);

function pushbutton_RecordParams_Callback(hObject, eventdata, handles)
global Record
if isfield(Record.Params, 'Experiment')
    Names = fieldnames(Record.Params.Experiment);
    for i = 1:numel(Names)
        eval(sprintf('ValueStr = Record.Params.Experiment.%s;', Names{i}));
        RecParams{i} = sprintf('%s = %s', Names{i}, ValueStr);
    end
    msgbox(RecParams, 'Record Parameters', 'help', 'replace')
end


function pushbutton_SeparatorMark_Callback(hObject, eventdata, handles)
global Record
axes(handles.axes_Ratio);
T = Record.Trace.T;
SeparatorT = ginput(1);
[mn SeparatorID] = min(abs(SeparatorT(1)-T));
Record.SeparatorID = SeparatorID;
pushbutton_ROIReset_Callback(handles.pushbutton_ROIReset, eventdata, handles);
SF_ExperimentUnSaved(handles);

function pushbutton_SeparatorRemove_Callback(hObject, eventdata, handles)
global Record
Record.SeparatorID = [];
pushbutton_ROIReset_Callback(handles.pushbutton_ROIReset, eventdata, handles);
SF_ExperimentUnSaved(handles);

function popupmenu_Separator_Callback(hObject, eventdata, handles)
global IDs Record
if isfield(Record, 'SeparatorID')
    IDs.Summary.Separator = get(hObject, 'Value');
else
    IDs.Summary.Separator = 1;
    set(hObject, 'Value', IDs.Summary.Separator);
end
function popupmenu_Separator_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function radiobutton_SeparatorSubtract_Callback(hObject, eventdata, handles)
global Experiment
Experiment.Flags.SeparatorSubtract = get(hObject, 'Value');

% invert record sign 
function checkbox_RecordInvert_Callback(hObject, eventdata, handles)
global Record
Record.Flags.Invert = get(hObject, 'Value');
SF_TraceInvert;
SF_PlotTraces(handles);
SF_ExperimentUnSaved(handles);


% Special additional record menu for exporting/importing records into
% record files, used for merging records from different experiments
% -------------------------------------------------------------------

function Rec_Callback(hObject, eventdata, handles)


% Export all records of the experiment into record files with a different
% directory for each group
function ExpRec_Callback(hObject, eventdata, handles)
global Experiment File
% if isfield(File, 'Export') && ~isempty(File.Export.Path)
%     ExprtPath = File.Export.Path;
% else
%     ExprtPath = File.Exp.Path;
% end
ExprtPath = File.Exp.Path;
File.Export.Path = uigetdir(ExprtPath, 'Select export directory');
ExpPath = fullfile(ExprtPath, Experiment.Name(1:end-4));
[s,mess] = mkdir(ExpPath);
if strcmp(mess, 'Directory already exists.')
    errordlg('Direcotry already exists');
else
    for g = 1:Experiment.NumGrps
        Group = Experiment.Groups(g).Group;
        GrpPath = fullfile(ExpPath, Group.Name);
        mkdir(GrpPath);
        for r = 1:Group.NumRecs
            Record = Group.Records(r).Record;
            save(fullfile(GrpPath,Record.Name), '-struct', 'Record');
        end
    end
end


% Import record(s) from file
function ImpRec_Callback(hObject, eventdata, handles)
Type = 'Record';
RecordLoad_Manager(handles, Type);


% ========================================================================

% Event Management
% ----------------

function pushbutton_EventPick_Callback(hObject, eventdata, handles)
global Record
if isfield(Record.Events, 'EventInd') && ~isempty(Record.Events.EventInd)
    axes(handles.axes_Ratio)
    T = Record.Trace.T;
    EventInd = Record.Events.EventInd;
    IndIn = Record.Events.IndIn;
    Tin = T(EventInd(2,IndIn));

    [t r] = ginput(1);
    t_dist_in = abs(Tin - t);
    [mn_in ind_eventin] = min(t_dist_in);
    set(handles.listbox_EvntIn, 'Value', ind_eventin);
    listbox_EvntIn_Callback(handles.listbox_EvntIn, eventdata, handles);
end

function pushbutton_OutEvntPick_Callback(hObject, eventdata, handles)
global Record
if isfield(Record.Events, 'EventInd') && ~isempty(Record.Events.EventInd)
    axes(handles.axes_Ratio)
    T = Record.Trace.T;
    EventInd = Record.Events.EventInd;
    IndOut = Record.Events.IndOut;
    Tout = T(EventInd(2,IndOut));
    [t r] = ginput(1);
    t_dist_out = abs(Tout - t);
    [mn_out ind_eventout] = min(t_dist_out);
    set(handles.listbox_EvntOut, 'Value', ind_eventout);
    listbox_EvntOut_Callback(handles.listbox_EvntOut, eventdata, handles);
end

function listbox_EvntIn_Callback(hObject, eventdata, handles)
global Record
i = Record.Events.IndIn(get(hObject, 'Value'));
SF_PlotTraces(handles);
SF_PlotSpikes(handles, 'Events', i);
function listbox_EvntIn_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function listbox_EvntOut_Callback(hObject, eventdata, handles)
global Record
i = Record.Events.IndOut(get(hObject, 'Value'));
SF_PlotTraces(handles);
SF_PlotSpikes(handles, 'Events', i);
function listbox_EvntOut_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton_EvntOut_Callback(hObject, eventdata, handles)
global Record
if Record.Events.NumIndIn
    jout = get(handles.listbox_EvntIn, 'Value');
    i = Record.Events.IndIn(jout);
    Record.Events.IndIn = setdiff(Record.Events.IndIn, i);
    [Record.Events.IndOut indoutsrt] = sort([Record.Events.IndOut i]);
    [mx indout] = max(indoutsrt);
    Record.Events.NumIndIn = Record.Events.NumIndIn-1;
    jnew = jout;
    if Record.Events.NumIndIn
        if jnew > Record.Events.NumIndIn
            jnew = Record.Events.NumIndIn;
        end
        set(handles.listbox_EvntIn, 'Value', jnew);
    else
        set(handles.pushbutton_EvntOut, 'Enable', 'off');
    end
    set(handles.pushbutton_EvntIn, 'Enable', 'on');
    SF_PlotTraces(handles);
    DisplaySpikes(handles, 'Events');
    set(handles.listbox_EvntOut, 'Value', indout);
    EventsRemoveAnalyzed(handles, eventdata, jout); % see below
    SF_ExperimentUnSaved(handles);
end

function pushbutton_EvntIn_Callback(hObject, eventdata, handles)
global Record
if ~isempty(Record.Events.IndOut)
    j = get(handles.listbox_EvntOut, 'Value');
    i = Record.Events.IndOut(j);
    Record.Events.IndOut = setdiff(Record.Events.IndOut, i);
    [Record.Events.IndIn indinsrt] = sort([Record.Events.IndIn i]);
    [mx indin] = max(indinsrt);
    Record.Events.NumIndIn = Record.Events.NumIndIn+1;
    if ~isempty(Record.Events.IndOut)
        if j > length(Record.Events.IndOut)
            j = length(Record.Events.IndOut);
        end
        set(handles.listbox_EvntOut, 'Value', j);
    else
        set(handles.pushbutton_EvntIn, 'Enable', 'off');
    end
    set(handles.pushbutton_EvntOut, 'Enable', 'on');
    SF_PlotTraces(handles);
    DisplaySpikes(handles, 'Events');
    set(handles.listbox_EvntIn, 'Value', indin);
    EventsUnAnalyze(handles);
    SF_ExperimentUnSaved(handles);
end


% ========================================================================

% Events Find
% -----------

% Manual

function pushbuttonSelectPeak_Callback(hObject, eventdata, handles)
global Record
axes(handles.axes_Ratio)
T = Record.Trace.T;
[t m] = ginput(1);
tid = find(T>t,1,'first');
if ~isempty(tid)
    if tid>1
        [mn mnid] = min([T(tid)-t t-T(tid-1)]);
        tid = tid-(mnid-1);
    end
    Record.Manual.PeakInd = tid;
    SF_PlotTraces(handles);
    SF_ExperimentUnSaved(handles);
end


% Automatic

function pushbutton_EvantsFindManual_Callback(hObject, eventdata, handles)
global Record
axes(handles.axes_Ratio)
T = Record.Trace.T;
% msgbox('Please select spike start point','Manual Spike Insertion');
StartT = ginput(1);
[mn StartID] = min(abs(StartT(1)-T));
NextStartPos = find(Record.Events.EventInd(1,:) > StartID, 1, 'first');
NextPeakPos = find(Record.Events.EventInd(2,:) > StartID, 1, 'first');
check1 = 1;
if ~isempty(NextStartPos) && ~isempty(NextPeakPos)
    if NextPeakPos < NextStartPos % new spike is within an existing spike
        SF_PlotTraces(handles);
        DisplaySpikes(handles, 'Events')
        msgbox('New start must come after previous spike peak');
        check1 = 0;
    end
end
if check1
    if ~isempty(NextStartPos)
        PeakTLimit = T(Record.Events.EventInd(1, NextStartPos));
    else
        PeakTLimit = T(end);
        NextStartPos = length(Record.Events.EventInd)+1;
    end
    plot(T(StartID), Record.Trace.R(StartID), 'g*');
    % msgbox('Please select spike peak point','Manual Spike Insertion');
    PeakT = ginput(1);
    if PeakT > PeakTLimit
        SF_PlotTraces(handles);
        DisplaySpikes(handles, 'Events')
        msgbox('New peak must come before next spike start');
    else
        [mn PeakID] = min(abs(PeakT(1)-T));
        plot(T(PeakID), Record.Trace.R(PeakID), 'go');
        button = questdlg('Please confirm new spike','Manual spike');
        if strcmp('Yes', button)
            Record.Events.EventInd = sort([Record.Events.EventInd [StartID; PeakID]], 2);
            InIncrmntInd = find(Record.Events.IndIn >= NextStartPos);
            Record.Events.IndIn(InIncrmntInd) = Record.Events.IndIn(InIncrmntInd)+1;
            Record.Events.IndIn = sort([Record.Events.IndIn NextStartPos]);
            OutIncrmntInd = find(Record.Events.IndOut >= NextStartPos);
            Record.Events.IndOut(OutIncrmntInd) = Record.Events.IndOut(OutIncrmntInd)+1;
            Record.Events.NumIndIn = Record.Events.NumIndIn+1;
            SF_ExperimentUnSaved(handles);
            EventsUnAnalyze(handles);
        end
        SF_PlotTraces(handles);
        DisplaySpikes(handles, 'Events')
    end
end

function pushbutton_EventsFindAuto_Callback(hObject, eventdata, handles)
Events_ReFind(handles, 'Events');
    
function Events_ReFind(handles, Type)
SF_AnalyzeSpikeDetect;
SF_PlotTraces(handles);
DisplaySpikes(handles, Type);
EventsUnAnalyze(handles);



% create parent and specify its child spikes
function pushbutton_ParentEvntAdd_Callback(hObject, eventdata, handles)
global Record IDs
Rect = getrect(handles.axes_Ratio);
T = Record.Trace.T;
EventInInd = Record.Events.EventInd(:,Record.Events.IndIn);
NewChildInd = find(T(EventInInd(2,:))>=Rect(1) & T(EventInInd(2,:))<=Rect(1)+Rect(3));
if ~isempty(NewChildInd)
    NewParentID = [Record.Events.Analyzed.StrtInd(NewChildInd(1)); Record.Events.Analyzed.EndInd(NewChildInd(end))];
    if ~isfield(Record, 'ParentEvents') || isempty(Record.ParentEvents.ParentInd)
        Record.ParentEvents.ParentInd = [];
        Record.ParentEvents.NumParents = 0;
    end
    % make sure no parent exists that includes any of the new parent's children
    check = 1;
    for i=1:Record.ParentEvents.NumParents
        Intrsct = intersect(Record.ParentEvents.ChildInd{i}, NewChildInd);
        if ~isempty(Intrsct)
            check = 0;
            break;
        end
    end
    if check
        Record.ParentEvents.NumParents = Record.ParentEvents.NumParents+1;
        Record.ParentEvents.ParentInd = [Record.ParentEvents.ParentInd NewParentID];
        [Srt SrtInd] = sort(Record.ParentEvents.ParentInd(1,:));
        Record.ParentEvents.ParentInd = Record.ParentEvents.ParentInd(:,SrtInd);
        Record.ParentEvents.ChildInd{Record.ParentEvents.NumParents} = NewChildInd;
        Record.ParentEvents.ChildInd = Record.ParentEvents.ChildInd(SrtInd);
        if ~isfield(Record.Events, 'IsChild')
            Record.Events.IsChild = zeros(1, Record.Events.NumIndIn);
        end
        Record.Events.IsChild(NewChildInd) = 1;
        Record.ParentEvents.Analyzed = [];
        Record.Flags.ParentEventsAnalyzed = 0;
        IDs.Parent = find(SrtInd==Record.ParentEvents.NumParents);
        SF_DisplayParents(handles);
        SF_PlotTraces(handles);
        SF_ExperimentUnSaved(handles);
    else
        msgbox('New parent may not include spikes from an existing parent');
    end
end

% remove selected parent
function pushbutton_ParentEvntRemove_Callback(hObject, eventdata, handles)
global Record IDs
if isfield(Record, 'ParentEvents') && Record.ParentEvents.NumParents
    Ind = setdiff(1:Record.ParentEvents.NumParents, IDs.Parent);
    Record.ParentEvents.Analyzed = [];
    Record.Flags.ParentEventsAnalyzed = 0;
    Record.Events.IsChild(Record.ParentEvents.ChildInd{IDs.Parent}) = 0;
    Record.ParentEvents.ChildInd = Record.ParentEvents.ChildInd(Ind);
    Record.ParentEvents.ParentInd = Record.ParentEvents.ParentInd(:,Ind);
    Record.ParentEvents.NumParents = Record.ParentEvents.NumParents-1;
    if IDs.Parent>1
        IDs.Parent = IDs.Parent-1;
    end
    SF_DisplayParents(handles);
    SF_PlotTraces(handles);
    SF_ExperimentUnSaved(handles);
end

function listbox_ParentEvnts_Callback(hObject, eventdata, handles)
global IDs
IDs.Parent = get(handles.listbox_ParentEvnts, 'Value');
SF_PlotTraces(handles);
function listbox_ParentEvnts_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_ParentEvntAnalyze_Callback(hObject, eventdata, handles)
global Record
SF_AnalyzeParents;
Record.Flags.ParentEventsAnalyzed = 1;
set(handles.pushbutton_ParentEvntAnalyze, 'ForeGroundColor', [0 0 0]);
SF_PlotTraces(handles);
SF_ExperimentUnSaved(handles);


function popupmenu_ParentEvntSelect_Callback(hObject, eventdata, handles)
global IDs
IDs.Summary.Parents = get(hObject, 'Value');
function popupmenu_ParentEvntSelect_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ========================================================================

% Event analysis
% --------------

function popupmenu_EventSource_Callback(hObject, eventdata, handles)
global IDs
Confirm = questdlg('Are you sure you want to switch event source, this will change all event records?');
if strcmpi(Confirm, 'YES')
    IDs.Event.Source = get(hObject, 'Value');
    switch IDs.Event.Source
        case 1
            set(handles.text6, 'String', 'YC (std)')
        case 2
            set(handles.text6, 'String', '%pixels')
    end
    SF_AnalyzeSpikeDetect;
else
    set(hObject, 'Value', IDs.Event.Source);
end
function popupmenu_EventSource_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton_EventsAnalyze_Callback(hObject, eventdata, handles)
global Experiment IDs Record
if isfield(Record.Events, 'NumIndIn')
    OK = 1;
    if Record.Flags.EventsAnalyzed
%         button = questdlg('Are you sure you want to reanalyze?', 'Record already analyzed');
%         if ~strcmp('Yes', button)
%             OK = 0;
%         end
        Experiment.Groups(IDs.Group).Group.NumAnalyzed = Experiment.Groups(IDs.Group).Group.NumAnalyzed-1;
    end
    if OK
        NumEvents = Record.Events.NumIndIn;
        Group = Experiment.Groups(IDs.Group).Group;
        set(handles.listbox_EvntIn, 'Value', 1);
        set(handles.listbox_EvntOut, 'Value', 1);
Record.Events.Analyzed = [];
Record.Events.Analyzed.FlagManualStrt = zeros(1,NumEvents);
Record.Events.Analyzed.FlagManualEnd = zeros(1,NumEvents);
if ~isempty(Record.Events.IndIn)
    Record.Events.Analyzed.StrtInd = Record.Events.EventInd(1,Record.Events.IndIn);
    Record.Events.Analyzed.PeakInd = Record.Events.EventInd(2,Record.Events.IndIn);
    Record.Events.Analyzed.EventFrequency = length(Record.Events.Analyzed.StrtInd)/(Record.Trace.T(end)-Record.Trace.T(1));
    Record.Events.Analyzed.StartTriggeredPeak = [];
    Record.Events.Analyzed.PeakTriggeredRatio = Record.Trace.R(Record.Events.Analyzed.StrtInd);
    RandStrtInd = ceil(rand(1,NumEvents)*length(Record.Trace.R));
    Record.Events.Analyzed.RandPeakTriggeredRatio = Record.Trace.R(RandStrtInd);
    Record.Events.Analyzed.MeanPeakTriggeredRatio = mean(Record.Trace.R);
else
    Record.Events.Analyzed.StrtInd = [];
    Record.Events.Analyzed.PeakInd = [];
    Record.Events.Analyzed.EventFrequency = 0;
    Record.Events.Analyzed.StartTriggeredPeak = NaN;
    Record.Events.Analyzed.PeakTriggeredRatio = NaN;
    Record.Events.Analyzed.RandPeakTriggeredRatio = NaN;
    Record.Events.Analyzed.MeanPeakTriggeredRatio = NaN;
end
Record.Events.Analyzed.CorrRatioYmotion = corr(Record.Trace.R', Record.Trace.C_M(2,:)');
if IDs.Event.Source==1
    Record.Events.Analyzed.AmpStrt = nan(1,NumEvents);
    Record.Events.Analyzed.AmpStrt0 = nan(1,NumEvents);
    Record.Events.Analyzed.ClimbRate = nan(1,NumEvents);
    Record.Events.Analyzed.ISI = nan(1,NumEvents-1);
end
        SF_PlotTraces(handles);
        DisplaySpikes(handles, 'Events');
if IDs.Event.Source==1
        for i=1:NumEvents
            SF_AnalyzeEvent(handles, i)
        end
end
        Record.Flags.EventsAnalyzed = 1;
        Group.NumAnalyzed = Group.NumAnalyzed+1;
        set(handles.uipanel_Record, 'Title', sprintf('Record %g/%g Analyzed %g', 1, Group.NumRecs, Group.NumAnalyzed));
        set(handles.pushbutton_EventsAnalyze, 'ForegroundColor', [0 0 0]);
        Experiment.Groups(IDs.Group).Group = Group;
        SF_ExperimentUnSaved(handles);
        GUIList = {'pushbutton_ShowAnalyzed', 'pushbutton_EditStart', 'pushbutton_EditEnd'};
        GUIEnable(handles, GUIList, 1);
    end
end

function pushbutton_AnalyzeAll_Callback(hObject, eventdata, handles)
global Experiment Record IDs
bt_str_all = 'All'; bt_str_unan = 'Only un-analyzed'; bt_str_cncl = 'Cancel';
button = questdlg('Analyze:','Analysis scope', bt_str_all, bt_str_unan, bt_str_cncl, bt_str_unan);
if ~strcmp(button, bt_str_cncl)
    set(handles.text_ExperimentFile, 'String', 'Analyzing - Please Wait');
    ids.Group = IDs.Group;
    ids.Record = IDs.Record;
    for i=1:Experiment.NumGrps
        IDs.Group = i;
        Group = Experiment.Groups(IDs.Group).Group;
        for j=1:Group.NumRecs
            IDs.Record = j;
            Record = Group.Records(IDs.Record).Record;
            if strcmp(button, bt_str_all) || (strcmp(button, bt_str_unan) && ~Record.Flags.EventsAnalyzed)
                pause(0.1);
                pushbutton_EventsAnalyze_Callback(handles.pushbutton_EventsAnalyze, eventdata, handles);
            end
        end
    end
    IDs.Group = ids.Group;
    IDs.Record = ids.Record;
    Record = Experiment.Groups(IDs.Group).Group.Records(IDs.Record).Record;
    set(handles.text_ExperimentFile, 'String', Experiment.Name);
end


function EventsUnAnalyze(handles)
global Record Experiment IDs
Group = Experiment.Groups(IDs.Group).Group;
if Record.Flags.EventsAnalyzed
    Group.NumAnalyzed = Group.NumAnalyzed-1;
    Record.Flags.EventsAnalyzed = 0;
    set(handles.pushbutton_EventsAnalyze, 'ForegroundColor', [1 0 0]);
    set(handles.uipanel_Record, 'Title', sprintf('Record %g/%g Analyzed %g', IDs.Record, Group.NumRecs, Group.NumAnalyzed));
end
Record.Events.Analyzed = [];
SF_ExperimentUnSaved(handles);

% remove event's analysis resluts
function EventsRemoveAnalyzed(handles, eventdata, i)
global Record
if Record.Flags.EventsAnalyzed && Record.Events.NumIndIn
    if isfield(Record.Events, 'IsChild') && Record.Events.IsChild(i)
        for j = 1:Record.ParentEvents.NumParents
            ChildID = find(Record.ParentEvents.ChildInd{j} == i);
            if ~isempty(ChildID)
                Record.ParentEvents.ChildInd{j}(ChildID) = [];
                pushbutton_ParentEvntAnalyze_Callback(handles.pushbutton_ParentEvntAnalyze, eventdata, handles)
                break;
            end
        end
    end
    AnNames = fieldnames(Record.Events.Analyzed);
    for j = 1:length(AnNames)
        if ~strcmp(AnNames{j}, 'ISI')
            Record.Events.Analyzed.(AnNames{j})(:,i) = [];
        else
            if i==Record.Events.NumIndIn+1
                Record.Events.Analyzed.ISI(i-1) = [];
            else
                Record.Events.Analyzed.ISI(i-1) = Record.Events.Analyzed.ISI(i-1)+Record.Events.Analyzed.ISI(i);
                Record.Events.Analyzed.ISI(i) = [];
            end
        end
    end
    SF_ExperimentUnSaved(handles);
else
    EventsUnAnalyze(handles); % no more events left
end


function pushbutton_EditStart_Callback(hObject, eventdata, handles)
global Record
axes(handles.axes_Ratio)
T = Record.Trace.T;
R = Record.Trace.R;
StrtInd = Record.Events.Analyzed.StrtInd;
StrtTimes = T(StrtInd);
EventInd = Record.Events.EventInd;
IndIn = Record.Events.IndIn;
[t_prv r_prv] = ginput(1);
t_dist = abs(StrtTimes - t_prv);
[mn ind_event] = min(t_dist);
t_end = T(Record.Events.Analyzed.EndInd(ind_event));
plot(T(StrtInd(ind_event)), R(StrtInd(ind_event)), 'ok', 'MarkerSize', 10,...
    'MarkerFaceColor', [1 0 0]);
[t_inp r_inp] = ginput(1);
if t_inp<t_end
    ind_strt_new = find(T>=t_inp, 1, 'first');
    Record.Events.Analyzed.StrtInd(ind_event) = ind_strt_new;
    Record.Events.Analyzed.FlagManualStrt(ind_event) = 1;
    SF_AnalyzeEvent(handles, ind_event);
end
SF_ExperimentUnSaved(handles);
pushbutton_ShowAnalyzed_Callback(handles.pushbutton_ShowAnalyzed, eventdata, handles);

function pushbutton_EditEnd_Callback(hObject, eventdata, handles)
global Record
axes(handles.axes_Ratio)
T = Record.Trace.T;
R = Record.Trace.R;
EndInd = Record.Events.Analyzed.EndInd;
EndTimes = T(EndInd);
EventInd = Record.Events.EventInd;
IndIn = Record.Events.IndIn;
[t_prv r_prv] = ginput(1);
t_dist = EndTimes - t_prv;
ind_event = find(t_dist>=0, 1, 'first');
t_strt = T(EventInd(1,IndIn(ind_event)));
plot(T(EndInd(ind_event)), R(EndInd(ind_event)), 'ok', 'MarkerSize', 10,...
    'MarkerFaceColor', [1 0 0]);
[t_inp r_inp] = ginput(1);
if t_inp>t_strt
    ind_end_new = find(T>=t_inp, 1, 'first');
    Record.Events.Analyzed.EndInd(ind_event) = ind_end_new;
    Record.Events.Analyzed.FlagManualEnd(ind_event) = 1;
    SF_AnalyzeEvent(handles, ind_event);
end
SF_ExperimentUnSaved(handles);
pushbutton_ShowAnalyzed_Callback(handles.pushbutton_ShowAnalyzed, eventdata, handles);

function pushbutton_ShowAnalyzed_Callback(hObject, eventdata, handles)
global Record
if isfield(Record, 'Events') && isfield(Record.Events, 'Analyzed')
    SF_PlotTraces(handles);
    SF_AnalyzedShow(handles);
end

function pushbutton_BleachCompute_Callback(hObject, eventdata, handles)
global Record
if Record.Events.NumIndIn
    SF_BleachCompute;
    GUIList = {'radiobutton_BleachCorrect', 'edit_TauBleach', 'text_TauBleach', ...
        'pushbutton_EventsAnalyze'};
    GUIEnable(handles, GUIList, 1);
    set(handles.edit_TauBleach, 'String', num2str(Record.Params.TauBl,'%2.1f'));
    if Record.Flags.BleachCorrect
        Record.Trace.R = Record.Trace.R0 - Record.Trace.BL;
    end
    SF_PlotTraces(handles);
    DisplaySpikes(handles, 'Events');
end

function edit_TauBleach_Callback(hObject, eventdata, handles)
global Record
if ~isempty(Record.Trace.BL)
    Record.Params.TauBl = str2num(get(hObject, 'String'));
    SF_BleachComputeConstrained;
    if Record.Flags.BleachCorrect
        Record.Trace.R = Record.Trace.R0 - Record.Trace.BL;
    end
    SF_PlotTraces(handles);
    DisplaySpikes(handles, 'Events');
end
function edit_TauBleach_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function radiobutton_BleachCorrect_Callback(hObject, eventdata, handles)
global Record
if ~isempty(Record.Trace.BL)
    Record.Flags.BleachCorrect = get(hObject, 'Value');
    % R0 is not the original R, but ratio change relative to F(1)
    % temporary fix: recompute R after bleaching is unchecked
    if Record.Flags.BleachCorrect
%         Record.Trace.R = Record.Trace.R0 - Record.Trace.BL;
        Record.Trace.R = Record.Trace.R - Record.Trace.BL;
        Record.Params.BleachCorrect = 1;
    else
%         Record.Trace.R = Record.Trace.R0;
        ID = 1:length(Record.Trace.Fluo(1,:));
        GoodInd = intersect(find(~isnan(Record.Trace.Fluo(1,:))), find(~isnan(Record.Trace.Fluo(2,:))));
        GoodInd = intersect(GoodInd, ID);
        NoStimInd = 1:length(GoodInd);
        F = Record.Trace.F;
        Record.Trace.R = (F(NoStimInd)-min(F(NoStimInd)))/min(F(NoStimInd))*100;
        Record.Params.BleachCorrect = 0;
    end
    SF_PlotTraces(handles);
    DisplaySpikes(handles, 'Events');
    SF_ExperimentUnSaved(handles);
else
    set(hObject, 'Value', Record.Flags.BleachCorrect);
end

% ========================================================================

% Motion
% ----------

% when toggled on motion trace is shown for every trace
function togglebutton_MotionOn_Callback(hObject, eventdata, handles)
global Params
button_state = get(hObject,'Value');
if button_state == get(hObject,'Min')
    Params.Motion.Detect = 0;
elseif button_state == get(hObject,'Max') 
    Params.Motion.Detect = 1;
 end
SF_PlotTraces(handles);

% when toggled on, ratio trace is not shown
function togglebutton_MotionBlind_Callback(hObject, eventdata, handles)
global Params
button_state = get(hObject,'Value');
if button_state == get(hObject,'Min')
    Params.Motion.Blind = 0;
elseif button_state == get(hObject,'Max') 
    Params.Motion.Blind = 1;
 end
SF_PlotTraces(handles);

% select general location of  beginning of motion
function pushbutton_MotionSelect_Callback(hObject, eventdata, handles)
global Record Params
if Params.Motion.Detect
    axes(handles.axes_Ratio)
    T = Record.Trace.T;
    [t m] = ginput(1);
    t = t/60;
    tid = find(T>t,1,'first');
    if ~isempty(tid)
        if tid>1
            [mn mnid] = min([T(tid)-t t-T(tid-1)]);
            tid = tid-(mnid-1);
        end
        Record.Motion.StrtInd = tid;
        SF_PlotTraces(handles);
        SF_ExperimentUnSaved(handles);
    end
end


% ========================================================================

% Parameters
% ----------

function pushbutton_SaveDefault_Callback(hObject, eventdata, handles)
global File Params
Confirm = questdlg('Save as default?');
if strcmp(upper(Confirm), 'YES')
    params.Events.Values = Params.Events.Values;
    params.Analysis.Values = Params.Analysis.Values;
    save(fullfile(File.Home, 'SF_Parameters.mat'), '-struct', 'params');
end

function pushbutton_RestoreDefault_Callback(hObject, eventdata, handles)
global Record File Params
Confirm = questdlg('Are you sure you want to restore default parameter settings?');
if strcmp(upper(Confirm), 'YES')
    params = load(fullfile(File.Home, 'SF_Parameters.mat'));
    Params.Events.Values = params.Events.Values;
    Params.Analysis.Values = params.Analysis.Values;
    SF_Parameters2GUI(handles, 'Events');
    if ~isempty(Record)
        FindSpikes('Events');
        SF_PlotTraces(handles);
        DisplaySpikes(handles, 'Events');
    end
end

function edit_EvntNumFrames_Callback(hObject, eventdata, handles)
global Record
check = SF_ParametersUpdate(handles, 'Events');
if check && ~isempty(Record)
    Events_ReFind(handles, 'Events');
end
function edit_EvntNumFrames_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_EvntDerivThresh_Callback(hObject, eventdata, handles)
global Record
check = SF_ParametersUpdate(handles, 'Events');
if check && ~isempty(Record)
    Events_ReFind(handles, 'Events');
end
function edit_EvntDerivThresh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_EvntYCThresh_Callback(hObject, eventdata, handles)
global Record
check = SF_ParametersUpdate(handles, 'Events');
if check && ~isempty(Record)
    Events_ReFind(handles, 'Events');
end
function edit_EvntYCThresh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_EvntNoiseThresh_Callback(hObject, eventdata, handles)
global Record
check = SF_ParametersUpdate(handles, 'Events');
if check && ~isempty(Record)
    Events_ReFind(handles, 'Events');
end
function edit_EvntNoiseThresh_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu_TimeType_Callback(hObject, eventdata, handles)
global Record
TimeTypes = get(hObject, 'String');
TimeType = TimeTypes{get(hObject, 'Value')};
if strcmp(TimeType, 'Stamp')
    Record.Trace.T = Record.Trace.Tstamp;
else
    Record.Trace.T = Record.Trace.Tmean;
end
Record.Axis.Lim0(1:2) = [Record.Trace.T(1) Record.Trace.T(end)];
SF_PlotTraces(handles);
function popupmenu_TimeType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% ========================================================================

% Plot
% ----

function popupmenu_PlotWhat_Callback(hObject, eventdata, handles)
SF_PlotTraces(handles);
SF_PlotSpikes(handles, 'Events');
function popupmenu_PlotWhat_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton_Zoom_Callback(hObject, eventdata, handles)
zoom;

function pushbutton_Pan_Callback(hObject, eventdata, handles)
pan;

function pushbutton_ROI_Callback(hObject, eventdata, handles)
global Record
Rect = getrect(handles.axes_Ratio);
Record.Axis.Rect = Rect;
Record.Axis.Lim = [Rect(1) Rect(1)+Rect(3) Rect(2) Rect(2)+Rect(4)];
SF_PlotTraces(handles);
SF_PlotSpikes(handles, 'Events');
% if isfield(Record.Events, 'Analyzed') && isfield(Record.Events.Analyzed, 'Tau0')
%     SF_PlotFits(handles, Spikes.Analyzed.Tau0.Fit)
% end

% time units
function popupmenu_TimeUnits_Callback(hObject, eventdata, handles)
global IDs
IDs.TimeUnit = get(hObject, 'Value');
function popupmenu_TimeUnits_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_ROIReset_Callback(hObject, eventdata, handles)
global Record
Record.Axis.Lim = Record.Axis.Lim0;
SF_PlotTraces(handles);
SF_PlotSpikes(handles, 'Events');
if isfield(Record, 'Analyzed') && isfield(Record.Analyzed, 'Tau0')
    SF_PlotFits(handles, Record.Analyzed.Tau0.Fit)
end

% hold trace for superimposition
function radiobutton_RatioHold_Callback(hObject, eventdata, handles)
global Plots IDs
Plots.Ratio.Hold = get(hObject, 'Value');
if Plots.Ratio.Hold
    Plots.Ratio.GroupID = IDs.Group;
    Plots.Ratio.RecordID = IDs.Record;
end


function radiobutton_IncludeOutRecords_Callback(hObject, eventdata, handles)
global Plots
Plots.Flags.IncludeOutRecords = get(hObject, 'Value');

function popupmenu_Group2Test_Callback(hObject, eventdata, handles)
global IDs
IDs.TestGroup = get(hObject, 'Value');
function popupmenu_Group2Test_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% Plot type
function popupmenu_PlotType_Callback(hObject, eventdata, handles)
global Plots Params
TypeID = get(handles.popupmenu_PlotType, 'Value');
Plots.Features.Ind = [1 1];
EventType = 'Events';
TypeList = Plots.Types.EventList;
FeatureList = Plots.Features.EventList;
TypeInd = TypeList(TypeID);
Plots.Types.Ind = TypeInd;
TypeFeatureList = intersect(Plots.Types.FeatureList{TypeInd}, FeatureList);
NameList = Plots.Features.NameList(TypeFeatureList);
set(handles.popupmenu_PlotFeatures1, 'String', NameList, 'Value', 1);
NumArgs = Plots.Types.NumArgList(TypeInd);
if NumArgs == 1
    set(handles.popupmenu_PlotFeatures2, 'String', ' ', 'Value', 1, 'Visible', 'off');
elseif NumArgs == 2
    set(handles.popupmenu_PlotFeatures2, 'String', NameList, 'Value', 1, 'Visible', 'on');
end
set(handles.text_PlotParam1, 'Visible', 'off');
set(handles.text_PlotParam2, 'Visible', 'off');
set(handles.edit_PlotParam1, 'Visible', 'off');
set(handles.edit_PlotParam2, 'Visible', 'off');
ParamList = Plots.Types.ParamList{TypeInd};
for i=1:length(ParamList)
    eval(sprintf('PHandle = handles.text_PlotParam%g;', i));
    set(PHandle, 'String', Params.Analysis.Names(ParamList(i)), 'Visible', 'on');
    eval(sprintf('PHandle = handles.edit_PlotParam%g;', i));
    set(PHandle, 'String', Params.Analysis.Values(ParamList(i)), 'Visible', 'on');
end

function popupmenu_PlotType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Plot Feature 1
function popupmenu_PlotFeatures1_Callback(hObject, eventdata, handles)
global Plots
Plots.Features.Ind(1) = get(hObject, 'Value');
function popupmenu_PlotFeatures1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Plot Feature 2
function popupmenu_PlotFeatures2_Callback(hObject, eventdata, handles)
global Plots
Plots.Features.Ind(2) = get(hObject, 'Value');
function popupmenu_PlotFeatures2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Plot
function pushbutton_Ax1Plot_Callback(hObject, eventdata, handles)
SF_PlotManager(handles, handles.axes_Analyzed1);

% Plot
function pushbutton_AxPlot_Callback(hObject, eventdata, handles)
SF_PlotManager(handles, handles.axes_Analyzed);

% Export
function pushbutton_Ax1Export_Callback(hObject, eventdata, handles)
figure;
h = copyobj(handles.axes_Analyzed1, gcf);
set(h, 'Units', 'normalized', 'Position', [0.25 0.25 0.5 0.5]);
set(h, 'FontSize', 16)

function pushbutton_AxExport_Callback(hObject, eventdata, handles)
hf = figure;
set(hf, 'Position', [100 100 500 400])
hf.Renderer='Painters';
h = copyobj(handles.axes_Analyzed, gcf);
set(h, 'Units', 'normalized', 'Position', [0.15 0.15 0.7 0.7]);
set(h, 'FontSize', 16)

function pushbutton_RatioExport_Callback(hObject, eventdata, handles)
figure(1);
h = copyobj(handles.axes_Ratio, gcf);
set(h, 'Units', 'normalized', 'Position', [0.15 0.15 0.7 0.7]);
set(h, 'FontSize', 16)
figure(2);
hYFP = copyobj(handles.axes_YFP, gcf);
set(hYFP, 'Units', 'normalized', 'Position', [0.15 0.15 0.7 0.7]);
set(hYFP, 'FontSize', 16)
figure(3);
hCFP = copyobj(handles.axes_CFP, gcf);
set(hCFP, 'Units', 'normalized', 'Position', [0.15 0.15 0.7 0.7]);
set(hCFP, 'FontSize', 16)


function pushbutton_Output_Callback(hObject, eventdata, handles)
SF_OutputFile(handles);


function edit_PlotParam1_Callback(hObject, eventdata, handles)
global Plots Params File
TypeInd = Plots.Types.Ind;
ParamList = Plots.Types.ParamList{TypeInd};
ValueStr = get(hObject, 'String');
v = str2double(char(ValueStr));
checkstr = sprintf('%s', Params.Analysis.Cond{ParamList(1)});
check = eval(sprintf(checkstr, v));
if check
    Params.Analysis.Values(ParamList(1)) = ValueStr;
    params.Events.Values = Params.Events.Values;
    params.Analysis.Values = Params.Analysis.Values;
    save(fullfile(File.Home, 'SF_Parameters.mat'), '-struct', 'params');
else
    Params.Analysis.Values(ParamList(1))
    set(hObject, 'String', Params.Analysis.Values(ParamList(1)));
end
function edit_PlotParam1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_PlotParam2_Callback(hObject, eventdata, handles)
global Plots Params File
TypeInd = Plots.Types.Ind;
ParamList = Plots.Types.ParamList{TypeInd};
ValueStr = get(hObject, 'String');
v = str2num(char(ValueStr));
check = eval('Params.Analysis.Cond{ParamList(2)}');
if check
    Params.Analysis.Values(ParamList(2)) = ValueStr;
    params.Events.Values = Params.Events.Values;
    params.Analysis.Values = Params.Analysis.Values;
    save(fullfile(File.Home, 'SF_Parameters.mat'), '-struct', 'params');
else
    set(hObject, 'String', Params.Analysis.Values(ParamList(2)));
end
function edit_PlotParam2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function radiobutton_PlotScatter_Callback(hObject, eventdata, handles)
global Plots
Plots.Flags.Scatter = get(hObject, 'Value');
pushbutton_AxPlot_Callback(handles.pushbutton_AxPlot, eventdata, handles);

function radiobutton_PlotHold_Callback(hObject, eventdata, handles)
global Plots
Plots.Flags.Hold = get(hObject, 'Value');

function edit_PlotR_Callback(hObject, eventdata, handles)
global Plots
r = str2double(char(get(hObject, 'String')));
if r>=0 && r<=1
    Plots.Colors.RGB(1) = r;
else
    set(hObject, 'String', num2str(Plots.Colors.RGB(1)));
end
function edit_PlotR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_PlotG_Callback(hObject, eventdata, handles)
global Plots
g = str2double(char(get(hObject, 'String')));
if g>=0 && g<=1
    Plots.Colors.RGB(2) = g;
else
    set(hObject, 'String', num2str(Plots.Colors.RGB(2)));
end
function edit_PlotG_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_PlotB_Callback(hObject, eventdata, handles)
global Plots
b = str2double(char(get(hObject, 'String')));
if b>=0 && b<=1
    Plots.Colors.RGB(3) = b;
else
    set(hObject, 'String', num2str(Plots.Colors.RGB(3)));
end
function edit_PlotB_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end









function edit_GroupNameDepth_Callback(hObject, eventdata, handles)
global Experiment File IDs
% check = WE_ParametersUpdate(handles, 'Display');
% if check && ~isempty(Experiment)
%     depth = str2num(get(hObject, 'String'));
%     for i=1:Experiment.NumGrps
%         Group = Experiment.Groups(i).Group;
%         for j=1:Group.NumRecs
%             Record = Group.Records(j).Record;
%             Record.Name = WE_Path2Name(Record.Path, depth);
%             Group.RecordList{j} = Record.Name;
%             Group.Records(j).Record = Record;
%         end
%         Experiment.Groups(i).Group = Group;
%     end
%     save([File.Exp.Path, File.Exp.Name], '-struct', 'Experiment');
%     set(handles.listbox_RecordIn, 'String', Experiment.Groups(IDs.Group).Group.RecordList);
% end
function edit_GroupNameDepth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function popupmenu_Summation_Callback(hObject, eventdata, handles)
global IDs
IDs.Summary.Summation = get(hObject, 'Value');
function popupmenu_Summation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_RawData_Callback(hObject, eventdata, handles)
SF_RawTraceDataFile;