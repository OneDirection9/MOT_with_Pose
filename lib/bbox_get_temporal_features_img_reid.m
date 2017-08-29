function [ feat ] = bbox_get_temporal_features_img_reid( p, locs1, features_fr1, locs2, features_fr2, idxs_pt_pair )
%BBOX_GET_TEMPORAL_FEATURES_IMG_REID Summary of this function goes here
%   Detailed explanation goes here

if (nargin < 5)
    [p,q] = meshgrid(size(locs1,1), size(locs2,1));
    idxs_pt_pair = [p(:) q(:)];
end

if(isempty(locs1) || isempty(locs2) || isempty(features_fr1) || isempty(features_fr2))
    feat = [];
    return;
end

num_pairs = size(idxs_pt_pair,1);

feat =  zeros(num_pairs, 1);

try
    
for i = 1:num_pairs
    
    pidx1 = locs1(idxs_pt_pair(i, 1), 5);
    pidx2 = locs2(idxs_pt_pair(i, 2), 5);
    p1_feature = features_fr1(pidx1, :);
    p2_feature = features_fr2(pidx2, :);
    
    feat(i) = (p1_feature - p2_feature) * (p1_feature - p2_feature)';
end

catch
    keyboard();
end
end

