% Author: Ben Wilson
% Date:   February, 25, 2015
% ------------------------------------------------------------------------
% This program reads IQ data from a binary file and plots the results in
% the time and frequency domain.
%
% In order to run this script, you will need to untar the binary file using
% the matlab function: "untar(tarfilename,outputdir)". Once the binary file
% is in the same directory as this script, you can enter the file name into
% line 17 and run the program.
%
% The values of the sampling frequency, numer of samples, and other
% metadata can be found the xml file that accompanied the binary file.
%-------------------------------------------------------------------------
clear;clc

biFileName = 'C:\Users\wilson_b\Desktop\Capstone\Jammer Captures\Jammer files from CO\Jammer 2\Jammer 2 200 ms at 62.5MSa\File_00TT.complex.1ch.float32';
fID = fopen(biFileName);  % Open the binary file
prec = 'single';

numPoint = 2^16;        % Enter a power of 2
samples = 12500000;     % Numbers of samples
fs= 6.25e+007;          % Sampling frequency
centerFreq = 1.57542e9; % Center frequency
T = 1/fs;               % Sample period
t = (0:numPoint-1)*T;	% Time vector
f = centerFreq + fs/2*linspace(-1,1,numPoint);

% Set axis limits of the first plot
xmin1 = 0;
xmax1 = 200e-3;
ymin1 =  1e6;
ymax1 = -1e6;
% Set axis limits of the second plot
xmin2 = centerFreq - fs/2;
xmax2 = centerFreq + fs/2;
ymin2 =  1e6;
ymax2 = -1e6;



% Create the figure and define two subplots
figure(1)
ax1 = subplot(2,1,1); % first subplot
ax2 = subplot(2,1,2); % second subplot
title (ax1,'Power vs. Time')
xlabel(ax1,'Time (S)')
ylabel(ax1,'Power (dBm)')
grid  (ax1, 'on');
hold(ax1, 'on')

i = floor(samples/numPoint);    % Number of plot iterations
% clear biFileName samples fs centerFreq xmin1 xmax1 ymin1 ymax1
for n = 1:i
    % Process data from binary file
    [IQraw, ~, IQdBm, ~] = procIQData(fID, numPoint, prec);
    
    % Compute the FFT
    spec = procFFT(IQraw, numPoint);
    
    if max(IQdBm) > ymax1
        ymax1 = 5*ceil(max(IQdBm)/5);
    end
    
    if min(IQdBm) < ymin1
        ymin1 = 5*floor(min(IQdBm)/5);
    end
    
    if max(spec) > ymax2
        ymax2 = 5*ceil(max(spec)/5);
    end
    
    if min(spec) < ymin2
        ymin2 = 5*floor(min(spec)/5);
    end
    
    plot(ax1, t, IQdBm,'b')     % Plot the time domain plot
    axis(ax1, [xmin1 xmax1 ymin1 ymax1])
    plot(ax2, f, spec, 'r')     % Plot the FFT plot
    title (ax2,'Power vs. Frequency')
    xlabel(ax2,'Frequency (Hz)')
    ylabel(ax2,'Power (dBm)')
    axis(ax2, [xmin2 xmax2 ymin2 ymax2])
    grid(ax2, 'on');
    
    t = t+(numPoint*T);
    pause(.01);
end
status = fclose(fID);    % Close the binary file
if ~status
    disp('File closed: exiting program');
else
    disp('Error closing file!');
end
close;
