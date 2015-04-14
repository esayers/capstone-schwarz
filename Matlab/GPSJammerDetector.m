function GPSJammerDetector(varargin)
if nargin == 1
    xml_file_name = varargin{1};
else
    disp('Incorrect number of input arguments.');
    disp('Pass the name of the .xml file you wish to use.');
    return
end

% Read .xml file
addpath(genpath(pwd))
disp('Attempting to parse .xml file...')
meta = sortData(parseXML(xml_file_name));
disp('    ...parsing complete.')

buffer.rows = 2^10;
buffer.columns = 2^6;
buffer.data = zeros(buffer.rows, buffer.columns);
buffer.next_row = zeros(1,buffer.columns);
buffer.count = 0;
buffer.full = false;

time.axis = (0:meta.num_fft_pts-1)*meta.samp_period;
time.wait_time = 0.01;
time.current = 0;
time.count = 0;
time.wait = false;
t = 0;

freq.axis = meta.center_freq + meta.samp_rate/2*linspace(-1,1,meta.num_fft_pts);
freq.axis_b = meta.samp_rate/2*linspace(-1,1,buffer.rows);
freq.spectrum = zeros(1,buffer.columns);
freq.threshold = -20;

detector.f_vs_t = zeros(1,buffer.rows);
detector.trigger = false;

file_ID = fopen(meta.file_name);  % Open the binary file
disp('Reading binary file...')
while ~feof(file_ID)
    % Read the I and Q values into the 1st and 2nd row of time.data.matrix
    if time.wait
        t = t + time.wait_time;
        while (t > 0) && ~feof(file_ID)
            time.data.matrix = fread(file_ID,[2 meta.num_fft_pts], meta.data_type);
            time.count = time.count + 1;
            t = t - meta.num_fft_pts/meta.samp_rate;
        end
        time.wait = false;
    else
        time.data.matrix = fread(file_ID,[2 meta.num_fft_pts], meta.data_type);
        time.count = time.count + 1;
    end
    time.data.complex = time.data.matrix(1,:) + time.data.matrix(2,:) * 1i;
    time.current = time.count * meta.num_fft_pts/meta.samp_rate;
    
    freq.spectrum = procFFT(time.data.complex, meta.num_fft_pts);
    if (max(freq.spectrum) > freq.threshold) && ~(detector.trigger)
        disp('Detector triggered...')
        disp(['Triggered at ', num2str(time.current), 's']);
        detector.trigger = true;  % Turn on detector
        buffer.count = 0;
    end
    
    if detector.trigger
        buffer.data(1,:) = [];
        buffer.data = [buffer.data; freq.spectrum];
        buffer.count = buffer.count + 1;
        if buffer.count == buffer.rows;
            buffer.full = true;
        end
    end
    
    if buffer.full
        % Run smaller FFTs to examine chirp properties
        disp('Determining Chirp Rate and Bandwidth...')
        for i = 1:buffer.rows
            [~, index] = max(buffer.data(i,:));
            detector.f_vs_t(i) = freq.axis(index);
        end
        chirp.bw = max(detector.f_vs_t) - min(detector.f_vs_t);
        chirp.data = procFFT(detector.f_vs_t,buffer.rows);
        chirp.data(1 + buffer.rows/2) = NaN;
        
        [~,chirp.rate] = max(chirp.data);
        chirp.rate = abs(freq.axis_b(chirp.rate));
        % plot(freq.axis_b, chirp.rate)
        
        disp('    ...complete.')
        disp(['Bandwith = ', prettyUnits(chirp.bw, 'Hz')]);
        disp(['Chirp Rate = ', prettyUnits(chirp.rate, 'Hz')]);
        disp(' ');
        disp(' ');
        
        buffer.data = zeros(buffer.rows, 2^6); % clear buffer
        buffer.count = 0;
        buffer.full = false;
        detector.trigger = false;
        time.wait = true;
    end
end
disp('    ...end of binary file.')
fclose(file_ID);