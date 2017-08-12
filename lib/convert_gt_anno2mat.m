function [ output_args ] = convert_gt_anno2mat( annolist_file, save_dir )
%CONVERT_GT Summary of this function goes here
%   Detailed explanation goes here

    load(annolist_file, 'annolist');
    
    num_videos = size(annolist, 1);
    for vidx = 1:num_videos
        fprintf('Convert ground truth to detections: `%s`. Videos: %d/%d\n', annolist_file, vidx, num_videos);
        
        % video information
        vinfo = annolist(vidx,:);
        vname = vinfo.name;
        vbbox = vinfo.bbox;
        num_persons = vinfo.num_persons;
        num_frames = vinfo.num_frames;
        
        detections = struct();
        detections.unPos = [];
        detections.frameIndex = [];
        
        for fidx = 1:num_frames
            for pidx = 1:num_persons
                
                % bbox: x, y, w, h
                bbox_s = vbbox{pidx, fidx};
                
                % skip empty entry.
                if(isempty(bbox_s))
                    continue;
                end
                
                bbox_a = struct2array(bbox_s);
                detections.unPos = [detections.unPos; bbox_a];
                detections.frameIndex = [detections.frameIndex; fidx];
            end
        end
        
        num_detections = size(detections.unPos, 1);
        detections.unProb = ones(num_detections, 1);
        detections.index = [1:num_detections]';
        detections.scale = ones(num_detections, 1);
        detections.partClass = zeros(num_detections, 1);
        
        save_file = fullfile(save_dir, vname);
        save(save_file, 'detections');
    end
end

