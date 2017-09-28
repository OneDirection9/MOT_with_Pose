function [ ] = convert_pred2challenge( pred_dir, gt_dir, save_dir, expidx )
%CONVERT_PRED2CHALLENGE Summary of this function goes here
%   Detailed explanation goes here

clear;
clc;

if nargin < 1
    % pred_dir = '/home/sensetime/warmer/PoseTrack/challenge/data/mot-multicut/';
    pred_dir = '/home/sensetime/warmer/PoseTrack/challenge/data/prune_tmp';
    gt_dir = '/home/sensetime/warmer/PoseTrack/challenge/data/source_annotations/val/';
    save_dir = '/home/sensetime/warmer/PoseTrack/challenge/data/predictions/';
    mkdir_if_missing(save_dir);
    cross_map_dir = '/home/sensetime/warmer/PoseTrack/challenge/data/cross_map';
    keypoints_dir = '/home/sensetime/warmer/PoseTrack/challenge/data/keypoints';
    score_thresh = 0.02;
    expidx = 2;
end

if isnumeric(expidx)
    expidx = num2str(expidx);
end

prefix = ['prediction_' expidx '_'];

anno_GT = dir([gt_dir '/*.mat']);

num_videos = size(anno_GT, 1);

for vidx = 1:num_videos
    file_name = anno_GT(vidx).name;
    fprintf('Converting prediction for %s to challenge %d/%d.\n', file_name, vidx, num_videos);
    
    gt_file = fullfile(gt_dir, file_name);
    
    pred_file = fullfile(pred_dir, [prefix file_name]);
    assert( exist(pred_file, 'file') == 2, 'Prediction for %s does not exists.', file_name );
    keypoints_file = fullfile(keypoints_dir, file_name);
    assert(exist(keypoints_file, 'file') == 2, 'Keypoints for %s does not exists.', file_name);
    cross_map_file = fullfile(cross_map_dir, file_name);
    assert(exist(cross_map_file, 'file') == 2, 'Cross map file for %s does not exists.', file_name);
    
    save_file = fullfile(save_dir, file_name);
    
    load(pred_file, 'people');
    load(gt_file, 'annolist');
    load(keypoints_file, 'detections');
    load(cross_map_file, 'cross_map');
    
    num_frames = size(annolist, 2);
    valid_idxs = people.unLab(:, 1) == 1;
    valid_track_ids = people.unLab(valid_idxs, 2);
    uni_track_ids = unique(valid_track_ids);
    
    pred = struct();
    for fidx = 1:num_frames
        pred(fidx).image.name = annolist(fidx).image.name;
        pred(fidx).imgnum = fidx;
        
        annorect = struct();
        wpeople = slice(people, fidx);
        
        unlab = wpeople.unLab;
        num_clusters = size(unlab, 1);
        count = 1;
        for cid = 1:num_clusters
             if(unlab(cid, 1) == 0)
                continue;
             end
             
             box_id = wpeople.origin_index(cid);
             origin_track_id = unlab(cid, 2);
             id = find(uni_track_ids == origin_track_id) - 1; % start from 0
             annorect(count).track_id = id;
             annorect(count).box_id = box_id;
             annorect(count).box_pos = wpeople.unPos(cid, :);
             annorect(count).box_score = wpeople.unProb(cid, :);
             key_idxs = cross_map(:, 2) == box_id;
             key = cross_map(key_idxs, :);
             points = generate_points(detections, key, fidx, score_thresh);
             if(isempty(points))
                continue;
             end
             annorect(count).annopoints.point = points;
             count = count + 1;
        end
        pred(fidx).annorect = annorect;
    end
    
    annolist = pred;
    save(save_file, 'annolist');
end

end

function [ wpeople ] = slice( people, fidx )
    cur_frame_index = people.frameIndex == fidx;
    
    wpeople.unPos = people.unPos(cur_frame_index, :);
    wpeople.unProb = people.unProb(cur_frame_index, :);
    wpeople.unLab = people.unLab(cur_frame_index, :);
    wpeople.frameIndex = people.frameIndex(cur_frame_index, :);
    wpeople.index = people.index(cur_frame_index, :);
    wpeople.origin_index = people.origin_index(cur_frame_index, :);
end

function [ points ] = generate_points(detections, key_idxs, fidx, score_thresh)
    points = [];
    
    frame_idxs = detections.frameIndex(key_idxs(:, 1), :);
    frame_id = unique(frame_idxs);
    assert(size(frame_id, 1) == 1, 'keypoints not in the same frame.');
    assert(frame_id == fidx, 'frame id not match.');
    
    pos = detections.unPos(key_idxs(:, 1), :);
    probs =detections.unProb(key_idxs(:, 1), :);
    
    k_id = 0;
    count = 1;
    num_kpts = size(pos, 1);
    for kid = 1:num_kpts
        prob = probs(kid, :);
        if(prob < score_thresh)
            continue;
        end
        
        points(count).x = pos(kid, 1);
        points(count).y = pos(kid, 2);
        points(count).id = k_id;
        points(count).score = prob;
        
        count = count + 1;
        k_id = k_id + 1;
    end
end