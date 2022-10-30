% 5/25 this version has added ramp analysis features, but still mostly uses
% the original MRT excell format...matlab analysis file is also created but
% new variables including full functionality of a tool still need to be
% added - does everything MRT scr does though


function varargout = SCS(varargin)

if nargin==0
    InitializeGUI;
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        rethrow(lasterror);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% InitializeGUI
    function InitializeGUI

        clear global SCSTEP;
        global SCSTEP;
        
        newfile
        filename = SCSTEP.datafile;

        %Size constants (in normalized units)
        LH = 0.04;  %height per line
        S  = 0.005;  %spacer
        ST = 0.005;
        SS = 0.02;
        AxW = 0.8;
        BW  = (1-AxW)/3;

        %make the figure window
        fig = figure( 'Name', ['SCSTEP - ' filename],...
            'NumberTitle', 'off', ...
            'HandleVisibility', 'on', ...
            'IntegerHandle', 'on', ...
            'units', 'normalized', ...
            'Position', [.1 .1 .8 .8], ...
            'UserData', zeros(4,30), ... 
            'KeyPressFcn', @KeyPresser );			

        %make the menus
        uimenu(fig, 'label', '>>');
        ToolMenu = uimenu(fig, 'label', 'SCSTools');
        SCSTEP.FreezeX = [];
        SCSTEP.FreezeY = [];
        SCSTEP.DisplayGrid = [];
        uimenu(ToolMenu, 'Label', 'Zoom X...',  'Callback', 'SCS(''Zoom_Callback'',1,0)', 'separator', 'off');
        uimenu(ToolMenu, 'Label', 'Zoom Y...',  'Callback', 'SCS(''Zoom_Callback'',0,1)', 'separator', 'off');
        uimenu(ToolMenu, 'Label', 'Zoom XY...',  'Callback', 'SCS(''Zoom_Callback'',1,1)', 'separator', 'off');
        uimenu(ToolMenu, 'Label', 'Select Pulse', 'Callback', 'SCS(''SelectPulse'')', 'separator', 'off');
        
        SCSTEP.MenuFreezeX = uimenu(ToolMenu, 'Label', 'FreezeX', 'Callback', 'SCS(''Menu_FreezeX'')', 'checked', 'off', 'separator', 'on');
        SCSTEP.MenuFreezeY = uimenu(ToolMenu, 'Label', 'FreezeY', 'Callback', 'SCS(''Menu_FreezeY'')', 'checked', 'off');
        uimenu(ToolMenu, 'Label', 'FreezeXY', 'Callback', 'SCS(''Menu_FreezeXY'')', 'checked', 'off');
        SCSTEP.DisplayGrid = uimenu(ToolMenu, 'Label', 'DisplayGrid', 'Callback', 'SCS(''Menu_DisplayGrid'')','checked', 'off', 'separator', 'on');
        uimenu(ToolMenu, 'Label', 'UnselectBadSweeps', 'Callback', 'SCS(''Menu_UnselectBadSweeps'')', 'separator', 'on');
        uimenu(ToolMenu, 'Label', 'UnselectBlankSweeps', 'Callback', 'SCS(''Menu_UnselectBlankSweeps'')', 'separator', 'on');
        uimenu(ToolMenu, 'Label', 'UnselectRamps', 'Callback', 'SCS(''Menu_UnselectRamps'')', 'separator', 'off');
        uimenu(ToolMenu, 'Label', 'CopySweepsToClipboard', 'Callback', 'SCS(''CopySweepsToClipboard'')', 'separator', 'on');
        SCSTEP.DG = [];
        
        FitMenu = uimenu(fig, 'label', 'FitTools');
        uimenu(FitMenu, 'Label', 'AdjSwOffset', 'Callback', 'SCS(''Menu_AdjSwOffset'')', 'separator', 'off');
        uimenu(FitMenu, 'Label', 'AdjLkOffset', 'Callback', 'SCS(''Menu_AdjLkOffset'')', 'separator', 'off');
        uimenu(FitMenu, 'Label', 'CopyFit', 'Callback', 'SCS(''Menu_CopyFit'')', 'separator', 'on');
        uimenu(FitMenu, 'Label', 'PasteFit', 'Callback', 'SCS(''Menu_PasteFit'')', 'separator', 'of');
        uimenu(FitMenu, 'Label', 'ResetFit', 'Callback', 'SCS(''Menu_ResetFit'')', 'separator', 'on');
        uimenu(FitMenu, 'Label', 'ResetAtool', 'Callback', 'SCS(''Menu_ResetAtool'')', 'separator', 'off');
     
        AnalysisMenu = uimenu(fig, 'label', 'NoiseAnalysis');
        uimenu(AnalysisMenu, 'Label', 'Variance/Avg', 'Callback', 'SCS(''Menu_Variance'')', 'separator', 'off');
        uimenu(AnalysisMenu, 'Label', 'CalcPo', 'Callback', 'SCS(''Menu_CalcPo'')', 'separator', 'on');
        uimenu(AnalysisMenu, 'Label', 'AutoCalcPo', 'Callback', 'SCS(''Menu_AutoCalcPo'')', 'separator', 'off');  
        
        StepMenu = uimenu(fig, 'label', 'StepAnalysis');
        uimenu(StepMenu, 'Label', 'Average traces', 'Callback', 'SCS(''Menu_AvgTraces'')', 'separator', 'off');
        uimenu(StepMenu, 'Label', 'Measure', 'Callback', 'SCS(''Menu_Measure'')', 'separator', 'on');
        uimenu(StepMenu, 'Label', 'FitSteps', 'Callback', 'SCS(''Menu_FitSteps'')', 'separator', 'off');        
        
        RampMenu = uimenu(fig, 'label', 'RampAnalysis');
        uimenu(RampMenu, 'Label', 'SweepsToExcell', 'Callback', 'SCS(''Menu_SCRnew'')', 'separator', 'off');
        uimenu(RampMenu, 'Label', 'AnalyzeCellExcell', 'Callback', 'SCS(''Menu_SCRCellAvg'')', 'separator', 'off');
        uimenu(RampMenu, 'Label', 'FinalExcelAnalysis', 'Callback', 'SCS(''Menu_SCRFinalAvg'')', 'separator', 'off');
        uimenu(RampMenu, 'Label', 'AverageActiveRamps', 'Callback', 'SCS(''Menu_ActiveRampCellAvg'')', 'separator', 'on');
        uimenu(RampMenu, 'Label', 'AvarageWithBlanks', 'Callback', 'SCS(''Menu_RampCellAvgBlank'')', 'separator', 'off');
        
        %Axes
        axes('Units', 'normalized', 'FontSize', 7, 'Position', [S+SS S+SS AxW-2*S-SS 1-3*S-SS]);

        %Some cell-level parameters (noneditable)
        SCSTEP.CellNum = MakeTextEditGroup('CellNum', 'left', 'left', [AxW  1-1*LH  .5*BW-S  LH-S-ST], [AxW+.5*BW  1-1*LH  BW-S  LH-S]);
        SCSTEP.Construct = MakeTextEditGroup('Construct', 'left', 'left', [AxW+1.5*BW  1-1*LH  .5*BW-S  LH-S-ST], [AxW+2*BW  1-1*LH  BW-S  LH-S]);
        SCSTEP.RI     = MakeTextEditGroup('RI',     'left', 'left', [AxW  1-2*LH  .5*BW-S  LH-S-ST], [AxW+.5*BW  1-2*LH  BW-S  LH-S]);
        SCSTEP.VStep     = MakeTextEditGroup('VStep',     'left', 'left', [AxW+1.5*BW  1-2*LH  .5*BW-S  LH-S-ST], [AxW+2*BW  1-2*LH  BW-S  LH-S]);

        % cell-level parameters (editable)
        SCSTEP.NumCh    = MakeTextEditGroup('NumCh',    'left', 'left', [AxW  1-3*LH  .5*BW-S  LH-S-ST], [AxW+.5*BW  1-3*LH  BW-S  LH-S]);
        SCSTEP.g    = MakeTextEditGroup('g',    'left', 'left', [AxW+1.5*BW  1-3*LH  .5*BW-S  LH-S-ST], [AxW+2*BW  1-3*LH  BW-S  LH-S]);
        SCSTEP.Vs    = MakeTextEditGroup('Vs',    'left', 'left', [AxW  1-4*LH  .5*BW-S  LH-S-ST], [AxW+.5*BW  1-4*LH  BW-S  LH-S]);

        %Buttons
        MakeButtonGroup('Bad',      [AxW+ 2*BW    1-7*LH  .5*BW-S  LH-S]);
        MakeButtonGroup('Blank',      [AxW+ 1.5*BW    1-7*LH  .5*BW-S  LH-S]);
        MakeButtonGroup('Good',     [AxW+ 2.5*BW  1-7*LH  .5*BW-S  LH-S]);
        MakeButtonGroup('StepLk',     [AxW+ .7*BW  1-7*LH  .7*BW-S  LH-S]);  
        MakeButtonGroup('AddLinFit', [AxW       1-5*LH    BW-S  LH-S]);     
        MakeButtonGroup('AddExpFit', [AxW       1-6*LH    BW-S  LH-S]);
        MakeButtonGroup('Atool', [AxW       1-7*LH    .7*BW-S  LH-S]);
        MakeButtonGroup('AutoExp',     [AxW 1-8*LH  .7*BW-S  LH-S]);
        MakeButtonGroup('AutoLine',     [AxW+.7*BW 1-8*LH  .7*BW-S  LH-S]);

       
      % make toggle buttons - value is 0 when unchecked
      SCSTEP.LkOnly = MakeCheckBox('LkOnly', [AxW+ BW    1-6*LH   BW-S  LH-S]);
      SCSTEP.AvgLkSub = MakeCheckBox('AvgLkSub', [AxW+1.6*BW    1-6*LH   BW-S  LH-S]);
      SCSTEP.SmoothLk = MakeCheckBox('SmoothLk', [AxW+2.3*BW    1-6*LH   BW-S  LH-S]);
      SCSTEP.FitLeak = MakeCheckBox('FitLeak', [AxW+1.32*BW    1-8*LH   BW-S  LH-S]);
      SCSTEP.UseGuess = MakeCheckBox('UseGuess', [AxW+1.7*BW    1-8*LH   BW-S  LH-S]);      
      %SCSTEP.CausalFilt = 0;
     % SCSTEP.CausalFilt = MakeCheckBox('Causal', [AxW+1.8*BW    1-8*LH   BW-S  LH-S]);
      SCSTEP.NoUpdate = MakeCheckBox('NoGraphUpdate', [AxW+2.2*BW    1-8*LH   BW-S  LH-S]);

