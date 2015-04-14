seed=double(4);
rng(seed);

power = 0.005;
precision = 'float32';
sampRate = 62.5e6;
numPointsA = 2 * sampRate * 0.09;
numPointsB = 2 * sampRate * 0.20;
noiseA = (rand(1, numPointsA) - 0.5) * power;
noiseB = (rand(1, numPointsB) - 0.5) * power;

file_name_srce = 'File_00TT.complex.1ch.float32';
file_name_dest = 'long_capture.complex.1ch.float32';
fID_dest = fopen(file_name_dest, 'w');
fwrite(fID_dest, noiseA, precision);

numData = 2 * 12.5e6;
num = 2 * 26.25e6; %420 ms of jammer data
while num > 0
    if num > numData
        data = numData;
    else
        data = num;
    end
    fID_srce = fopen(file_name_srce);
    a = fread(fID_srce, data, precision);
    fclose(fID_srce);
    fwrite(fID_dest, a, precision);
    num = num - numData;
end

fwrite(fID_dest, noiseB, precision);

numData = 2 * 12.5e6;
num = 2 * 18.125e6; %420 ms of jammer data
while num > 0
    if num > numData
        data = numData;
    else
        data = num;
    end
    fID_srce = fopen(file_name_srce);
    a = fread(fID_srce, data, precision);
    fclose(fID_srce);
    fwrite(fID_dest, a, precision);
    num = num - numData;
end

fclose(fID_dest);