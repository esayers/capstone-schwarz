function readCaptureData(varargin)
% Author: Ben Wilson
% Date:   February 25, 2015
% Revision: 2 - March  4, 2015
%     add the xml parser function to pull data from .xml files
%     add the option to pass file name and sample number to the function
% Revision: 3 - March 25, 2015
%     bandwith calculation added
%     chirp rate calculation added
%     updated variable names to be more descriptive
% Requires:
%     parseXML.m
%     procFFT.m
%     procIQData.m
%     prettyUnits.m
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
    xml_file_name = varargin{1};
    num_fft_pts = 2^16;
elseif nargin == 2
    xml_file_name = varargin{1};
    num_fft_pts = 2^varargin{2};
else
    disp('incorrect number of input arguments');
    return
end

% Read .xml file
addpath(genpath(pwd))
disp('Attempting to parse .xml file...')
xml_doc = parseXML(xml_file_name);
disp('    ...parsing complete.')

% Setup program using metadata from .xml file
num_samples= str2double(xml_doc(3).Children( 8).Children.Data);
samp_rate  = str2double(xml_doc(3).Children(10).Children.Data);
center_freq= str2double(xml_doc(3).Children(22).Children.Children.Children.Children.Data);
data_type  = xml_doc(3).Children(14).Children.Data;
file_name  = xml_doc(3).Children(20).Children.Data;
file_ID = fopen(file_name);  % Open the binary file

samp_period = 1/samp_rate;
time = (0:num_fft_pts-1)*samp_period;                        % Time axis
freq = center_freq + samp_rate/2*linspace(-1,1,num_fft_pts); % Freq axis

num_sweeps = floor(num_samples/num_fft_pts);    % Number of plot iterations
IQ_data_raw = zeros(num_sweeps, num_fft_pts);
IQ_data_dBm = zeros(num_sweeps, num_fft_pts);
spectrum = zeros(num_sweeps, num_fft_pts);

% Read binary file into MatLab
disp('Loading IQ data into MatLab...')
for i = 1:num_sweeps
    % Process data from binary file
    [raw,~,dBm,~] = procIQData(file_ID, num_fft_pts, data_type);
    IQ_data_raw(i,:) = raw;
    IQ_data_dBm(i,:) = dBm;
    
    % Compute the FFT
    spectrum(i,:) = procFFT(IQ_data_raw(i,:), num_fft_pts);
end
disp('    ...complete.')

% Run smaller FFTs to examine chirp properties
disp('Determining Chirp Rate and Bandwidth...')
sub_points = 2^6;
sub_ffts = num_fft_pts/sub_points;
peak_freq = zeros(1,sub_ffts);
sub_freq = samp_rate/2 * linspace(-1,1,sub_ffts);
for i=1:sub_ffts
    [~,peak_index] = max(procFFT(IQ_data_raw(1,(sub_points*(i-1)+1):sub_points*i), num_fft_pts));
    peak_freq(1,i) = freq(peak_index);
end
sub_spectrum = procFFT(peak_freq(1,:),sub_ffts);
sub_spectrum(1 + sub_ffts/2) = NaN;
[~,chirp_ind] = max(sub_spectrum);
chirp_rate = abs(sub_freq(chirp_ind));
chirp_rate = prettyUnits(chirp_rate, 'Hz');
freq_max_chirp = max(peak_freq);
freq_min_chirp = min(peak_freq);
band_width = freq_max_chirp - freq_min_chirp;
band_width = prettyUnits(band_width, 'Hz');
disp('    ...complete.')

% Create the plot figure
figure('units','normalized','outerposition',[0.5 0 0.5 0.5])

% Set axis limits of the plot
xmin = center_freq - samp_rate/2;
xmax = center_freq + samp_rate/2;
ymin = 5*floor(min(spectrum(:))/5)+10;
ymax = 5*ceil(max(spectrum(:))/5);

% Create vertical lines to indicate the chirp bandwidth
max_freq = [freq_max_chirp freq_max_chirp];
min_freq = [freq_min_chirp freq_min_chirp];
vert = [ymin ymax];

% Plot FFT output in quick succession to simulate spectrum analyzer
for i = 1:num_sweeps
    % Plot FFT and bandwidth markers
    plot(freq,spectrum(i,:),'r', max_freq,vert,'b', min_freq,vert,'b')
    
    % Title and label plot
    title ('Power vs. Frequency')
    xlabel('Frequency (Hz)')
    ylabel('Power (dBm)')
    
    % Display bandwidth, chirp rate, and elapsed time on plot
    text(xmin, ymin+30, ['  Bandwidth:    ', band_width], 'FontWeight','bold')
    text(xmin, ymin+20, ['  Chirp Rate:   ', chirp_rate], 'FontWeight','bold')
    text(xmin, ymin+10, ['  Elapsed Time: ', num2str(time(end)), ' s'], 'FontWeight','bold')
    
    % Set x and y axis limits
    axis([xmin xmax ymin ymax])
    grid('on');
    
    % Increment time array
    time = time + (num_fft_pts * samp_period);
    pause(.01);
end

% Close the binary file
status = fclose(file_ID);
if ~status
    disp('File closed:');
else
    disp('Error closing file!');
end

% Pause the program before closing the figure
input('Press enter to close the program');
close;
clear;clc
end