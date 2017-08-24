function [] = bbox_vis_people(expidx, vIdx, multicutDir, options)

if(nargin < 4)
    options.minTrackLen = 6;
    options.minAvgJoints = 5;
end

colors = {'r','g','b','c','m','y'};
person_colors = hsv(10);
markerSize = 6;
lineWidth = 3;

p = bbox_exp_params(expidx);
% exp_dir = fullfile(p.expDir, p.shortName);
load(p.testGT,'annolist');

if(nargin < 3)
    multicutDir = p.ptMulticutDir;
end

fprintf('vididx: %d\n',vIdx);
ann = annolist(vIdx);
vid_name    = ann.name;
vid_dir     = fullfile(p.vidDir, vid_name);
num_frames  = ann.num_frames;
fn          = dir([vid_dir,'/*.jpg']);

load([multicutDir '/prediction_' num2str(expidx) '_' vid_name], 'people');

for fidx = 1:num_frames 
    fprintf('Frame: %d/%d\n', fidx, num_frames);
    fr_fn = fullfile(vid_dir, fn(fidx).name);
    
    img = imread(fr_fn);
    figure(1), imshow(img); hold on;
    
    % detections' index in the fidx-th frame.
    dIdxs = people.index(people.frameIndex == fidx);
    % detections' in the fidx-th frame is valid or not.
    valid = people.unLab(dIdxs, 1) == 1;
    % the index for detections needed to show.
    dIdxs = dIdxs(valid);
    
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
        cluster = clusters(didx);
        color = colors{mod(cluster, length(colors))+1};
        pos = det_pos(didx, :);
        rectangle('Position', pos, 'EdgeColor', color, 'LineWidth', lineWidth);
        text(pos(1)+5, pos(2)+15, num2str(cluster), 'FontSize', 20);
    end 
    
    pause(0.001);
end
close all;
end