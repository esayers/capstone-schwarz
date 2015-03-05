function readCaptureData(varargin)
% Author: Ben Wilson
% Date:   February, 25, 2015
% Revision: 2 - March, 4, 2015
%     xml parser function to pull data from .xml files
%     option to pass file name and sample number to the function
%     elapsed time added to frequency domain plot
%	  removed time domain plot for increased plotting speed
%	  figure opens in full screen
%	  
% Requires: 
%     parseXML.m
%     procFFT.m
%     procIQData.m
% ------------------------------------------------------------------------
% This program reads IQ data from a binary file and plots the results in
% the frequency domain.
%
% In order to run this script, you will need to untar the binary file using
% the matlab function: "untar(tarfilename,outputdir)". Binary files and
% .xml files must be in subdirectories of this script.
% 
% readCaptureData(XMLfile) - pass the .xml file as a string to the 
% function. Assumes that the number of sample points for the FFT is 2^16.
% 
% readCaptureData(XMLfile, powerOfTwo) - pass the .xml file as a string and
% the number of sample points for the FFT in terms of the power of two as 
% an integer. 
%-------------------------------------------------------------------------

if nargin == 1
    xmlFileName = varargin{1};
    numPoint = 2^16;
elseif nargin == 2
    xmlFileName = varargin{1};
    numPoint = 2^varargin{2};
else
    disp('incorrect number of input arguments');
    return
end

addpath(genpath(pwd))
disp('Attempting to parse .xml file...')
xDoc = parseXML(xmlFileName);
disp('    ...parsing complete.')

numSamples= str2double(xDoc(3).Children( 8).Children.Data);
sampRate  =	str2double(xDoc(3).Children(10).Children.Data);
centerFreq= str2double(xDoc(3).Children(22).Children.Children.Children.Children.Data);
dataType  =	xDoc(3).Children(14).Children.Data;
fileName  =	xDoc(3).Children(20).Children.Data;
fID = fopen(fileName);  % Open the binary file
% scalFact  =	str2double(xDoc(3).Children(16).Children.Data);
% format    =	xDoc(3).Children(12).Children.Data;

% duration  = numSamples/sampRate;
sampPeriod = 1/sampRate;
t = (0:numPoint-1)*sampPeriod;                       % Time axis array
f = centerFreq + sampRate/2*linspace(-1,1,numPoint); % Frequency axis array

% Create the figure and define two subplots
figure('units','normalized','outerposition',[0 0 1 1])
% ax1 = subplot(2,1,1); % first subplot
ax2 = subplot(1,1,1); % second subplot
% title (ax1,'Power vs. Time')
% xlabel(ax1,'Time (S)')
% ylabel(ax1,'Power (dBm)')
% grid  (ax1, 'on');
% hold(ax1, 'on')

i = floor(numSamples/numPoint);    % Number of plot iterations
IQraw = zeros(i, numPoint);
IQdBm = zeros(i, numPoint);
spec = zeros(i, numPoint);

clear fileName numSamples xDoc xmlFileName
disp('Loading IQ data into MatLab...')
for n = 1:i
    % Process data from binary file
    [IQraw(n,:), ~, IQdBm(n,:), ~] = procIQData(fID, numPoint, dataType);
    
    % Compute the FFT
    spec(n,:) = procFFT(IQraw(n,:), numPoint);
end
disp('    ...complete.')
% Set axis limits of the first plot
% xmin1 = 0;
% xmax1 = duration;
% ymin1 = 5*floor(min(IQdBm(:))/5);
% ymax1 = 5*ceil(max(IQdBm(:))/5);

% Set axis limits of the second plot
xmin2 = centerFreq - sampRate/2;
xmax2 = centerFreq + sampRate/2;
ymin2 = 5*floor(min(spec(:))/5)+10;
ymax2 = 5*ceil(max(spec(:))/5);

clear centerFreq dataType sampRate

for n = 1:i
%     plot(ax1, t, IQdBm(n,:),'b')     % Plot the time domain plot
%     axis(ax1, [xmin1 xmax1 ymin1 ymax1])
    plot(ax2, f, spec(n,:), 'r')     % Plot the FFT plot
    title (ax2,'Power vs. Frequency')
    text(xmin2, ymin2+10, ['  Elapsed Time: ', num2str(t(end)), ' s'])
    xlabel(ax2,'Frequency (Hz)')
    ylabel(ax2,'Power (dBm)')
    axis(ax2, [xmin2 xmax2 ymin2 ymax2])
    grid(ax2, 'on');
    
    t = t+(numPoint*sampPeriod);
    pause(.01);
end

status = fclose(fID);    % Close the binary file
if ~status
    disp('File closed:');
    x = input('Press enter to close the program');
else
    disp('Error closing file!');
end
close;
clear;clc
end