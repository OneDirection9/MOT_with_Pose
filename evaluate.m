% main function.

% get parameters.
expidx = 2;
p = bbox_exp_params(expidx);


if(~p.useGT)
    % convert *.txt to *.mat
    source_dir = p.txtDetectionsDir;
    save_dir = p.matDetectionsDir;
    fprintf('Use dection to track.\n');
    convert_txt2mat(source_dir, save_dir);
else
    % getnerate detections mat from annolist.bbox.
    fprintf('Use ground truth to track.\n');
    save_dir = p.matDetectionsDir;
    convert_gt_anno2mat(p.trainGT, save_dir);
    convert_gt_anno2mat(p.testGT, save_dir);
end

% Test model

% Index of the video. Use any value between 1-30
start_index = 1;

% Number of videos to process starting from the index 'start_index'
num_videos = 30;

% multiple object tracking
% bbox_tracking(2, start_index, num_videos, false, true);

% convert prediction to txt format follow MOT15 format.
curSaveDir = fullfile(p.expDir, 'thresh02_pre_prune');
% convert_prediction2txt( expidx, p.motPredictionSaveDir, p.testGT,
% p.ptMulticutDir, p.pruneThresh);
convert_prediction2txt( expidx, p.motPredictionSaveDir, p.testGT, p.ptMulticutDir, p.pruneThresh, curSaveDir);

% evaluate the performance.
benchmarkDir = p.motDir;
seqfile = fullfile(p.evlSeqmaps, 'eval.txt');
isShowFP = 0;
vidDir = p.vidDir;
allMets = evaluateTracking(seqfile, p.motPredictionSaveDir, benchmarkDir, vidDir, isShowFP );

% visualize bad case.
total_videos = size(allMets.mets2d, 2);
for vidx = 4:total_videos
    res = allMets.mets2d(vidx);
    if res.m(end-2) < 50
        % bbox_vis_people(expidx, vidx, curSaveDir);
        bbox_vis_people(expidx, vidx);
    end
end