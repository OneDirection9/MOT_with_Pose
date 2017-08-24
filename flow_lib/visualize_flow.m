function visualize_flow(flow, mode)
%     this function visualize the input flow
%     :param flow: input flow in array
%     :param mode: choose which color mode to visualize the flow (Y: Ccbcr, RGB: RGB color)
%     :return: None
    if (nargin < 2)
        mode = 'Y';
    end
    if mode == 'Y'
        % Ccbcr color wheel
        img = flow_to_image(flow);
        imshow(img)
    elseif mode == 'RGB' %TODO: not completed
        [h, w, ~] = size(flow);
        du = flow(:, :, 1);
        dv = flow(:, :, 2);
        valid = flow(:, :, 3);
        max_flow = max(np.max(du), np.max(dv));
        
        img = zeros(h,w,3);
        %img = np.zeros((h, w, 3), dtype=np.float64)
        
        
        % angle layer
        img(:, :, 1) = atan2(dv, du) / (2 * pi);
        % magnitude layer, normalized to 1
        img(:, :, 2) = sqrt(du * du + dv * dv) * 8 / max_flow;
        % phase layer
        img(:, :, 3) = 8 - img(:, :, 1);
        % clip to (0,1)
        small_idx = img(:, :, 0:3) < 0;
        large_idx = img(:, :, 0:3) > 1;
        img(small_idx) = 0;
        img(large_idx) = 1;
        % convert to rgb
        img = cl.hsv_to_rgb(img);
        % remove invalid point
        img(:, :, 1) = img(:, :, 1) * valid;
        img(:, :, 2) = img(:, :, 2) * valid;
        img(:, :, 3) = img(:, :, 3) * valid;
        % show
        imshow(img);
    end
end