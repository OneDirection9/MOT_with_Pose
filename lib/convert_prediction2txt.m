function [ ] = convert_prediction2txt( expidx, save_dir, annolist_test, prediction_dir, pruneThresh, curSaveDir )
%GENERATE_MOT_DET Summary of this function goes here
%   Detailed explanation goes here

    if(nargin<5)
        pruneThresh = 5;
    end
    load(annolist_test, 'annolist');
    
    num_videos = size(annolist, 1);
    
    for vidx = 1:num_videos
        fprintf('Converting prediction to txt: `%s`. Videos: %d/%d\n', annolist(vidx,:).name, vidx, num_videos);
        % video name
        vinfo = annolist(vidx, :);
        vname = vinfo.name;
        num_frames = vinfo.num_frames;
        
        save_file = fullfile(save_dir, [vname '.txt']);
        fsave = fopen(save_file, 'w');
        
        prediction_save_file = fullfile(curSaveDir, ['/prediction_' num2str(expidx) '_' vname]);
        % prediction result.
        pred_file = fullfile(prediction_dir, ['/prediction_' num2str(expidx) '_' vname]);
        load(pred_file, 'people');
        unLab = people.unLab;
        
        clusters = unique(unLab(:, 2));
        num_cluster = size(clusters, 1);
        for cidx = 1:num_cluster
            % cluster number
            cluster = clusters(cidx);
            % index for detections belong to cluster
            indexs = people.index(unLab(:,2) == cluster);
            num_ = size(indexs, 1);
            
            if(num_ <= pruneThresh)
                people.unLab(indexs, 1) = 0;
                continue;
            end
            cpeople = MultiScaleDetections.slice(people, indexs);
            people = MergeWithinFrame(people, cpeople, num_frames);
            
            for i = 1:num_
                index = indexs(i);
                isValid = people.unLab(index, 1);
                if isValid == 0
                    continue;
                end
                bbox = people.unPos(index, :);
                fidx = people.frameIndex(index, :);
                fprintf(fsave, [num2str(fidx), ',']); % frame index
                fprintf(fsave, [num2str(cluster), ',']); % object id
                fprintf(fsave, [num2str(bbox(1)), ',']); % x
                fprintf(fsave, [num2str(bbox(2)), ',']); % y
                fprintf(fsave, [num2str(bbox(3)), ',']); % w
                fprintf(fsave, [num2str(bbox(4)), ',']); % h
                fprintf(fsave, [num2str(-1), ',']); % flag
                fprintf(fsave, [num2str(-1), ',']); % X
                fprintf(fsave, [num2str(-1), ',']); % Y
                fprintf(fsave, [num2str(-1), ',']); % Z
                fprintf(fsave, '\n');
            end
        end
        
        save(prediction_save_file, 'people');
    end
end

function [ people ] = MergeWithinFrame(people, cpeople, num_frames)
    for fidx = 1:num_frames
        idxs = find(cpeople.frameIndex == fidx);
        num_dets = size(idxs, 1);
        if num_dets > 1
            indexs = cpeople.index(idxs);
            people.unLab(indexs, 1) = 0;
            
            probs = cpeople.unProb(idxs);
            [~, max_idx] = max(probs);
            idd = idxs(max_idx);
            index = cpeople.index(idd);
            people.unLab(index, 1) = 1;
        end
    end
end

