% Copyright (C) 2016 Nils Persson
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

function varargout = GTFiber(varargin)
% GTFIBER MATLAB code for GTFiber.fig
%      GTFIBER, by itself, creates a new GTFIBER or raises the existing
%      singleton*.
%
%      H = GTFIBER returns the handle to a new GTFIBER or the handle to
%      the existing singleton*.
%
%      GTFIBER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GTFIBER.M with the given input arguments.
%
%      GTFIBER('Property','Value',...) creates a new GTFIBER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GTFiber_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GTFiber_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GTFiber

% Last Modified by GUIDE v2.5 10-Sep-2023 16:25:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GTFiber_OpeningFcn, ...
                   'gui_OutputFcn',  @GTFiber_OutputFcn, ...
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


function GTFiber_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for GTFiber
handles.output = hObject;
% addpath(genpath('./'))

if ~(ismcc || isdeployed)
    addpath(genpath(pwd)); % MATLAB:mpath:PathAlterationNotSupported in compiled application mode.
    set(handles.modeDispBox,'String',"App mode");
else
    set(handles.modeDispBox,'String',"Deploy mode");
end

% guidata(hObject, handles);


% Update handles structure
guidata(hObject, handles);


function varargout = GTFiber_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


%__________________________________________________________________________


function Main_Callback(hObject, eventdata, handles)


function Load_Callback(hObject, eventdata, handles)

h=get(groot, 'Children'); % ウインドウオブジェクトを全て取得
for i=1:length(h)
  if ~strcmp( h(i).Tag, 'mainFig')
      close(h(i)); %　メインウインドウ以外を閉じる
  end
end


[filename, folderpath] = uigetfile({'*.jpg;*.jpeg;*.tif;*.tiff;*.png;*.gif;*.bmp','All Image Files'});
if isequal(filename, 0); return; end % Cancel button pressed

% Prompt user for the image width
prompt = {'Enter image width in nanometers, with no commas (ex. 5000):'};
dlg_title = 'Image Scale';
num_lines = 1;

definput = {handles.nmWid.String};

answer = inputdlg(prompt,dlg_title,num_lines,definput);
set(handles.nmWid,'String',answer{1});
nmWid_Callback(hObject, eventdata, handles);

% Initialize the internal image data structure, "ims"
imfile = [folderpath, filename];
handles.ims = initImgData(imfile);
set(handles.fileNameBox,'String',handles.ims.imName);

%waitfor(isfield(handles.ims,'img'));
%waitfor(handles.ims.img);

% change color of "1. Run Filter" button after image loading
set(handles.Coherence_Filter,'ForegroundColor', 'black');
set(handles.runStitch,'ForegroundColor', [0.7, 0.7, 0.7]);

% Initialize the figure window and don't let the user close it
handles = imshowGT(handles.ims.img,handles,'img_axes');

disp("Ready for Run Filter");

guidata(hObject, handles);


function Coherence_Filter_Callback(hObject, eventdata, handles)

if ~isfield(handles,'ims')
    noload = errordlg('Go to File>Load Image to load an image before filtering.');
    return
end

% Get Settings
handles.ims.settings = get_settings(handles);
handles.ims = pix_settings(handles.ims);

% Run Filter Regime
handles = main_filter(handles);

set(handles.Coherence_Filter,'ForegroundColor', 'black');
set(handles.runStitch,'ForegroundColor', 'black');
disp("Ready for Stitch Fibers");

guidata(hObject, handles);


function runStitch_Callback(hObject, eventdata, handles)

if ~isfield(handles,'ims')
    noload = errordlg('Go to File>Load Image to load an image, then "Run Filter" and "Stitch Filter".');
    return
end

%if ~isfield(handles.ims,'skelTrim')
%    noload = errordlg('Go to File>Load Image to load an image, then Run Filter.');
%    return
%end

% Get Settings
handles.ims.settings = get_settings(handles);
handles.ims = pix_settings(handles.ims);

% Stitch fiber segments and calculate length
handles.ims = StitchFibers2(handles.ims);
handles = FiberVecPlot_stitch(handles);

if strcmp(get(handles.Option,'Checked'),'on')
    [folderPath,fileName, ext0] = fileparts(ims.imPath);
    saveFileNameLastResult = fullfile(folderPath,[fileName,'_last_result']);
    save(saveFileNameLastResult,'ims');
    disp(['last_result was saved in ', saveFileNameLastResult]);

end

