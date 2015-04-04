% Signal Attenuator
%{
	This program is designed to input a interleaved 32bit floating point signal file and create a new attenuated signal file.
	
	Programmer: Lorenzen Devin
	Version: 1.1
	Release Date: 4/01/15
	
%}
function attenuator()
clear	% Clears all variables
clc		% Clears Command window

%% User Inputs
FileName=[]; 	% full file name including extensions of a binary file. Input as string. 
Attenuation=[]; % Attenuation amount in dBm.

%% Variables
Seed=double(4); % Sets seed value of the random number generator.
I=1;			% Sets loop/Index counter to 1.

%% Opens float32 signal file and attenuates the signal.
FileName=input('Type the file name you wish to open: ','s');	% Prompts user for the signal file name to be modified. 
SignalFileID = fopen(FileName);									% Opens signal file and obtains a file ID
Signal = fread(SignalFileID,[2 2^24],'float32');				% Reads interleaved values of the signal file and separates the IQ data

Attenuation=str2double(input('please enter the amount of attenuation in dBm: ','s'));	% Prompts the user for the amount of desired attenuation in dBm.
display('runing...')

ComplexSignal = Signal(1,:)+Signal(2,:)*1i;  	% Create the complex IQ array.
Phase = angle(ComplexSignal);					% Calculates the Phase of the complex signal.
mag = abs(ComplexSignal);						% Calculates the magnitude of the complex signal.
SignalPower = db(mag,'voltage',50)+30;  		% Convert the magnitude of the signal to dBm.

rng(Seed); 										% Sets the random generated number function with a seed value.
RndArray = randn(1,length(Signal))+1i*randn(1,length(Signal));	% Creates a complex random noise array of equal length to the signal array.
NormalizedNoiseMag = abs(RndArray)/max(abs(RndArray));			% Calculates the noise magnitude and sets it to values between -1 and 1.
%NoisePhase = abs(atand(RndArray));								% Calculates the noise phase. 
Noise = NormalizedNoiseMag * Attenuation;						% Scales the noise array to the magnitude of the attenuation.
r=10 .^ (((SignalPower + Noise - Attenuation)-10) ./ 20) ./ sqrt(2);    	%converts dBm back into VRMS
ComplexAttenuatedSignal = r .* cos(Phase) + 1i * r .* sin(Phase); 			% Attenuates the signal and converts magnitude and phase into complex form.

%% converts the Attenuated Signal back to a interleaved form.
A=single(real(ComplexAttenuatedSignal)); 			 % creates matrix A using only the real values of the complex signal.
B=single(imag(ComplexAttenuatedSignal)); 			 % Creates matrix B using only the imaginary values of the complex signal.
InterleavedAttenuatedSignal = (1:1:2*length(B));
while(I<=length(B))
    InterleavedAttenuatedSignal(I+I-1) = A(I);  	 % places I data value in each odd index.
    InterleavedAttenuatedSignal(I+I)= B(I); 	 	 % Places Q data value in each even index.
    I = I+1;               		 			 		 % Increments the counter.
end
InterleavedAttenuatedSignal=single(InterleavedAttenuatedSignal);

%% creates new file and saves attenuated data as a float 32
AttenuatedFID=fopen(['Attenuated_' FileName], 'w');					% creates a new file.
fwrite(AttenuatedFID,InterleavedAttenuatedSignal,'float32');		% Wrights the interleaved attenuated signal array to the file
fclose(AttenuatedFID);												% closes attenuated signal file
fclose(SignalFileID);												% closes Signal file
display('complete')
end

