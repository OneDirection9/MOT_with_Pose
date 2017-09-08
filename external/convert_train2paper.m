function [] = convert_train2paper(source_dir, save_mat_file, save_dir, prefix, isSave)

source_files = dir([source_dir, '/*.mat']);
num_videos = size(source_files, 1);

pre = [];
for vidx=1:num_videos
    source_file = source_files(vidx).name;
    source_file = fullfile(source_dir, source_file);
    load(source_file, 'annolist');
    fprintf('Covnerting %s.\n', source_file);
    
    [~, only_name, ~] = fileparts(source_file);
    
    if isSave
        save_video_dir = fullfile(save_dir, only_name);
        % Guarantee the video name only occurred once.
        assert(exist(save_video_dir, 'dir') ~= 7, 'ERROR: Video name `%s` alredy exists.', save_video_dir);
        mkdir(save_video_dir);
    end
    
    cur = struct();
    % calculate num_frames.
    % choose labeld frames.
    total_frames = size(annolist, 2);
    sidx = -1; eidx = -1;
    for tfidx = 1:total_frames
        if annolist(tfidx).is_labeled == 1 && sidx == -1
            sidx = tfidx;
        elseif annolist(tfidx).is_labeled == 1
            eidx = tfidx;
        end
    end
    labeled = annolist(sidx:eidx);
    num_frames = size(labeled, 2);
    
    % calculate num_persons
    min_id = 0;
    max_id = 0;
    for lfidx = 1:num_frames
        if isempty(labeled(lfidx).annorect)
            continue;
        end
        
        annorects = labeled(lfidx).annorect;
        persons = size(annorects, 2);
        
        for pidx = 1:persons
            annorect = annorects(pidx);
            t_id = annorect.track_id;
            min_id = min(min_id, t_id);
            max_id = max(max_id, t_id);
        end
    end
    num_persons = max_id - min_id + 1;
    
    % format cur
    cur.num_frames = num_frames;
    cur.name = only_name;
    cur.num_persons = num_persons;
    cur.annopoints = cell(num_persons, num_frames);
    
    % calculate annopoints
    for lfidx = 1:num_frames
        if isSave
            % copy images to save_video_dir
            img_file = labeled(lfidx).image.name;
            img_file = fullfile(prefix, img_file);
            [~, ~, suffix] = fileparts(img_file);
            save_name = sprintf('%05d%s', lfidx, suffix);
            save_file = fullfile(save_video_dir, save_name);
            command = ['cp ' img_file ' ' save_file];
            s = unix(command);
            assert(s == 0);
        end
        
        % format annopoints
        if isempty(labeled(lfidx).annorect)
            continue;
        end
        annorects = labeled(lfidx).annorect;
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
                
                if size(indexs, 1) == num_points
                    pause();
                end
                
                tmp.point(indexs) = [];
            end
            tmp.head_rect = [annorect.x1, annorect.y1, annorect.x2, annorect.y2];
            cur.annopoints{t_id + 1, lfidx} = tmp;
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