disp("Ready for Export Results");
guidata(hObject, handles);


function AngMap_Callback(hObject, eventdata, handles)

if ~isfield(handles,'ims')
    noload = errordlg('Go to File>Load Image to load an image before filtering.');
    return
end

if ~isfield(handles.ims,'AngMap')
    nofilt = errordlg('"Run Filter" must be executed before results can be displayed');
    return
end

FiberVec_ACM(handles.ims);


function op2d_Callback(hObject, eventdata, handles)

if ~isfield(handles,'ims')
    noload = errordlg('Go to File>Load Image to load an image before filtering.');
    return
end

if ~isfield(handles.ims,'AngMap')
    nofilt = errordlg('"Run Filter" must be executed before results can be displayed');
    return
end

if ~isfield(handles.ims,'Fibers')
    nofilt = errordlg('"Stitch Fibers" must be executed before results can be displayed');
    return
end

plotS2D(handles.ims,0);
ODist_plot(handles.ims,0);

guidata(hObject, handles);


function GetFiberLength_Callback(hObject, eventdata, handles)

if ~isfield(handles,'ims')
    noload = errordlg('Go to File>Load Image to load an image before filtering.');
    return
end

if ~isfield(handles.ims,'Fibers')
    nofilt = errordlg('"Stitch Fibers" must be executed before results can be displayed');
    return
end

FLD_hist(handles.ims);
FWD_hist(handles.ims);

guidata(hObject, handles);


% --- Executes on button press in runDir.
function runDir_Callback(hObject, eventdata, handles)

% Solicit the folder to run
folderPath = uigetdir;

if isequal(folderPath, 0)
    return
end

if ispc
    separator = '\';
else
    separator = '/';
end

folderPath = [folderPath, separator];

% Get name for results file
prompt = {'Save results with file name (no extension necessary):'};
dlg_title = 'Save File Name';
num_lines = 1;
fileName = inputdlg(prompt,dlg_title,num_lines);
saveFilePath = [folderPath, fileName{1}, '.csv'];

run_directory(handles,folderPath,saveFilePath);


% function chainStacker_Callback(hObject, eventdata, handles)
% 
% % Solicit the folder to run
% folderPath = uigetdir;
% 
% if isequal(folderPath, 0)
%     return
% end
% 
% if ispc
%     separator = '\';
% else
%     separator = '/';
% end
% 
% folderPath = [folderPath, separator];
% 
% % Get name for results file
% prompt = {'Save results with file name (no extension necessary):'};
% dlg_title = 'Save File Name';
% num_lines = 1;
% fileName = inputdlg(prompt,dlg_title,num_lines);
% saveFilePath = [folderPath, fileName{1}, '.csv'];
% 
% % Solicit range of molecular weight and PDI for simulations
% prompt = {'List of Mn to use', 'List of PDI to use', 'Number of simulations per point'};
% dlg_title = 'MW Parameters';
% num_lines = 3;
% Mn_input = inputdlg(prompt,dlg_title,num_lines);
% 
% Mn_vec = str2num(Mn_input{1});
% PDI_vec = str2num(Mn_input{2});
% nruns = str2num(Mn_input{3});
% 
% run_directory_CS(handles,folderPath,saveFilePath,Mn_vec,PDI_vec,nruns);



%__________________________________________________________________________
% Fields for image processing settings


function gauss_Callback(hObject, eventdata, handles)

function gauss_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    
end


function rho_Callback(hObject, eventdata, handles)

function rho_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function difftime_Callback(hObject, eventdata, handles)

function difftime_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noiseArea_Callback(hObject, eventdata, handles)

function noiseArea_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function minFibLen_Callback(hObject, eventdata, handles)

function minFibLen_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tophatSize_Callback(hObject, eventdata, handles)

function tophatSize_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function nmWid_Callback(hObject, eventdata, handles)

nmWid = str2num(get(handles.nmWid,'String'));

if get(handles.scaleParams,'Value')
    if ~isempty(nmWid)
        set(handles.gauss,'String',num2str(nmWid*5/5000));
        set(handles.rho,'String',num2str(nmWid*15/5000));
        set(handles.tophatSize,'String',num2str(nmWid*40/5000));
        set(handles.noiseArea,'String',num2str(nmWid*1500/5000));
        set(handles.maxBranchSize,'String',num2str(nmWid*60/5000));
        set(handles.stitchGap,'String',num2str(nmWid*60/5000));
    end
end

guidata(hObject, handles);

