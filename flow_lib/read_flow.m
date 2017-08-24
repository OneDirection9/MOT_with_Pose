function data2d = read_flow(filename)
%     read optical flow from Middlebury .flo file
%     :param filename: name of the flow file
%     :return: optical flow data in matrix
    f = fopen(filename, 'rb');
    magic = fread(f, 1, 'float32');
    data2d = [];

    if 202021.25 ~= magic
        print 'Magic number incorrect. Invalid .flo file'
    else
        w = fread(f, 1, 'int32');
        h = fread(f, 1, 'int32');
        %fprintf('Reading %d x %d flo file\n', h, w);
        tmp = fread(f, 2 * w * h, 'float32');
        % reshape data into 3D array (columns, channels, rows)
        data2d = reshape_C(tmp, [h, 2, w]);
    fclose(f);
    end
end