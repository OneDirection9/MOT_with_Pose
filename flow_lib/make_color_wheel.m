function colorwheel = make_color_wheel()
%   Generate color wheel according Middlebury color code
%   :return: Color wheel
    RY = 15;
    YG = 6;
    GC = 4;
    CB = 11;
    BM = 13;
    MR = 6;

    ncols = RY + YG + GC + CB + BM + MR;
    colorwheel = zeros(ncols, 3);
    col = 1;

    % RY
    colorwheel(1:RY, 1) = 255;
    colorwheel(1:RY, 2) = (floor(255*(0: RY-1) / RY))';
    col = col + RY;

    % YG
    colorwheel(col:col+YG-1, 1) = 255 - (floor(255*(0: YG-1) / YG))';
    colorwheel(col:col+YG-1, 2) = 255;
    col = col + YG;

    % GC
    colorwheel(col:col+GC-1, 2) = 255;
    colorwheel(col:col+GC-1, 3) = (floor(255*(0: GC-1) / GC))';
    col = col + GC;

    % CB
    colorwheel(col:col+CB-1, 2) = 255 - (floor(255*(0: CB-1) / CB))';
    colorwheel(col:col+CB-1, 3) = 255;
    col = col + CB;

    % BM
    colorwheel(col:col+BM-1, 3) = 255;
    colorwheel(col:col+BM-1, 1) = (floor(255*(0:BM-1) / BM))';
    col = col + BM;

    % MR
    colorwheel(col:col+MR-1, 3) = 255 - (floor(255 * (0:MR-1) / MR))';
    colorwheel(col:col+MR-1, 1) = 255;
end
