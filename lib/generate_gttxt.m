function [] = generate_gttxt( annolist_file, save_dir, usage, IOU_thresh )

    if nargin < 4
        IOU_thresh = 0.3;
    end

    load(annolist_file);
    
%     if exist(save_dir, 'dir')
%         rmdir(save_dir, 's');
%     end
    mkdir_if_missing(save_dir);
        
    num_videos = size(annolist, 1);
    
    for vidx = 1:num_videos
        fprintf('Generating gt.txt. `%s: %s`. Videos: %d/%d\n', usage, annolist(vidx).name, vidx, num_videos);
        
        % video information.
        vinfo = annolist(vidx,:);
        vname = vinfo.name;
        num_frames = vinfo.num_frames;
        num_persons = vinfo.num_persons;
        fbbox = vinfo.bbox;
        
        % generate img1 , det.
        mkdir_if_missing(fullfile(save_dir, vname, 'det'));
        mkdir_if_missing(fullfile(save_dir, vname, 'img1'));
        % save in the gt/gt.txt
        save_result_dir = fullfile(save_dir, vname, 'gt');
        mkdir_if_missing(save_result_dir);
        save_file = fullfile(save_result_dir, 'gt.txt');
        fsave = fopen(save_file, 'w');
        
        % read for img size.
        img_size = vinfo.img_size;
        % calculate pair.
        [q1, q2] = meshgrid(1:img_size(1), 1:img_size(2));
        idxsAllrel = [ q1(:) q2(:)];
        
        frame_mask = [];
        for fidx = 1:num_frames
            if ~isempty(vinfo.ignore_regions)
                ignore_regions = vinfo.ignore_regions{fidx};
                if ~isempty(ignore_regions)
                    frame_mask = generateFrameMask(img_size(1:2), ignore_regions, idxsAllrel);
                end
            end
            
            for pidx = 1:num_persons
                % fprintf('Generating gt.txt. `%s: %s`. person/frame: %d/%d\n', usage, annolist(vidx).name, pidx, fidx);
                % skip empty entry
                pbox = fbbox{pidx, fidx};
                if(isempty(pbox))
                    continue;
                end
                
                if ~isempty(frame_mask)
                    x = max(1, floor(pbox.x));
                    y = max(1, floor(pbox.y));
                    w = floor(pbox.w);
                    h = floor(pbox.h);
                    maxy = min(img_size(1), y + h);
                    maxx = min(img_size(1), x + w);
                    sub_matrix = frame_mask(y : maxy, x : maxx);
                    num_pixels = sum(sum(sub_matrix));
                    iou = num_pixels / (w * h);
                    if iou > IOU_thresh
                        continue;
                    end
                end
                
                % frameid, objid, x, y, w, h, flag, X, Y, Z
                fprintf(fsave, [num2str(fidx), ',']); % frame id
                fprintf(fsave, [num2str(pidx), ',']); % object id
                fprintf(fsave, [num2str(pbox.x), ',']); % x
                fprintf(fsave, [num2str(pbox.y), ',']); % y
                fprintf(fsave, [num2str(pbox.w), ',']); % w
                fprintf(fsave, [num2str(pbox.h), ',']); % h
                fprintf(fsave, [num2str(1), ',']); % flag: 1(evaluate), 0(not evaluate)
                fprintf(fsave, [num2str(1), ',']); % X
                fprintf(fsave, [num2str(1), ',']); % Y
                fprintf(fsave, [num2str(1), ',']); % Z
                fprintf(fsave, '\n');
            end
        end
        fclose(fsave);
    end
    fprintf('Generate gt.txt done.\n');
end

function [ frame_mask ] = generateFrameMask(img_size, ignore_regions, idxsAllrel)
    all_points = [];
    
    num_ignore = size(ignore_regions, 2);
    for ig_idx = 1:num_ignore
        if isfield(ignore_regions(ig_idx), 'point')
            num_points = length(ignore_regions(ig_idx).point);
            ir_points  = get_points(ignore_regions(ig_idx), num_points);
            idx  = ~isnan(ir_points(:,1));
            ir_points = ir_points(idx,:);
            all_points = [all_points; ir_points; NaN, NaN];
        end
    end
    ins = inpolygon(idxsAllrel(:,2), idxsAllrel(:, 1), all_points(:, 1), all_points(:, 2));
    frame_mask = reshape_C(ins, [img_size, 1]);
end

function points = get_points(annopoints, num_points)
    points = NaN(num_points, 2);
    
    if(isfield(annopoints, 'point'))
        ids  = [annopoints.point.id]+1;
        x = [annopoints.point.x]';
        y = [annopoints.point.y]';
        points(ids,:) = [x, y];
    end
end