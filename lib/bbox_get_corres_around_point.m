function [ out_corres, idx ] = bbox_get_corres_around_point(in_corres, pt, patch_size)
%PT_GET_CORRES_AROUND_POINT Summary of this function goes here
%   Detailed explanation goes here

if(isempty(in_corres))
    out_corres = [];
    return;
end

r = patch_size / 2;

% --------
% |      |
% |      |
% |      |
% |      |
% --------
% pt: x, y, w, h
% left-top point: x, y
idx = bitand(in_corres(:,1) >= pt(1), in_corres(:,1) <= pt(1)+pt(3));
tmp_corres = in_corres;
tmp_corres(~idx,:) = nan;

idx = bitand(tmp_corres(:,2) >= pt(2), tmp_corres(:,2) <= pt(2)+pt(4));
out_corres = tmp_corres(idx,:);

int_idx = [1:size(in_corres,1)]';
idx = int_idx(idx);

end

