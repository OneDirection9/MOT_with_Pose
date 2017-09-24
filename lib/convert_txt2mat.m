function [ ] = convert_txt2mat(p, IOU_thresh)
% convert txt files under source_dir to mat and saved in save_dir.
% 

if nargin < 2
    IOU_thresh = 0.3;
end

source_dir = p.txtDetectionsDir;
save_dir = p.matDetectionsDir;

testGT = p.testGT;
load(testGT, 'annolist');

% % empty save_dir
% if exist(save_dir, 'dir')
%     fprintf('`%s` already exists, delete.\n', save_dir);
%     rmdir(save_dir, 's');
% end
% mkdir(save_dir);

num_videos = size(annolist, 1);
for i = 1:num_videos
    vinfo = annolist(i, :);
    vname = vinfo.name;
    num_frames = vinfo.num_frames;
    
    file_name = [ vname '.txt' ];
    full_file = fullfile(source_dir, file_name);
    assert(exist(full_file, 'file') ~= 0);
    
    fprintf('Converting detection txt `%s` to mat. %d/%d\n', vname, i, num_videos);
    [names, xs, ys, ws, hs, scores] = textread(full_file, '%f%f%f%f%f%f');
    
    if false && ~isempty(vinfo.ignore_regions)
        num_det = size(names, 1);
        not_ignore = ones(1, num_det); % 1: not ignore.
        
        % read for img size.
        img_size = vinfo.img_size;
        
        % calculate pair.
        [q1, q2] = meshgrid(1:img_size(1), 1:img_size(2));
        idxsAllrel = [ q1(:) q2(:)];
        
        for fidx = 1:num_frames
            ignore_regions = vinfo.ignore_regions{fidx};
            if isempty(ignore_regions)
                continue;
            end
            
%             full_name = sprintf('%05d', fidx);
%             frame_file = fullfile(vid_dir, [full_name '.jpg']);
%             img = imread(frame_file);
%             imshow(img);
            
            frame_mask = generateFrameMask(img_size(1:2), ignore_regions, idxsAllrel);
            
            % calculate sub matrix for each detection
            det_idxs = find(names == fidx);
            det_xs = xs(det_idxs);
            det_ys = ys(det_idxs);
            det_ws = ws(det_idxs);
            det_hs = hs(det_idxs);
            minxs = max(1, floor(det_xs));
            minys = max(1, floor(det_ys));
            maxxs = max(1, floor(det_xs + det_ws));
            maxys = max(1, floor(det_ys + det_hs));
            
            num_dets = size(det_idxs, 1);
            for id = 1:num_dets
                sub_matrix = frame_mask(minys(id):maxys(id), minxs(id):maxxs(id));
                num_pixels = sum(sum(sub_matrix));
                iou = num_pixels / (det_ws(id) * det_hs(id));
                if iou > IOU_thresh
                    not_ignore(det_idxs(id)) = 0;
                end
            end
        end
        
        names = names(not_ignore == 1);
        xs = xs(not_ignore == 1);
        ys = ys(not_ignore == 1);
        ws = ws(not_ignore == 1);
        hs = hs(not_ignore == 1);
        scores = scores(not_ignore  == 1);
    end
    
    % convert `full_file` to mat.
    % fields: unPos, unProb, frameIndex, index, scale, partClass.
    detections = struct();
    detections.unPos = [xs, ys, ws, hs];
    
    scores = min(1 - 1e-15, scores);
    scores = max(1e-15, scores);
    detections.unProb = scores;
    detections.frameIndex = names;
    detections.index = [1:size(names,1)]';
    detections.scale = ones(size(names,1), 1);
    detections.partClass = zeros(size(names,1), 1);

    % save as the mat.
    file_name = deblank(file_name);
    splits = regexp(file_name, '\.', 'split'); % 000001.txt_result.txt => [000001, txt_result, txt]
    save_name = splits{1};
    full_save = fullfile(save_dir, save_name);
    save(full_save, 'detections');
end

fprintf('Convert detection .txt to .mat, done.\n');
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