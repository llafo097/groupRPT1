% =========================================================================
% =========================================================================
%                             RPT1 Group   
% =========================================================================
% =========================================================================

% Developed by: Nathaniel Mailhot
% GROUP: RPT1
% University of Ottawa
% Mechanical Engineering
% Latest Revision: 11/12/2020 by Luca LaFontaine

% =========================================================================
% SOFTWARE DESCRIPTION
% =========================================================================


function varargout = MAIN(varargin)
% MAIN MATLAB code for MAIN.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MAIN_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MAIN_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MAIN

% Last Modified by GUIDE v2.5 30-Nov-2020 20:55:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MAIN_OpeningFcn, ...
                   'gui_OutputFcn',  @MAIN_OutputFcn, ...
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

% --- Outputs from this function are returned to the command line.
function varargout = MAIN_OutputFcn(hObject, eventdata, handles) %#ok
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% End initialization code - DO NOT EDIT

% =========================================================================
% =========================================================================
% --- Executes just before MAIN is made visible.
% =========================================================================
% =========================================================================

function MAIN_OpeningFcn(hObject, eventdata, handles, varargin) %#ok
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MAIN (see VARARGIN)

% Choose default command line output for MAIN
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Set the default values on the GUI. It is recommended to choose a valid set 
%of default values as a starting point when the program launches.
clc
%set(handles.Slideraxial_force,'Value',Default_depth);
%set(handles.TXTaxial_force,'String',num2str(Default_depth));
set(handles.NumTraps,'Value',1); %The 1st item of the list is selected. Change the list from the GUIDE.
set(handles.TXT_trapDiameter,'String','0.25');
set(handles.TXT_depth,'String','50');
set(handles.TXT_trapWeight,'String','1');
%Set the window title with the group identification:
set(handles.figure1,'Name','Group RPT1 // CADCAM 2020');

%Add the 'subfunctions' folder to the path so that subfunctions can be
%accessed
addpath('Subfunctions');

% =========================================================================

% --- Executes on button press in BTN_Generate.
function BTN_Generate_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to BTN_Generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(isempty(handles))
    Wrong_File();
