function img = flow_to_image(flow)
%   Convert flow into middlebury color code image
%   :param flow: optical flow map
%   :return: optical flow image in middlebury color
    UNKNOWN_FLOW_THRESH = 1e7;

    u = squeeze(flow(:, 1, :));
    v = squeeze(flow(:, 2, :));

    maxu = -999.;
    maxv = -999.;
    minu = 999.;
    minv = 999.;
    idxUnknow = (abs(u) > UNKNOWN_FLOW_THRESH) | (abs(v) > UNKNOWN_FLOW_THRESH);
    u(idxUnknow) = 0;
    v(idxUnknow) = 0;

    maxu = max(maxu, max(max(u)));
    minu = min(minu, min(min(u)));

    maxv = max(maxv, max(v));
    minv = min(minv, min(v));

    rad = sqrt(u.^2 + v.^2);
    maxrad = max(max(-1, max(rad)));

    fprintf('max flow: %.4f\nflow range:\nu = %.3f .. %.3f\nv = %.3f .. %.3f\n', maxrad, minu,maxu, minv, maxv)

    u = u./(maxrad + eps);
    v = v./(maxrad + eps);

    img = compute_color(u, v);
    idx = cat(3, idxUnknow, idxUnknow, idxUnknow);
    img(idx) = 0;

end