function nmWid_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function threshMethod_Callback(hObject, eventdata, handles)

function threshMethod_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function globalThresh_Callback(hObject, eventdata, handles)

function globalThresh_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function maxBranchSize_Callback(hObject, eventdata, handles)

function maxBranchSize_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function saveFigs_Callback(hObject, eventdata, handles)


function mainFig_CreateFcn(hObject, eventdata, handles)


function widthText_CreateFcn(hObject, eventdata, handles)


function fibWidSamps_Callback(hObject, eventdata, handles)

function fibWidSamps_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%__________________________________________________________________________


% function Make_Gif_Callback(hObject, eventdata, handles)
% if ~isfield(handles,'ims')
%     noload = errordlg('Go to File>Load Image to load an image before filtering.');
%     return
% end
% 
% settings = get_settings(handles);
% [settings, ims] = pix_settings(settings,handles.ims);
% handles.ims = ims;
% gif_filter(handles.ims,settings);
% 
% settings.figSwitch = 1; % Gotta turn on figSwitch to make the figure
% settings.figSave = 0;   % No need to save
% gif_op2d_am(handles.ims,settings);
% 
% guidata(hObject, handles);


function invertColor_Callback(hObject, eventdata, handles)

switch get(handles.invertColor,'Value')
    case 1
        handles=imshowGT(imcomplement(handles.ims.gray),handles,'img_axes');
    case 0
        handles=imshowGT(handles.ims.gray,handles,'img_axes');
end

guidata(hObject, handles);

%__________________________________________________________________________
% Buttons for switching what figure is displayed in the image processing
% preview window

function showCED_ButtonDownFcn(hObject, eventdata, handles)


function showTopHat_ButtonDownFcn(hObject, eventdata, handles)


function showThresh_ButtonDownFcn(hObject, eventdata, handles)


function showClean_ButtonDownFcn(hObject, eventdata, handles)


function showSkel_ButtonDownFcn(hObject, eventdata, handles)


function showSkelTrim_ButtonDownFcn(hObject, eventdata, handles)


function showSegs_ButtonDownFcn(hObject, eventdata, handles)


function showFibers_ButtonDownFcn(hObject, eventdata, handles)


function showImg_ButtonDownFcn(hObject, eventdata, handles)


function showImg_Callback(hObject, eventdata, handles)

if isfield(handles.ims,'img')
    handles=imshowGT(handles.ims.img,handles,'img_axes');
end
guidata(hObject, handles);


function showCED_Callback(hObject, eventdata, handles)

if isfield(handles.ims,'CEDgray')
    handles=imshowGT(handles.ims.CEDgray,handles,'img_axes');
end
guidata(hObject, handles);


function showTopHat_Callback(hObject, eventdata, handles)

if isfield(handles.ims,'CEDtophat')
    handles=imshowGT(handles.ims.CEDtophat,handles,'img_axes');
end
guidata(hObject, handles);


function showThresh_Callback(hObject, eventdata, handles)

if isfield(handles.ims,'CEDbw')
    handles=imshowGT(handles.ims.CEDbw,handles,'img_axes');
end
guidata(hObject, handles);


function showClean_Callback(hObject, eventdata, handles)

if isfield(handles.ims,'CEDclean')
    handles=imshowGT(handles.ims.CEDclean,handles,'img_axes');
end
guidata(hObject, handles);


function showSkel_Callback(hObject, eventdata, handles)

if isfield(handles.ims,'skel')
    handles=imshowGT(handles.ims.skel,handles,'img_axes');
end
guidata(hObject, handles);


function showSkelTrim_Callback(hObject, eventdata, handles)

if isfield(handles.ims,'skelTrim')
    handles=imshowGT(handles.ims.skelTrim,handles,'img_axes');
end
guidata(hObject, handles);


function showSegs_Callback(hObject, eventdata, handles)

if isfield(handles.ims,'fibSegs')
    handles=FiberVecPlot_segs(handles);
end
guidata(hObject, handles);


function showFibers_Callback(hObject, eventdata, handles)

if isfield(handles.ims,'Fibers')
    handles=FiberVecPlot_stitch(handles);
end
guidata(hObject, handles);

%__________________________________________________________________________
% Fiber Stitching Setting Fields

function curvLen_Callback(hObject, eventdata, handles)

function curvLen_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function maxCurv_Callback(hObject, eventdata, handles)

function maxCurv_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function minWidth_Callback(hObject, eventdata, handles)