else
    %Get the design parameters from the interface (DO NOT PERFORM ANY DESIGN CALCULATIONS HERE)

    %return depth, trap diameter
    depth = str2double(get(handles.TXT_depth,'String'));
    trap_diameter = str2double(get(handles.TXT_trapDiameter,'String'));
    %return the entire drop down in an array of strings
    num_traps_total = cellstr(get(handles.NumTraps,'String'));
    %Actually take the correct number of traps
    num_traps = str2double(num_traps_total{get(handles.NumTraps,'Value')});
    trap_weight = str2double(get(handles.TXT_trapWeight,'String'));
    

    
    %Perform basic range checking (for those that can go out of range)
    if isnan(depth) || (depth < 50) || (depth > 600)
        msgbox('The depth specified is not an acceptable value. Enter a value between 50m and 600m.','Cannot generate!','warn');
        return;
    end
    if isnan(trap_diameter) || (trap_diameter < 0.25) || (trap_diameter > 1.5)
        msgbox('The trap diamter is not an acceptable value. Enter a value between 0.25m and 1.5m.','Cannot generate!','warn');
        return;
    end 
    if isnan(trap_weight) || (trap_weight < 1) || (trap_weight > 100)
        msgbox('The trap weight is not an acceptable value. Enter a value between 1 Kg and 100 Kg.','Cannot generate!','warn');
        return;
    end
    
    SP_code();
    RL_code();
    LF_code();
    LT_code();
    %Show the results on the GUI.
    %TAKE OUT there're 2 log files here, the first is the actual and the
    %second is for dev. alternate between as needed
    %log_file = 'Y:\groupRPT1\Log\groupRPT1_LOG.TXT';
    %======================================================================
    %This all has to be put back at the end
    
    %log_file = 'C:\Users\luca_\OneDrive\Documents\Capstone\groupRPT1\Log\groupRPT1_LOG.TXT';
    %fid = fopen(log_file,'r'); %Open the log file for reading
    %S=char(fread(fid)'); %Read the file into a string
    %fclose(fid);

    
    
    %set(handles.TXT_log,'String',S); %write the string into the textbox
    %set(handles.TXT_path,'String',log_file); %show the path of the log file
    %set(handles.TXT_path,'Visible','on');
    %======================================================================
end

% =========================================================================

% --- Executes on button press in BTN_Finish.
function BTN_Finish_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to BTN_Finish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close gcf

% =========================================================================

% --- Gives out a message that the GUI should not be executed directly from
% the .fig file. The user should run the .m file instead.
function Wrong_File()
clc
h = msgbox('You cannot run the MAIN.fig file directly. Please run the program from the Main.m file directly.','Cannot run the figure...','error','modal');
uiwait(h);
disp('You must run the MAIN.m file. Not the MAIN.fig file.');
disp('To run the MAIN.m file, open it in the editor and press ');
disp('the green "PLAY" button, or press "F5" on the keyboard.');
close gcf

function TXTaxial_force_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to TXTaxial_force (see GCBO) 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TXTaxial_force as text
%        str2double(get(hObject,'String')) returns contents of TXTaxial_force as a double

if(isempty(handles))
    Wrong_File();
else
    value = round(str2double(get(hObject,'String')));

    %Apply basic testing to see if the value does not exceed the range of the
    %slider (defined in the gui)
    if(value<get(handles.Slideraxial_force,'Min'))
        value = get(handles.Slideraxial_force,'Min');
    end
    if(value>get(handles.Slideraxial_force,'Max'))
        value = get(handles.Slideraxial_force,'Max');
    end
    set(hObject,'String',value);
    set(handles.Slideraxial_force,'Value',value);
end

% =========================================================================
% =========================================================================
% The functions below are created by the GUI. Do not delete any of them! 
% Adding new buttons and inputs will add more callbacks and createfcns.
% =========================================================================
% =========================================================================


function TXT_log_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to TXT_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TXT_log as text
%        str2double(get(hObject,'String')) returns contents of TXT_log as a double

% --- Executes during object creation, after setting all properties.
function TXT_log_CreateFcn(hObject, eventdata, handles) %#ok
% hObject    handle to TXT_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function Slideraxial_force_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to Slideraxial_force (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

if(isempty(handles))
    Wrong_File();
else
    value = round(get(hObject,'Value')); %Round the value to the nearest integer
    set(handles.TXTaxial_force,'String',num2str(value));
end

% --- Executes during object creation, after setting all properties.
function Slideraxial_force_CreateFcn(hObject, eventdata, handles) %#ok
% hObject    handle to Slideraxial_force (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function TXTaxial_force_CreateFcn(hObject, eventdata, handles) %#ok
% hObject    handle to TXTaxial_force (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in NumTraps.
function NumTraps_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to NumTraps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns NumTraps contents as cell array
%        contents{get(hObject,'Value')} returns selected item from NumTraps


% --- Executes during object creation, after setting all properties.
function NumTraps_CreateFcn(hObject, eventdata, handles) %#ok
% hObject    handle to NumTraps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function TXT_trapDiameter_Callback(hObject, eventdata, handles) %#ok
% hObject    handle to TXT_trapDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TXT_trapDiameter as text
%        str2double(get(hObject,'String')) returns contents of TXT_trapDiameter as a double


% --- Executes during object creation, after setting all properties.
function TXT_trapDiameter_CreateFcn(hObject, eventdata, handles) %#ok
% hObject    handle to TXT_trapDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TXT_depth_Callback(hObject, eventdata, handles)
% hObject    handle to TXT_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TXT_depth as text
%        str2double(get(hObject,'String')) returns contents of TXT_depth as a double


% --- Executes during object creation, after setting all properties.
function TXT_depth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TXT_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TXT_trapWeight_Callback(hObject, eventdata, handles)
% hObject    handle to TXT_trapWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TXT_trapWeight as text
%        str2double(get(hObject,'String')) returns contents of TXT_trapWeight as a double


% --- Executes during object creation, after setting all properties.
function TXT_trapWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TXT_trapWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
