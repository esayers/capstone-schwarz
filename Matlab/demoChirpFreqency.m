function demoChirpFreqency(varargin)
% Author: Ben Wilson
% Date:   May 29, 2015
% Requires:
%     parseXML.m
%     procFFT.m
%     procIQData.m
%     prettyUnits.m
% ------------------------------------------------------------------------
% program description
%-------------------------------------------------------------------------

%% Read function arguments
if nargin == 1
    xml_file_name = varargin{1};
    threshold = 0;
    inf_loop = false;
elseif nargin == 2
    xml_file_name = varargin{1};
    threshold = varargin{2};
    inf_loop = false;
elseif nargin == 3
    xml_file_name = varargin{1};
    threshold = varargin{2};
    inf_loop = varargin{3};
else
    disp('incorrect number of input arguments');
    return
end

%% Parse XML file and read metadata
% Read .xml file
addpath(genpath(pwd))
disp('Attempting to parse .xml file...')
xml_doc = parseXML(xml_file_name);
disp('    ...parsing complete.')

% Setup program using metadata from .xml file
num_fft_pts = 2^6;
num_samples = str2double(xml_doc(3).Children( 8).Children.Data);
samp_rate   = str2double(xml_doc(3).Children(10).Children.Data);
center_freq = str2double(xml_doc(3).Children(22).Children.Children.Children.Children.Data);
data_type   = xml_doc(3).Children(14).Children.Data;
file_name   = xml_doc(3).Children(20).Children.Data;

%% Initialize variables
% Initialize ints and doubles
time = 0;
trigger = 0;
count = 1;
band_l = NaN;
band_h = NaN;
samp_period = 1/samp_rate;
num_sweeps = floor(num_samples/num_fft_pts);    % Number of plot iterations

% Initialize arrays
freq_max = nan(1,1024);
win = blackmanharris(num_fft_pts);
spectrum = zeros(num_sweeps, num_fft_pts);
IQ_data_raw = zeros(num_sweeps, num_fft_pts);
time_f = 0 : num_fft_pts*samp_period : 1023*num_fft_pts*samp_period;% num_fft_pts*samp_period * linspace(0,1,1024);
chrp_f = samp_rate/(2*num_fft_pts)*linspace(-1,1,1025);
chrp_f(end) = [];
freq = center_freq + samp_rate/2*linspace(-1,1,num_fft_pts); % Freq axis

%% Set up figure
% Create the plot figure
figure('units','normalized','outerposition',[0 0 1 1])
h1 = subplot(2, 1, 1);
h2 = subplot(2, 1, 2);

% Set axis limits of the plot
xmin1 = time_f(1);
xmax1 = time_f(end);
ymin1 = freq(1);
ymax1 = freq(end);

% Set axis limits of the plot
xmin2 = 0;
xmax2 = chrp_f(end);
ymin2 = 80;
ymax2 = 180;

%% Open binary file and process data in a loop
% Open the binary file
file_ID = fopen(file_name);
disp('Processing data...');
for i = 1:num_sweeps %120000% 
    % Process data from binary file
    data = fread(file_ID, [2 num_fft_pts], data_type);
    raw = data(1,:) + data(2,:)*1i;       % Create the complex IQ array
    IQ_data_raw(i,:) = raw .* win;
    
    % Compute the FFT
    spectrum(i,:) = procFFT(IQ_data_raw(i,:), num_fft_pts);
    [peak, ind] = max(spectrum(i,:));
    
    % Determine if the detector is triggered
    if (peak > threshold && trigger == 0)
        trigger = 1;
        freq_max = nan(1,1024);
        freq_max(count) = freq(ind);
        band_l = freq(ind);
        band_h = freq(ind);
    end
    
    
    if trigger == 1
        count = count + 1;
        if peak < threshold
            freq_max(count) = freq_max(count-1);
        else
            freq_max(count) = freq(ind);
        end
        
        if freq_max(count) > band_h
            band_h = freq_max(count);
        end
        
        if freq_max(count) < band_l
            band_l = freq_max(count);
        end
    end
    
    if count == 1024
		chirp_rate = procFFT(freq_max, 1024);
        chirp_rate(1:513) = 0;
        [~, chirp_i] = max(chirp_rate);
        vert_x = [chrp_f(chirp_i) chrp_f(chirp_i)];
        vert_y = [ymin2 ymax2];
    
		% Plot the results
	    plot(h1, time_f, freq_max, 'b', time_f, ones(size(time_f))*band_l, 'r', time_f, ones(size(time_f))*band_h, 'r')
		plot(h2, chrp_f(514:end), chirp_rate(514:end),'b', vert_x, vert_y, 'r')
        
		% Title and label plot 1
        band_w = band_h - band_l;
        band_w = prettyUnits(band_w, 'Hz');
        title (h1, {'Peak Frequency vs. Time'; ['Bandwidth:  ', band_w]}, 'FontSize', 14, 'FontWeight', 'bold')
		xlabel(h1, 'Time (s)', 'FontSize', 12, 'FontWeight', 'bold')
		ylabel(h1, 'Frequency (Hz)', 'FontSize', 12, 'FontWeight', 'bold')

		% Title and label plot 2
        chirp_r = prettyUnits(chrp_f(chirp_i), 'Hz');
        title (h2, {'Power vs. Frequency'; ['Chrip Rate: ', chirp_r]}, 'FontSize', 14, 'FontWeight', 'bold')
		xlabel(h2, 'Frequency (Hz)', 'FontSize', 12, 'FontWeight', 'bold')
		
		% Set x and y axis limits
		axis(h1, [xmin1 xmax1 ymin1 ymax1])
		grid(h1, 'on');
	    axis(h2, [xmin2 xmax2 ymin2 ymax2])
		grid(h2, 'on');
        
        count = 1;
        trigger = 0;
        band_l = freq(end);
        band_h = freq(1);
		pause(.001);
    end
    
    % Increment time array
    time = time + (num_fft_pts * samp_period);
end

%% Close the binary file and exit program
status = fclose(file_ID);
if ~status
    disp('File closed:');
else
    disp('Error closing file!');
end
close;

if inf_loop
    demoChirpDetector(xml_file_name, threshold, inf_loop);
else
    % Pause the program before closing the figure
    input('Press enter to close the program');
    clear;clc
end
end