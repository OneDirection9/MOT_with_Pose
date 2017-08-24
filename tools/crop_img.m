function [ ] = crop_img( expidx )
%CROP_IMG Summary of this function goes here
%   Detailed explanation goes here

p = bbox_exp_params(expidx);

train_annolist_file = p.trainGT;
test_annolist_file = p.testGT;

croped_det_dirs = p.cropedDetections;
matDetectionsDir = p.matDetectionsDir;
vidDir = p.vidDir;

crop(train_annolist_file, matDetectionsDir, vidDir, croped_det_dirs)
crop(test_annolist_file, matDetectionsDir, vidDir, croped_det_dirs)

end

function [] = crop(annolist_file, detections_dir, vidDir, save_dir)
    load(annolist_file, 'annolist');
    num_videos = size(annolist, 1);
    
    for vidx = 1:num_videos
        fprintf('%s. Cropping detections for %d/%d.\n', annolist_file, vidx, num_videos);
        vinfo = annolist(vidx, :);
        vname = vinfo.name;
        
        video_dir = fullfile(vidDir, vname);
        frames = dir([video_dir, '/*.jpg']);
        mat_detection = fullfile(detections_dir, vname);
        load(mat_detection, 'detections');
        
        save_det_dir = fullfile(save_dir, vname);
        if(exist(save_det_dir))
            rmdir(save_det_dir, 's');
        end
        mkdir(save_det_dir);
        
        num_det = size(detections.index, 1);
        for didx = 1:num_det
            fidx = detections.frameIndex(didx);
            fr_name = frames(fidx).name;
            fr_file = fullfile(video_dir, fr_name);
            fr_img = imread(fr_file);
            bbox = detections.unPos(didx, :); % x, y, w, h
            fr_img = imcrop(fr_img, bbox);
            
            save_file = fullfile(save_det_dir, [int2str(didx) '.jpg']);
            imwrite(fr_img, save_file);
        end
    end
end