function minWidth_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function maxWidth_Callback(hObject, eventdata, handles)

function maxWidth_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function fiberStep_Callback(hObject, eventdata, handles)

function fiberStep_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stitchGap_Callback(hObject, eventdata, handles)

function stitchGap_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function scaleParams_Callback(hObject, eventdata, handles)



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to minFibLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minFibLen as text
%        str2double(get(hObject,'String')) returns contents of minFibLen as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minFibLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Export_Callback(hObject, eventdata, handles)
% hObject    handle to Export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if ~isfield(handles,'ims')
    noload = errordlg('Go to File>Load Image to load an image before exporting.');
    return
end

if ~isfield(handles.ims,'Fibers')
    nofilt = errordlg('"Stitch Fibers" must be executed before results can be exported.');
    return
end

[outputFolderName,name0, ext0] = fileparts(handles.ims.imPath);
disp(['exporting length and width in ', outputFolderName]);
fileNameLength = fullfile(outputFolderName,strcat(handles.ims.imName,'_FLD.txt'));
fileNameWidth = fullfile(outputFolderName,strcat(handles.ims.imName,'_FWD.txt'));
fileNameLW = fullfile(outputFolderName, strcat(handles.ims.imName, '_FLWD.csv'));
waitfor(isfield(handles.ims,'FLD'));
%writematrix(handles.ims.FLD, fileNameLength);
%disp(['list of length was saved in', fileNameLength]);
waitfor(isfield(handles.ims,'FWD'));
%writematrix(transpose(handles.ims.FWD), fileNameWidth);
%disp(['list of width was saved in', fileNameWidth]);

FLD = handles.ims.FLD;
FWD = transpose(handles.ims.FWD);

FLWD = [FLD, FWD];

writematrix(FLWD, fileNameLW);

% Initialize the Cell for the csv file
xl = cell(2,7);
xl{1,1} = 'Image Name';
xl{1,2} = 'Sfull fit';
xl{1,3} = 'Correlation Length (nm)';
xl{1,4} = 'Average Orientation (degrees)';
xl{1,5} = 'Fiber Length Density (1/um)';
xl{1,6} = 'Mean Fiber Length (nm)';
xl{1,7} = 'Mean Fiber Width (nm)';

% Write data to csv cell
xl{2,1} = handles.ims.imName;
xl{2,2} = handles.ims.op2d.Sfull;
xl{2,3} = handles.ims.op2d.decayLen;
xl{2,4} = handles.ims.ODist.director;
xl{2,5} = handles.ims.fibLengthDensity;
xl{2,6} = mean(handles.ims.FLD);
xl{2,7} = mean(handles.ims.FWD);

    if handles.ims.settings.figSave
        if exist(handles.ims.imNamePath)==0
            mkdir(handles.ims.imNamePath);  % make the directory to save the results figures
        end
    end

    % Save figures if specified
    if handles.ims.settings.figSave
        ODist_plot(handles.ims,1);
        plotS2D(handles.ims,1);
        handles = FiberVecPlot_stitch(handles,1);
        FLD_hist(handles.ims,1);
        FWD_hist(handles.ims,1);
    end

savePath = handles.ims.imNamePath;
saveFilePath = [savePath, '.csv'];
cell2csv(saveFilePath, xl, ',', 1999, '.');
disp("Exported results.");

% --- Executes on button press in pushbuttonExportResults13.
function pushbuttonExportResults13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonExportResults13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Export_Callback(hObject, eventdata, handles); % call Export_Callback function from menu


% --------------------------------------------------------------------
function Save_Setting_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Setting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get Settings

handles.ims.settings = get_settings(handles);

if ~isfield(handles.ims,'img')
    noload = errordlg('Load Image files before save settings to receive pix size.');
    return
end

handles.ims = pix_settings(handles.ims);

if ~isfield(handles.ims,'settings')
    noload = errordlg('Settings are empty. Load settings before save settings.');
    return
end

last_settings = handles.ims.settings;

[fileout,pathout,indx] = uiputfile('*.*','File Selection','last_settings.mat');
filename = fullfile(pathout,fileout);
save(filename, "last_settings");
disp("settings saved to last_settings");


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over fileNameBox.
function fileNameBox_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to fileNameBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Load_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function fileNameBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileNameBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function Load_Setting_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Setting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ims.settings = get_settings(handles);
% handles.ims = pix_settings(handles.ims);

