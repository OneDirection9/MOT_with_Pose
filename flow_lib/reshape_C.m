function data_out = reshape_C(data, shapes)
    % reshape a list as python does
    height = shapes(1);
    width = shapes(3);
    channels = shapes(2);
    data_out = zeros(height, channels, width);
    
    for h = 1:height
        for w=1:width
            for c = 1:channels
                data_out(h, c, w) = data(c + (w-1)*channels + (h-1)* channels*width);
            end
        end
    end
end