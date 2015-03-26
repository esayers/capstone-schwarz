% This function converts int and float values into easily readable strings.
% The user passed the int or float value along with the unit type.
function unitS = prettyUnits(num, unit)
if num < 1e12 && num >= 1e9
    unitS = ['G', unit];
    mantissa = num * 1e-9;
elseif num < 1e9 && num >= 1e6
    unitS = ['M', unit];
    mantissa = num * 1e-6;
elseif num < 1e6 && num >= 1e3
    unitS = ['k', unit];
    mantissa = num * 1e-3;
elseif num < 1e3 && num >= 1e0
    unitS = ['', unit];
    mantissa = num * 1e0;
elseif num < 1 && num >= 1e-3
    unitS = ['m', unit];
    mantissa = num * 1e3;
elseif num < 1e-3 && num >= 1e-6
    unitS = ['u', unit];
    mantissa = num * 1e6;
elseif num < 1e-6 && num >= 1e-9
    unitS = ['n', unit];
    mantissa = num * 1e9;
elseif num < 1e-9 && num >= 1e-12
    unitS = ['p', unit];
    mantissa = num * 1e12;
elseif num < 1e-12 && num >= 1e-15
    unitS = ['f', unit];
    mantissa = num * 1e15;
end
mantissa = num2str(mantissa);
unitS = [mantissa , ' ', unitS];
end