%Sweep-level parameters
        SCSTEP.m  = MakeTextEditGroup('m',  'left', 'left', [AxW+BW  1-5*LH  .3*BW-S  LH-S-ST], [AxW+1.3*BW  1-5*LH  .7*BW-S  LH-S]);
        SCSTEP.b  = MakeTextEditGroup('b',  'left', 'left', [AxW+2*BW  1-5*LH  .3*BW-S  LH-S-ST], [AxW+2.3*BW  1-5*LH  .7*BW-S  LH-S]);
        SCSTEP.FiltHz  = MakeTextEditGroup('FiltHz',  'left', 'left', [AxW+1.5*BW  1-4*LH  .5*BW-S  LH-S-ST], [AxW+2*BW  1-4*LH  BW-S  LH-S]);
        SCSTEP.XMin    = MakeTextEditGroup('XMin',    'left', 'left', [AxW  1-9*LH  .5*BW-S  LH-S-ST], [AxW+.5*BW  1-9*LH  2.5*BW-S  LH-S]);
        SCSTEP.XMax    = MakeTextEditGroup('XMax',    'left', 'left', [AxW  1-10*LH  .5*BW-S  LH-S-ST], [AxW+.5*BW  1-10*LH  2.5*BW-S  LH-S]);
        SCSTEP.Tau    = MakeTextEditGroup('Tau',    'left', 'left', [AxW  1-11*LH  .5*BW-S  LH-S-ST], [AxW+.5*BW  1-11*LH  2.5*BW-S  LH-S]);
        SCSTEP.Amp    = MakeTextEditGroup('Amp',    'left', 'left', [AxW  1-12*LH  .5*BW-S  LH-S-ST], [AxW+.5*BW  1-12*LH  2.5*BW-S  LH-S]);
        SCSTEP.Delay    = MakeTextEditGroup('Delay',    'left', 'left', [AxW  1-13*LH  .5*BW-S  LH-S-ST], [AxW+.5*BW  1-13*LH  2.5*BW-S  LH-S]);
        %Listbox
        SCSTEP.Box = uicontrol('Style', 'Listbox', 'String', '', 'Callback', 'SCS(''UpdateGraphics'')', 'units', 'normalized', 'Position', [AxW S 1-AxW-S 1-13*LH-2*S], 'backgroundcolor', [.9 .9 .9], 'Max', 2);

        UpdateBox;
        
        
        function KeyPresser(varargin)
            global SCSTEP
            KeyVal = varargin{2};            
            if isempty(KeyVal.Modifier)
                KeyNum = str2double(KeyVal.Key);
                if ~isempty(KeyNum) && ~isnan(KeyNum)
                    SelectPulseNum(KeyNum)
                else
                    switch KeyVal.Key
                        case 'uparrow'
                            nSel = get(SCSTEP.Box, 'value');
                            if nSel>1
                                set(SCSTEP.Box, 'value',nSel-1)
                                UpdateGraphics
                            end                            
                        case 'downarrow'
                            nSel = get(SCSTEP.Box, 'value');
                            NumSelections = length(get(SCSTEP.Box,'string'));
                            if nSel<NumSelections
                                set(SCSTEP.Box,'value', nSel+1)
                                UpdateGraphics
                            end
                        case 'a'
                            AutoLine;
                        case 'c'
                            Menu_CopyFit;
                        case 'v'
                            Menu_PasteFit;
                        case 'b'
                            Bad;
                        case 'n'
                            Good;
                        case 'l'
                            AddLinFit;
                        case 'e'
                            AddExpFit;
                            
                    end
                    
                end                
                
            else
                Modifier = KeyVal.Modifier;
                switch Modifier{1}
                    case 'control'
                        switch KeyVal.Key
                            case 'c'
                                Menu_CopyFit        
                                disp('Copied Fit')
                            case 'v'
                                Menu_PasteFit
                                disp('Paste Fit')
                        end                            
                end
            end
            
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function S = MakeTextEditGroup(UIGroupName, AlignText, AlignEdit, PosTxt, PosBox)

            %Callback strings are generic
            S.Text = uicontrol('Style', 'text', 'String', UIGroupName, 'HorizontalAlignment', AlignText, 'units', 'normalized', 'Position', PosTxt);
            S.Edit = uicontrol('Style', 'edit', 'String', '', 'BackgroundColor', [1 1 1], 'Callback', ['SCS(''Edit_Callback'',''' UIGroupName ''')'], 'HorizontalAlignment', AlignEdit, 'units', 'normalized', 'Position', PosBox);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function S = MakeButtonGroup(ButtonName, Pos)

            S = uicontrol('Style', 'pushbutton', 'String', ButtonName, 'Callback', ['SCS(''' ButtonName ''')'], 'HorizontalAlignment', 'left', 'units', 'normalized', 'Position', Pos);
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function S = MakeCheckBox(ButtonName, Pos)

            S = uicontrol('Style', 'check', 'String', ButtonName, 'Callback', 'SCS(''UpdateGraphics'')', 'HorizontalAlignment', 'center',....
                'units', 'normalized', 'Position', Pos, 'value',0);
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
   %% Edit Callback

        function Edit_Callback(UIGroupName)
            global SCSTEP

            switch UIGroupName

                %Non-edit parameters read in from data file
                case {'CellNum' 'Construct' 'RI' 'VStep' }
                    UpdateGraphics;
                    set(gcf, 'pointer', 'arrow');

               %cell level parameters identical for all runs within a cell
                case {'NumCh' 'g' 'Vs'}
                    set(gcf, 'pointer', 'watch'); drawnow;
                    nSel = get(SCSTEP.Box, 'value');
                    for k=1:length(nSel);
                    DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{(nSel(k))});
                    CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),'']; %note that loaddata already puts in the run, swp num
                    S.(CellNumString).NumCh = str2num(get(SCSTEP.NumCh.Edit, 'string'));
                    S.(CellNumString).g = str2num(get(SCSTEP.g.Edit, 'string'));
                    S.(CellNumString).Vs = str2num(get(SCSTEP.Vs.Edit, 'string'));
                    save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
                    end
                    UpdateGraphics;
                    set(gcf, 'pointer', 'arrow');

               % sweep level parameters - editable for each sweep
                case {'FiltHz'} % note, anything that may be empty or a matrix must use str2num not str2double to avoid NaN being retured
                    set(gcf, 'pointer', 'watch'); drawnow;
                    nSel = get(SCSTEP.Box, 'value');
                    for k=1:length(nSel)
                    ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                    S.(SCSTEP.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                    S.(SCSTEP.RunSwp{(nSel(k))}).FiltHz = str2num(get(SCSTEP.FiltHz.Edit, 'string'));                  
                    save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
                    end
                     UpdateGraphics;
                     set(gcf, 'pointer', 'arrow');
                case {'Tau', 'Amp', 'XMax','XMin', 'm', 'b','Delay'} % note, anything that may be empty or a matrix must use str2num not str2double to avoid NaN being retured
                    set(gcf, 'pointer', 'watch'); drawnow;
                    nSel = get(SCSTEP.Box, 'value');
                    for k = 1:length(nSel);
                        ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                        S.(SCSTEP.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                        S.(SCSTEP.RunSwp{(nSel(k))}).Amp = str2num(get(SCSTEP.Amp.Edit, 'string'));
                        S.(SCSTEP.RunSwp{(nSel(k))}).Tau = str2num(get(SCSTEP.Tau.Edit, 'string'));
                        S.(SCSTEP.RunSwp{(nSel(k))}).XMax = str2num(get(SCSTEP.XMax.Edit, 'string'));
                        S.(SCSTEP.RunSwp{(nSel(k))}).XMin = str2num(get(SCSTEP.XMin.Edit, 'string'));
                        S.(SCSTEP.RunSwp{(nSel(k))}).Delay = str2num(get(SCSTEP.Delay.Edit, 'string'));
                        S.(SCSTEP.RunSwp{(nSel(k))}).m = str2num(get(SCSTEP.m.Edit, 'string'));
                        S.(SCSTEP.RunSwp{(nSel(k))}).b = str2num(get(SCSTEP.b.Edit, 'string'));
                        save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
                    end
                    UpdateGraphics;
                    set(gcf, 'pointer', 'arrow');
                otherwise
                    waitfor(errordlg(['There is a bug in the code -- need to write Edit_Callback routine for ' UIGroupName]));
            end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Tool Menu Functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            function SelectPulse
                global SCSTEP
                nSel = get(SCSTEP.Box, 'value');
                DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(1)});
                if strfind(DATA(1).StimName, 'Step')                    
                    StimParameters = DATA.StimParams;
                    DStep  = StimParameters.Dstep;                    
                    NumPulses = length(DStep);                                       
                    PNum = listdlg('PromptString', 'Select Pulse', 'SelectionMode', 'single', 'ListString', num2str([1:NumPulses]'));                    
                    SelectPulseNum(PNum)
                end
                
            function SelectPulseNum(PNum)
                global SCSTEP
                nSel = get(SCSTEP.Box, 'value');
                DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(1)});
                if strfind(DATA(1).StimName, 'Step')                    
                    StimParameters = DATA.StimParams;
                    DStep  = StimParameters.Dstep;                    
                    NumPulses = length(DStep); 
                    if PNum<NumPulses+1
                        TBegin = cumsum([0 DStep]);
                        TEnd = cumsum(DStep);                    
                        MinX = max([0, TBegin(PNum)-15]);
                        MaxX = TEnd(PNum);
                        SCSTEP.FreezeX = [MinX  MaxX];
                        set(SCSTEP.MenuFreezeX, 'checked', 'on');                                        
                        UpdateGraphics
                    end
                end
                
                                
            function Zoom_Callback( bX, bY)
            global SCSTEP;

            %now draw . .
            AxRect = DrawRectOnAx;

            %save values
            if bX
                SCSTEP.FreezeX = [AxRect(1)  AxRect(1)+AxRect(3)];
                set(SCSTEP.MenuFreezeX, 'checked', 'on');
            end
            if bY
                SCSTEP.FreezeY = [AxRect(2)  AxRect(2)+AxRect(4)];
                set(SCSTEP.MenuFreezeY, 'checked', 'on');
            end

            UpdateGraphics;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_FreezeX
            global SCSTEP;

            if isempty(SCSTEP.FreezeX)
                SCSTEP.FreezeX = get(gca, 'xlim');
                set(SCSTEP.MenuFreezeX, 'checked', 'on');
            else
                SCSTEP.FreezeX = [];
                set(SCSTEP.MenuFreezeX, 'checked', 'off');
            end
            
            UpdateGraphics;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_FreezeY
            global SCSTEP;

            if isempty(SCSTEP.FreezeY)
                SCSTEP.FreezeY = get(gca, 'ylim');
                set(SCSTEP.MenuFreezeY, 'checked', 'on');
            else
                SCSTEP.FreezeY = [];
                set(SCSTEP.MenuFreezeY, 'checked', 'off');
            end
            UpdateGraphics;
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_FreezeXY
            global SCSTEP;

            Menu_FreezeX;
            Menu_FreezeY;
            UpdateGraphics;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_DisplayGrid
            global SCSTEP;

            if isempty(SCSTEP.DG)
                set(gca, 'YGrid', 'on', 'XGrid','on')
                set(SCSTEP.DisplayGrid, 'checked', 'on');
                SCSTEP.DG = 1;
            else
                set(gca, 'YGrid', 'off', 'XGrid','off')
                set(SCSTEP.DisplayGrid, 'checked', 'off');
                SCSTEP.DG = [];
            end
            UpdateGraphics;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_UnselectBadSweeps
            global SCSTEP;
            nSel = get(SCSTEP.Box, 'value');

            for k=1:length(nSel)
                ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                Good(k) = [swANALYSIS.GoodBad];
            end

            nSel = nSel(Good==1);

            set(SCSTEP.Box, 'value', nSel);
            UpdateGraphics;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_UnselectBlankSweeps
            global SCSTEP;
            nSel = get(SCSTEP.Box, 'value')

            for k=1:length(nSel)
                ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                Blank(k) = [swANALYSIS.Blank];
            end

            nSel = nSel(Blank==0);

            set(SCSTEP.Box, 'value', nSel);
            UpdateGraphics;
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_UnselectRamps
            global SCSTEP;
            nSel = get(SCSTEP.Box, 'value');

            for k=1:length(nSel)
                DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(k)});
                %(findstr(DATA(1).StimName, 'Ramp'))
                if (findstr(DATA(1).StimName, 'Ramp'))
                Good(k) = 0;
                else
                    Good(k) = 1;
                end
            end

            nSel = nSel(Good==1);

            set(SCSTEP.Box, 'value', nSel);
            UpdateGraphics;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            function CopySweepsToClipboard
                global SCSTEP;

                set(gcf, 'pointer', 'watch'); drawnow;

                nSel = get(SCSTEP.Box, 'value');

                % load data and analysis files
                for k=1:length(nSel)
                    DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(k)});
                    ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                    swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                    CellNum = DATA(1).CellNum;
                    CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];


                    %read in some parameter values from data and analysis files
                    try
                        NumCh = ANALYSIS.(CellNumString).NumCh;
                        g = ANALYSIS.(CellNumString).g;
                        Vs = ANALYSIS.(CellNumString).Vs;
                    catch
                        NumCh = 1;
                        g = 0;
                        Vs = 0;
                    end
                    Construct = DATA(1).XFect;
                    RI = DATA(1).StimParams.RI;
                    VStep = [];
                    FiltHz = swANALYSIS.FiltHz;
                    XMin = swANALYSIS.XMin;
                    XMax = swANALYSIS.XMax;
                    Tau = swANALYSIS.Tau;
                    Amp = swANALYSIS.Amp;
                    m = swANALYSIS.m;
                    b = swANALYSIS.b;
                    swOffset = swANALYSIS.swOffset;
                    lkOffset = swANALYSIS.lkOffset;
                    try 
                        Delay = swANALYSIS.Delay;
                    catch
                        Delay = 0;
                    end
                    SF = [];
                    GoodBad = swANALYSIS.GoodBad;
                    AMin = swANALYSIS.AMin;
                    AMax = swANALYSIS.AMax;
                    GoodLeak = swANALYSIS.GoodLeak;

                    %plotting ramp data
                    if (findstr(DATA(1).StimName, 'Ramp'))
                        v = DATA.StimWaveform;
                        iRaw = DATA.AcqWaveform;
                        iRaw = LowpassFilter(DATA.Time, iRaw, FiltHz);
                        smoothleak = 0;
                        for n=1:(length(XMin))
                            ilk = Amp(n)*exp(-(Tau(n))*(v)); % u dont need a voltage delay in ramps ... MBJ
                            ilk(v<XMin(n))=0;
                            ilk(v>XMax(n))=0;
                            smoothleak = smoothleak + ilk;
                        end
                        try
                            LinearFit = m*v + b;
                            smoothleak = smoothleak + LinearFit;
                        end
                        if get(SCSTEP.LkOnly, 'value')
                            plot(v, iRaw, 'color', [.9 .9 .9]);
                            plot(v, smoothleak, 'r');
                        end
                        if get(SCSTEP.SmoothLk, 'value')
                            iRaw = iRaw - smoothleak;
                        end
                        %initialize matrix for copy/paste
                        M = zeros(length(v), 2+NumCh+length(nSel));
                        M(:,1) = DATA.Time;
                        M(:,2) = v;
                        M(:,2+NumCh+k) = iRaw;

                        %calculate GVT fits
                        Unitary = v * 0;  %initialize
                        tmpV = v - Vs;
                        I = find(abs(tmpV)/12>.01);
                        Unitary(I)  = -g*tmpV(I).*exp(-tmpV(I)/12)./(1 - exp(-tmpV(I)/12));  %traditional eqn
                        I = find(abs(tmpV)/12<=.01);
                        Unitary(I)  = -g*tmpV(I).*(1 - tmpV(I)/12)./(tmpV(I)/12);  %linearized eqn near zero
                        for j=1:NumCh
                            M(:,j+2) = j*Unitary ;
                        end
                        strColHeaders = {'t' 'v'};
                        for j=1:NumCh
                            strColHeaders = [strColHeaders {[num2str(j) 'xUnitary']}];
                        end
                        strColHeaders = [strColHeaders {'i'}];

                    else

                        %plotting step data
                        
                        SF = DATA(2).StimParams.LeakSF;
                        Dstep = DATA(1).StimParams.Dstep;
                        VStep = DATA(1).StimParams.Vstep;
                        t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms
                        iRaw = DATA(1).AcqWaveform(1,:);
                        iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);

                        % allow some leaks to be removed from avg
                        if isempty(GoodLeak)
                            GoodLeak =ones(1,length(DATA(2).AcqWaveform(1,1,:)));
                        end
                        LkSum = 0;
                        for n=1:length(GoodLeak);
                            iLeak(:,n) = DATA(2).AcqWaveform(1,:,n);
                            if GoodLeak(n)==1;
                                LkSum = LkSum + iLeak(:,n);
                            end
                        end

                        %%%%%%%%%%  add in a fix for if no leaks are aquired
                        if isempty(GoodLeak)
                            avgLk = mean(DATA(2).AcqWaveform,3);
                        else
                            avgLk = LkSum/sum(GoodLeak);
                        end

                        % avgLk  = mean(DATA(2).AcqWaveform,3);

                        %zero offset:
                        if swANALYSIS.swOffset==0
                            swOffset = mean(iRaw(10:DATA(1).StimParams.PrePoints));
                        end
                        if swANALYSIS.lkOffset==0
                            lkOffset = mean(avgLk(10:DATA(1).StimParams.PrePoints));
                        end
                        iRaw = iRaw - swOffset;
                        avgLk = avgLk - lkOffset;

                        %leak display
                        avgLk = avgLk*SF;
                        smoothleak = 0;
                        try
                            for n=1:(length(XMin))
                                ilk = Amp(n)*exp(-(Tau(n))*(t-Delay(n)));
                                ilk(t<XMin(n))=0;
                                ilk(t>XMax(n))=0;
                                smoothleak = smoothleak + ilk;
                            end
                        end
                        try
                            LinearFit = m*t + b;
                            smoothleak = smoothleak + LinearFit;
                        end
                        try
                            for n=1:(length(AMin));
                                alk = iRaw-smoothleak;
                                alk(t<AMin(n))=0;
                                alk(t>AMax(n))=0;
                                smoothleak = smoothleak + alk;
                            end
                        end
                        if get(SCSTEP.AvgLkSub, 'value')
                            try
                            iRaw = iRaw-avgLk';
                            end
                        end
                        if get(SCSTEP.SmoothLk, 'value')
                            iRaw = iRaw - smoothleak;
                        end
                        M= zeros(length(t), 4);
                        M(:,1) = t;
                        M(:,2) = iRaw;
                        if get(SCSTEP.LkOnly, 'value')
                            %initialize matrix for copy/paste
                            M(:,3) = avgLk;
                            M(:,4) = smoothleak;
                        end
                        strColHeaders = {'t' 'i' 'avgLk' 'smoothleak'};

                    end
                end

                %swpNames = get(SCSTEP.Box, 'String');
                %swpNames = swpNames(nSel);
                %for j=1:length(swpNames)
                %    swpNames{j} = swpNames{j}(6:end);
                %end
                %strColHeaders = [strColHeaders swpNames'];
                 CopyToClipboard(M, {}, {});
%                 CopyToClipboard(M, {}, {});
                %CopyToClipboard(M,{}, {});

                set(gcf, 'pointer', 'arrow');

                waitfor(helpdlg('Data has been copied to the clipboard.  Paste it into an excel spreadsheet'));
            
            function CopySweepsToClipboardvMBJ
                global SCSTEP;

                set(gcf, 'pointer', 'watch'); drawnow;

                nSel = get(SCSTEP.Box, 'value');

                % load data and analysis files
                for k=1:length(nSel)
                    DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(k)});
                    ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                    swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                    CellNum = DATA(1).CellNum;
                    CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];


                    %read in some parameter values from data and analysis files
                    try
                        NumCh = ANALYSIS.(CellNumString).NumCh;
                        g = ANALYSIS.(CellNumString).g;
                        Vs = ANALYSIS.(CellNumString).Vs;
                    catch
                        NumCh = 1;
                        g = 0;
                        Vs = 0;
                    end
                    Construct = DATA(1).XFect;
                    RI = DATA(1).StimParams.RI;
                    VStep = [];
                    FiltHz = swANALYSIS.FiltHz;
                    XMin = swANALYSIS.XMin;
                    XMax = swANALYSIS.XMax;
                    Tau = swANALYSIS.Tau;
                    Amp = swANALYSIS.Amp;
                    m = swANALYSIS.m;
                    b = swANALYSIS.b;
                    swOffset = swANALYSIS.swOffset;
                    lkOffset = swANALYSIS.lkOffset;
                    try 
                        Delay = swANALYSIS.Delay;
                    catch
                        Delay = 0;
                    end
                    SF = [];
                    GoodBad = swANALYSIS.GoodBad;
                    AMin = swANALYSIS.AMin;
                    AMax = swANALYSIS.AMax;
                    GoodLeak = swANALYSIS.GoodLeak;

                    %plotting ramp data
                    if (findstr(DATA(1).StimName, 'Ramp'))
                        v = DATA.StimWaveform;
                        iRaw = DATA.AcqWaveform;
                        %iRaw = LowpassFilter(DATA.Time, iRaw, FiltHz);
                        smoothleak = 0;
                        for n=1:(length(XMin))
                            ilk = Amp(n)*exp(-(Tau(n))*(v)); % u dont need a voltage delay in ramps ... MBJ
                            ilk(v<XMin(n))=0;
                            ilk(v>XMax(n))=0;
                            smoothleak = smoothleak + ilk;
                        end
                        try
                            LinearFit = m*v + b;
                            smoothleak = smoothleak + LinearFit;
                        end
                        if get(SCSTEP.LkOnly, 'value')
                            plot(v, iRaw, 'color', [.9 .9 .9]);
                            plot(v, smoothleak, 'r');
                        end
                        if get(SCSTEP.SmoothLk, 'value')
                            iRaw = iRaw - smoothleak;
                        end
                        %initialize matrix for copy/paste
%                         M = zeros(length(v), 1+length(nSel));
%                         M(:,1) = DATA.Time;
                        M(:,1) = v;
                        M(:,k+2) = iRaw;

%                         %calculate GVT fits
                        Unitary = v * 0;  %initialize
                        tmpV = v - Vs;
                        I = find(abs(tmpV)/12>.01);
                        Unitary(I)  = -g*tmpV(I).*exp(-tmpV(I)/12)./(1 - exp(-tmpV(I)/12));  %traditional eqn
                        I = find(abs(tmpV)/12<=.01);
                        Unitary(I)  = -g*tmpV(I).*(1 - tmpV(I)/12)./(tmpV(I)/12);  %linearized eqn near zero
                        M(:,2) = Unitary;
%                         for j=1:NumCh
%                             M(:,j+2) = j*Unitary ;
%                         end
%                         strColHeaders = {'t' 'v'};
%                         for j=1:NumCh
%                             strColHeaders = [strColHeaders {[num2str(j) 'xUnitary']}];
%                         end
%                         strColHeaders = [strColHeaders {'i'}];

                    else

                        %plotting step data
                        
                        SF = DATA(2).StimParams.LeakSF;
                        Dstep = DATA(1).StimParams.Dstep;
                        VStep = DATA(1).StimParams.Vstep;
                        t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms
                        iRaw = DATA(1).AcqWaveform(1,:);
                        iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);

                        % allow some leaks to be removed from avg
                        if isempty(GoodLeak)
                            GoodLeak =ones(1,length(DATA(2).AcqWaveform(1,1,:)));
                        end
                        LkSum = 0;
                        for n=1:length(GoodLeak);
                            iLeak(:,n) = DATA(2).AcqWaveform(1,:,n);
                            if GoodLeak(n)==1;
                                LkSum = LkSum + iLeak(:,n);
                            end
                        end

                        %%%%%%%%%%  add in a fix for if no leaks are aquired
                        if isempty(GoodLeak)
                            avgLk = mean(DATA(2).AcqWaveform,3);
                        else
                            avgLk = LkSum/sum(GoodLeak);
                        end

                        % avgLk  = mean(DATA(2).AcqWaveform,3);

                        %zero offset:
                        if swANALYSIS.swOffset==0
                            swOffset = mean(iRaw(10:DATA(1).StimParams.PrePoints));
                        end
                        if swANALYSIS.lkOffset==0
                            lkOffset = mean(avgLk(10:DATA(1).StimParams.PrePoints));
                        end
                        iRaw = iRaw - swOffset;
                        avgLk = avgLk - lkOffset;

                        %leak display
                        avgLk = avgLk*SF;
                        smoothleak = 0;
                        try
                            for n=1:(length(XMin))
                                ilk = Amp(n)*exp(-(Tau(n))*(t-Delay(n)));
                                ilk(t<XMin(n))=0;
                                ilk(t>XMax(n))=0;
                                smoothleak = smoothleak + ilk;
                            end
                        end
                        try
                            LinearFit = m*t + b;
                            smoothleak = smoothleak + LinearFit;
                        end
                        try
                            for n=1:(length(AMin));
                                alk = iRaw-smoothleak;
                                alk(t<AMin(n))=0;
                                alk(t>AMax(n))=0;
                                smoothleak = smoothleak + alk;
                            end
                        end
                        if get(SCSTEP.AvgLkSub, 'value')
                            try
                            iRaw = iRaw-avgLk';
                            end
                        end
                        if get(SCSTEP.SmoothLk, 'value')
                            iRaw = iRaw - smoothleak;
                        end
                        M= zeros(length(t), 4);
                        M(:,1) = t;
                        M(:,2) = iRaw;
                        if get(SCSTEP.LkOnly, 'value')
                            %initialize matrix for copy/paste
                            M(:,3) = avgLk;
                            M(:,4) = smoothleak;
                        end
                        strColHeaders = {'t' 'i' 'avgLk' 'smoothleak'};

                    end
                end

                %swpNames = get(SCSTEP.Box, 'String');
                %swpNames = swpNames(nSel);
                %for j=1:length(swpNames)
                %    swpNames{j} = swpNames{j}(6:end);
                %end
                %strColHeaders = [strColHeaders swpNames'];
%                 CopyToClipboard(M, strColHeaders, {});
                CopyToClipboard(M, {}, {});
                %CopyToClipboard(M,{}, {});

                set(gcf, 'pointer', 'arrow');

                waitfor(helpdlg('Data has been copied to the clipboard.  Paste it into an excel spreadsheet'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Fit Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Menu_AdjLkOffset 
    %note that for leaks, b.c. offset is originally the avg of the 1st pts,
    %the leak offset must be used before mult by the scale factor

    global SCSTEP;
   
    set(gcf,'Pointer','fullcross');
    nSel = get(SCSTEP.Box, 'value');
    
    Message = text(.7, .9,'select zero', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');

                 [x y] = ginput(1);
                 delete(Message);
                 SCSTEP.lkOffset = SCSTEP.lkOffset + y/SCSTEP.SF;
                 SaveSwParams;
                 UpdateGraphics
                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Menu_AdjSwOffset
    
    global SCSTEP;
   
    set(gcf,'Pointer','fullcross');
    nSel = get(SCSTEP.Box, 'value');
    
    Message = text(.7, .9,'select zero', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');

                 [x y] = ginput(1);
                 delete(Message);
                 SCSTEP.swOffset = SCSTEP.swOffset + y;
                 SaveSwParams;
                 UpdateGraphics
                   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Menu_CopyFit
global SCSTEP;

nSel = get(SCSTEP.Box, 'value');
if length(nSel) > 1
    waitfor(errordlg('CopyFit can only be done if a single sweep is selected'));
    return;
end

%get leak data - don't take the offset data
    ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
    swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel});
    FitParams.Amp=swANALYSIS.Amp;
    FitParams.Tau=swANALYSIS.Tau;
    FitParams.XMin=swANALYSIS.XMin;
    FitParams.XMax=swANALYSIS.XMax;
    try
    FitParams.Delay=swANALYSIS.Delay;
    catch
    end
    FitParams.m=swANALYSIS.m;
    FitParams.b=swANALYSIS.b; 
    FitParams.AMin=swANALYSIS.AMin;
    FitParams.AMax=swANALYSIS.AMax;
                            
SCSTEP.FitClipboard = FitParams;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Menu_PasteFit
global SCSTEP;

set(gcf, 'pointer', 'watch'); drawnow;
nSel = get(SCSTEP.Box, 'value'); 

ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
    for k=1:length(nSel)     
        S.(SCSTEP.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
        S.(SCSTEP.RunSwp{(nSel(k))}).Amp = SCSTEP.FitClipboard.Amp;
        S.(SCSTEP.RunSwp{(nSel(k))}).Tau = SCSTEP.FitClipboard.Tau;
        try
        S.(SCSTEP.RunSwp{(nSel(k))}).Delay = SCSTEP.FitClipboard.Delay;
        end
        S.(SCSTEP.RunSwp{(nSel(k))}).XMax = SCSTEP.FitClipboard.XMax;
        S.(SCSTEP.RunSwp{(nSel(k))}).XMin = SCSTEP.FitClipboard.XMin;
        S.(SCSTEP.RunSwp{(nSel(k))}).m = SCSTEP.FitClipboard.m;
        S.(SCSTEP.RunSwp{(nSel(k))}).b = SCSTEP.FitClipboard.b;
        S.(SCSTEP.RunSwp{(nSel(k))}).AMin = SCSTEP.FitClipboard.AMin;
        S.(SCSTEP.RunSwp{(nSel(k))}).AMax = SCSTEP.FitClipboard.AMax;
    end
  save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
UpdateGraphics;

set(gcf, 'pointer', 'arrow'); drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Menu_ResetFit   % reset all exponential and linear coefficients to zero
global SCSTEP;

set(gcf, 'pointer', 'watch'); drawnow;
nSel = get(SCSTEP.Box, 'value');
  
ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
  for k=1:length(nSel)
        S.(SCSTEP.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
        S.(SCSTEP.RunSwp{(nSel(k))}).Amp = [];
        S.(SCSTEP.RunSwp{(nSel(k))}).Tau = [];
        S.(SCSTEP.RunSwp{(nSel(k))}).Delay = [];
        S.(SCSTEP.RunSwp{(nSel(k))}).XMax = [];
        S.(SCSTEP.RunSwp{(nSel(k))}).XMin = [];
        S.(SCSTEP.RunSwp{(nSel(k))}).m = [];
        S.(SCSTEP.RunSwp{(nSel(k))}).b = [];
        S.(SCSTEP.RunSwp{(nSel(k))}).AMin = [];
        S.(SCSTEP.RunSwp{(nSel(k))}).AMax = [];           
    end
  save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');

UpdateGraphics;

set(gcf, 'pointer', 'arrow'); drawnow;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Menu_ResetAtool
        global SCSTEP;
set(gcf, 'pointer', 'watch'); drawnow;
nSel = get(SCSTEP.Box, 'value');

                    for k=1:length(nSel)
                    ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                    S.(SCSTEP.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                    S.(SCSTEP.RunSwp{(nSel(k))}).AMin = []; 
                     S.(SCSTEP.RunSwp{(nSel(k))}).AMax = [];  
                    end
                    save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
                   set(gcf, 'pointer', 'arrow');
                UpdateGraphics;
                                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Noise Analysis Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Menu_Variance
        global SCSTEP;
        set(gcf, 'pointer', 'watch'); 
        nSel = get(SCSTEP.Box, 'value');
        cla; 
        xlim('auto');
        
            DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel});
            ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
            swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel});
            XMin = swANALYSIS.XMin;
            XMax = swANALYSIS.XMax;
            Tau = swANALYSIS.Tau;
            Delay = swANALYSIS.Delay;
            Amp = swANALYSIS.Amp;
            m = swANALYSIS.m;
            b = swANALYSIS.b;
            SF = DATA(2).StimParams.LeakSF;
            Dstep = DATA(1).StimParams.Dstep;
            time    = DATA(1).Time*1000 ;  %time in ms starting from begining of data
            t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms where zero is at start of p2
            iRaw = DATA(1).AcqWaveform;
            %iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);
                avgLk  = mean(DATA(2).AcqWaveform,3);
%note that the swANALYSIS offset does not seem to equal the global value -
%check this!!!!
                
                iRaw = iRaw - SCSTEP.swOffset;
                avgLk = avgLk - SCSTEP.lkOffset;
                avgLk = avgLk*SF;
                smoothleak = 0;
                try
                    for n=1:(length(XMin))
                        ilk = Amp(n)*exp(-(Tau(n))*(t-Delay(n)));
                        ilk(t<XMin(n))=0;
                        ilk(t>XMax(n))=0;
                        smoothleak = smoothleak + ilk;
                    end
                end
                try
                    LinearFit = m*t + b;
                    smoothleak = smoothleak + LinearFit;
                end
                try
                    for n=1:(length(AMin));
                        alk = iRaw-smoothleak;
                        alk(t<AMin(n))=0;
                        alk(t>AMax(n))=0;
                        smoothleak = smoothleak + alk;
                    end
                end
                iRaw = iRaw - smoothleak;
                plot(time, iRaw);
       
Message = text(.7, .9,'select X range', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        [xmn ytemp] = ginput(1);
        [xmx ytemp] = ginput(1);
        delete(Message);

        
        ST=xmn*length(iRaw)/(time(end));
        ET = (xmx*length(iRaw))/(time(end));

        SubTrace = iRaw(ST:ET);
        plot(time(ST:ET), SubTrace, 'r')
        Variance = var(SubTrace);
        AverageI= mean(SubTrace);
        format('short');
        Message = text(.3, .9,['variance: ', num2str(Variance), '  Average I: ', num2str(AverageI)], 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        waitforbuttonpress;
        delete(Message);
        UpdateGraphics;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_AutoCalcPo
            global SCSTEP;
            set(gcf, 'pointer', 'watch'); drawnow;
            nSel = get(SCSTEP.Box, 'value');
            cla;  xlim('auto');

            [Filename, Pathname] = uigetfile('*.xls;*.xlsx', 'Choose the excel spreadsheet'); % user to choose file
            if Filename==0
                return;
            end
            xlsFile = [Pathname  Filename];

            for k=1:length(nSel);
                cla;
               
                DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(k)});
                ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                XMin = swANALYSIS.XMin;
                XMax = swANALYSIS.XMax;
                Tau = swANALYSIS.Tau;
                Amp = swANALYSIS.Amp;
                Delay = swANALYSIS.Delay;
                m = swANALYSIS.m;
                b = swANALYSIS.b;
                SF = DATA(2).StimParams.LeakSF;
                CellNum = DATA(1).CellNum;
                CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
                fullfile = SCSTEP.datafile;
                l = findstr(fullfile, '\');
                file = fullfile(l(end)+1:end);
                RunSwp = SCSTEP.RunSwp{nSel};
                freq = DATA(1).SamplingFreqHz;
                RI = DATA(1).StimParams.RI;
                xFect = DATA(1).DBParams.XFect;

                 %if (findstr(DATA(1).StimName, 'Step'));
                
                try
                    NumCh = ANALYSIS.(CellNumString).NumCh;
                    g = ANALYSIS.(CellNumString).g;
                    Vs = ANALYSIS.(CellNumString).Vs;
                catch
                    waitfor(errordlg('you must set the single channel level for this analysis'));
                end

                Dstep = DATA(1).StimParams.Dstep;
                VStep = DATA(1).StimParams.Vstep;
                time    = DATA(1).Time*1000 ;  %time in ms starting from begining of data
                t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms where zero is at start of p2
                iRaw = DATA(1).AcqWaveform;
                %iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);
                avgLk  = mean(DATA(2).AcqWaveform,3);
                iRaw = iRaw - SCSTEP.swOffset;
                avgLk = avgLk - SCSTEP.lkOffset;
                avgLk = avgLk*SF;
                smoothleak = 0;
                try
                    for n=1:(length(XMin))
                        ilk = Amp(n)*exp(-(Tau(n))*(t-Delay(n)));
                        ilk(t<XMin(n))=0;
                        ilk(t>XMax(n))=0;
                        smoothleak = smoothleak + ilk;
                    end
                end
                try
                    LinearFit = m*t + b;
                    smoothleak = smoothleak + LinearFit;
                end
                try
                    for n=1:(length(AMin));
                        alk = iRaw-smoothleak;
                        alk(t<AMin(n))=0;
                        alk(t>AMax(n))=0;
                        smoothleak = smoothleak + alk;
                    end
                end
                iRaw = iRaw - smoothleak;
 
                prepts= 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;
                ST=(prepts)*length(iRaw)/(time(end));
                ET = (Dstep(1)*length(iRaw))/(time(end));
                baseline = iRaw(ST:ET);
                VarianceB = var(baseline);
                AverageBL= mean(baseline);

                ST=(Dstep(1)+prepts+30)/time(end)*length(iRaw);
                ET = (Dstep(1)+Dstep(2)+prepts - 10)*length(iRaw)/time(end);
                step = iRaw(ST:ET);
                Variance = var(step);
                AverageI= mean(step);

                %note - assume step 2 is the pulse and ZF = 12
                v = VStep(2);
                i = -g*(v-Vs)*exp(-(v-Vs)/12)/(1-exp(-(v-Vs)/12));
                Po= 1-(Variance-VarianceB)/AverageI*i;
                N = AverageI/(Po*i);

                strColHeaders = {'xFect' 'Cell' 'file'  'run_swp' 'freq' 'RI' 'V' 'i' 'Var(base)' '<i>base' 'Variance' '<i>' 'Po' 'N'}
                values(k,:) = [{xFect} CellNum {file} {RunSwp} freq RI v i VarianceB AverageBL Variance AverageI Po N];
            end
                 try
            [dum, dum, temp] = xlsread(xlsFile, num2str(CellNum));
            final = [temp; strColHeaders; values];
            catch
                final = [strColHeaders; values];
            end
                      
            xlswrite(xlsFile, final, num2str(CellNum), 'A2');
       
            UpdateGraphics;

            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_CalcPo
            global SCSTEP;
            set(gcf, 'pointer', 'watch'); drawnow;
            nSel = get(SCSTEP.Box, 'value');
            cla;  xlim('auto');
            
            for k=1:length(nSel);
            cla;
                DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(k)});
                ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                XMin = swANALYSIS.XMin;
                XMax = swANALYSIS.XMax;
                Tau = swANALYSIS.Tau;
                Amp = swANALYSIS.Amp;
                Delay = swANALYSIS.Delay;
                m = swANALYSIS.m;
                b = swANALYSIS.b;
                SF = DATA(2).StimParams.LeakSF;
                CellNum = DATA(1).CellNum;
                CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
                fullfile = SCSTEP.datafile;
                l = findstr(fullfile, '\');
                file = fullfile(l(end)+1:end);
                RunSwp = SCSTEP.RunSwp{nSel};
                freq = DATA(1).SamplingFreqHz;
                RI = DATA(1).StimParams.RI;
                xFect = DATA(1).DBParams.XFect;

                try
                    NumCh = ANALYSIS.(CellNumString).NumCh;
                    g = ANALYSIS.(CellNumString).g;
                    Vs = ANALYSIS.(CellNumString).Vs;
                catch
                    waitfor(errordlg('you must set the single channel level for this analysis'));
                end

                Dstep = DATA(1).StimParams.Dstep;
                VStep = DATA(1).StimParams.Vstep;
                time    = DATA(1).Time*1000 ;  %time in ms starting from begining of data
                t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms where zero is at start of p2
                iRaw = DATA(1).AcqWaveform;
                %iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);
                avgLk  = mean(DATA(2).AcqWaveform,3);
                iRaw = iRaw - SCSTEP.swOffset;
                avgLk = avgLk - SCSTEP.lkOffset;
                avgLk = avgLk*SF;
                smoothleak = 0;
                try
                    for n=1:(length(XMin))
                        ilk = Amp(n)*exp(-(Tau(n))*(t-Delay(n)));
                        ilk(t<XMin(n))=0;
                        ilk(t>XMax(n))=0;
                        smoothleak = smoothleak + ilk;
                    end
                end
                try
                    LinearFit = m*t + b;
                    smoothleak = smoothleak + LinearFit;
                end
                try
                    for n=1:(length(AMin));
                        alk = iRaw-smoothleak;
                        alk(t<AMin(n))=0;
                        alk(t>AMax(n))=0;
                        smoothleak = smoothleak + alk;
                    end
                end
                iRaw = iRaw - smoothleak;
                plot(time, iRaw);

                Message = text(.7, .9,'select X range for baseline', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
                [xmnb ytemp] = ginput(1);
                [xmxb ytemp] = ginput(1);
                delete(Message);
                ST=xmnb/time(end)*length(iRaw);
                ET = xmxb*length(iRaw)/time(end);
                baseline = iRaw(ST:ET);
                VarianceB = var(baseline);
                AverageBL= mean(baseline);


                Message = text(.7, .9,'select X range for step', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
                [xmn ytemp] = ginput(1);
                [xmx ytemp] = ginput(1);
                delete(Message);
                ST=xmn/time(end)*length(iRaw);
                ET = xmx*length(iRaw)/time(end);
                step = iRaw(ST:ET);
                Variance = var(step);
                AverageI= mean(step);
                
                %note - assume step 2 is the pulse and ZF = 12
                v = VStep(2);
                i = -g*(v-Vs)*exp(-(v-Vs)/12)/(1-exp(-(v-Vs)/12));
                Po= 1-(Variance-VarianceB)/AverageI*i;
                N = AverageI/(Po*i);

                if VarianceB > 0.5*Variance
                    Message = text(.5, .9, 'your baseline variance is more than half your step Var', 'Units', 'normalized','FontSize', 18, 'Color', 'r');
                else
                    Message = text(.5, .9, ['Var: ', num2str(Variance), '  Avg: ', num2str(AverageI), '  Po: ', num2str(Po)],'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
                end
                waitforbuttonpress;

                strColHeaders = 'xFect\tCell\tfile\trun_swp\tfreq\tRI\tV\ti\tVar(base)\t<i>base\tVariance\t<i>\tPo\tN'
              % values(k,:) = [xFect '\t' num2str(CellNum) '\t' file '\t' RunSwp '\t' num2str(freq) '\t' num2str(RI) '\t' num2str(v) '\t' num2str(i) '\t' num2str(VarianceB) '\t' num2str(AverageBL) '\t' num2str(Variance) '\t' num2str(AverageI) '\t' num2str(Po) '\t' num2str(N)  ];
                values(k,:) = [{xFect} CellNum {file} {RunSwp} freq RI v i VarianceB AverageBL Variance AverageI Po N];
            end
        
          %xlswrite('temp', values, num2str(CellNum), 'A3');
  
            UpdateGraphics;
%% Step Analysis Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            function Menu_AvgTraces
                global SCSTEP;
                set(gcf, 'pointer', 'watch'); drawnow;
                nSel = get(SCSTEP.Box, 'value');
                cla;  xlim('auto');
                %
                %             [Filename, Pathname] = uigetfile('*.xls;*.xlsx', 'Choose the excel spreadsheet'); % user to choose file
                %             if Filename==0
                %                 return;
                %             end
                %             xlsFile = [Pathname  Filename];

                iSum = 0;
                count = 0;

                for k=1:length(nSel);
%                     cla;

                    DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(k)});
                    ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                    swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                    Good = [swANALYSIS.GoodBad];
                    Blank = [swANALYSIS.Blank];
                    FiltHz = swANALYSIS.FiltHz;

                    if Good==1 & Blank==0;

                        XMin = swANALYSIS.XMin;
                        XMax = swANALYSIS.XMax;
                        Tau = swANALYSIS.Tau;
                        Amp = swANALYSIS.Amp;
                        try
                        Delay = swANALYSIS.Delay;
                        end
                        m = swANALYSIS.m;
                        b = swANALYSIS.b;
                        AMin = swANALYSIS.AMin;
                        AMax = swANALYSIS.AMax;
                        swOffset = swANALYSIS.swOffset;
                        lkOffset = swANALYSIS.lkOffset;

                        SF = DATA(2).StimParams.LeakSF;
                        CellNum = DATA(1).CellNum;
                        CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
                        fullfile = SCSTEP.datafile;
                        l = findstr(fullfile, '\');
                        file = fullfile(l(end)+1:end);
                        RunSwp = SCSTEP.RunSwp{nSel(k)};
                        freq = DATA(1).SamplingFreqHz;
                        RI = DATA(1).StimParams.RI;
                        xFect = DATA(1).DBParams.XFect;

                        try
                            NumCh = ANALYSIS.(CellNumString).NumCh;
                            g = ANALYSIS.(CellNumString).g;
                            Vs = ANALYSIS.(CellNumString).Vs;
                        catch
                            %                     waitfor(errordlg('you must set the single channel level for this analysis'));
                        end

                        Dstep = DATA(1).StimParams.Dstep;
                        VStep = DATA(1).StimParams.Vstep;
                        time    = DATA(1).Time*1000 ;  %time in ms starting from begining of data
                        t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms where zero is at start of p2
                        iRaw = DATA(1).AcqWaveform;
                        iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);
                        avgLk  = mean(DATA(2).AcqWaveform,3);
% 
%                         %zero offset:
%                         if swANALYSIS.swOffset==0
%                             swOffset = mean(iRaw(10:DATA(1).StimParams.PrePoints));
%                         end
%                         if swANALYSIS.lkOffset==0
%                             lkOffset = mean(avgLk(10:DATA(1).StimParams.PrePoints));
%                         end
%                         iRaw = iRaw - swOffset;
%                         avgLk = avgLk - lkOffset;



                       % avgLk  = mean(DATA(2).AcqWaveform,3);
                       % find where the first pulse ends
                       % MBJ
                       EndofPulse1 = find(abs(diff(DATA(1).StimWaveform)),1);
                       %zero offset:
                       if swANALYSIS.swOffset==0
                            swOffset = mean(iRaw(EndofPulse1-DATA(1).StimParams.PrePoints-1:EndofPulse1));
                       end
                       if swANALYSIS.lkOffset==0
                            lkOffset = mean(avgLk(EndofPulse1-DATA(1).StimParams.PrePoints-1:EndofPulse1));
                       end
                       iRaw = iRaw - swOffset;
                       avgLk = avgLk - lkOffset;

                        
%                         iRaw = iRaw - SCSTEP.swOffset;
%                         avgLk = avgLk - SCSTEP.lkOffset;
                        avgLk = avgLk*SF;
                        smoothleak = 0;
                        try
                            for n=1:(length(XMin))
                                ilk = Amp(n)*exp(-(Tau(n))*(t-Delay(n)));
                                ilk(t<XMin(n))=0;
                                ilk(t>XMax(n))=0;
                                smoothleak = smoothleak + real(ilk);
                            end
%                             smoothleak = LowpassFilter(DATA(1).Time, smoothleak, 1500);
                            
                        end
                        try
                            LinearFit = m*t + b;
                            smoothleak = smoothleak + LinearFit;
                        end
                        try
                            for n=1:(length(AMin));
                                alk = iRaw-smoothleak;
                                alk(t<AMin(n))=0;
                                alk(t>AMax(n))=0;
                                smoothleak = smoothleak + alk;
                            end
                        end
                        iRaw = iRaw - smoothleak;

                        prepts= 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;
                        v = VStep(2);
                        
                        count = 1 + count;
                        iSum = iRaw + iSum;
                        
                        
                 end
                end
                iAvg = iSum/count;

                M= zeros(length(t), 3);
                M(:,1) = t;
                M(:,2) = iAvg;
                M(1,3) = count;
                strColHeaders = {'t' 'iAvg' 'number of traces' };

                CopyToClipboard(M, strColHeaders, {});             
                
                plot (t, iAvg);
                set(gcf, 'pointer', 'arrow');
                
                %                  try
                %             [dum, dum, temp] = xlsread(xlsFile, num2str(CellNum));
                %             final = [temp; strColHeaders; values];
                %             catch
                %                 final = [strColHeaders; values];
                %             end
                %
                %             xlswrite(xlsFile, final, num2str(CellNum), 'A2');
               


                %             UpdateGraphics;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                
function Menu_FitSteps
%         global SCSTEP
%         set(gcf, 'pointer', 'watch'); drawnow;
%         nSel = get(SCSTEP.Box, 'value');  
%         k = 1;
%         % load data and analysis files
%         if length(nSel)>1
%             nSel = nSel(1);
%             disp('Pick One trace at a time, choosing trace 1');
%         end
%         DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(k)});
%         ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
%         swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
%         CellNum = DATA(1).CellNum;
%         CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
%         GoodLeak = swANALYSIS.GoodLeak;
%         swOffset = swANALYSIS.swOffset;
%         lkOffset = swANALYSIS.lkOffset;
%         Tau = swANALYSIS.Tau;
%         Amp = swANALYSIS.Amp;        
%         if (findstr(DATA(1).StimName, 'Ramp'))
%             waitfor(errordlg('This tool only works for step commands'));
%         end                    
%         SF = DATA(2).StimParams.LeakSF;
%         Dstep = DATA(1).StimParams.Dstep;
%         VStep = DATA(1).StimParams.Vstep;
%         t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms
%         iRaw = DATA(1).AcqWaveform;
%         iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);
%         nPulses = length(DATA(1).StimParams.Vstep);
%         for i =1:length(
        
%                       
%                 if isempty(GoodLeak)
%                     GoodLeak =ones(1,length(DATA(2).AcqWaveform(1,1,:)));
%                 end
%                 LkSum = 0;
%                 for n=1:length(GoodLeak);
%                     iLeak(:,n) = DATA(2).AcqWaveform(1,:,n);
%                     if GoodLeak(n)==1;
%                         LkSum = LkSum + iLeak(:,n);
%                     end
%                 end
% 
%                 if isempty(GoodLeak)
%                     avgLk = mean(DATA(2).AcqWaveform,3);
%                 else
%                     avgLk = LkSum/sum(GoodLeak);
%                 end
% 
%                 %zero offset:
%                 if swANALYSIS.swOffset==0
%                     swOffset = mean(iRaw(10:DATA(1).StimParams.PrePoints));
%                 end
%                 if swANALYSIS.lkOffset==0
%                     lkOffset = mean(avgLk(10:DATA(1).StimParams.PrePoints));
%                 end
%                 iRaw = iRaw - swOffset;
%                 avgLk = avgLk - lkOffset;
% 
% 
%                 avgLk = avgLk*SF;
%                 iRawFilt = LowpassFilter(DATA(1).Time, iRaw, 0);
% 
%                 t1 = find(t>0, 1);
%                 t2 = find(t>299, 1);
%                 time = t(t1:t2);
%                 Leak = avgLk(t1:t2);
%                 iRawFit = iRawFilt(t1:t2)';
%                 if get(SCSTEP.FitLeak, 'value')
%                     plot(time, Leak);
%                     y = Leak;
%                 else
%                     plot(time, iRawFit);
%                     y = iRawFit;
%                 end
% 
%                 %autofit(TauGuess, AmpGuess, t, avgLk);
% 
%                 t = time;
%                 %h = plot(t, y, 'r');
% 
%                 if get(SCSTEP.UseGuess, 'value')
%                     start = Tau;
%                 else
%                     start = [6.4053e-005    0.088143     0.41024      3.1947      3.1112  ];
%                 end
% 
%                 % We use an anonymous function to pass additional parameters t, y, h to the
%                 % output function.
% 
% 
% %                 outputFcn = @(x,optimvalues,state) fitoutputfun(x,optimvalues,state,t,y,h);
% %                 options = optimset('OutputFcn',outputFcn,'TolX',0.1);
% %                 estimated_lambda = fminsearch(@(x)fitfun(x,t,y),start,options);
% 
% digits(6);
%                 estimated_lambda = fminsearch(@(x)fitfun(x,t,y),start);
% 
% 
%                 for n=1:length(estimated_lambda)
%                     XMin(n) = 0;
%                     XMax(n) = 300;
%                 end
%                 Tau = round(estimated_lambda/0.0001)*0.0001;
%                 Amp = round(SCSTEP.AmpHold/0.001)*0.001;
%                 
%                 S.(SCSTEP.RunSwp{nSel(k)})= ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
%                 S.(SCSTEP.RunSwp{nSel(k)}).XMin = XMin;
%                 S.(SCSTEP.RunSwp{nSel(k)}).XMax = XMax;
%                 %S.(SCSTEP.RunSwp{nSel(k)}).Tau = estimated_lambda;
%                 S.(SCSTEP.RunSwp{nSel(k)}).Tau = Tau;
%                 %S.(SCSTEP.RunSwp{nSel(k)}).Amp = SCSTEP.AmpHold';
%                 S.(SCSTEP.RunSwp{nSel(k)}).Amp = Amp';
%                 save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
%             end



            set(gcf, 'pointer', 'arrow');
            UpdateGraphics;

        
        
        
        
        
        
        
        
function Menu_Measure

        global SCSTEP;
        ylim('manual');
        xlim('manual');
        axis on;
        set(gcf, 'pointer', 'fullcross'); drawnow;
        nSel = get(SCSTEP.Box, 'value');
        bMeasure = true;
        xlimit = get(gca, 'xlim');
        ylimit = get(gca, 'ylim');
        htext = [];
        while bMeasure
            measurement = ginput(2);
            if ~isempty(measurement)
                fprintf('t= %f   i = %5.4f\n',measurement');
                fprintf('i_LKsub = %5.4f\n -------------\n', measurement(2,2)-measurement(1,2));                                
                if isempty(htext)
                    htext = text(xlimit(1)+diff(xlimit)*0.1, ylimit(2)-(diff(ylimit)*0.9),sprintf('i = %5.4f',measurement(2,2)-measurement(1,2)),'color',[1 0 0],'fontsize',12);
                else 
                    set(htext, 'string', sprintf('i = %5.4f',measurement(2,2)-measurement(1,2)))
                end
            else
                bMeasure =false;
                
            end
        end
        delete(htext)
        set(gcf, 'pointer', 'arrow'); drawnow;       


%% Ramp Analysis Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
    function Menu_SCRnew
        
        global SCSTEP;

        set(gcf, 'pointer', 'watch'); drawnow;
        nSel = get(SCSTEP.Box, 'value');
        cla;  hold on;


        %open an excell file to paste into
        [Filename, Pathname] = uigetfile('*.xls;*.xlsx', 'Choose the excel spreadsheet'); % user to choose file
        if Filename==0
            return;
        end
        xlsFile = [Pathname  Filename];


        %M = 'File\tRun\tSwp\tGoodTrace\tGain\tFiltHz\tVmin\tVmax\tm\tb\tAmp1\tTau1\tAmp2\tTau2\tAmp3\tTau3\tconstruct\tCellNum\tnotes';
strColHeaders = {'File' 'Run' 'Swp' 'GoodTrace' 'Gain' 'FiltHz' 'Vmin' 'Vmax' 'm' 'b' 'Tau1' 'Amp1' 'Tau2' 'Amp2' 'Tau3' 'Amp3' 'construct'  'CellNum' 'notes' 'XMin' 'XMax' 'ATool' 'calc chan #' 'overide chan #'};

%         M = [M '\n'];
%         Fit = '0\t0\t0\t0\t0\t0\t0\t0';   %default fit

            N = {'NumCh'; 'g';  'Vs'; 'ZF'; 'ActivFiltHz';  'NL'; 'ActVR1'; 'ActVR2'; 'OneCh'; 'TwoCh'; 'ThreeCh'; 'GoodCell'};

       % load data and analysis files
        for k=1:length(nSel)
            DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(k)});
            ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
            swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
            CellNum = DATA(1).CellNum;
            CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
            GoodLeak = swANALYSIS.GoodLeak;
            swOffset = swANALYSIS.swOffset;
            lkOffset = swANALYSIS.lkOffset;
            try
                NumCh = ANALYSIS.(CellNumString).NumCh;
                g = ANALYSIS.(CellNumString).g;
                Vs = ANALYSIS.(CellNumString).Vs;
            catch
                waitfor(errordlg('you need to have your conductance parameters set to do this analysis'));
            end

            FiltHz = swANALYSIS.FiltHz;
            XMin = swANALYSIS.XMin;
            XMax = swANALYSIS.XMax;
            AMin = swANALYSIS.AMin;
            AMax = swANALYSIS.AMax;

            Tau = [ 0 0 0];
            Amp = [0 0 0];
            T = swANALYSIS.Tau;
            A = swANALYSIS.Amp;
            for l=1:length(T)
                Tau(l) = T(l);
                Amp(l) = A(l);
            end
            
            m = swANALYSIS.m;
            b = swANALYSIS.b;
            RunSwp = SCSTEP.RunSwp{nSel(k)};
            Run = RunSwp(4:7);
            Swp = RunSwp(12:15);
            FileTemp = SCSTEP.datafile;
            m = findstr(FileTemp, '\');
            l = m(end)+1;
            %l = findstr(FileTemp, 'IED');
            File = FileTemp(l:end);

            if (findstr(DATA(1).StimName, 'Step'))
                waitfor(errordlg('This tool only works for Ramp commands'));
            end

            %SF = DATA(2).StimParams.LeakSF;
            Dstep = DATA(1).StimParams.Dstep;
            VStep = DATA(1).StimParams.Vstep;
            %t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms
            v = DATA.StimWaveform;
            iRaw = DATA(1).AcqWaveform;
            %iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);


            if (findstr(DATA(1).StimName, 'Ramp'))
                %M = [M '\n' File '\t' Run '\t' Swp '\t' SCSTEP.GoodBad '\t' num2str(DATA(1).StimParams.Gain) '\t0\t' '-100' '\t' '100' '\t' m '\t\' b '\t' Amp(1)  '\t' Tau(1)  '\t' Amp(2)  '\t' Tau(2)  '\t' Amp(3)  '\t' Tau(3)  '\t' num2str(DATA(1).DBParams.XFect)  '\t' num2str(DATA(1).DBParams.CellNum)  '\n'];
                M(k,:) = {File  Run  Swp  SCSTEP.GoodBad  num2str(DATA(1).StimParams.Gain) num2str(FiltHz)  '-100' '100' m  b  Tau(1)   Amp(1)   Tau(2)   Amp(2)   Tau(3)   Amp(3)   num2str(DATA(1).DBParams.XFect)   num2str(DATA(1).DBParams.CellNum) ' '  num2str(XMin) num2str(XMax) num2str([AMin AMax]) '0' '0' };
            end

        end

        %these parameters will determine how many channels are counted in
        %each trace - they are given some default values here and can be
        %changed in the excel sheet during analysis
        
        O ={num2str(NumCh); num2str(g); num2str(Vs); '12'; '2'; '0.1'; '-100'; '45'; 'A(1)>.015 && A(2)<.001'; 'A(2)>.001 && A(3)<.001'; 'A(3)>.001 && A(4)<.001'; '1'}  


        %clipboard('copy', sprintf(M));
        xlswrite(xlsFile, strColHeaders,['SwpCell' num2str(CellNum)], 'A9');
        xlswrite(xlsFile, M,['SwpCell' num2str(CellNum)], 'A10');
        xlswrite(xlsFile, N,['FitCell' num2str(CellNum)], 'A10');
xlswrite(xlsFile, O,['FitCell' num2str(CellNum)], 'B10');

        set(gcf, 'pointer', 'arrow');

        waitfor(helpdlg('Data has been copied to your file'));
 
        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [M, g, Vs, ZF, GoodCell] = Menu_SCRCellAvg
global SCSTEP;


% for now this function will read off the excel sheet as mrt originally
% designed

nSel = get(SCSTEP.Box, 'value');
set(gcf, 'pointer', 'watch'); drawnow;

%read the cell-level parameters

[Filename, Pathname] = uigetfile('*.xls;*.xlsx', 'Choose the excel spreadsheet where you saved your cell sweep analysis'); % user to choose file
        if Filename==0
            return;
        end
        xlsFile = [Pathname  Filename];
        
        
        
        DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(1)});
        CellNum = DATA(1).CellNum;
        
        %keep this bit of mrt code for now so that you can be sure you load
        %the correct trace matching the excel sheet
        [mdata, mtxt] = xlsread(xlsFile, ['SwpCell' num2str(CellNum)], 'A9:P10000');
        mtxt = mtxt(2:end, 1);
        SCRAMP.FileRunSwpGood = repmat({'' 0 0 0}, size(mdata,1), 1);
        BoxTxt = repmat({''}, size(mdata,1), 1);
        for k=1:size(mdata,1)
            SCRAMP.FileRunSwpGood(k, :) = {mtxt{k}  mdata(k,1)  mdata(k,2)  mdata(k,3)};
        end

[data, txt] = xlsread(xlsFile, ['FitCell' num2str(CellNum)], 'B10:B21');
NumCh = data(1);
g     = data(2);
Vs    = data(3);
ZF    = data(4);
ActivFiltHz = data(5);
NL          = data(6);
ActVR       = [data(7) data(8)];
GoodCell    = data(12);
if length(data)>=9 && ~isnan(data(9))
    OneCh       = data(9);
else
    OneCh = txt{1};
end
if length(data)>=10 && ~isnan(data(10))
    TwoCh       = data(10);
else
    if ischar(OneCh)
        TwoCh = txt{2};
    else
        TwoCh = txt{1};
    end
end
if length(data)>=11 && ~isnan(data(11))
    ThreeCh     = data(11);
else
    ThreeCh = txt{end};
end

%These cell-level parameters relate to an additional leak fix  %this is not
%currently working
data = xlsread(xlsFile, ['FitCell' num2str(CellNum)], 'H10:H29');
FitEnable =0; % data(end);
FitX = 0; %data(end-1);

%read the sweep-level parameters
LeakData = xlsread(xlsFile, ['SwpCell' num2str(CellNum)], ['E' num2str(10) ':X' num2str(1000)]);
Gain = LeakData(:,1);
FiltHz = LeakData(:,2);
Vmin = LeakData(:,3);
Vmax = LeakData(:,4);
% LeakData = LeakData(:,5:end);
m = LeakData(:,5);
b = LeakData(:,6);
tau1 = LeakData(:,7);
Amp1 = LeakData(:, 8);
tau2 = LeakData(:,9);
Amp2 = LeakData(:,10);
tau3 = LeakData(:,11);
Amp3 = LeakData(:,12);  %note that the older excel files have a typo where amp and tau are labled wrong, but this is the correct read of all sheets, typo is only in the header
%ied addition
%ManChan = xlsread(SCRAMP.xlsFile, ['SwpCell' num2str(SCRAMP.cell)], ['X' num2str(10+1), ':X' num2str(10+size(SCRAMP.FileRunSwpGood,1))]);
ManChan = LeakData(:,20);
% ied addition
% Activity=zeros(length(ManChan),8);  %create a matrix where the "activity" values can be stored later to guide with parameter settings if needed
% 
% Activity(:,2)=[SCRAMP.FileRunSwpGood{:,2}];
% Activity(:,3)=[SCRAMP.FileRunSwpGood{:,3}];

for k=1:size(SCRAMP.FileRunSwpGood,1)

    %     if k==26
    %         'debug'
    %     end

    DATA = LoadDataMRT(SCRAMP.FileRunSwpGood{k, 1:3}, Gain(k));
    v = DATA.StimWaveform;
    iRaw = DATA.AcqWaveform;

    if k==1
        %some temporary variables
        MasterV = v;
        Mean.i = 0*v;
        Mean.n = 0*v;
        if NumCh==1
            SubMean = [];
        else
            for n=1:NumCh
                SubMean(n).i         = 0*v;
                SubMean(n).n         = 0*v;
            end
        end

        %calculate GVT fits
        Unitary = v * 0;  %initialize
        tmpV = v - Vs;
        I = find(abs(tmpV)/ZF>.01);
        Unitary(I)  = -g*tmpV(I).*exp(-tmpV(I)/ZF)./(1 - exp(-tmpV(I)/ZF));  %traditional eqn
        I = find(abs(tmpV)/ZF<=.01);
        Unitary(I)  = -g*tmpV(I).*(1 - tmpV(I)/ZF)./(tmpV(I)/ZF);  %linearized eqn near zero

        %next, create some variables that are useful for activity determination
        I = find( v>=ActVR(1) & v <= ActVR(2) );  %limit our activity threshold over some voltage range
        UnitaryClip = Unitary(I);
        ScaledNoise = -NL./UnitaryClip;

        %         also, the leak-fix
        if FitEnable
            tmp = polyval(data(end-2:-1:1), v);
            tmp(v<FitX) = 0;
            LkFix = tmp;
        else
            LkFix = v*0;;
        end
    elseif length(MasterV) ~= length(v) || any(MasterV ~= v)
        err = 'All sweeps in a cell must have the same voltage range';
        waitfor(errordlg(err));
        error(err);
    end

    %skip if this sweep is marked bad
    if ~SCRAMP.FileRunSwpGood{k, 4}
        continue;
    end

    %     %calculate and subtract leak
    %     P = LeakData(k,:);
    %     P = P(end:-1:1);
    %     P = P(~isnan(P));
    %     iLk = polyval(P, v);
    %     iRaw = iRaw - iLk;
    %     iRaw = LowpassFilter(DATA.Time, iRaw, FiltHz(k));

    %calculate and subtract leak

    iLk = m(k)*v + b(k) + Amp1(k)*exp(-tau1(k)*v)+ Amp2(k)*exp(-tau2(k)*v) + Amp3(k)*exp(-tau3(k)*v);
    iRaw = iRaw - iLk;
    iRaw = LowpassFilter(DATA.Time, iRaw, FiltHz(k));

    %next calculate the "activity" of this sweep, and decide if it has 1,2,3 channels active

    ScaledTrace = iRaw(I)./Unitary(I);
    if ActivFiltHz
        ScaledTrace = LowpassFilter(v(I), ScaledTrace, ActivFiltHz);
    end
    for n=1:NumCh
        %activity at each timepoint is zero if lower than prev level, 1 if higher than current level, and linearly 0 to 1 if between
        Activ = (ScaledTrace-ScaledNoise-n+1);  %first subtract the floor
        Activ(Activ<0) = 0;                     %clean up anything that dropped below the floor
        Activ = Activ./(1-ScaledNoise);       %now scale up the rest
        Activ(Activ>1 | Activ<0) = 1;           %and clean up again, note, the <0 stuff matters after the noise levels cross
        TraceActivity(n) =  mean(Activ);
    end
    A = [TraceActivity 0 0 0 0]; %we create the param "A", and eval the user-given code for each level
    if NumCh>=1
        if ischar(OneCh)
            YesNo(1) = eval(OneCh);
        else
            YesNo(1) = OneCh;
        end
    end
    if NumCh>=2
        if ischar(TwoCh)
            YesNo(2) = eval(TwoCh);
        else
            YesNo(2) = TwoCh;
        end
    end
    if NumCh>=3
        if ischar(ThreeCh)
            YesNo(3) = eval(ThreeCh);
        else
            YesNo(3) = ThreeCh;
        end
    end
    if NumCh>=4
        YesNo(4:NumCh) = 0;
    end
    debugYN(k) = YesNo(1);


    %just add a count of the number of channels

    NumberOfChannels=0;
    for n=1:NumCh
        if YesNo(n);
            NumberOfChannels=n;
        end
    end

    %ied - allow a manual overide of the number of channels - careful, you
    %must have zeroes in column X when this is active
    %disp('new sweep');
    AdjChanNum=0;
    if ManChan(k)~=0
        %disp('manual');
        AdjChanNum=ManChan(k);
    else
        for n=1:NumCh
            %disp([n YesNo(n)])
            if YesNo(n)
                AdjChanNum=n;
            end
        end
    end
    %NumberOfChannels
    if AdjChanNum>=4
        AdjChanNum=0;
    end

    % (ied addition) fill in a matrix to be pasted to exel for
    % troubleshooting purposes
    Activity(k,1)=k; %fill in a matrix with the activity levels for each sweep
    Activity(k,4:7)=A(1:4);
    Activity(k,8)=NumberOfChannels;

    %finally, add this sweep to the running sums, accordingly
    %     for n=1:NumCh
    %         if YesNo(n)
    %             try
    %                 Mean.i(v>=Vmin(k)&v<=Vmax(k))  =  Mean.i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/n;
    %                 Mean.n(v>=Vmin(k)&v<=Vmax(k))  =  Mean.n(v>=Vmin(k)&v<=Vmax(k))  +  1;
    %
    %             catch
    %                 waitfor(errordlg(['You probably have sweeps with different sampling intervals -- this is not allowed for the same cell . . .sorry ' lasterr]));
    %                 rethrow(lasterror);
    %             end
    %
    %             if ~isempty(SubMean)
    %                 SubMean(n).i(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(n).i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/n;
    %                 SubMean(n).n(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(n).n(v>=Vmin(k)&v<=Vmax(k))  +  1;
    %             end
    %         end
    %     end
    % end

    %ied change
    %finally, add this sweep to the running sums, accordingly
    if AdjChanNum ~=0
        nc=AdjChanNum;
        try
            Mean.i(v>=Vmin(k)&v<=Vmax(k))  =  Mean.i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/nc;
            Mean.n(v>=Vmin(k)&v<=Vmax(k))  =  Mean.n(v>=Vmin(k)&v<=Vmax(k))  +  1;

        catch
            waitfor(errordlg(['You probably have sweeps with different sampling intervals -- this is not allowed for the same cell . . .sorry ' lasterr]));
            rethrow(lasterror);
        end

        if ~isempty(SubMean)
            SubMean(nc).i(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(nc).i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/nc;
            SubMean(nc).n(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(nc).n(v>=Vmin(k)&v<=Vmax(k))  +  1;
        end
    end
end



%divide by n to get average, also do the LkFix
Mean.i = Mean.i./Mean.n - LkFix;
for n=1:length(SubMean)
    SubMean(n).i = SubMean(n).i./SubMean(n).n - LkFix;
end

%(ied addition) put the activity levels in the clipboard to be pasted into excel if needed
%CopyToClipboard(Activity, {'index' 'run' 'sweep' '1chan'  '2chan'  '3chan'  '4chan'  '# chan'}, []);

%initialize matrix for copy/paste
M = zeros(length(v), 7+3*length(SubMean));
M(:,1) = DATA.Time;
M(:,2) = v;
M(:,3) = Unitary;
M(:,4) = LkFix;
M(:,5) = Mean.n;   %this will hold the average current
M(:,6) = Mean.i;   %this will hold the average current
M(:,7) = Mean.i./Unitary;  %this will hold the Po = AveCurrent/Unitary
for n=1:length(SubMean)
    M(:,8+3*(n-1)) = SubMean(n).n;   %this will hold the average current
    M(:,9+3*(n-1)) = SubMean(n).i;   %this will hold the average current
    M(:,10+3*(n-1)) = SubMean(n).i./Unitary;  %this will hold the Po = AveCurrent/Unitary
end

strColHeaders = {'t' 'v' 'Unitary' 'LkFix' 'n' 'Iave' 'Po'};
for n=1:length(SubMean)
    strColHeaders = [strColHeaders {[num2str(n) 'n'] [num2str(n) 'Iave'] [num2str(n) 'Po']}];
end
xlswrite(xlsFile, strColHeaders, ['FitCell' num2str(CellNum)], 'A30');
xlswrite(xlsFile, M, ['FitCell' num2str(CellNum)], 'A31');

%ied addition: add a column for # channels determined for each trace
NumChanTrace=Activity(:,8);
xlswrite(xlsFile, NumChanTrace, ['SwpCell' num2str(CellNum)],'W10');

set(gcf, 'pointer', 'arrow');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Menu_SCRFinalAvg
global SCSTEP;

Cell = [];
bDone = 0;
k = 0;
h = waitbar(0);

[Filename, Pathname] = uigetfile('*.xls;*.xlsx', 'Choose the excel spreadsheet where you saved your cell sweep analysis'); % user to choose file
if Filename==0
    return;
end
xlsFile = [Pathname  Filename];


[typ, desc] = xlsfinfo(xlsFile);
SwpCellIndex = strmatch('FitCell', desc);
for m=1:length(SwpCellIndex);
    SwpCellNum{m} = desc(SwpCellIndex(m));
    CellNumTemp = char(SwpCellNum{m});
    CellNum(m) = str2num(CellNumTemp(8:end));
end


while ~bDone
    k = k+1; 
    try
        %SCRAMP.cell = k;
        %ied addition: add an if statement so that bad cells are not run
        %through RecalculateCellAverage
        Cell(k).GoodCell = xlsread(xlsFile, ['FitCell' num2str(CellNum(k))], 'B21');
        %Cell(k).version = xlsread(xlsFile, ['FitCell' CellNum(k,:)], 'B22');
        if Cell(k).GoodCell;
            
            close(h);
            UpdateBox;
            h = waitbar(k/10, ['started analysis of cell # ' num2str(k)]);
%             if Cell(k).version
%                 [M, g, Vs, ZF, GoodCell] = Menu_RecalculateCellAverageMRT;
%             else
%             [M, g, Vs, ZF, GoodCell] = Menu_RecalculateCellAverage;
%             end
Params = xlsread(xlsFile, ['FitCell' num2str(CellNum(k))], 'B10:B20');
AvgData = xlsread(xlsFile, ['FitCell' num2str(CellNum(k))], 'A31:F8000');

            Cell(k).t  = AvgData(:,1);
            Cell(k).v  = AvgData(:,2);
            Cell(k).i  = AvgData(:,6);
            Cell(k).g  = Params(2);
            Cell(k).Vs = Params(3);
            Cell(k).ZF = Params(4);
            %Cell(k).GoodCell = GoodCell;
            
        end
    catch
        bDone = 1;
    end
end

% SCRAMP.cell = prevCell;
% UpdateBox;

%NOTE: all cells must have identical v -- i.e. same Vramp and Dramp
v = [];
for k=1:length(Cell)
    if Cell(k).GoodCell 
        if isempty(v)
            v = Cell(k).v;
            t = Cell(k).t;
        elseif ~all(Cell(k).v == v) || ~all(Cell(k).t == t)
            waitfor(errordlg(['All cells must have identical Vramp and Dramp, check cell#' num2str(k)]));
            return;
        end
    end
end
if isempty(v)
    waitfor(errordlg('All cells are marked as bad'));
    return;
end

%Find the average Vs, g, ZF
Vs = 0;
g  = 0;  %these should be the same for all cells, . . but just to be safe
ZF = 0;  %these should be the same for all cells, . . but just to be safe
N  = 0;
minVs = inf;
maxVs = -inf;
for k=1:length(Cell)
    if Cell(k).GoodCell
        minVs = min(minVs, Cell(k).Vs);
        maxVs = max(maxVs, Cell(k).Vs);
        Vs = Vs + Cell(k).Vs;
        g = g  + Cell(k).g;
        ZF = ZF + Cell(k).ZF;
        N = N + 1;
    end
end
Vs = Vs/N;
g  = g/N;
ZF = ZF/N;

%Next we average the current, and we correct for shifts in Vs
i = v*0;
isquare = i;     %dty adds variable for SD calc
n = v*0;
dv = v(2)-v(1);  %sampling interval
Imax = length(v);
for k=1:length(Cell)
    if Cell(k).GoodCell
        deltaI = round((Vs - Cell(k).Vs)/dv);  %#of sample points to shift cell
        Iave  = max(1,1+deltaI):min(Imax,Imax+deltaI);  %ave indices of overlap
        Icell = max(1,1-deltaI):min(Imax,Imax-deltaI);  %cell indices of overlap

        %running sum
        i(Iave) = i(Iave) + Cell(k).i(Icell);
        isquare(Iave) = isquare(Iave) + (Cell(k).i(Icell)).^2;    %dty add for SD calc
        n(Iave) = n(Iave) + 1;
    end
end
i = i./n;  %convert to mean
isquare = isquare./n;  %dty convert to mean var en route to SD
ivariance = isquare - i.^2; %dty convert to mean var en route to SD
iSD = ivariance.^(1/2); %dty convert to mean var en route to SD

%Unitary current - GHK
Unitary = v * 0;  %initialize
tmpV = v - Vs;
I = find(abs(tmpV)/ZF>.01);
Unitary(I)  = -g*tmpV(I).*exp(-tmpV(I)/ZF)./(1 - exp(-tmpV(I)/ZF));  %traditional eqn
I = find(abs(tmpV)/ZF<=.01);
Unitary(I)  = -g*tmpV(I).*(1 - tmpV(I)/ZF)./(tmpV(I)/ZF);  %linearized eqn near zero


%now write data to xls 
M = zeros(length(v), 6);
M(:,1) = t;
M(:,2) = v;
M(:,3) = Unitary;
M(:,4) = n;   %this will hold the average current
M(:,5) = i;   %this will hold the average current
M(:,6) = i./Unitary;  %this will hold the Po = AveCurrent/Unitary
M(:,7) = abs(iSD./Unitary); %dty SD of Po

strColHeaders = {'t' 'v' 'Unitary' 'N' 'Iave' 'Po' 'SD Po'};        %dty adds SD Po dump
xlswrite(xlsFile, strColHeaders, 'FinalFit', 'A30');
xlswrite(xlsFile, M, 'FinalFit', 'A31');
xlswrite(xlsFile, [g; Vs; ZF], 'FinalFit', 'B10:B12');

close(h)
waitfor(helpdlg('Analysis is complete!'));
%% temp
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [M, g, Vs, ZF, GoodCell] = Menu_ActiveRampCellAvg
        global SCSTEP;


        nSel = get(SCSTEP.Box, 'value');
        set(gcf, 'pointer', 'watch'); drawnow;

        %read the cell-level parameters
        %waitfor(errordlg('This script is not written yet'));

        [Filename, Pathname] = uigetfile('*.xls;*.xlsx', 'Choose the excel spreadsheet to save your data'); % user to choose file
        if Filename==0
            return;
        end
        xlsFile = [Pathname  Filename];

    ActivFiltHz = 2; %should make these editable
    NL          = .1;
    ActVR       = [-100 45];
    GoodCell    = 1;
    OneCh = 'A(1)>.015 && A(2)<.001';
    TwoCh =  'A(2)>.001 && A(3)<.001';
    ThreeCh = 'A(3)>.001 && A(4)<.001';

    %read the sweep-level parameters
    

    % LeakData = LeakData(:,5:end);


    %ManChan = LeakData(:,20);

  
    h = waitbar(0,'analyzing cell, please wait');
    for k=1:length(nSel) %should really combine all above into one for loop, but this is okay for now
        DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(k)});
        ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
        swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
        CellNum = DATA(1).CellNum;
        CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
        Gain = num2str(DATA(1).StimParams.Gain);
       waitbar(k/(length(nSel)));

        %read in some parameter values from data and analysis files
        try
            NumCh = ANALYSIS.(CellNumString).NumCh;
            g = ANALYSIS.(CellNumString).g;
            Vs = ANALYSIS.(CellNumString).Vs;
        catch
            NumCh = 1;
            g = 0;
            Vs = 0;
        end
        ZF    = 12;
        Construct = DATA(1).XFect;
        RI = 0;%DATA(1).StimParams.RI;
        VStep = [];
        FiltHz(k) = swANALYSIS.FiltHz;
        XMin = swANALYSIS.XMin;
        XMax = swANALYSIS.XMax;
        Tau = swANALYSIS.Tau;
        Amp = swANALYSIS.Amp;
        m = swANALYSIS.m;
        b = swANALYSIS.b;
        swOffset = swANALYSIS.swOffset;
        lkOffset = swANALYSIS.lkOffset;
        SF = [];
        GoodBad = swANALYSIS.GoodBad;
        Blank = swANALYSIS.Blank;
        AMin = swANALYSIS.AMin;
        AMax = swANALYSIS.AMax;
        GoodLeak = swANALYSIS.GoodLeak;
        

        v = DATA.StimWaveform;
        iRaw = DATA.AcqWaveform;

        if k==1
            %some temporary variables
            MasterV = v;
            Mean.i = 0*v;
            Mean.n = 0*v;
            if NumCh==1
                SubMean = [];
            else
                for n=1:NumCh
                    SubMean(n).i         = 0*v;
                    SubMean(n).n         = 0*v;
                end
            end

            %calculate GVT fits
            Unitary = v * 0;  %initialize
            tmpV = v - Vs;
            I = find(abs(tmpV)/ZF>.01);
            Unitary(I)  = -g*tmpV(I).*exp(-tmpV(I)/ZF)./(1 - exp(-tmpV(I)/ZF));  %traditional eqn
            I = find(abs(tmpV)/ZF<=.01);
            Unitary(I)  = -g*tmpV(I).*(1 - tmpV(I)/ZF)./(tmpV(I)/ZF);  %linearized eqn near zero

            %next, create some variables that are useful for activity determination
            I = find( v>=ActVR(1) & v <= ActVR(2) );  %limit our activity threshold over some voltage range
            UnitaryClip = Unitary(I);
            ScaledNoise = -NL./UnitaryClip;

            %         also, the leak-fix
            %          if FitEnable
            %              tmp = polyval(data(end-2:-1:1), v);
            %              tmp(v<FitX) = 0;
            %              LkFix = tmp;
            %          else
            LkFix = v*0;;
            %          end
        elseif length(MasterV) ~= length(v) || any(MasterV ~= v)
            err = 'All sweeps in a cell must have the same voltage range';
            waitfor(errordlg(err));
            error(err);
        end

        %skip if this sweep is marked bad
        if ~GoodBad
            continue;
        end

        %calculate and subtract leak

        smoothleak = 0;
        for n=1:(length(XMin))
            ilk = Amp(n)*exp(-(Tau(n))*v);
            ilk(v<XMin(n))=0;
            ilk(v>XMax(n))=0;
            smoothleak = smoothleak + ilk;
        end
        try
            LinearFit = m*v + b;
            smoothleak = smoothleak + LinearFit;
        end
        try
            for n=1:(length(AMin));
                alk = iRaw-smoothleak;
                alk(v<AMin(n))=0;
                alk(v>AMax(n))=0;
                smoothleak = smoothleak + alk;
            end
        end


        % iLk = m(k)*v + b(k) + Amp1(k)*exp(-tau1(k)*v)+ Amp2(k)*exp(-tau2(k)*v) + Amp3(k)*exp(-tau3(k)*v);
        iRaw = iRaw - smoothleak;
        iRaw = LowpassFilter(DATA.Time, iRaw, FiltHz(k));

        %next calculate the "activity" of this sweep, and decide if it has 1,2,3 channels active

        ScaledTrace = iRaw(I)./Unitary(I);
        if ActivFiltHz
            ScaledTrace = LowpassFilter(v(I), ScaledTrace, ActivFiltHz);
        end
        for n=1:NumCh
            %activity at each timepoint is zero if lower than prev level, 1 if higher than current level, and linearly 0 to 1 if between
            Activ = (ScaledTrace-ScaledNoise-n+1);  %first subtract the floor
            Activ(Activ<0) = 0;                     %clean up anything that dropped below the floor
            Activ = Activ./(1-ScaledNoise);       %now scale up the rest
            Activ(Activ>1 | Activ<0) = 1;           %and clean up again, note, the <0 stuff matters after the noise levels cross
            TraceActivity(n) =  mean(Activ);
        end
        A = [TraceActivity 0 0 0 0]; %we create the param "A", and eval the user-given code for each level
        if NumCh>=1
            if ischar(OneCh)
                YesNo(1) = eval(OneCh);
            else
                YesNo(1) = OneCh;
            end
        end
        if NumCh>=2
            if ischar(TwoCh)
                YesNo(2) = eval(TwoCh);
            else
                YesNo(2) = TwoCh;
            end
        end
        if NumCh>=3
            if ischar(ThreeCh)
                YesNo(3) = eval(ThreeCh);
            else
                YesNo(3) = ThreeCh;
            end
        end
        if NumCh>=4
            YesNo(4:NumCh) = 0;
        end
        debugYN(k) = YesNo(1);


        %just add a count of the number of channels

        NumberOfChannels=0;
        for n=1:NumCh
            if YesNo(n);
                NumberOfChannels=n;
            end
        end

        %ied - allow a manual overide of the number of channels - careful, you
        %must have zeroes in column X when this is active
        %disp('new sweep');
        AdjChanNum=0;
        %     if ManChan(k)~=0
        %         %disp('manual');
        %         AdjChanNum=ManChan(k);
        %     else
        for n=1:NumCh
            %disp([n YesNo(n)])
            if YesNo(n)
                AdjChanNum=n;
            end
        end
        %     end
        %     %NumberOfChannels
        %     if AdjChanNum>=4
        %         AdjChanNum=0;
        %     end

        % (ied addition) fill in a matrix to be pasted to exel for
        % troubleshooting purposes
        %     Activity(k,1)=k; %fill in a matrix with the activity levels for each sweep
        %     Activity(k,4:7)=A(1:4);
        %     Activity(k,8)=NumberOfChannels;

        %ied change
        %finally, add this sweep to the running sums, accordingly
        Vmin(k) = -100;
        Vmax(k) = 100; %should adjust code below to remove Vmin and max, they are obsolete w/ the a tool
        if AdjChanNum ~=0
            nc=AdjChanNum;
            try
                Mean.i(v>=Vmin(k)&v<=Vmax(k))  =  Mean.i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/nc;
                Mean.n(v>=Vmin(k)&v<=Vmax(k))  =  Mean.n(v>=Vmin(k)&v<=Vmax(k))  +  1;

            catch
                waitfor(errordlg(['You probably have sweeps with different sampling intervals -- this is not allowed for the same cell . . .sorry ' lasterr]));
                rethrow(lasterror);
            end

            if ~isempty(SubMean)
                SubMean(nc).i(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(nc).i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/nc;
                SubMean(nc).n(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(nc).n(v>=Vmin(k)&v<=Vmax(k))  +  1;
            end
        end
    end

    %divide by n to get average, also do the LkFix
    Mean.i = Mean.i./Mean.n - LkFix;
    for n=1:length(SubMean)
        SubMean(n).i = SubMean(n).i./SubMean(n).n - LkFix;
    end

    %(ied addition) put the activity levels in the clipboard to be pasted into excel if needed
    %CopyToClipboard(Activity, {'index' 'run' 'sweep' '1chan'  '2chan'  '3chan'  '4chan'  '# chan'}, []);

    %initialize matrix for copy/paste
    M = zeros(length(v), 7+3*length(SubMean));
    M(:,1) = DATA.Time;
    M(:,2) = v;
    M(:,3) = Unitary;
    M(:,4) = LkFix;
    M(:,5) = Mean.n;   %this will hold the average current
    M(:,6) = Mean.i;   %this will hold the average current
    M(:,7) = Mean.i./Unitary;  %this will hold the Po = AveCurrent/Unitary
    for n=1:length(SubMean)
        M(:,8+3*(n-1)) = SubMean(n).n;   %this will hold the average current
        M(:,9+3*(n-1)) = SubMean(n).i;   %this will hold the average current
        M(:,10+3*(n-1)) = SubMean(n).i./Unitary;  %this will hold the Po = AveCurrent/Unitary
    end

    strColHeaders = {'t' 'v' 'Unitary' 'LkFix' 'n' 'Iave' 'Po'};
    for n=1:length(SubMean)
        strColHeaders = [strColHeaders {[num2str(n) 'n'] [num2str(n) 'Iave'] [num2str(n) 'Po']}];
    end
    N = {'NumCh'; 'g';  'Vs'; 'ZF'; 'ActivFiltHz';  'NL'; 'ActVR1'; 'ActVR2'; 'OneCh'; 'TwoCh'; 'ThreeCh'; 'GoodCell'};
    %make this real numbers
    O ={num2str(NumCh); num2str(g); num2str(Vs); '12'; '2'; '0.1'; '-100'; '45'; 'A(1)>.015 && A(2)<.001'; 'A(2)>.001 && A(3)<.001'; 'A(3)>.001 && A(4)<.001'; '1'};

    xlswrite(xlsFile, strColHeaders, ['FitCell' num2str(CellNum)], 'A30');
    xlswrite(xlsFile, M, ['FitCell' num2str(CellNum)], 'A31');
    xlswrite(xlsFile, N,['FitCell' num2str(CellNum)], 'A10');
    xlswrite(xlsFile, O,['FitCell' num2str(CellNum)], 'B10');

    %ied addition: add a column for # channels determined for each trace
    % NumChanTrace=Activity(:,8);
    % xlswrite(xlsFile, NumChanTrace, ['SwpCell' num2str(CellNum)],'W11');
close(h);
   % waitfor(helpdlg('Analysis is complete!'));
    set(gcf, 'pointer', 'arrow');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [M, g, Vs, ZF, GoodCell] = Menu_RampCellAvgBlank
            global SCSTEP;


            nSel = get(SCSTEP.Box, 'value');
            set(gcf, 'pointer', 'watch'); drawnow;

            %read the cell-level parameters
            %waitfor(errordlg('This script is not written yet'));

            [Filename, Pathname] = uigetfile('*.xls;*.xlsx', 'Choose the excel spreadsheet to save your data'); % user to choose file
            if Filename==0
                return;
            end
            xlsFile = [Pathname  Filename];

            ActivFiltHz = 2; %should make these editable
            NL          = .1;
            ActVR       = [-100 45];
            GoodCell    = 1;
            OneCh = 'A(1)>.015 && A(2)<.001';
            TwoCh =  'A(2)>.001 && A(3)<.001';
            ThreeCh = 'A(3)>.001 && A(4)<.001';

            %read the sweep-level parameters


            % LeakData = LeakData(:,5:end);


            %ManChan = LeakData(:,20);
            waitfor(helpdlg('Make sure your channel number is set correctly, it will be used for every sweep'));

            h = waitbar(0,'analyzing cell, please wait');
            for k=1:length(nSel) %should really combine all above into one for loop, but this is okay for now
                DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(k)});
                ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                CellNum = DATA(1).CellNum;
                CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
                Gain = num2str(DATA(1).StimParams.Gain);
                waitbar((k-1)/(length(nSel)));

                %read in some parameter values from data and analysis files
                try
                    NumCh = ANALYSIS.(CellNumString).NumCh;
                    g = ANALYSIS.(CellNumString).g;
                    Vs = ANALYSIS.(CellNumString).Vs;
                catch
                    NumCh = 1;
                    g = 0;
                    Vs = 0;
                end
                ZF    = 12;
                Construct = DATA(1).XFect;
                RI = 0;%DATA(1).StimParams.RI;
                VStep = [];
                FiltHz(k) = swANALYSIS.FiltHz;
                XMin = swANALYSIS.XMin;
                XMax = swANALYSIS.XMax;
                Tau = swANALYSIS.Tau;
                Amp = swANALYSIS.Amp;
                m = swANALYSIS.m;
                b = swANALYSIS.b;
                swOffset = swANALYSIS.swOffset;
                lkOffset = swANALYSIS.lkOffset;
                SF = [];
                GoodBad = swANALYSIS.GoodBad;
                Blank = swANALYSIS.Blank;
                AMin = swANALYSIS.AMin;
                AMax = swANALYSIS.AMax;
                GoodLeak = swANALYSIS.GoodLeak;


                v = DATA.StimWaveform;
                iRaw = DATA.AcqWaveform;

                if k==1
                    %some temporary variables
                    MasterV = v;
                    Mean.i = 0*v;
                    Mean.n = 0*v;
                    Mean.idealpo = 0*v;
                    if NumCh==1
                        SubMean = [];
                    else
                        for n=1:NumCh
                            SubMean(n).i         = 0*v;
                            SubMean(n).n         = 0*v;
                        end
                    end

                    %calculate GVT fits
                    Unitary = v * 0;  %initialize
                    tmpV = v - Vs;
                    I = find(abs(tmpV)/ZF>.01);
                    Unitary(I)  = -g*tmpV(I).*exp(-tmpV(I)/ZF)./(1 - exp(-tmpV(I)/ZF));  %traditional eqn
                    I = find(abs(tmpV)/ZF<=.01);
                    Unitary(I)  = -g*tmpV(I).*(1 - tmpV(I)/ZF)./(tmpV(I)/ZF);  %linearized eqn near zero

                    %next, create some variables that are useful for activity determination
                    I = find( v>=ActVR(1) & v <= ActVR(2) );  %limit our activity threshold over some voltage range
                    UnitaryClip = Unitary(I);
                    ScaledNoise = -NL./UnitaryClip;

                    %         also, the leak-fix
                    %          if FitEnable
                    %              tmp = polyval(data(end-2:-1:1), v);
                    %              tmp(v<FitX) = 0;
                    %              LkFix = tmp;
                    %          else
                    LkFix = v*0;;
                    %          end
                elseif length(MasterV) ~= length(v) || any(MasterV ~= v)
                    err = 'All sweeps in a cell must have the same voltage range';
                    waitfor(errordlg(err));
                    error(err);
                end

                %skip if this sweep is marked bad
                if ~GoodBad
                    continue;
                end

                %calculate and subtract leak

                smoothleak = 0;
                for n=1:(length(XMin))
                    ilk = Amp(n)*exp(-(Tau(n))*v);
                    ilk(v<XMin(n))=0;
                    ilk(v>XMax(n))=0;
                    smoothleak = smoothleak + ilk;
                end
                try
                    LinearFit = m*v + b;
                    smoothleak = smoothleak + LinearFit;
                end
                try
                    for n=1:(length(AMin));
                        alk = iRaw-smoothleak;
                        alk(v<AMin(n))=0;
                        alk(v>AMax(n))=0;
                        smoothleak = smoothleak + alk;
                    end
                end


                % iLk = m(k)*v + b(k) + Amp1(k)*exp(-tau1(k)*v)+ Amp2(k)*exp(-tau2(k)*v) + Amp3(k)*exp(-tau3(k)*v);
                iRaw = iRaw - smoothleak;
                iRaw = LowpassFilter(DATA.Time, iRaw, FiltHz(k));

                %next calculate the "activity" of this sweep, and decide if it has 1,2,3 channels active

                ScaledTrace = iRaw(I)./Unitary(I);
                
                %idealized averages;
                idealized = round(iRaw./Unitary);
                idealized = idealized.*(idealized>0);
                
                
                if ActivFiltHz
                    ScaledTrace = LowpassFilter(v(I), ScaledTrace, ActivFiltHz);
                end
                for n=1:NumCh
                    %activity at each timepoint is zero if lower than prev level, 1 if higher than current level, and linearly 0 to 1 if between
                    Activ = (ScaledTrace-ScaledNoise-n+1);  %first subtract the floor
                    Activ(Activ<0) = 0;                     %clean up anything that dropped below the floor
                    Activ = Activ./(1-ScaledNoise);       %now scale up the rest
                    Activ(Activ>1 | Activ<0) = 1;           %and clean up again, note, the <0 stuff matters after the noise levels cross
                    TraceActivity(n) =  mean(Activ);
                end
                A = [TraceActivity 0 0 0 0]; %we create the param "A", and eval the user-given code for each level
                if NumCh>=1
                    if ischar(OneCh)
                        YesNo(1) = eval(OneCh);
                    else
                        YesNo(1) = OneCh;
                    end
                end
                if NumCh>=2
                    if ischar(TwoCh)
                        YesNo(2) = eval(TwoCh);
                    else
                        YesNo(2) = TwoCh;
                    end
                end
                if NumCh>=3
                    if ischar(ThreeCh)
                        YesNo(3) = eval(ThreeCh);
                    else
                        YesNo(3) = ThreeCh;
                    end
                end
                if NumCh>=4
                    YesNo(4:NumCh) = 0;
                end
                debugYN(k) = YesNo(1);


                %just add a count of the number of channels

                NumberOfChannels=0;
                for n=1:NumCh
                    if YesNo(n);
                        NumberOfChannels=n;
                    end
                end


                Vmin(k) = -100;
                Vmax(k) = 100; %should adjust code below to remove Vmin and max, they are obsolete w/ the a tool

                nc=NumCh;
                try
                    Mean.i(v>=Vmin(k)&v<=Vmax(k))  =  Mean.i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/nc;
                    Mean.n(v>=Vmin(k)&v<=Vmax(k))  =  Mean.n(v>=Vmin(k)&v<=Vmax(k))  +  1;
                    Mean.idealpo(v>=Vmin(k)&v<=Vmax(k)) = Mean.idealpo(v>=Vmin(k)&v<=Vmax(k)) + idealized(v>=Vmin(k)&v<=Vmax(k))/nc;
                    
                catch
                    waitfor(errordlg(['You probably have sweeps with different sampling intervals -- this is not allowed for the same cell . . .sorry ' lasterr]));
                    rethrow(lasterror);
                end

                if ~isempty(SubMean)
                    SubMean(nc).i(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(nc).i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/nc;
                    SubMean(nc).n(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(nc).n(v>=Vmin(k)&v<=Vmax(k))  +  1;
                end
            end


            %divide by n to get average, also do the LkFix
            Mean.i = Mean.i./Mean.n - LkFix;
            for n=1:length(SubMean)
                SubMean(n).i = SubMean(n).i./SubMean(n).n - LkFix;
            end
            Mean.idealpo = Mean.idealpo./Mean.n;
            %(ied addition) put the activity levels in the clipboard to be pasted into excel if needed
            %CopyToClipboard(Activity, {'index' 'run' 'sweep' '1chan'  '2chan'  '3chan'  '4chan'  '# chan'}, []);

            %initialize matrix for copy/paste
            M = zeros(length(v), 8+3*length(SubMean));
            M(:,1) = DATA.Time;
            M(:,2) = v;
            M(:,3) = Unitary;
            M(:,4) = LkFix;
            M(:,5) = Mean.n;   %this will hold the average current
            M(:,6) = Mean.i;   %this will hold the average current
            M(:,7) = Mean.i./Unitary;  %this will hold the Po = AveCurrent/Unitary
            for n=1:length(SubMean)
                M(:,8+3*(n-1)) = SubMean(n).n;   %this will hold the average current
                M(:,9+3*(n-1)) = SubMean(n).i;   %this will hold the average current
                M(:,10+3*(n-1)) = SubMean(n).i./Unitary;  %this will hold the Po = AveCurrent/Unitary
            end
            M(:,end) = Mean.idealpo;

            strColHeaders = {'t' 'v' 'Unitary' 'LkFix' 'n' 'Iave' 'Po'};
            for n=1:length(SubMean)
                strColHeaders = [strColHeaders {[num2str(n) 'n'] [num2str(n) 'Iave'] [num2str(n) 'Po']}];
            end
            N = {'NumCh'; 'g';  'Vs'; 'ZF'; 'ActivFiltHz';  'NL'; 'ActVR1'; 'ActVR2'; 'OneCh'; 'TwoCh'; 'ThreeCh'; 'GoodCell'};
            %make this real numbers
            O ={num2str(NumCh); num2str(g); num2str(Vs); '12'; '2'; '0.1'; '-100'; '45'; 'A(1)>.015 && A(2)<.001'; 'A(2)>.001 && A(3)<.001'; 'A(3)>.001 && A(4)<.001'; '1'};

            xlswrite(xlsFile, strColHeaders, ['FitCell' num2str(CellNum)], 'A30');
            xlswrite(xlsFile, M, ['FitCell' num2str(CellNum)], 'A31');
            xlswrite(xlsFile, N,['FitCell' num2str(CellNum)], 'A10');
            xlswrite(xlsFile, O,['FitCell' num2str(CellNum)], 'B10');

            %ied addition: add a column for # channels determined for each trace
            % NumChanTrace=Activity(:,8);
            % xlswrite(xlsFile, NumChanTrace, ['SwpCell' num2str(CellNum)],'W11');
            close(h);
            % waitfor(helpdlg('Analysis is complete!'));
            set(gcf, 'pointer', 'arrow');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     

%% General Button functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Bad
            global SCSTEP;

            set(gcf, 'pointer', 'watch'); drawnow;
            nSel = get(SCSTEP.Box, 'value');

            for k=1:length(nSel)
                ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                S.(SCSTEP.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                S.(SCSTEP.RunSwp{(nSel(k))}).GoodBad = 0;
            end
            save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
            set(gcf, 'pointer', 'arrow');
            UpdateGraphics;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Good
            global SCSTEP;

            set(gcf, 'pointer', 'watch'); drawnow;
            nSel = get(SCSTEP.Box, 'value');

            for k=1:length(nSel)
                ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                S.(SCSTEP.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                S.(SCSTEP.RunSwp{(nSel(k))}).GoodBad = 1;
            end
            save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
            set(gcf, 'pointer', 'arrow');
            UpdateGraphics;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Blank
            global SCSTEP;

            set(gcf, 'pointer', 'watch'); drawnow;
            nSel = get(SCSTEP.Box, 'value');

            for k=1:length(nSel)
                ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                Blank = swANALYSIS.Blank;
                S.(SCSTEP.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                if Blank == 0;
                    S.(SCSTEP.RunSwp{(nSel(k))}).Blank = 1;
                          else
                   S.(SCSTEP.RunSwp{(nSel(k))}).Blank = 0;
                end

            end
            save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
            set(gcf, 'pointer', 'arrow');
            UpdateGraphics;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function StepLk

    global SCSTEP;
    set(gcf, 'pointer', 'watch'); drawnow;
    nSel = get(SCSTEP.Box, 'value');
    if length(nSel)>1
         waitfor(errordlg('you may only have one sweep selected for leak selection'));
    else
        DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel});
        if (findstr(DATA(1).StimName, 'Ramp'))
            waitfor(errordlg('leaks are not recorded for ramps'));
        else
            Dstep = DATA(1).StimParams.Dstep;
            t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms
            iRaw = DATA(1).AcqWaveform - SCSTEP.swOffset;
            %avgLk  = (mean(DATA(2).AcqWaveform,3) - SCSTEP.lkOffset)*SCSTEP.SF;
            GoodLeak = ones(1,length(DATA(2).AcqWaveform(1,1,:)));
            LkSum = 0;
            for n=1:length(DATA(2).AcqWaveform(1,1,:))
                iLeak(:,n) = (DATA(2).AcqWaveform(1,:,n) - SCSTEP.lkOffset)*SCSTEP.SF;
                cla; hold on;
                plot(t, iRaw);
                plot(t, iLeak(:,n),'r');
                text(-30, 1, ['leak' num2str(n)]);
                GL = (questdlg('Keep Leak?', 'GoodLeaks', 'Yes', 'No ', 'Yes'));
                if GL=='No ';
                    GoodLeak(n) = 0;
                else
                LkSum = LkSum + iLeak(:,n);
                end
            end
             avgLk =LkSum/sum(GoodLeak); 
            cla; hold on;
            plot(t, iRaw);
            plot(t, avgLk,'k');
            text(.7, .9, 'average leak', 'units', 'normalized', 'fontsize', 18);
            waitforbuttonpress
        end

        axis auto;
        ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
        S.(SCSTEP.RunSwp{(nSel)})= ANALYSIS.(SCSTEP.RunSwp{nSel});
        S.(SCSTEP.RunSwp{(nSel)}).GoodLeak = GoodLeak;
        save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
    end
        set(gcf, 'pointer', 'arrow');
        UpdateGraphics;
        
%% Fit Button functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Atool

        global SCSTEP;
        n = 1 + length(SCSTEP.AMin);
        addAtool(n);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function addAtool(n);
        global SCSTEP;
        set(gcf, 'pointer', 'watch'); drawnow;
        nSel = get(SCSTEP.Box, 'value');

        Message = text(.7, .9,'select X range to zero', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        [xmn ytemp] = ginput(1);
        [xmx ytemp] = ginput(1);
        ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
        S.(SCSTEP.RunSwp{(nSel)})= ANALYSIS.(SCSTEP.RunSwp{nSel});
        S.(SCSTEP.RunSwp{(nSel)}).AMin(n) = xmn;
        S.(SCSTEP.RunSwp{(nSel)}).AMax(n) = xmx;
        save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
        set(gcf, 'pointer', 'arrow');      
        delete(Message);
        UpdateGraphics;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function AddLinFit
        global SCSTEP;
        Menu_FreezeX;
        Menu_FreezeY;
        
        set(gcf, 'pointer', 'watch'); drawnow;
        nSel = get(SCSTEP.Box, 'value');
        if length(nSel)>1
            waitfor(errordlg('you may only have one sweep selected for leak selection'));
        else

        range = get(gca, 'xLim');
        xLinFit = [range(1):(range(2)-range(1))/100:range(2)];

        Message = text(.7, .9,'select 2 points to fit', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        [x1 y1]=ginput(1);
        [x2 y2]=ginput(1);
        delete(Message);

        Y = [y1 ; y2];
        coef = [ x1  1; x2  1];
        lsoln = coef\Y;
        m = lsoln(1);
        b = lsoln(2);
        FitLine = m*xLinFit + b;

        plot(xLinFit, FitLine, 'r');

        waitforbuttonpress

        set(SCSTEP.m.Edit, 'string', num2str(m));
        set(SCSTEP.b.Edit, 'string', num2str(b));
        ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
        S.(SCSTEP.RunSwp{(nSel)})= ANALYSIS.(SCSTEP.RunSwp{nSel});
        S.(SCSTEP.RunSwp{(nSel)}).m = m;
        S.(SCSTEP.RunSwp{(nSel)}).b = b;
        save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
        end
        set(gcf, 'pointer', 'arrow');
        UpdateGraphics;
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function AddExpFit

        global SCSTEP;
        nSel = get(SCSTEP.Box, 'value');
        if length(nSel)>1
            waitfor(errordlg('you may only have one sweep selected'));
        else
        n = 1 + length(str2num(get(SCSTEP.Tau.Edit, 'string')));        
        ExpFitMBJ(n);
        
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ExpFit(n)

       global SCSTEP;
        ylim('manual');
        xlim('manual');
        axis on;
        set(gcf, 'pointer', 'watch'); drawnow;
        nSel = get(SCSTEP.Box, 'value');

        DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{(nSel)});
        ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
        swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{(nSel)});
        xmin = swANALYSIS.XMin;
        xmax = swANALYSIS.XMax;

        Message = text(.7, .9,'select X min', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');        
        [xmn ytemp] = ginput(1);
        set(Message, 'string','select X max')
%         Message = text(.7, .9,'select X max', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        [xmx ytemp] = ginput(1);
        xmin(n) = xmn;
        xmax(n) = xmx;
        set(SCSTEP.XMin.Edit, 'string', num2str(xmin));
        set(SCSTEP.XMax.Edit, 'string', num2str(xmax));
        delete(Message);                
        
        % downsample t to estimate exp
        SCSTEP.tExpFit = [xmin(n):(xmax(n)-xmin(n))/100:xmax(n)];

        Message = text(.7, .9,'select 2 points for initial fit', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        [x1 y1]=ginput(1);
        [x2 y2]=ginput(1);
        delete(Message);

        y = [log(y1); log(y2)];
        A = [1 -x1; 1 -x2];
        soln = real(A\y);
        tau = soln(2); 
        soln(1);
        Amp = exp(soln(1));
        FitE = Amp*exp(-tau*SCSTEP.tExpFit);

        SCSTEP.CP = [0 0];
        SCSTEP.TauHold = swANALYSIS.Tau;
        SCSTEP.TauHold(n) = tau;
        SCSTEP.AmpHold = swANALYSIS.Amp;
        SCSTEP.AmpHold(n) = Amp;
        SCSTEP.expline = line('xdata',SCSTEP.tExpFit,'ydata',FitE,'color','g');

        Message = text(.7, .9,'drag fit to adjust', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        
        waitforbuttonpress
        set(gcf,'windowbuttonmotionfcn' , ['UpdateExp(' num2str(n) ')']);
        %set(gcf, 'windowbuttondownfcn', ['set(gcf,''windowbuttonmotionfcn'' , ''UpdateExp('  num2str(n)     ')'' )']);
        set(gcf, 'windowbuttonupfcn', 'ExpDone');
        
        waitforbuttonpress;
        axis auto;
        UpdateGraphics;

    function ExpFitMBJ(n)
        % Modified Exp fit for steps ... basically adds a delay parameter
        % to account for different kinetics in steps
        global SCSTEP;
        ylim('manual');
        xlim('manual');
        axis on;
        set(gcf, 'pointer', 'watch'); drawnow;
        nSel = get(SCSTEP.Box, 'value');

        DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{(nSel)});
        ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
        swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{(nSel)});
        if ~isfield(swANALYSIS,'Delay')
            swANALYSIS.Delay = [];
        end
        xmin = swANALYSIS.XMin;
        xmax = swANALYSIS.XMax;
        if strcmp(DATA(1).StimName,'StepWaveform')
        Message = text(.7, .9,'SelectPulse', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');        
        
        %Message = text(.7, .9,'select X min', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');        
        [xmn ytemp] = ginput(1);
        %set(Message, 'string','select X max')
%         Message = text(.7, .9,'select X max', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        %[xmx ytemp] = ginput(1);
%         xmin(n) = xmn;
%         xmax(n) = xmx;         
        
        TPulses= [0 cumsum(DATA(1).StimParams.Dstep)];
        Pulse2Fit = TPulses>xmn;
        PulseNum = find(Pulse2Fit,1);
        xmin(n) = TPulses(PulseNum-1);
        xmax(n) = TPulses(PulseNum);
        Delay = xmin(n);
        else
           Message = text(.7, .9,'select X min', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');        
           [xmn ytemp] = ginput(1);
           set(Message, 'string','select X max')
%            Message = text(.7, .9,'select X max', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
           [xmx ytemp] = ginput(1);
           xmin(n) = xmn;
           xmax(n) = xmx;   
           Delay =0;
        end
        delete(Message);
        set(SCSTEP.XMin.Edit, 'string', num2str(xmin));
        set(SCSTEP.XMax.Edit, 'string', num2str(xmax));
        
        
        % downsample t to estimate exp
        SCSTEP.tExpFit = [xmin(n):(xmax(n)-xmin(n))/100:xmax(n)];

        Message = text(.7, .9,'select 2 points for initial fit', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        [x1 y1]=ginput(1);
        [x2 y2]=ginput(1);
        delete(Message);

        y = [log(y1); log(y2)];
        A = [1,  -(x1-Delay); 1, - (x2-Delay)];
        soln = real(A\y);
        tau = soln(2);         
        Amp = exp(soln(1));
        FitE = Amp*exp(-tau*(SCSTEP.tExpFit-Delay));

        SCSTEP.CP = [0 0];
        SCSTEP.TauHold = swANALYSIS.Tau;
        SCSTEP.TauHold(n) = tau;
        SCSTEP.AmpHold = swANALYSIS.Amp;
        SCSTEP.AmpHold(n) = Amp;
        SCSTEP.DelayHold = swANALYSIS.Delay;
        SCSTEP.DelayHold(n) = Delay;
        SCSTEP.expline = line('xdata',SCSTEP.tExpFit,'ydata',FitE,'color','g');

        Message = text(.7, .9,'drag fit to adjust', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        
        waitforbuttonpress
        set(gcf,'windowbuttonmotionfcn' , ['UpdateExp(' num2str(n) ')']);
        %set(gcf, 'windowbuttondownfcn', ['set(gcf,''windowbuttonmotionfcn'' , ''UpdateExp('  num2str(n)     ')'' )']);
        set(gcf, 'windowbuttonupfcn', 'ExpDone');
        
        waitforbuttonpress;
        axis auto;
        UpdateGraphics;
        SCSTEP = rmfield(SCSTEP,'DelayHold');
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ExpDone
        
    global SCSTEP;
        nSel = get(SCSTEP.Box, 'value');
        set(gcf, 'windowbuttonupfcn', '');
        set(gcf, 'windowbuttonmotionfcn', '');
        ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
        S.(SCSTEP.RunSwp{(nSel)})= ANALYSIS.(SCSTEP.RunSwp{nSel});
        S.(SCSTEP.RunSwp{(nSel)}).XMin = str2num(get(SCSTEP.XMin.Edit, 'string'));
        S.(SCSTEP.RunSwp{(nSel)}).XMax = str2num(get(SCSTEP.XMax.Edit, 'string'));
        S.(SCSTEP.RunSwp{(nSel)}).Tau = SCSTEP.TauHold;
        S.(SCSTEP.RunSwp{(nSel)}).Amp = SCSTEP.AmpHold;
        S.(SCSTEP.RunSwp{(nSel)}).Delay = SCSTEP.DelayHold;
        save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function UpdateExp(n);

        global SCSTEP;
        hold on;
        ylim('manual');
        xlim('manual');

        CPnew = get(gcf, 'currentpoint');
        CPold = SCSTEP.CP;
        TauOld = SCSTEP.TauHold(n);
        AmpOld = SCSTEP.AmpHold(n);
        if isfield(SCSTEP,'DelayHold')
            DelayTemp = SCSTEP.DelayHold(n);
        else
            DelayTemp = 0;
        end
        
        if CPold(1) == 0;
            CPold = CPnew;
            TauNew = TauOld;
            AmpNew = AmpOld;
        else
            CPdiff = CPnew - CPold;
            if AmpOld > 0
                AmpNew = (1+CPdiff(2)*5)*AmpOld;
            else
                AmpNew = (1-CPdiff(2)*5)*AmpOld;
            end
            TauNew = (1+CPdiff(1)*5)*TauOld;
            yNew = AmpNew*exp(-TauNew*(SCSTEP.tExpFit-DelayTemp));
        end

        try
            set(SCSTEP.expline, 'xdata', SCSTEP.tExpFit, 'ydata', yNew);
        catch
        end

        SCSTEP.CP = CPnew;
        SCSTEP.TauHold(n) = TauNew;
        SCSTEP.AmpHold(n) = AmpNew;     
        if isfield(SCSTEP,'DelayHold')
            SCSTEP.DelayHold(n) = DelayTemp;
            set(SCSTEP.Delay.Edit, 'string', num2str(real(SCSTEP.DelayHold)));
        end
        set(SCSTEP.Tau.Edit, 'string', num2str(SCSTEP.TauHold));
        set(SCSTEP.Amp.Edit, 'string', num2str(real(SCSTEP.AmpHold)));
               

%% Auto Button functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        function AutoExp
            global SCSTEP;

            set(gcf, 'pointer', 'watch'); drawnow;
            nSel = get(SCSTEP.Box, 'value');
            cla;  hold on;

            % load data and analysis files
            for k=1:length(nSel)
                DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(k)});
                ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                CellNum = DATA(1).CellNum;
                CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
                GoodLeak = swANALYSIS.GoodLeak;
                swOffset = swANALYSIS.swOffset;
                lkOffset = swANALYSIS.lkOffset;
                Tau = swANALYSIS.Tau;
                Amp = swANALYSIS.Amp;

                if (findstr(DATA(1).StimName, 'Ramp'))
                    waitfor(errordlg('This tool only works for step commands'));
                end
                 
                SF = DATA(2).StimParams.LeakSF;
                Dstep = DATA(1).StimParams.Dstep;
                VStep = DATA(1).StimParams.Vstep;
                t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms
                iRaw = DATA(1).AcqWaveform;
                %iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);
                      
                if isempty(GoodLeak)
                    GoodLeak =ones(1,length(DATA(2).AcqWaveform(1,1,:)));
                end
                LkSum = 0;
                for n=1:length(GoodLeak);
                    iLeak(:,n) = DATA(2).AcqWaveform(1,:,n);
                    if GoodLeak(n)==1;
                        LkSum = LkSum + iLeak(:,n);
                    end
                end

                if isempty(GoodLeak)
                    avgLk = mean(DATA(2).AcqWaveform,3);
                else
                    avgLk = LkSum/sum(GoodLeak);
                end

                %zero offset:
                if swANALYSIS.swOffset==0
                    swOffset = mean(iRaw(10:DATA(1).StimParams.PrePoints));
                end
                if swANALYSIS.lkOffset==0
                    lkOffset = mean(avgLk(10:DATA(1).StimParams.PrePoints));
                end
                iRaw = iRaw - swOffset;
                avgLk = avgLk - lkOffset;


                avgLk = avgLk*SF;
                iRawFilt = LowpassFilter(DATA(1).Time, iRaw, 0);

                t1 = find(t>0, 1);
                t2 = find(t>299, 1);
                time = t(t1:t2);
                Leak = avgLk(t1:t2);
                iRawFit = iRawFilt(t1:t2)';
                if get(SCSTEP.FitLeak, 'value')
                    plot(time, Leak);
                    y = Leak;
                else
                    plot(time, iRawFit);
                    y = iRawFit;
                end

                %autofit(TauGuess, AmpGuess, t, avgLk);

                t = time;
                %h = plot(t, y, 'r');

                if get(SCSTEP.UseGuess, 'value')
                    start = Tau;
                else
                    start = [6.4053e-005    0.088143     0.41024      3.1947      3.1112  ];
                end

                % We use an anonymous function to pass additional parameters t, y, h to the
                % output function.


%                 outputFcn = @(x,optimvalues,state) fitoutputfun(x,optimvalues,state,t,y,h);
%                 options = optimset('OutputFcn',outputFcn,'TolX',0.1);
%                 estimated_lambda = fminsearch(@(x)fitfun(x,t,y),start,options);

digits(6);
                estimated_lambda = fminsearch(@(x)fitfun(x,t,y),start);


                for n=1:length(estimated_lambda)
                    XMin(n) = 0;
                    XMax(n) = 300;
                end
                Tau = round(estimated_lambda/0.0001)*0.0001;
                Amp = round(SCSTEP.AmpHold/0.001)*0.001;
                
                S.(SCSTEP.RunSwp{nSel(k)})= ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                S.(SCSTEP.RunSwp{nSel(k)}).XMin = XMin;
                S.(SCSTEP.RunSwp{nSel(k)}).XMax = XMax;
                %S.(SCSTEP.RunSwp{nSel(k)}).Tau = estimated_lambda;
                S.(SCSTEP.RunSwp{nSel(k)}).Tau = Tau;
                %S.(SCSTEP.RunSwp{nSel(k)}).Amp = SCSTEP.AmpHold';
                S.(SCSTEP.RunSwp{nSel(k)}).Amp = Amp';
                save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
            end



            set(gcf, 'pointer', 'arrow');
            UpdateGraphics;
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            function AutoLine
                global SCSTEP;

                set(gcf, 'pointer', 'watch'); drawnow;
                nSel = get(SCSTEP.Box, 'value');
                cla;  hold on;

                % load data and analysis files
                for k=1:length(nSel)
                    DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(k)});
                    ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                    swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                    CellNum = DATA(1).CellNum;
                    CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
                    GoodLeak = swANALYSIS.GoodLeak;
                    swOffset = swANALYSIS.swOffset;
                    lkOffset = swANALYSIS.lkOffset;
                    Tau = swANALYSIS.Tau;
                    Amp = swANALYSIS.Amp;

                    if (findstr(DATA(1).StimName, 'Step'))
                        waitfor(errordlg('This tool only works for Ramp commands'));
                    end

                    %SF = DATA(2).StimParams.LeakSF;
                    Dstep = DATA(1).StimParams.Dstep;
                    VStep = DATA(1).StimParams.Vstep;
                    t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms
                    v = DATA.StimWaveform;
                    iRaw = DATA(1).AcqWaveform;
                    iRaw2 = iRaw;
                    %iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);
                    try
                    iRaw2 = filt2(t,iRaw,50);
                    catch
                        disp('filtering didnt work')
                    end
                    
%                     p0x1 = find(v >= -65, 1);
%                     p0y1  = mean(iRaw2(p0x1-100:p0x1+100));
%                     p0x1  = -65;
%                     p0x2 = find(v >= -40, 1);
%                     p0y2  =  mean(iRaw2(p0x2-100:p0x2+100));
%                     p0x2  = -40;
% 
%                     yl = [p0y1 ; p0y2];
%                     coef = [ p0x1  1; p0x2  1];
%                     lsoln = coef\yl;
%                     m = lsoln(1);
%                     b = lsoln(2);
                    Mask = (v>-55)&(v<-40);
                    FitFcn.V = v(Mask);
                    FitFcn.i = iRaw2(Mask);
                    p = polyfit(FitFcn.V, FitFcn.i,1);
                    m = p(1);
                    b = p(2);
                    set(SCSTEP.m.Edit, 'string', num2str(m));
                    

                    set(SCSTEP.b.Edit, 'string', num2str(b));
                    ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
                    S.(SCSTEP.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
                    S.(SCSTEP.RunSwp{(nSel(k))}).m = m;
                    S.(SCSTEP.RunSwp{(nSel(k))}).b = b;
                    save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
                end
                set(gcf, 'pointer', 'arrow');
                UpdateGraphics;

                
                
                      

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function err = fitfun(lambda,t,y)
    global SCSTEP;
    
    
%FITFUN Used by FITDEMO.
%   FITFUN(lambda,t,y) returns the error between the data and the values
%   computed by the current function of lambda.
%
%   FITFUN assumes a function of the form
%
%     y =  c(1)*exp(-lambda(1)*t) + ... + c(n)*exp(-lambda(n)*t)
%
%   with n linear parameters and n nonlinear parameters.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.8.4.1 $  $Date: 2004/11/29 23:30:50 $

A = zeros(length(t),length(lambda));
for j = 1:length(lambda)
    A(:,j) = exp(-lambda(j)*t);
end

% if get(SCSTEP.CausalFilt, 'value') %remove this feature - it adds no
% benefit
%     [b, a] = butter(3, .7);
%     A= filter(b,a, A);
% end

c = A\y;
z = A*c;
err = norm(z-y);
SCSTEP.AmpHold = c;           


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                              
%         function CDI
%             global SCSTEP;
%             set(gcf, 'pointer', 'watch');
%             nSel = get(SCSTEP.Box, 'value');
%             cla;
% 
%             DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel});
%             ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
%             swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel});
%             XMin = swANALYSIS.XMin;
%             XMax = swANALYSIS.XMax;
%             Tau = swANALYSIS.Tau;
%             Amp = swANALYSIS.Amp;
%             m = swANALYSIS.m;
%             b = swANALYSIS.b;
%             SF = DATA(2).StimParams.LeakSF;
%             Dstep = DATA(1).StimParams.Dstep;
%             time    = DATA(1).Time*1000 ;  %time in ms starting from begining of data
%             t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms where zero is at start of p2
%             iRaw = DATA(1).AcqWaveform;
%             %iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);
%                 avgLk  = mean(DATA(2).AcqWaveform,3);
% %note that the swANALYSIS offset does not seem to equal the global value -
% %check this!!!!
%                 
%                 iRaw = iRaw - SCSTEP.swOffset;
%                 avgLk = avgLk - SCSTEP.lkOffset;
%                 avgLk = avgLk*SF;
%                 smoothleak = 0;
%                 try
%                     for n=1:(length(XMin))
%                         ilk = Amp(n)*exp(-(Tau(n))*t);
%                         ilk(t<XMin(n))=0;
%                         ilk(t>XMax(n))=0;
%                         smoothleak = smoothleak + ilk;
%                     end
%                 end
%                 try
%                     LinearFit = m*t + b;
%                     smoothleak = smoothleak + LinearFit;
%                 end
%                 try
%                     for n=1:(length(AMin));
%                         alk = iRaw-smoothleak;
%                         alk(t<AMin(n))=0;
%                         alk(t>AMax(n))=0;
%                         smoothleak = smoothleak + alk;
%                     end
%                 end
%                 iRaw = iRaw - smoothleak;
%                 
%    
%                 
%                 
%                 plot(time, iRaw);


%% UpdateFunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function UpdateBox
        global SCSTEP;

        set(gcf, 'pointer', 'watch'); drawnow;
        set(SCSTEP.Box, 'String', SCSTEP.RunSwp);
        UpdateGraphics;
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateGraphics
    global SCSTEP;
    
      if get(SCSTEP.NoUpdate, 'value')
          set(gcf, 'pointer', 'arrow');
      else
          UpdateGraphicsx
      end
          

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function UpdateGraphicsx
        global SCSTEP;

        set(gcf, 'pointer', 'watch'); drawnow;
        nSel = get(SCSTEP.Box, 'value');
        cla; hold on;
        aFig = gcf;
%         bFig = figure;  %xxxx
        
        % load data and analysis files
        for k=1:length(nSel)
            figure(aFig);
            DATA = LoadData(SCSTEP.datafile, SCSTEP.RunSwp{nSel(k)});            
            ANALYSIS = load(SCSTEP.AnalysisFile, '-mat');
            swANALYSIS = ANALYSIS.(SCSTEP.RunSwp{nSel(k)});
            CellNum = DATA(1).CellNum;
            CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
            
            %read in some parameter values from data and analysis files
            try
                NumCh = ANALYSIS.(CellNumString).NumCh;
                g = ANALYSIS.(CellNumString).g;
                Vs = ANALYSIS.(CellNumString).Vs;
            catch
                NumCh = 1;
                g = 0;
                Vs = 0;
            end
            Construct = DATA(1).XFect;
            RI = 0;%DATA(1).StimParams.RI;
            VStep = [];
            FiltHz = swANALYSIS.FiltHz;
            XMin = swANALYSIS.XMin;
            XMax = swANALYSIS.XMax;
            Tau = swANALYSIS.Tau;
            Amp = swANALYSIS.Amp;
            if isfield(swANALYSIS,'Delay')
                Delay = swANALYSIS.Delay;
            else
                Delay = zeros(size(Tau));
            end
            m = swANALYSIS.m;
            b = swANALYSIS.b;
            swOffset = swANALYSIS.swOffset;
            lkOffset = swANALYSIS.lkOffset;
            SF = [];
            GoodBad = swANALYSIS.GoodBad;
            Blank = swANALYSIS.Blank;
            AMin = swANALYSIS.AMin;
            AMax = swANALYSIS.AMax;
            GoodLeak = swANALYSIS.GoodLeak;
            
            map = jet;
            if GoodBad==1

                if Blank==1
                    color = [.5 .5 .5];
                else if length(nSel)==1
                        color = [0 0 1];
                    else
                        color = map( 1+round((k-1)*(length(map)-1)/(length(nSel)-1)) ,:);
                    end
                end
            else
                color = [.9 .9 .9];
            end

            %plotting ramp data
            if (findstr(DATA(1).StimName, 'Ramp'))
               
                
                v = DATA.StimWaveform;
                iRaw = DATA.AcqWaveform;
                
                iRawFiltered = LowpassFilter(DATA.Time, iRaw, FiltHz);
                smoothleak = 0;
                for n=1:(length(XMin))
                    ilk = Amp(n)*exp(-(Tau(n))*v);
                    ilk(v<XMin(n))=0;
                    ilk(v>XMax(n))=0;
                    smoothleak = smoothleak + ilk;
                end
                try
                    LinearFit = m*v + b;
                    smoothleak = smoothleak + LinearFit;
                end
                try
                    for n=1:(length(AMin));
                        alk = iRaw-smoothleak;
                        alk(v<AMin(n))=0;
                        alk(v>AMax(n))=0;
                        smoothleak = smoothleak + alk;
                    end
                end
                
                if get(SCSTEP.LkOnly, 'value')
                    plot(v, iRaw, 'color', [.9 .9 .9]);
                    plot(v, smoothleak, 'r');
                end
                if get(SCSTEP.SmoothLk, 'value')
                    iRaw = iRaw - smoothleak;
                    iRawFiltered = iRawFiltered - smoothleak;
                end
                
                %calculate GVT fits
                Unitary = v * 0;  %initialize
                tmpV = v - Vs;
                I = find(abs(tmpV)/12>.01);
                Unitary(I)  = -g*tmpV(I).*exp(-tmpV(I)/12)./(1 - exp(-tmpV(I)/12));  %traditional eqn
                I = find(abs(tmpV)/12<=.01);
                Unitary(I)  = -g*tmpV(I).*(1 - tmpV(I)/12)./(tmpV(I)/12);  %linearized eqn near zero
                
                 iRaw = iRaw.*(iRaw<Unitary/2)+iRawFiltered.*(iRaw>=Unitary/2);
                
                for j=0:NumCh
                    UU = j*Unitary ;
                    plot(v(1:30:end),UU(1:30:end),'k:') ;
                end
            if GoodBad==1
                plot(v, iRaw, 'color', color); %(iRaw./Unitary)>0.5
%                 hold on; 
%                 tempx=[-90 30]; gtemp = 0.018; Vrevtemp = 6;
%                 tempy = gtemp*(tempx-Vrevtemp);
%                 plot(tempx, tempy)
%                  plot(tempx, tempy*0)
% %                 figure(bFig)
%                 subplot(length(nSel),1,k)
%                 plot(v, iRaw, 'k-', v, Unitary,'r-')
%                 line([-40 -40+50*150/200],[0.2 0.2])
%                 line([-60 50],[0.2 0.2]*0)
%                 line([-40 -40],[-1.5 -0.5])
%                 xlim([-60 50])
%                 ylim([-2.5 0.5])
%                 axis off;
%                 
                
            end    
            else
        %plotting step data
                SF = DATA(2).StimParams.LeakSF;
                Dstep = DATA(1).StimParams.Dstep;
                VStep = DATA(1).StimParams.Vstep;
                t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms
                iRaw = DATA(1).AcqWaveform;
                iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);
                
                % allow some leaks to be removed from avg                
                if isempty(GoodLeak)
                    GoodLeak =ones(1,length(DATA(2).AcqWaveform(1,1,:)));
                end

                
                LkSum = sum(DATA(2).AcqWaveform(1,:,logical(GoodLeak)),3)';   % does the same thing as below ... 
              %%%%%%%%%%  add in a fix for if no leaks are aquired
               if isempty(GoodLeak)
                   avgLk = mean(DATA(2).AcqWaveform,3);
               else
                   avgLk = LkSum/sum(GoodLeak);
               end
               
               % avgLk  = mean(DATA(2).AcqWaveform,3);
               % find where the first pulse ends
               % MBJ
               EndofPulse1 = find(t>DATA(1).StimParams.Dstep(1),1);%find(abs(diff(DATA(1).StimWaveform)),1);
               %zero offset:
               if swANALYSIS.swOffset==0
                    swOffset = mean(iRaw(EndofPulse1-DATA(1).StimParams.PrePoints+1:EndofPulse1));
               end
               if swANALYSIS.lkOffset==0
                    lkOffset = mean(avgLk(EndofPulse1-DATA(1).StimParams.PrePoints+1:EndofPulse1));
               end
               iRaw = iRaw - swOffset;
               avgLk = avgLk - lkOffset;

                %leak display
                avgLk = avgLk*SF;
                smoothleak = 0;
                try
                    for n=1:(length(XMin))
                        ilk = Amp(n)*exp(-(Tau(n))*(t-Delay(n)));
                        ilk(t<XMin(n))=0;
                        ilk(t>XMax(n))=0;
                        smoothleak = smoothleak + ilk;
                    end
                     smoothleak = LowpassFilter(DATA(1).Time, smoothleak, 2000);
                end
                
%                 if 1
%                     [bFilter, aFilter] = butter(4, .2);   
%                      smoothleak= filter(bFilter,aFilter, smoothleak);
%                 end
                
                % MBJ For the first 0.5ms let us use the data from leak kidn of
                % like mask function we have in wcviewer leakfit
                
                try
                    LinearFit = m*t + b;
                    smoothleak = smoothleak + LinearFit;
                end
                SCSTEP.bViewSmoothLeak = 0;
                if SCSTEP.bViewSmoothLeak
                    plot(t,iRaw,'color',color)
                    hold on
                        plot(t,smoothleak,'color',[1 0 0])                                        
                    hold off
                else  
                    try
                        for n=1:(length(AMin));
                            alk = iRaw-smoothleak;
                            alk(t<AMin(n))=0;
                            alk(t>AMax(n))=0;
                            smoothleak = smoothleak + alk;
                        end
                    end                                 
                    if get(SCSTEP.AvgLkSub, 'value')
                       iRaw = iRaw-avgLk';
                    end
                    if get(SCSTEP.SmoothLk, 'value')
                        iRaw = iRaw - smoothleak;
                    end
                    plot(t, iRaw, 'color', color);
                    
                end
                    
                if get(SCSTEP.LkOnly, 'value')
                    cla;
                    plot(t,LowpassFilter(DATA(1).Time, avgLk',0)', 'color', 0.5*ones(1,3));
%                     plot(t, (avgLk'-smoothleak), 'k');
                    if sum(abs(smoothleak))>0
                        plot(t, smoothleak, 'r');
                    end
                end
            end
        end
        
        
%         axis auto;
%         myxlim = get(gca,'xlim');
%         line(myxlim, [0 0],'color',[0 0 0])
%         if isempty(strfind(DATA(1).StimName, 'Ramp'))
%             Gv =  str2num(get(SCSTEP.g.Edit, 'string'));
%             for NIndex  = 1:str2num(get(SCSTEP.NumCh.Edit, 'string'));
%                 line(myxlim, NIndex*Gv*ones(1,2),'color',0.7*ones(1,3))
%             end
%         end

        % set editable and global variables that were read in from file
        set(SCSTEP.CellNum.Edit, 'string', num2str(CellNum));
        set(SCSTEP.Construct.Edit, 'string', num2str(Construct));
        set(SCSTEP.VStep.Edit, 'string', num2str(VStep));
        set(SCSTEP.RI.Edit, 'string', num2str(unique(RI)));
        set(SCSTEP.FiltHz.Edit, 'string', num2str(FiltHz));
        set(SCSTEP.NumCh.Edit, 'string', num2str(NumCh));
        set(SCSTEP.g.Edit, 'string', num2str(g));
        set(SCSTEP.Vs.Edit, 'string', num2str(Vs));
        set(SCSTEP.XMin.Edit, 'string', num2str(XMin));
        set(SCSTEP.XMax.Edit, 'string', num2str(XMax));
        set(SCSTEP.Tau.Edit, 'string', num2str(Tau));
        set(SCSTEP.Amp.Edit, 'string', num2str(Amp));
        set(SCSTEP.Delay.Edit, 'string', num2str(Delay));
        set(SCSTEP.m.Edit, 'string', num2str(m));
        set(SCSTEP.b.Edit, 'string', num2str(b));
        SCSTEP.swOffset = (swOffset);
        SCSTEP.lkOffset = (lkOffset);
        SCSTEP.SF = (SF);
        SCSTEP.GoodBad = (GoodBad);
        SCSTEP.Blank = (Blank);
        SCSTEP.AMin = (AMin);
        SCSTEP.AMax = (AMax);
        SCSTEP.GoodLeak = (GoodLeak);

        if ~isempty(SCSTEP.FreezeX)
            set(gca, 'xlim', SCSTEP.FreezeX);
        else
            if (findstr(DATA(1).StimName, 'Ramp'))
                dV = v(end)-v(1);
                set(gca, 'xlim', [min(v)-dV/50 max(v)+dV/50]);
            else
                dT = t(end)-t(1);
                set(gca, 'xlim', [t(1)-10*(t(2)-t(1)) t(end)+10*(t(2)-t(1))]);
            end
        end
        if ~isempty(SCSTEP.FreezeY)
            set(gca, 'ylim', SCSTEP.FreezeY);
        end
            
        if strfind(DATA(1).StimName,'StepRamp')
            clc
            disp([SCSTEP.RunSwp{nSel(k)} '   : StepRamp'])
        else
            clc
        end
        set(gcf, 'pointer', 'arrow');

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function AxRect = DrawRectOnAx

        %change mouse pointer to indicate we are starting to draw a rectangle
        set(gcf,'Pointer','fullcross');

        %Use rbbox to draw a rectangle
        waitforbuttonpress;
        set(gcf,'Pointer','crosshair');
        point1 = get(gca,'CurrentPoint');    % button down detected
        rbbox;
        point2 = get(gca,'CurrentPoint');    % button up detected
        point1 = point1(1,1:2);              % extract x and y
        point2 = point2(1,1:2);
        p1 = min(point1,point2);             % calculate locations
        offset = abs(point1-point2);         % and dimensions

        %This is the position of the rectangle on the axes coordinates.
        AxRect = [p1(1) p1(2) offset(1) offset(2)];

        %change mouse pointer to indicate we are done
        set(gcf,'Pointer','arrow');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load/Save functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function SaveSwParams
        global SCSTEP;
% careful - this allows all values of sweeps selected to be reset when any change is made 
        set(gcf, 'pointer', 'watch'); drawnow;
        nSel = get(SCSTEP.Box, 'value');
        for k = 1:length(nSel);
        S.(SCSTEP.RunSwp{(nSel(k))}).FiltHz = str2num(get(SCSTEP.FiltHz.Edit, 'string'));
        S.(SCSTEP.RunSwp{(nSel(k))}).Amp = str2num(get(SCSTEP.Amp.Edit, 'string'));
        S.(SCSTEP.RunSwp{(nSel(k))}).Tau = str2num(get(SCSTEP.Tau.Edit, 'string'));
        S.(SCSTEP.RunSwp{(nSel(k))}).XMax = str2num(get(SCSTEP.XMax.Edit, 'string'));
        S.(SCSTEP.RunSwp{(nSel(k))}).XMin = str2num(get(SCSTEP.XMin.Edit, 'string'));
        S.(SCSTEP.RunSwp{(nSel(k))}).m = str2num(get(SCSTEP.m.Edit, 'string'));
        S.(SCSTEP.RunSwp{(nSel(k))}).b = str2num(get(SCSTEP.b.Edit, 'string'));
        S.(SCSTEP.RunSwp{(nSel(k))}).swOffset = SCSTEP.swOffset;
        S.(SCSTEP.RunSwp{(nSel(k))}).lkOffset = SCSTEP.lkOffset;
        S.(SCSTEP.RunSwp{(nSel(k))}).GoodBad = SCSTEP.GoodBad;
        S.(SCSTEP.RunSwp{(nSel(k))}).Blank = SCSTEP.Blank;
        S.(SCSTEP.RunSwp{(nSel(k))}).AMin = SCSTEP.AMin;
        S.(SCSTEP.RunSwp{(nSel(k))}).AMax = SCSTEP.AMax;
        S.(SCSTEP.RunSwp{(nSel(k))}).GoodLeak = SCSTEP.GoodLeak;
        save(SCSTEP.AnalysisFile, '-struct', 'S', '-append');
        end
           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function newfile
        global SCSTEP;

        fileOK = 0;
        datafilename = [];

        while isempty(datafilename)
            [datafilename,datafilepath] = uigetfile('*.zsd','Select Data File');
            datafile=[datafilepath datafilename];
        end
 
        SCSTEP.RunSwp = who('-file', datafile);
        SCSTEP.datafile = datafile;
        NewMatFile = [datafile(1:end-4) '_analysis.mat'];
        
        if exist(NewMatFile)==0
            fprintf('creating new analysis file:  %s \n', NewMatFile)
            %set some initial values
            for k=1:length(SCSTEP.RunSwp)
                S.(SCSTEP.RunSwp{k}).GoodBad = 1;
                S.(SCSTEP.RunSwp{k}).Blank = 0;
                S.(SCSTEP.RunSwp{k}).Offset = 0;
                S.(SCSTEP.RunSwp{k}).FiltHz = 0;
                S.(SCSTEP.RunSwp{k}).XMin = [];
                S.(SCSTEP.RunSwp{k}).XMax = [];
                S.(SCSTEP.RunSwp{k}).Tau = [];
                S.(SCSTEP.RunSwp{k}).Amp = [];
                S.(SCSTEP.RunSwp{k}).swOffset = 0;
                S.(SCSTEP.RunSwp{k}).lkOffset = 0;
                S.(SCSTEP.RunSwp{k}).m = [];
                S.(SCSTEP.RunSwp{k}).b = [];
                S.(SCSTEP.RunSwp{k}).AMin = [];
                S.(SCSTEP.RunSwp{k}).AMax = [];
                S.(SCSTEP.RunSwp{k}).GoodLeak = [];
            end
            save(NewMatFile , '-struct', 'S');
        end

        SCSTEP.AnalysisFile = NewMatFile;
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function DATA = LoadData(FullPathname, RunSwp);

            Error = [];

            if strcmpi(FullPathname(end-3:end), '.zsd')
                DATA = load(FullPathname, RunSwp, '-mat');
                DATA = DATA.(RunSwp);

                for k=1:length(DATA)
                    DATA(k).LowpassHz = DATA(k).SamplingFreqHz;
                    DATA(k).NB = 0;
                    %DATA(k).RI = DATA(k).StimParams.RI;
                    DATA(k).HoldingValue = DATA(k).StimParams.H;
                    DATA(k).SamplingFreqHz = DATA(k).SamplingFreqHz;
                    DATA(k).CellNum = DATA(k).DBParams.CellNum;
                    DATA(k).XFect = DATA(k).DBParams.XFect;

                    %now initialize these
                    DATA(k).Time           = (0:size(DATA(k).AcqWaveform16,2)-1)/DATA(k).SamplingFreqHz;
                    DATA(k).AcqWaveform    = double(DATA(k).AcqWaveform16);
                    for ch=1:size(DATA(k).AcqWaveform,1)
                        DATA(k).AcqWaveform(ch,:,:)    = DATA(k).AcqWaveform(ch,:,:)/DATA(k).AcqPtsPerUnit(ch);
                    end
                    DATA(k).StimWaveform    = double(DATA(k).StimWaveform16);
                    for ch=1:size(DATA(k).StimWaveform,1)
                        DATA(k).StimWaveform(ch,:,:)    = DATA(k).StimWaveform(ch,:,:)/DATA(k).StimPtsPerUnit(ch);
                    end
                    if findstr(DATA(k).StimName, 'StepRamp')
                       RampPos = DATA(k).StepRampStepLen+1;
                       DATA(k).Time = DATA(k).Time(RampPos:end);
                       DATA(k).AcqWaveform = DATA(k).AcqWaveform(RampPos:end);
                       DATA(k).StimWaveform = DATA(k).StimWaveform(RampPos:end);                       
                    end                    
                end

                % invert reversed data
                % if strcmpi(FullPathname(end-6:end-4), 'inv')
                if (findstr(DATA(1).StimName, 'Ramp'))
                    DATA.AcqWaveform  = -DATA.AcqWaveform;                    
                else
                    for k=1:length(DATA)
                        DATA(k).AcqWaveform = -DATA(k).AcqWaveform;
                    end
                end
                %end

            else


                try
                    %open file
                    datafileID = fopen(FullPathname, 'rb');
                    dirblock = fread(datafileID, 256, 'short');

                    %now load the info from each run - not the data, just the info.
                    infoADRS = dirblock(Run*2+1);
                    fseek(datafileID, infoADRS*512, -1);
                    infoblock = fread(datafileID, 128, 'short');

                    if infoblock(1) ~= 32100
                        disp('DecFile::LoadData Warning - Infoblock is weird');
                    end

                    %first the leak/BlocksPerTrace
                    BlocksPerTrace =  double(infoblock(13+1));    %blocks per trace, inlcuding leak

                    %now some things that we'll assume is the same for each run/channel
                    DATA.SamplingFreqHz =  1e6/double(infoblock(6+1));
                    DATA.LowpassHz      = double(infoblock(21+1));		% lopass filter frequency
                    DATA.HoldingValue   =  double(infoblock(2+1));		% holding potential
                    DATA.RI             = double(infoblock(5+1))/10;
                    DATA.NB             = double(infoblock(13+1));
                    %Gain                =  double(infoblock(7+1))/10;   % gain (mV/pA)
                    StimulusType        =  double(infoblock(18+1));  %0: step, 1:ramp, 2:family, 3:APW Step, 4:APW Family
                    if StimulusType ~= 1
                        disp('Warning, this data is not a ramp!!!!');
                    end

                    %now initialize these
                    DATA.Time           = ((0:256*BlocksPerTrace-13))/DATA.SamplingFreqHz;
                    DATA.AcqWaveform    = zeros(1, 256*BlocksPerTrace-12,  1);
                    DATA.StimWaveform   = zeros(1, 256*BlocksPerTrace-12,  1);

                    %Get dtata for this sweep
                    %     traceADRS = infoADRS + 2 + BlocksPerTrace + 1*BlocksPerTrace*(Swp-1);
                    traceADRS = infoADRS + 2 + BlocksPerTrace + 1*BlocksPerTrace*(Swp-1);
                    fseek(datafileID, 512*traceADRS, -1);
                    dtrace=fread(datafileID, 256*BlocksPerTrace, 'short');

                    %now trim that junk
                    dtrace = dtrace(1:256*BlocksPerTrace-12);  %trim some junk at end, I think????
                    dtrace = double(dtrace)*(10000/2048)/Gain;  %This is the current trace in pico Amps

                    %now save it
                    DATA.AcqWaveform = dtrace';

                    %Type = 'Ramp';
                    Vramp =  double(infoblock(23:24)');  % Family start,stop, (note: increment is 25, but that's not important)
                    DATA.StimWaveform = DATA.Time/DATA(1).Time(end)*(Vramp(2)-Vramp(1)) + Vramp(1);
             
                end
            end
                
                %close file
                try
                    fclose(datafileID);
                catch
                end

                %now throw any error
                if ~isempty(Error)
                    rethrow(Error);
                end

        
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DATA = LoadDataMRT(FullPathname, Run, Swp, Gain);

Error = [];

%ied addition: open zsd

if strcmpi(FullPathname(end-3:end), '.zsd')
    DATA = load(FullPathname, ['Run' num2str(Run,'%.4d') '_Swp' num2str(Swp,'%.4d')], '-mat');
    DATA = DATA.(['Run' num2str(Run,'%.4d') '_Swp' num2str(Swp,'%.4d')]);
    DATA.LowpassHz = DATA.SamplingFreqHz;
    DATA.NB = 0;
    DATA.RI = DATA.StimParams.RI;
    DATA.HoldingValue = DATA.StimParams.H;
    DATA.SamplingFreqHz = DATA.SamplingFreqHz;
    for k=1:length(DATA)
        %now initialize these
        DATA(k).Time           = (0:size(DATA(k).AcqWaveform16,2)-1)/DATA(k).SamplingFreqHz;
        DATA(k).AcqWaveform    = double(DATA(k).AcqWaveform16);
        for ch=1:size(DATA(k).AcqWaveform,1)
            DATA(k).AcqWaveform(ch,:,:)    = DATA(k).AcqWaveform(ch,:,:)/DATA(k).AcqPtsPerUnit(ch);
        end
        DATA(k).StimWaveform    = double(DATA(k).StimWaveform16);
        for ch=1:size(DATA(k).StimWaveform,1)
            DATA(k).StimWaveform(ch,:,:)    = DATA(k).StimWaveform(ch,:,:)/DATA(k).StimPtsPerUnit(ch);
        end

    end

    % ied addition , invert reversed data

    %if strcmpi(FullPathname(end-6:end-4), 'inv')
    DATA.AcqWaveform  = -DATA.AcqWaveform;
    %end
    %end


else


    try
        %open file
        datafileID = fopen(FullPathname, 'rb');
        dirblock = fread(datafileID, 256, 'short');

        %now load the info from each run - not the data, just the info.
        infoADRS = dirblock(Run*2+1);
        fseek(datafileID, infoADRS*512, -1);
        infoblock = fread(datafileID, 128, 'short');

        if infoblock(1) ~= 32100
            disp('DecFile::LoadData Warning - Infoblock is weird');
        end

        %first the leak/BlocksPerTrace
        BlocksPerTrace =  double(infoblock(13+1));    %blocks per trace, inlcuding leak

        %now some things that we'll assume is the same for each run/channel
        DATA.SamplingFreqHz =  1e6/double(infoblock(6+1));
        DATA.LowpassHz      = double(infoblock(21+1));		% lopass filter frequency
        DATA.HoldingValue   =  double(infoblock(2+1));		% holding potential
        DATA.RI             = double(infoblock(5+1))/10;
        DATA.NB             = double(infoblock(13+1));
        %Gain                =  double(infoblock(7+1))/10;   % gain (mV/pA)
        StimulusType        =  double(infoblock(18+1));  %0: step, 1:ramp, 2:family, 3:APW Step, 4:APW Family
        if StimulusType ~= 1
            disp('Warning, this data is not a ramp!!!!');
        end

        %now initialize these
        DATA.Time           = ((0:256*BlocksPerTrace-13))/DATA.SamplingFreqHz;
        DATA.AcqWaveform    = zeros(1, 256*BlocksPerTrace-12,  1);
        DATA.StimWaveform   = zeros(1, 256*BlocksPerTrace-12,  1);

        %Get dtata for this sweep
        %     traceADRS = infoADRS + 2 + BlocksPerTrace + 1*BlocksPerTrace*(Swp-1);
        traceADRS = infoADRS + 2 + BlocksPerTrace + 1*BlocksPerTrace*(Swp-1);
        fseek(datafileID, 512*traceADRS, -1);
        dtrace=fread(datafileID, 256*BlocksPerTrace, 'short');

        %now trim that junk
        dtrace = dtrace(1:256*BlocksPerTrace-12);  %trim some junk at end, I think????
        dtrace = double(dtrace)*(10000/2048)/Gain;  %This is the current trace in pico Amps

        %now save it
        DATA.AcqWaveform = dtrace';

        %Type = 'Ramp';
        Vramp =  double(infoblock(23:24)');  % Family start,stop, (note: increment is 25, but that's not important)
        DATA.StimWaveform = DATA.Time/DATA(1).Time(end)*(Vramp(2)-Vramp(1)) + Vramp(1);


    catch
        Error = lasterror;
    end
end

%close file
try
    fclose(datafileID);
catch
end
%now throw any error
if ~isempty(Error)
    rethrow(Error);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       