function [ output_args ] = visual_box_and_kpt( vIdx )
%VISUAL_BOX_AND_KPT Summary of this function goes here
%   Detailed explanation goes here
vidDir = '/media/sensetime/1C2E42932E4265BC/challenge/videos';
testGT = './data/annolist/test/annolist';
multicutDir = './data/prune_tmp';
cross_map_dir = './data/cross_map';
keypoints_dir = './data/keypoints/';
expidx = 2;

colors = {'r','g','b','c','m','y'};
person_colors = hsv(10);
markerSize = 6;
lineWidth = 3;

load(testGT,'annolist');

fprintf('vididx: %d\n',vIdx);
ann = annolist(vIdx);
vid_name    = ann.name;
fprintf('video name: %s\n', vid_name);
vid_dir     = fullfile(vidDir, vid_name);
num_frames  = ann.num_frames;
fn          = dir([vid_dir,'/*.jpg']);

load([multicutDir '/prediction_' num2str(expidx) '_' vid_name], 'people');
load(fullfile(cross_map_dir, vid_name), 'cross_map');
load(fullfile(keypoints_dir, vid_name), 'detections');

for fidx = 1:num_frames 
    fprintf('Frame: %d/%d\n', fidx, num_frames);
    fr_fn = fullfile(vid_dir, fn(fidx).name);
    
    img = imread(fr_fn);
    
    % detections' index in the fidx-th frame.
    dIdxs = people.index(people.frameIndex == fidx);
    % detections' in the fidx-th frame is valid or not.
    valid = people.unLab(dIdxs, 1) == 1;
    % the index for detections needed to show.
    dIdxs = dIdxs(valid);
    origin_idxs = people.origin_index(dIdxs);
    % if none detections in this frame, continue.
    if(isempty(dIdxs))
        continue;
    end
    
    % the position for detections. [x, y, w, h]
    det_pos = people.unPos(dIdxs, :);
    % the clusters for each detections.
    clusters = people.unLab(dIdxs, 2);
    
    num_dets = size(det_pos,1);
    
    for didx = 1:num_dets
        figure(fidx), imshow(img); hold on;
        cluster = clusters(didx);
        color = colors{mod(cluster, length(colors))+1};
        pos = det_pos(didx, :);
        rectangle('Position', pos, 'EdgeColor', color, 'LineWidth', lineWidth);
        text(pos(1)+5, pos(2)+15, num2str(cluster), 'FontSize', 20);
        
        origin_idx = origin_idxs(didx);
        ktp_idxs = cross_map(:, 2) == origin_idx;
        keys = cross_map(ktp_idxs, 1);
        keys_pos = detections.unPos(keys, :);
        key_score = detections.unProb(keys, :);
        num_keys = size(keys, 1);
        for kid = 1:num_keys
            x = keys_pos(kid, 1);
            y = keys_pos(kid, 2);
            plot(x, y, [color '*']);
            text(x, y, num2str(key_score(kid)), 'FontSize', 10, 'Color', color);
        end
        pause();
        close all;
    end 
    
end


end

