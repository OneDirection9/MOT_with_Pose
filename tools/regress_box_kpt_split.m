function [ box_matrix ] = regress_box_kpt_split( people )
%REGRESS_BOX_KPT_SPLIT Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
    load('/home/sensetime/warmer/PoseTrack/challenge/data/prediction_6_001735_mpii_relpath_5sec_testsub_1', 'people');
end

box_matrix = [];
if(isempty(people))
    return;
end

box_matrix = cellfun(@regress_box_according_kpt, people, 'UniformOutput', false);

end

function [ box ] = regress_box_according_kpt( kpts )
    box = [];
    if(isempty(kpts))
        return;
    end
    
    is_nan = isnan(kpts);
    is_valid = sum(is_nan, 2) == 0;
    
    valid_kpts = kpts(is_valid, :);
    box = calculate_box( valid_kpts );
end

function [ box ] = calculate_box( points )
    box = struct();
    
    xs = points(:, 1);
    ys = points(:, 2);
    % calculate x, y, w, h
    minx = min(xs);
    miny = min(ys);
    maxx = max(xs);
    maxy = max(ys);
    
    box.x = minx;
    box.y = miny;
    box.w = maxx - minx;
    box.h = maxy - miny;
end