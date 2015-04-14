seed=double(4);
rng(seed);

power = 0.005;
precision = 'float32';
sampRate = 62.5e6;
t1 = 1/sampRate: 1/sampRate: 0.42;
t2 = 1/sampRate: 1/sampRate: 0.29;


numPointsA = 2 * sampRate * 0.09;
numPointsB = sampRate * 0.42;
numPointsC = 2 * sampRate * 0.20;
numPointsD = sampRate * 0.29;

noiseA = (rand(1, numPointsA) - 0.5) * power;
noiseC = (rand(1, numPointsC) - 0.5) * power;
cosineB(1,:) = power * cos((2*pi*1562.42e6*t1) + (pi/2)) + ((rand(1, numPointsB) - 0.5) * power); %1575.42 MHz
cosineB(2,:) = power * cos((2*pi*1562.42e6*t1)) + ((rand(1, numPointsB) - 0.5) * power); 
cosineD(1,:) = power * cos((2*pi*1562.42e6*t2) + (pi/2)) + ((rand(1, numPointsD) - 0.5) * power); 
cosineD(2,:) = power * cos((2*pi*1562.42e6*t2)) + ((rand(1, numPointsD) - 0.5) * power);

file_name_dest = 'cosine_capture.complex.1ch.float32';
fID_dest = fopen(file_name_dest, 'w');

fwrite(fID_dest, cosineB, precision);
fwrite(fID_dest, noiseC, precision);
fwrite(fID_dest, cosineD, precision);
fwrite(fID_dest, noiseA, precision);
fclose(fID_dest);
clear;clc