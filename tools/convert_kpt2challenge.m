function [ ] = convert_kpt2challenge( multicut_dir, anno_dir, save_dir, expidx )
%CONVERT_KTP2CHALLENGE Summary of this function goes here
%   Detailed explanation goes here

clear;
clc;

if(nargin < 4)
    multicut_dir = './data/tmp/';
    anno_dir = './data/source_annotations/val/';
    save_dir = './data/evaluate_result/';
    mkdir_when_missing(save_dir);
    expidx = 6;
end

annolists = dir([anno_dir '/*.mat']);
num_videos = size(annolists, 1);

for vidx = 1:num_videos
    file_name = annolists(vidx).name;
    fprintf('Processing %s (%d/%d).\n', file_name, vidx, num_videos);
    anno_file = fullfile(anno_dir, file_name);
    
    pred_name = ['prediction_' num2str(expidx) '_' file_name];
    pred_file = fullfile(multicut_dir, pred_name);
    assert(exist(pred_file, 'file') == 2, 'Prediction file: %s does not exists.', pred_file);
    
    score_name = ['prediction_score_' num2str(expidx) '_' file_name];
    score_file = fullfile(multicut_dir, score_name);
    assert(exist(score_file, 'file') == 2, 'Score file: %s does not exists.', score_file);
    
    load(anno_file, 'annolist');
    load(pred_file, 'people_out');
    load(score_file, 'score_out');
    save_file = fullfile(save_dir, file_name);
    
    num_frames = size(annolist, 2);
    num_det_people = size(people_out, 1);
    assert(num_det_people <= 100, 'Track id of %s larger than 100', pred_file);
    
    pred = struct();
    for fidx = 1:num_frames
        pred(fidx).image.name = annolist(fidx).image.name;
        pred(fidx).imgnum = fidx;
        
        annorect = struct();
        pcount = 1;
        for pid = 1:num_det_people
            kpts = people_out{pid, fidx};
            scores = score_out{pid, fidx};
            if(isempty(kpts))
                continue;
            end
            
            is_nan = isnan(kpts);
            is_valid = sum(is_nan, 2) == 0;
            if(sum(is_valid, 1) == 0)
                continue;
            end
            
            annorect(pcount).track_id = pid - 1;
            
            num_kpts = size(kpts, 1);
            kcount = 1;
            points = struct();
            for kid = 1:num_kpts
                point = kpts(kid, :);
                score = scores(kid, 1);
                if sum(isnan(point), 2) == size(point, 2)
                    continue;
                end
                points(kcount).x = point(1);
                points(kcount).y = point(2);
                points(kcount).id = kid - 1;
                points(kcount).score = score;
                kcount = kcount + 1;
            end
            annorect(pcount).annopoints.point = points;
            pcount = pcount + 1;
        end
        pred(fidx).annorect = annorect;
    end
    
    annolist = pred;
    save(save_file, 'annolist');
end

end

function [ ] = mkdir_when_missing(dir)
    if(exist(dir, 'dir') == 7)
        return;
    end
    mkdir(dir);
end