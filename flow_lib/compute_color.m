function img = compute_color(u, v)
%   compute optical flow color map
%   :param u: optical flow horizontal map
%   :param v: optical flow vertical map
%   :return: optical flow in color code
    [h, w] = size(u);
    img = zeros(h, w, 3);
    nanIdx = isnan(u) | isnan(v);
    u(nanIdx) = 0;
    v(nanIdx) = 0;

    colorwheel = make_color_wheel();
    ncols = size(colorwheel, 1);

    rad = sqrt(u.^2+v.^2);
    a = atan2(-v, -u) / pi;
    fk = (a+1) / 2 * (ncols - 1) + 1;
    k0 = floor(fk);
    k1 = k0 + 1;
    k1(k1 == ncols+1) = 1;
    f = fk - k0;

    for i = 1: size(colorwheel, 2)
        tmp = colorwheel(:, i);
        col0 = tmp(k0) / 255;
        col1 = tmp(k1) / 255;
        col = (1-f) .* col0 + f .* col1;

        idx = rad <= 1;
        col(idx) = 1-rad(idx).*(1-col(idx));
        notidx = not(idx);

        col(notidx) = col(notidx) * 0.75;
        img(:, :, i) = uint8(floor(255 * col.*(1-nanIdx)));
    end
    img = uint8(img);