[filename, folderpath] = uigetfile({'*.mat','mat File'});
if isequal(filename, 0); return; end % Cancel button pressed
[filepath0,filename_wo_ext,ext0] = fileparts(filename);
fileNameLastSetting = [folderpath, filename];
tempSettings = load(fileNameLastSetting, "last_settings");
handles.ims.settings = tempSettings.last_settings;
clear('tempSettings');
set_settings(handles);

handles.ims.settings = get_settings(handles);
%handles.ims = pix_settings(handles.ims);

guidata(hObject, handles);

function set_settings(handles)

nmWid = handles.ims.settings.nmWid;
invert = handles.ims.settings.invert;
thnm = handles.ims.settings.thnm;
noisenm = handles.ims.settings.noisenm;
maxBranchSizenm = handles.ims.settings.maxBranchSizenm;
globalThresh = handles.ims.settings.globalThresh;
threshMethod = handles.ims.settings.threshMethod;
figSave = handles.ims.settings.figSave;
gaussnm = handles.ims.settings.gaussnm;
rhonm = handles.ims.settings.rhonm;
Options = handles.ims.settings.Options;
fibWidSamps2 = handles.ims.settings.fibWidSamps2;
fiberStep_nm = handles.ims.settings.fiberStep_nm;
maxCurv = handles.ims.settings.maxCurv;
stitchGap = handles.ims.settings.stitchGap;
minFibLen = handles.ims.settings.minFibLen;
initDelay = handles.ims.settings.initDelay;
CEDStepDelay = handles.ims.settings.CEDStepDelay;
CEDFinalDelay = handles.ims.settings.CEDFinalDelay;
skelDelay = handles.ims.settings.skelDelay;
plotDelay = handles.ims.settings.plotDelay;
plotFinal = handles.ims.settings.plotFinal;
thpix = handles.ims.settings.thpix;
noisepix = handles.ims.settings.noisepix;
maxBranchSize = handles.ims.settings.maxBranchSize;
fiberStep = handles.ims.settings.fiberStep;
searchLat = handles.ims.settings.searchLat;
searchLong = handles.ims.settings.searchLong;


set(handles.nmWid, 'String', num2str(nmWid));
set(handles.invertColor,'Value', invert);
set(handles.tophatSize, 'String', num2str(thnm));
set(handles.noiseArea, 'String', num2str(noisenm));
set(handles.maxBranchSize, 'String', num2str(maxBranchSizenm));
set(handles.globalThresh, 'String', num2str(globalThresh));

set(handles.threshMethod, 'Value', threshMethod);

set(handles.saveFigs, 'Value', figSave);
set(handles.gauss, 'String', num2str(gaussnm));
set(handles.rho, 'String', num2str(rhonm));
set(handles.difftime, 'String', num2str(Options.T));

set(handles.fiberStep, 'String', num2str(fiberStep_nm));
set(handles.maxCurv, 'String', num2str(maxCurv*1000));
set(handles.stitchGap, 'String', num2str(stitchGap));
set(handles.minFibLen, 'String', num2str(minFibLen));


% --- Executes on button press in pbImage.
function pbImage_Callback(hObject, eventdata, handles)
% hObject    handle to pbImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h=get(groot, 'Children'); % ウインドウオブジェクトを全て取得
for i=1:length(h)
  if ~strcmp( h(i).Tag, 'mainFig')
      close(h(i)); %　メインウインドウ以外を閉じる
  end
end

%if isfield(handles.ims, '')
%    previousimPath = ''
%else previousimPath = handles.ims.imPath;
%end

[filename, folderPath] = uigetfile({'*.jpg;*.jpeg;*.tif;*.tiff;*.png;*.gif;*.bmp','All Image Files',previousimPath});
if isequal(filename, 0); return; end % Cancel button pressed

filePath = [folderPath,filename];

set(handles.fileNameBox,'String',filename);
guidata(hObject, handles);

% Get name for results file
[folderPath0,filename_wo_ext, file_ext] = fileparts(filePath);
saveFilePath = [folderPath, filename_wo_ext, '.csv'];

run_file(hObject,eventdata, handles,filePath,saveFilePath);


% --------------------------------------------------------------------
function Option_Callback(hObject, eventdata, handles)
% hObject    handle to Option (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function save_mat_file_Callback(hObject, eventdata, handles)
% hObject    handle to save_mat_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(hObject,'Checked'),'on')
    set(hObject,'Checked','off');
else 
    set(hObject,'Checked','on');
end

