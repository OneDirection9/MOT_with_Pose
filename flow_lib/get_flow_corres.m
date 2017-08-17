function corres_pts = get_flow_corres(filename)
%filename = '/home/sensetime/WORK/flow/flownet2_example/00000011.flo'
    data2d = read_flow(filename);
    height = size(data2d, 1);
    width = size(data2d, 3);
    u = squeeze(data2d(:,1,:)); % u ---> w axis
    v = squeeze(data2d(:,2,:)); % v ---> h axis
    corres_pts = zeros(height*width,4);
    
    for h = 1:height
        for w = 1:width
            if (h+v(h,w) > height) || (w+u(h,w) > width) || (h+v(h,w) < 0) || (w+u(h,w) < 0) 
                continue
            end
            corres_pts(w+(h-1)*width, 1) = h;
            corres_pts(w+(h-1)*width, 2) = w;
            corres_pts(w+(h-1)*width, 3) = h+v(h,w);
            corres_pts(w+(h-1)*width, 4) = w+u(h,w);
        end
    end
end