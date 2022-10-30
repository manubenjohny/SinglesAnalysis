function varargout = MakeExemplarPlot(varargin)

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

function InitializeGUI
    clear global EXPLOT
    global EXPLOT

    %Size constants (in normalized units)
    LH = 0.04;  %height per line
    S  = 0.005;  %spacer
    ST = 0.005;
    SS = 0.02;
    AxW = 0.8;
    BW  = (1-AxW)/2;

    %make the figure window
    EXPLOT.FIG = figure( 'Name', 'Make Singles Exemplar',...
        'NumberTitle', 'off', ...
        'HandleVisibility', 'on', ...
        'IntegerHandle', 'on', ...
        'units', 'normalized', ...
        'Position', [.1 .1 .3 .3], ...
        'UserData', zeros(4,30), ... 
        'KeyPressFcn', @KeyPresser );

     EXPLOT.FILE = MakeButtonGroup('PickDataFile',[S    1-LH*2  BW*4  LH*2-S]);
     EXPLOT.TABLE = uitable('units', 'normalized', 'position',[S    1-LH*12  BW*4  LH*10-S]);
     EXPLOT.ANALYSIS = MakeButtonGroup('PickPoFile',[S    1-LH*14  BW*4  LH*2-S]);
     EXPLOT.FNAME = uicontrol('Style', 'text', 'String', '', 'HorizontalAlignment', 'left', 'units', 'normalized', 'Position', [S   1-LH*16  BW*4  LH*2-S]);
     EXPLOT.VLOC    = MakeTextEditGroup('VXLS',    'left', 'left', [S    1-LH*18  BW*2  LH*2-S],[S+2*BW    1-LH*18  BW*2  LH*2-S]);
     EXPLOT.PoLOC    = MakeTextEditGroup('PoXLS',    'left', 'left', [S    1-LH*20  BW*2  LH*2-S],[S+2*BW    1-LH*20  BW*2  LH*2-S]);
     EXPLOT.FiltHz    = MakeTextEditGroup('FiltHz',    'left', 'left', [S    1-LH*22  BW*2  LH*2-S],[S+2*BW    1-LH*22  BW*2  LH*2-S]);
     EXPLOT.FILE = MakeButtonGroup('GO',[S    1-LH*24  BW*4  LH*2-S]);
     set(EXPLOT.VLOC.Edit,'string', 'V3:V4002');
     set(EXPLOT.PoLOC.Edit,'string', 'W3:W4002');
              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S = MakeTextEditGroup(UIGroupName, AlignText, AlignEdit, PosTxt, PosBox)
            %Callback strings are generic
            S.Text = uicontrol('Style', 'text', 'String', UIGroupName, 'HorizontalAlignment', AlignText, 'units', 'normalized', 'Position', PosTxt);
            S.Edit = uicontrol('Style', 'edit', 'String', '', 'BackgroundColor', [1 1 1], 'Callback', '', 'HorizontalAlignment', AlignEdit, 'units', 'normalized', 'Position', PosBox);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function S = MakeButtonGroup(ButtonName, Pos)
    S = uicontrol('Style', 'pushbutton', 'String', ButtonName, 'Callback', ['MakeExemplarPlot(''' ButtonName ''')'], 'HorizontalAlignment', 'left', 'units', 'normalized', 'Position', Pos);

function PickDataFile
    global EXPLOT
    fileOK = 0;
    datafilename = [];
    while isempty(datafilename)
        [datafilename,datafilepath] = uigetfile('*.zsd','Select Data File');
        datafile=[datafilepath datafilename];
    end
    RunSwp = who('-file', datafile);
    EXPLOT.datafile = datafile;
    NewMatFile = [datafile(1:end-4) '_analysis.mat'];
    if exist(NewMatFile)==0
        errordlg('No Analysis File Exists');
    end
    EXPLOT.AnalysisFile = NewMatFile;
    Selection = listdlg('ListString',RunSwp);
    EXPLOT.RunSwp = RunSwp(Selection);
    set(EXPLOT.TABLE,'data',RunSwp(Selection))
    
    
function PickPoFile
    global EXPLOT
    fileOK = 0;
    datafilename = [];
    while isempty(datafilename)
        [datafilename,datafilepath] = uigetfile({'*.xls;*.xlsx','Excel File'},'Select Data File');
        datafile=[datafilepath datafilename];
    end
    EXPLOT.PoTraceFile = datafile;
    [status,sheets] = xlsfinfo(datafile);
    Selection = listdlg('ListString',sheets);
    EXPLOT.Sheet = sheets(Selection);
    set(EXPLOT.FNAME,'String',datafile);
    
function GO
    global EXPLOT
    FullPathName = EXPLOT.datafile;
    SelectedList = EXPLOT.RunSwp;
    FullPathName = EXPLOT.datafile;
    ANALYSIS = load(EXPLOT.AnalysisFile, '-mat');
    NumAxes = 0;
    numGood = 0;
    oldpage = 0;
    row = 0;
    for index = 1:length(SelectedList)    
        CurrentRunSwp = SelectedList{index};
        RunNum = str2num(CurrentRunSwp(4:7));
        SwpNum =  str2num(CurrentRunSwp(end-3:end));
        DATA = load(FullPathName, CurrentRunSwp , '-mat');    
        DATA = DATA.(CurrentRunSwp);
        CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];    
        swANALYSIS = ANALYSIS.(CurrentRunSwp);        
        if (findstr(DATA(1).StimName, 'Ramp'))
        % in case there are leaks
            DATA.AcqWaveform    = double(DATA.AcqWaveform16);
            for ch=1:size(DATA.AcqWaveform,1)
                DATA.AcqWaveform(ch,:,:)    = -DATA.AcqWaveform(ch,:,:)/DATA.AcqPtsPerUnit(ch);
            end
            DATA.StimWaveform    = double(DATA.StimWaveform16);
            for ch=1:size(DATA.StimWaveform,1)
                DATA.StimWaveform(ch,:,:)    = DATA.StimWaveform(ch,:,:)/DATA.StimPtsPerUnit(ch);
            end
        end
        GoodBad = swANALYSIS.GoodBad;
        numGood = numGood+GoodBad;
        % Now subtract fits from the analysis file.
        v = DATA.StimWaveform;
        iRaw = DATA.AcqWaveform;
        smoothleak = 0*iRaw;

        % Parameters for fits ... 
        % linear fit
        m = swANALYSIS.m;
        b = swANALYSIS.b;
        if ~isempty(m)
            smoothleak = smoothleak + m*v + b;
        end
        % exponential fits
        XMin = swANALYSIS.XMin;
        XMax = swANALYSIS.XMax;
        Tau = swANALYSIS.Tau;
        Amp = swANALYSIS.Amp;
        AMin = swANALYSIS.AMin;
        AMax = swANALYSIS.AMax;
        if ~isempty(XMin)
            disp(['yo, I dont know abt this trace ' CurrentRunSwp])
            % this gives u mask to trunctate fite beyond certain locations ...
            % it is counterintuitive but if u work out math, should be good ...                
            Mask = ones(size(XMin))'*v;
            XMinMat = XMin'*ones(size(v));
            XMaxMat = XMax'*ones(size(v));
            Mask = (Mask>XMinMat).*(Mask<XMaxMat);        
            % now for the fits; i think this is right but need to check, yo
            smoothleak = smoothleak + Amp*(exp(-Tau'*v).*Mask);        
        end
        iRaw = iRaw - smoothleak;
        FiltHz = str2num(get(EXPLOT.FiltHz.Edit,'String'));
        if ~ isempty(FiltHz)
            t = (0:length(DATA.StimWaveform)-1)/DATA.SamplingFreqHz;
            iRawFiltered = LowpassFilter(t,iRaw,FiltHz);
        end
        NumCh = ANALYSIS.(CellNumString).NumCh; 
        NumCh = 1; %%% take this out xxxxxxx
        g = ANALYSIS.(CellNumString).g;
        Vs = ANALYSIS.(CellNumString).Vs;
        Unitary = v * 0;  %initialize
        tmpV = v - Vs;
        Unitary  = -g*tmpV.*exp(-tmpV/12)./(1 - exp(-tmpV/12));  %traditional eqn    
        
        if ~isempty(FiltHz)
           iRaw = iRaw.*(iRaw<Unitary*0.5)+ iRawFiltered.*(iRaw>=Unitary*0.5);
        end
        
        if GoodBad
            NumAxes = NumAxes+1;
            NumPerCol = floor(12/NumCh);
            AH = 1.6*NumCh;
            AW = 3.5; VS = 0.4; HS = 0.5;
            row = row + 1;
            col = 1;
            % 4 columns / page ... 
            NumColsPerPage = 5;
            page = floor((col-1)/NumColsPerPage)+1;
            colInPage = mod(col-1, NumColsPerPage)+1; 
            figure(4)               
                set(4, 'units','inches','PaperPosition', [0.25, 0.25, 8, 10.5])           
                AL = (HS*5+AW)*(colInPage-1)+HS;
                AB = VS+(NumPerCol-row)*(AH+VS);
                AX(NumAxes) = axes('units','centimeters', 'position', [AL, AB, AW, AH]);
                plot(v, ([0:NumCh]'*Unitary)','color',[0.5 0.5 0.5])
                hold on
                plot(AX(NumAxes), v, iRaw,'color',[0 0 0])    
                hold off;
                text(-30, 0.3, [num2str(RunNum) ',' num2str(SwpNum)],'color',[0.5 0.5 0.5])  
                axis off;
                xlim([-60 40])
                ylim([-2.5*NumCh 1]);
        end
    end
    
    V = xlsread(EXPLOT.PoTraceFile,EXPLOT.Sheet{1},get(EXPLOT.VLOC.Edit,'string'));
    Po = xlsread(EXPLOT.PoTraceFile,EXPLOT.Sheet{1},get(EXPLOT.PoLOC.Edit,'string'));
   
    NumAxes = NumAxes + 1;
    row = row + 1;
    col = 1;
    % 4 columns / page ... 
    NumColsPerPage = 5;
    page = floor((col-1)/NumColsPerPage)+1;
    colInPage = mod(col-1, NumColsPerPage)+1; 
            
            
    AL = HS*1.5;
    AB = VS+((NumPerCol)-row)*(AH+VS);
    AX(NumAxes+1) = axes('units','centimeters', 'position', [AL, AB, AW*1.2, AH*1.2]);
    plot(V, LowpassFilter(t',Po',FiltHz)', 'k-')
    set(AX(NumAxes+1),'Tickdir','out')
    xlim([-60 50])
    ylim([-0.05 0.5])
    box off;         

    
function [lowydata] = LowpassFilter(xdata, ydata ,fcutoff)
%function [lowydata] = LowpassFilter(xdata, ydata ,fcutoff)
%
%set fcutoff==0 for no filtering

lowydata = ydata;  %allocate memory for return
if fcutoff==0
    return;
end

%zeropad the beginning of the trace
%Npad = round(length(xdata)/10);
Npad=0;
ydatapad = zeros(1,Npad);

for k=1:size(ydata,1)
    ydata1row = [ydatapad,ydata(k,:)];

    %calculate inputs to GAUSS filter
    T = (xdata(2)-xdata(1));		% sampling interval in sec
    %fmax = 1/T;			  	% this is the maximum freq (hz)
    N = length(xdata) + Npad;		% number of points
    N2=2^ceil(log(N)/log(2));

    % pgp's GAUSS filter.
    wc = 2*pi*fcutoff;
    w=0:2*pi/(N2*T):2*pi*(N2-1)/(N2*T);				% radians/sec 0:2*pi/T
    w(N2/2+2:N2)=-2*pi/(2*T)+2*pi/(N2*T):2*pi/(N2*T):-2*pi/(N2*T);	% Adjust so +/- 2*pi/2T
    lfilt=GAUSS(w,wc,T);

    %n = round(N2*fcutoff/fmax)			% end of square pulse
    %lfilt = zeros(1,N2);
    %lfilt(1:n) = ones(1,n);
    %lfilt(N2-n+1:N2) = ones(1,n);		% this is the crude filter

    %ydata = get(kids(j),'ydata');
    ydata1row = real(ifft(fft(ydata1row,N2).*lfilt));
    lowydata(k,:) = ydata1row(1+Npad:length(xdata)+Npad);
end


function H = GAUSS(w,wc,T)
% GAUSSIAN Filter Components with corner (3dB) frequency at wc.

sigma = 0.1325*(2*pi/wc);

W=(-sigma*sigma/2)*w.^2;
H=exp(W);

% Gaussian Filters have no delay

