% The following function takes the complex IQ data and computes the FFT
% based on the number of points that are specified by the user.
function fDomain = procFFT(IQraw, numPoint)
fDomain = fft(IQraw,numPoint)/numPoint;
temp = zeros(1,numPoint);
temp(1:numPoint/2) = fDomain(numPoint/2+1:end);
temp(numPoint/2+1:end) = fDomain(1:numPoint/2);
fDomain = 10*log10((abs(temp)).^2)+30;
end