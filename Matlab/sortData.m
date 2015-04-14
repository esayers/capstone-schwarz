function data = sortData(xml_doc)
% Setup program using datadata from .xml file
data.num_fft_pts = 2^6;
data.num_samples= str2double(xml_doc(3).Children( 8).Children.Data);
data.samp_rate  = str2double(xml_doc(3).Children(10).Children.Data);
data.center_freq= str2double(xml_doc(3).Children(22).Children.Children.Children.Children.Data);
data.data_type  = xml_doc(3).Children(14).Children.Data;
data.file_name  = xml_doc(3).Children(20).Children.Data;
data.samp_period = 1/data.samp_rate;
data.num_frames = floor(data.num_samples/data.num_fft_pts);    % Number of plot iterations
end