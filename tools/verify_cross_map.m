clear;
% clc;

testGT = './data/annolist/test/annolist';
cross_map = './data/cross_map/';
box_detections = './data/detections';
keypoints = './data/keypoints';
vidDir = '/media/sensetime/1C2E42932E4265BC/challenge/videos';

load(testGT, 'annolist');
num_videos = size(annolist, 1);

for vidx = 1:num_videos
    vinfo = annolist(vidx, :);
    vname = vinfo.name;
    
    vid_dir = fullfile(vidDir, vname);
    frames = dir([vid_dir '/*.jpg']);
    
    file_name = [ vname '.mat'];
    box_file = fullfile(box_detections, file_name);
    keypoints_file = fullfile(keypoints, file_name);
    cross_map_file = fullfile(cross_map, file_name);
    
    load(box_file, 'box_detections');
    load(keypoints_file, 'detections');
    load(cross_map_file, 'cross_map');
    
    num_keypoints = size(cross_map, 1);
    num_boxes = size(box_detections.unPos, 1);
    
    for bid = 1:num_boxes
        kidxs = cross_map(cross_map(:, 2) == bid);
        
        box_frame_idx = box_detections.frameIndex(bid);
        frame = frames(box_frame_idx).name;
        fprintf('Detection idx: %d, showing frame(%d): %s\n', bid, box_frame_idx, frame);
        frame_file = fullfile(vid_dir, frame);
        
        img = imread(frame_file);
        imshow(img); hold on;
        imshow(frame_file);
        rectangle('Position', box_detections.unPos(bid, :), 'EdgeColor', 'r', 'LineWidth', 3);
        
        num_keypoints = size(kidxs, 1);
        for kid = 1:num_keypoints
            id = kidxs(kid);
            keypoint_frame_idx = detections.frameIndex(id);
            assert(box_frame_idx == keypoint_frame_idx, 'Keypoint frame index not equal to box frame index.');
            
            x = detections.unPos(id, 1);
            y = detections.unPos(id, 2);
            plot(x, y, 'ro');
        end
        pause();
        close all;
    end
end

