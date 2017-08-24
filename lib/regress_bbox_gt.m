function [ ] = regress_bbox_gt( annolist_file, videos_dir, save_dir, scale, isSave, isShow, useIncludeUnvisiable )
%CALCULATE_BBOX_GT Summary of this function goes here
%   Detailed explanation goes here
    
    fprintf('Calculating ground truth for `%s`\n', annolist_file);
    load(annolist_file, 'annolist');
    
    [file_path, file_name, ~] = fileparts(annolist_file);
    
    num_videos = size(annolist, 1);
    
    for vidx = 1:num_videos
        fprintf('Regressing bbox: %s(%d/%d).\n', annolist(vidx, :).name, vidx, num_videos);
        
        % video information
        vinfo = annolist(vidx, :);
        vname = vinfo.name;
        num_frames = vinfo.num_frames;
        num_persons = vinfo.num_persons;
        video_dir = fullfile(videos_dir, vname);
        
        fimages = dir([video_dir,'/*.jpg']);
        
        video_save_dir = fullfile(save_dir, vname);
        if(exist(video_save_dir))
            rmdir(video_save_dir, 's');
        end
        mkdir_if_missing(video_save_dir);
        % add field: bbox.
        vinfo.bbox = cell( num_persons, num_frames);
        for fidx = 1:num_frames
            % fprintf('Regressing bbox: %s(%d/%d). Frames: %d/%d\n', annolist(vidx, :).name, vidx, num_videos, fidx, num_frames);
            image_name = fimages(fidx).name;
            fimage = fullfile(video_dir, image_name);
            img = imread(fimage);
            
            if(isShow)
                figure(1), imshow(img);
                hold on;
            end
            
            [by, bx, ~] = size(img);
            for pidx = 1:num_persons
                % fprintf('Regressing bbox: %s(%d/%d). Frames: %d/%d Persons: %d/%d\n', annolist(vidx, :).name, vidx, num_videos, fidx, num_frames, pidx, num_persons);
                fp_info = vinfo.annopoints{pidx, fidx};
                
                % the pidx-th person in the fidx-th frames.
                if(isempty(fp_info))
                    continue;
                end
                if(~isfield(fp_info, 'point'))
                    continue;
                end
                
                bbox_gt = calculate_bbox(fp_info, scale, bx, by, useIncludeUnvisiable);
                vinfo.bbox{pidx, fidx} = bbox_gt;

                if(isempty(bbox_gt))
                    continue;
                end
                if(isShow)
                    rectangle('Position', [bbox_gt.x, bbox_gt.y, bbox_gt.w, bbox_gt.h], 'EdgeColor', 'r', 'LineWidth', 3);
                end
            end
            
            save_name = fullfile(video_save_dir, image_name);
            % save figures.
            if(isSave)
                print(gcf, '-r300', '-djpeg', save_name);
            end
            
            if(isShow)
                pause(0.001);     
            end
        end
        
        if(isShow)
            close all;
        end
        
        annolist(vidx).bbox = vinfo.bbox;
        annolist(vidx).scale = scale;
        annolist(vidx).useIncludeUnvisiable = useIncludeUnvisiable;
    end
    % save in the mat.
    save(annolist_file, 'annolist');
end

function [ bbox ] = calculate_bbox( annopoint, scale, bx, by, useIncludeUnvisiable )
    points = annopoint.point;
    
    bbox = struct();
    
    if(useIncludeUnvisiable)
        visible_idx = [1:size(points, 2)];
    else
        visible_idx = find(cellfun(@(x)isequal(x,1), {points.is_visible}));
    end
    
    if(isempty(visible_idx))
        bbox = [];
        return
    end
    xs = [points(visible_idx).x];
    ys = [points(visible_idx).y];
    % calculate x, y, w, h
    minx = min(xs);
    miny = min(ys);
    maxx = max(xs);
    maxy = max(ys);
    w = maxx - minx;
    h = maxy - miny;
    
    % calculate coordinate of center.
    half_w = w/2;
    half_h = h/2;
    x_center = minx + half_w;
    y_center = miny + half_h;
    half_w_s = half_w * scale;
    half_h_s = half_h * scale;
    
    top_left_x = x_center - half_w_s;
    top_left_y = y_center - half_h_s;
    bottom_right_x = x_center + half_w_s;
    bottom_right_y = y_center + half_h_s;
    
    [top_left_x, top_left_y] = constraintNotOutBoundary(top_left_x, top_left_y, bx, by);
    [bottom_right_x, bottom_right_y] = constraintNotOutBoundary(bottom_right_x, bottom_right_y, bx, by);
    
    bbox.x = top_left_x;
    bbox.y = top_left_y;
    bbox.w = bottom_right_x - top_left_x;
    bbox.h = bottom_right_y - top_left_y;
end

function [x, y] = constraintNotOutBoundary( x, y, bx, by)
    if(x < 0)
        x = 0;
    elseif(x > bx)
        x = bx;
    end
    
    if(y < 0)
        y = 0;
    elseif(y > by)
        y = by;
    end
end