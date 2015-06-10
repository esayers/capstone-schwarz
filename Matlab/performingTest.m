function test(varargin)
%Author: Ben Wilson, Hanjae Noh, Devin Lorenzen
%This code attenuates original signal and tells 
%whether a jammer is detected or not, based on the threshold power -40 dBm.
%
%You need to run this code by two inputs *.xml file name and attenuation
%value. i.e) test('CO_02_32p0_0200.xml',10)
%
%As a result, this code generates attenuated binary file and determine a
%jammer is present.
%
%Or you can run this code by one input(xml file name), then it generates attenuated
%signal from 0 to -60 dBm stepping by user input


if nargin == 1
    file_name = varargin{1};
    disp('attenuation from 0 to -60 dBm by user input');
elseif nargin == 2
    file_name = varargin{1};
    attenuation = abs(varargin{2});
elseif nargin == 3
    file_name = varargin{1};
    attenuation = abs(varargin{2});
    duration = varargin{3};
else
    disp('incorrect number of input arguments');
    return
end
%%
addpath(genpath(pwd))
addpath(genpath('../Jammer Captures for FPGA'))
% Parse metadata file
if strcmp('.xml',file_name(end-3:end))
    disp('Attempting to parse .xml file...')
    meta = sortData(parseXML(file_name));
    disp('    ...parsing complete.')
elseif strcmp('.txt',file_name(end-3:end))
    disp('Attempting to parse .txt file...')
    meta = parseTXT(file_name); %need parseTXT
    disp('    ...parsing complete.')
else
    disp('Unknown file format: please enter .xml or .txt file name.');
    return
end 
if ~exist('duration','var')
    duration = meta.num_samples / meta.samp_rate;
end
%%
% Generate new destination file names
old_bin_name = fopen(meta.file_name);
signal = fread(old_bin_name, 2*meta.num_samples, meta.data_type);
if exist('attenuation','var')
    signal = signal*sqrt(1/(10^(attenuation/10))); %calc->10^(attenuation/10)=x, sqrt(1/x)
    var = length(signal);
    var = cast(var, 'int64');
    % Generate white noise
    noise = rand(var - 0.5, 1) * 0.01;
    signal=signal + noise;

    new_name = file_name(1:end-4);
    new_bin_name = [new_name, '_m', num2str(attenuation), '.complex.1ch.float32'];
    new_txt_name = [new_name, '_m', num2str(attenuation), '.txt'];
    new_xml_name = [new_name, '_m', num2str(attenuation), '.xml'];
    % Open new binary file
    f_bin_new = fopen(new_bin_name, 'w');
    fwrite(f_bin_new, signal, meta.data_type);
    fclose(f_bin_new);
    fprintf('signal is attenuated by %d dBm\n', attenuation)
else
    attenuation=input('Enter a value for attenuation step:');
    attenuation=abs(attenuation);
    for attenuation2 = 0 : attenuation : 60
    signal = signal*sqrt(1/(10^(attenuation2/10)));
    var = length(signal);
    var = cast(var, 'int64');
    noise = rand(var - 0.5, 1) * 0.01;
    signal=signal + noise;

% signal=signal+rand(length(signal))*noisefloor;
    new_name = file_name(1:end-4);
    new_bin_name = [new_name, '_m', num2str(attenuation2), '.complex.1ch.float32'];
    new_txt_name = [new_name, '_m', num2str(attenuation2), '.txt'];

% Open new binary file
    f_bin_new = fopen(new_bin_name, 'w');
    fwrite(f_bin_new, signal, meta.data_type);
    fclose(f_bin_new);
    end
    fprintf('Original signal is attenuated from 0 to -60dBm(step: %d  dBm)\n',attenuation)
end
%%
% % Open new text file
f_txt_new = fopen(new_txt_name, 'w');% f_txt_new = fopen(new_txt_name, 'w');
% 
% % Write metadata to text file
meta.duration = duration;% meta.duration = duration;
meta.attenuation = attenuation;% meta.attenuation = attenuation;

fprintf(f_txt_new,'duration: %12f\r\nattenuation: %12f\r\n',meta.duration,meta.attenuation);
fprintf(f_txt_new,'num_samp: %12f\r\ncenter_freq: %12e',meta.num_samples,meta.center_freq);
fclose(f_txt_new);% fclose(f_txt_new);

%%
%Open new attenuated binary file-this part is Ben's fft matlab code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
num_fft_pts = 2^16;
xml_doc = parseXML(new_xml_name);
num_samples= str2double(xml_doc(3).Children( 8).Children.Data);
data_type  = xml_doc(3).Children(14).Children.Data;
file_name  = xml_doc(3).Children(20).Children.Data;
file_ID = fopen(file_name);

num_sweeps = floor(num_samples/num_fft_pts);    % Number of plot iterations
IQ_data_raw = zeros(num_sweeps, num_fft_pts);
IQ_data_dBm = zeros(num_sweeps, num_fft_pts);
spectrum = zeros(num_sweeps, num_fft_pts);

for i = 1:num_sweeps
    % Process data from binary file
    [raw,~,dBm,~] = procIQData(file_ID, num_fft_pts, data_type);
    IQ_data_raw(i,:) = raw;
    IQ_data_dBm(i,:) = dBm;
    
    % Compute the FFT
    spectrum(i,:) = procFFT(IQ_data_raw(i,:), num_fft_pts);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%find maximum power in attenuated signal and decide a jammer is presentin
maxpower=max(spectrum(:));
if maxpower>-40  %threshold power to detect jammer is -40 dBm
    disp('A jammer is detected')
else
    disp('A jammer is not detected')
end