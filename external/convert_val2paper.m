function [ ] = convert_val2paper( source_dir, save_mat_file, save_dir, prefix, isSave )
%CONVERT_VAL2PAPER Summary of this function goes here
%   Detailed explanation goes here

source_files = dir([source_dir, '/*.mat']);
num_videos = size(source_files, 1);

pre = [];
for vidx=1:num_videos
    source_file = source_files(vidx).name;
    source_file = fullfile(source_dir, source_file);
    load(source_file, 'annolist');
    fprintf('Covnerting %s.\t%d/%d\n', source_file, vidx, num_videos);
    
    [~, only_name, ~] = fileparts(source_file);
    if isSave
        save_video_dir = fullfile(save_dir, only_name);
        % Guarantee the video name only occurred once.
        assert(exist(save_video_dir, 'dir') ~= 7, 'ERROR: Video name `%s` alredy exists.', save_video_dir);
        mkdir(save_video_dir);
    end
    
    cur = struct();
    num_frames = size(annolist, 2);
    % calculate num_persons
    min_id = 0;
    max_id = 0; 
    for tfidx = 1:num_frames
        f_anno = annolist(tfidx);
        
        if f_anno.is_labeled == 1
            if isempty(f_anno.annorect)
                continue;
            end
            
            annorects = f_anno.annorect;
            persons = size(annorects, 2);
            
            for pidx = 1:persons
                annorect = annorects(pidx);
                t_id = annorect.track_id;
                min_id = min(min_id, t_id);  
                max_id = max(max_id, t_id);
            end
        end
    end
    num_persons = max_id - min_id + 1;
    
    % format cur
    cur.num_frames = num_frames;
    cur.name = only_name;
    cur.num_persons = num_persons;
    cur.annopoints = cell(num_persons, num_frames);
    cur.is_labeled = [ annolist.is_labeled ];
    
    if isfield(annolist, 'ignore_regions')
        cur.ignore_regions = cell(1, num_frames);
    else
        cur.ignore_regions = [];
    end
    
    % calculate annopoints
    for fidx = 1:num_frames
        % copy images to save_video_dir
        if isSave
            img_file = annolist(fidx).image.name;
            img_file = fullfile(prefix, img_file);
            [~, ~, suffix] = fileparts(img_file);
            save_name = sprintf('%05d%s', fidx, suffix);
            save_file = fullfile(save_video_dir, save_name);
            command = ['cp ' img_file ' ' save_file];
            s = unix(command);
            assert(s == 0);
        end
        
        % format annopoints
        if annolist(fidx).is_labeled == 1
            if isempty(annolist(fidx).annorect)
                continue;
            end
            
            if isfield(annolist, 'ignore_regions')
                cur.ignore_regions{fidx} = annolist(fidx).ignore_regions;
            end
    
            annorects = annolist(fidx).annorect;
            persons = size(annorects, 2);
            for pidx = 1:persons
                tmp = struct();
                annorect = annorects(pidx);
                t_id = annorect.track_id;

                if (~isfield(annorect, 'annopoints')) || isempty(annorect.annopoints) || (~isfield(annorect.annopoints, 'point'))
                    tmp.point = [];
                else
                    tmp.point = annorect.annopoints.point;
                    num_points = size(tmp.point, 2);
                    indexs = [];
                    for point_idx = 1:num_points
                        point = tmp.point(point_idx);
                        if point.x < -100 || point.y < -100
                            indexs = cat(1, indexs, point_idx);
                        end
                    end
                    tmp.point(indexs) = [];
                end
                
                if size(indexs, 1) == num_points
                    pause();
                end
                
                tmp.head_rect = [annorect.x1, annorect.y1, annorect.x2, annorect.y2];
                cur.annopoints{t_id + 1, fidx} = tmp;
            end
        end
    end
    
    if isempty(pre)
        pre = cur;
    else
        pre = cat(1, pre, cur);
    end
end

annolist = pre;
save(save_mat_file, 'annolist');

end

