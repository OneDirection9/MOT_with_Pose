function [ output_args ] = draw_bbox_detection( videos_dir, annolist_file, detection_dir, save_dir )
%BBOX_DETECTION_DRAW Summary of this function goes here
%   Detailed explanation goes here

    fprintf('Draw detect results ...\n');
    
    load(annolist_file, 'annolist');
    num_videos = size(annolist, 1);

    for vidx = 1:num_videos
        % video information
        vinfo = annolist(vidx, :);
        vname = vinfo.name;
        num_frames = vinfo.num_frames;
        
        video_dir = fullfile(videos_dir, vname);
        fimages = dir([video_dir, '/*.jpg']);
        % empty the original save dir.
        video_save_dir = fullfile(save_dir, vname);
        if(exist(video_save_dir))
            rmdir(video_save_dir, 's');
        end
        mkdir_if_missing(video_save_dir);
        
        % load detection file
        detection_file = fullfile(detection_dir, vname);
        load(detection_file, 'detections');
        for fidx = 1:num_frames
            fprintf('Videos: %s(%d/%d). Frames: %d/%d\n', vname, vidx, num_videos, fidx, num_frames);
            % detections' positions.
            dposs = detections.unPos(detections.frameIndex == fidx, :);
            num_detections = size(dposs, 1);
            % show figure.
            fimg_name = fimages(fidx).name;
            fimg = fullfile(video_dir, fimg_name);
            img = imread(fimg);
            figure(1); imshow(img);
            hold on;
            % draw rectangle.
            for didx = 1:num_detections
                rectangle('Position', dposs(didx, :), 'EdgeColor', 'r', 'LineWidth', 3);
            end
            % save file.
            save_name = fullfile(video_save_dir, fimg_name);
            % print(gcf, '-r300', '-djpeg', save_name);
            pause(0.001);
        end
        close all;
    end
    
end