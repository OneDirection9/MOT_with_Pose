function [ ] = convert_txt_with_keypoints(p)
% convert txt files under source_dir to mat and saved in save_dir.
% 

if nargin < 1
    keypoints_dir = './data/keypoints_txt/';
    save_keypoint_dir = './data/keypoints/';
    save_map_dir = './data/cross_map/';
    testGT = './data/annolist/test/annolist';
    score_thresh = 0;
end

load(testGT, 'annolist');

% % empty save_dir
% if exist(save_dir, 'dir')
%     fprintf('`%s` already exists, delete.\n', save_dir);
%     rmdir(save_dir, 's');
% end
mkdir_if_missing(save_keypoint_dir);
mkdir_if_missing(save_map_dir);

num_videos = size(annolist, 1);
for i = 1:num_videos
    vinfo = annolist(i, :);
    vname = vinfo.name;
    num_frames = vinfo.num_frames;
    
    file_name = [ vname '.txt' ];
    full_file = fullfile(keypoints_dir, file_name);
    assert(exist(full_file, 'file') ~= 0);
    
    fprintf('Converting detection txt `%s` to mat. %d/%d\n', vname, i, num_videos);
    [box_idxs, frame_idxs, xs, ys, scores] = textread(full_file, '%f%f%f%f%f');
    
    % convert `full_file` to mat.
    % fields: unPos, unProb, frameIndex, index, scale, partClass.
    detections = struct();
    [valid_indexs, classes] = generate_valid_index(scores, score_thresh);
    num_keypoints = sum(valid_indexs);
    
    detections.unPos = [xs(valid_indexs == 1), ys(valid_indexs == 1)];
    
    scores = min(1 - 1e-15, scores);
    scores = max(1e-15, scores);
    detections.unProb = scores(valid_indexs == 1);
    detections.frameIndex = frame_idxs(valid_indexs == 1);
    detections.cand = [1:num_keypoints]';
    detections.scale = ones(num_keypoints, 1);
    detections.partClass = classes;

    % save as the mat.
    file_name = deblank(file_name);
    splits = regexp(file_name, '\.', 'split'); % 000001.txt_result.txt => [000001, txt_result, txt]
    save_name = splits{1};
    full_save = fullfile(save_keypoint_dir, save_name);
    save(full_save, 'detections');
    
    cross_map = struct();
    cross_map = [1:num_keypoints]';
    cross_map = [cross_map, box_idxs(valid_indexs == 1)];
    full_map_save = fullfile(save_map_dir, save_name);
    save(full_map_save, 'cross_map');
end

fprintf('Convert keypoints .txt to .mat, done.\n');
end

function [ valid_idxs, classes ] = generate_valid_index( scores, score_thresh )
    num_keypoints = size(scores, 1);
    valid_idxs = ones(num_keypoints, 1);
    classes = [];
    
    for id = 1:num_keypoints
        cid = rem(id - 1, 15) + 1;
        if scores(id) < score_thresh
            valid_idxs(id) = 0;
            continue;
        end
        classes = [classes; cid];
    end
end
