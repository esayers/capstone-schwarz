function [raw,mag,dBm,phse] = procIQData(fileID, numPoint, precision)
% Read the I and Q values into the 1st and 2nd row of A, respectively
A = fread(fileID,[2 numPoint],precision);

raw = A(1,:) + A(2,:)*1i;       % Create the complex IQ array
phse= abs(atand(raw));          % Create the IQ phase array
mag = abs(raw);                 % Create the magnitude array
dBm = db(mag,'voltage',50)+30;  % Convert the magnitude to dBm
end
