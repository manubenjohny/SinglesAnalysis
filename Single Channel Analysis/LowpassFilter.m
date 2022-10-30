function [lowydata] = LowpassFilter(xdata, ydata ,fcutoff)
%function [lowydata] = LowpassFilter(xdata, ydata ,fcutoff)
%
%set fcutoff==0 for no filtering

lowydata = ydata;  %allocate memory for return
if fcutoff==0
    return;
end

%zeropad the beginning of the trace
Npad = round(length(xdata)/10);
% Npad=0;
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

