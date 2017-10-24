function bbox_tracking( expidx,firstidx,nVideos,bRecompute,bVis )
%PT_TRACK_JOINT Summary of this function goes here
%   Detailed explanation goes here

fprintf('bbox_tracking()\n');

if (ischar(expidx))
    expidx = str2num(expidx);
end

if (ischar(firstidx))
    firstidx = str2num(firstidx);
end

if (nargin < 2)
    firstidx = 1;
end

if (nargin < 3)
    nVideos = 1;
elseif ischar(nVideos)
    nVideos = str2num(nVideos);
end

if (nargin < 4)
    bRecompute = false;
end

if (nargin < 5)
    bVis = false;
end

fprintf('expidx: %d\n',expidx);
fprintf('firstidx: %d\n',firstidx);
fprintf('nVideos: %d\n',nVideos);

p = bbox_exp_params(expidx);
load(p.testGT,'annolist');

ptMulticutDir = p.ptMulticutDir;
mkdir_if_missing(ptMulticutDir);
fprintf('multicutDir: %s\n',ptMulticutDir);
visDir = fullfile(ptMulticutDir, 'vis');
mkdir_if_missing(visDir);

ptDetectionDir = p.matDetectionsDir;
mkdir_if_missing(ptDetectionDir);
fprintf('detectionDir: %s\n',ptDetectionDir);

num_videos = length(annolist);

lastidx = firstidx + nVideos - 1;
if (lastidx > num_videos)
    lastidx = num_videos;
end

if (firstidx > lastidx)
    return;
end

% computation parameters
% stride = p.stride;
% half_stride = stride/2;
% locref_scale_mul = p.locref_scale;
% nextreg = isfield(p, 'nextreg') && p.nextreg;
unLab_cls = 'uint64';
max_sizet_val = intmax(unLab_cls);
ptPairwiseDir = p.ptPairwiseDir;
cidx = p.cidx;
% pad_orig = p.([video_set 'Pad']);

fprintf('Loading temporal model from %s\n', ptPairwiseDir);
usedCidx = p.usedCidx;
modelName  = [ptPairwiseDir '/temporal_model_with_dist_cidx_' num2str(usedCidx)];
temporal_model = struct;
m = load(modelName,'temporal_model');
temporal_model.diff = struct;
temporal_model.diff.log_reg = m.temporal_model.log_reg;
temporal_model.diff.training_opts = m.temporal_model.training_opts;

stagewise = false;
if isfield(p, 'cidxs_full')
    cidxs_full = p.cidxs_full;
else
    cidxs_full = p.cidxs;
end

if stagewise
    num_stages = length(p.cidxs_stages);
else
    num_stages = 1;
end

if isfield(p, 'dets_per_part_per_stage')
    dets_per_part = p.dets_per_part_per_stage;
elseif isfield(p, 'dets_per_part')
    dets_per_part = p.dets_per_part;
    if stagewise
        dets_per_part = repmat(dets_per_part, num_stages);
    end
end

use_graph_subset = isfield(p, 'graph_subset');
if use_graph_subset
    load(p.graph_subset);
end


% pairwise = load_pairwise_data(p);

if isfield(p, 'nms_dist')
    nms_dist = p.nms_dist;
else
    nms_dist = 1.5;
end

% hist_pairwise = isfield(p, 'histogram_pairwise') && p.histogram_pairwise;
% pwIdxsAllrel1 = build_pairwise_pairs(cidxs_full);

fprintf('recompute %d\n', bRecompute);

idxStart = 1;
for vIdx = firstidx:lastidx
    fprintf('vididx: %d\n',vIdx);
    ann = annolist(vIdx);
    vid_name    = ann.name;
    vid_dir     = fullfile(p.vidDir, vid_name);
    num_frames  = ann.num_frames;
    fn          = dir([vid_dir,'/*.jpg']);
    frame_pairs = bbox_build_frame_pairs(num_frames, p.maxFrameDist);
    corres_dir = fullfile(p.correspondences, vid_name);
    flows_dir = fullfile(p.ptFlowDir, vid_name);
    reid_file = fullfile(p.reid, vid_name);
    
    detPerFrame = zeros(num_frames,1); 
    detections = [];
    
    cidxs = cidxs_full;
        
    % fname = [ptMulticutDir '/' vid_name '_cidx_' num2str(cidxs(1)) '_' num2str(cidxs(end))];
    detFname = [p.matDetectionsDir '/' vid_name];
    
    predFname = [ptMulticutDir '/prediction_' num2str(expidx) '_' vid_name '.mat'];
    [pathstr,~,~] = fileparts(predFname);
    mkdir_if_missing(pathstr);

    if(exist(predFname, 'file'))
       fprintf('Prediction already exist at: %s\n', predFname);
%        bbox_vis_people(expidx, vIdx);
%        continue;
    end
        
    if(exist([detFname,'.mat'], 'file') && ~bRecompute)
        load(detFname, 'detections');
    else
        fprintf('Need detections first.\n');
        assert(false);
    end
    
    temporalWindows = bbox_generate_frame_windows(num_frames, p.temporalWinSize);
    
    for w = 1:size(temporalWindows, 1)
        stIdx  = temporalWindows(w, 1);
        endIdx = temporalWindows(w, 2);
        
        idxs = ismember(detections.frameIndex, stIdx:endIdx) > 0;
        wDetections = MultiScaleDetections.slice(detections, idxs);
        wDetections.unLab = zeros(size(wDetections.unProb,1),2,unLab_cls);
        wDetections.unLab(:,:) = max_sizet_val;
        origin_detections = copy_detections(wDetections);
        if(w > 1)
            fprintf('Window %d/%d: Previous: %d \t New: %d\n', w, size(temporalWindows, 1), size(prev_dets.unProb,1), size(wDetections.unProb,1));
            wDetections = MultiScaleDetections.merge(prev_dets, wDetections);
            origin_detections = MultiScaleDetections.merge(pre_origin_detections, origin_detections);
        end
        pre_origin_detections = origin_detections;
        origin_index = pre_origin_detections.index;
        wDetections.index = [1:size(wDetections.unProb,1)]';
        fprintf('Number of Detections: %d\n', size(wDetections.unProb,1));
                    
        pwProbTemporal = [];
        
        fprintf('Computing temporal pairwise probabilities. Part = %d\n',cidx);
        pwProb = bbox_compute_temporal_pairwise_probabilities(p, wDetections, temporal_model, cidx, fn, corres_dir, flows_dir, origin_index, reid_file);
        pwProbTemporal = [pwProbTemporal;pwProb];
        
        % compute spatial probability.
        fprintf('Computing spatial pairwise probabilities. Part = %d\n', cidx);
        pwProbSpatial = cell(num_frames,1);
        spatial_det_rel = cell(num_frames,1);
        for fIdx = 1:endIdx
            bbox_idxs = wDetections.frameIndex == fIdx;
            fDetections = MultiScaleDetections.slice(wDetections, bbox_idxs);
            if (size(fDetections.unProb,1) == 0) 
                continue;
            end

            num_dets  = size(fDetections.unPos, 1);
            spatial_det_rel{fIdx} = bbox_build_frame_pairs(num_dets, num_dets);
            spatial_pairs = spatial_det_rel{fIdx};
            num_pairs = size(spatial_pairs, 1);
            detPairIdx = [fDetections.index(spatial_pairs(:, 1)), fDetections.index(spatial_pairs(:, 2))];

            pwProbSpatial{fIdx,1} = ones(num_pairs, 1) * fIdx;
            pwProbSpatial{fIdx,1} = cat(2, pwProbSpatial{fIdx, 1}, detPairIdx );
            pwProbSpatial{fIdx,1} = cat(2, pwProbSpatial{fIdx, 1}, zeros(num_pairs, 1)); % part class 1
            pwProbSpatial{fIdx,1} = cat(2, pwProbSpatial{fIdx, 1}, zeros(num_pairs, 1)); % part class 2
            pwProbSpatial{fIdx,1} = cat(2, pwProbSpatial{fIdx, 1}, zeros(num_pairs, 1)); % probility
        end
        pwProbSpatial = cell2mat(pwProbSpatial);

        % prepare problem for solver
        numDetections = size(wDetections.unProb, 1);
        pwProbSolverTemp = pwProbTemporal(:,3:6);
        pwProbSolverTemp(:,1:2) = pwProbSolverTemp(:,1:2) - min(wDetections.index);
%         idxs = pwProbSolverTemp(:,3) <  0.6;
        pwProbSolverTemp(:,3) = pwProbSolverTemp(:,3);
        pwProbSolverSpat = pwProbSpatial(:, 2:6);
        pwProbSolverSpat(:,1:2) = pwProbSolverSpat(:,1:2) - min(wDetections.index); 
 
        problemFname  = [ptMulticutDir '/pt-problem-'  vid_name '-' num2str(stIdx) '-' num2str(endIdx) '-exp-' num2str(expidx) '.h5'];
        solutionFname = [ptMulticutDir '/pt-solution-' vid_name '-' num2str(stIdx) '-' num2str(endIdx) '-exp-' num2str(expidx) '.h5'];

        [pathstr,~,~] = fileparts(problemFname);
        mkdir_if_missing(pathstr);
        [pathstr,~,~] = fileparts(solutionFname);
        mkdir_if_missing(pathstr);

        fprintf('save problem\n');
        % write problem
        dataName    = 'detections-info';
        write_mode  = 'overwrite';
        marray_save(problemFname, dataName, numDetections, write_mode);

        dataName = 'part-class-probabilities';
        write_mode = 'append';
        marray_save(problemFname, dataName, cat(2, wDetections.partClass, wDetections.unProb), write_mode);

        dataName = 'join-probabilities-temporal';
        write_mode = 'append';
        marray_save(problemFname, dataName, pwProbSolverTemp, write_mode);
        
%         dataName = 'join-probabilities-spatial';
%         write_mode = 'append';
%         marray_save(problemFname, dataName, pwProbSolverSpat, write_mode);
        
        dataName = 'coordinates-vertices';
        marray_save(problemFname, dataName, cat(2, wDetections.frameIndex, wDetections.unPos), write_mode);

        singMultSwitch = 'm';
        if (isfield(p,'single_people_solver') && p.single_people_solver)
            singMultSwitch = 's';
        end
            
        solver = p.ptSolver;
        time_limit = p.time_limit;
        cmd = [solver ' ' problemFname  '  ' solutionFname ' ' singMultSwitch ' ' num2str(time_limit)];

        if(size(temporalWindows, 1) > 1 && w > 1)
            initSolutionFname = fullfile(ptMulticutDir, ['pt-init-solution-' vid_name '-' num2str(stIdx) '-' num2str(endIdx) '-exp-' num2str(expidx) '.h5']);
            dataName = 'detection-parts-and-clusters';
            marray_save(initSolutionFname, dataName, wDetections.unLab, 'overwrite');
            cmd = [cmd ' ' initSolutionFname];
        end

        fprintf('calling pt-solver: %s\n', cmd);

        [~,hostname] = unix('echo $HOSTNAME');

        fprintf('hostname: %s',hostname);
        pre_cmd = ['export GRB_LICENSE_FILE=' p.gurobi_license_file];

        tic
        setenv('LD_LIBRARY_PATH', '');
        s = unix([pre_cmd '; ' cmd]);
        toc
        if (s > 0)
            error('solver error');
        end
        assert(s == 0);

        % clean up
        unix(['rm ' problemFname]);

        % load solution
        dataName = 'part-tracks';
        unLab = marray_load(solutionFname, dataName);
        
        % TODO: prune Detections.
        out_dets = copy_detections(wDetections);
        % [unLab, idxs] = pruneDetections(unLab, wDetections, cidxs, 0);
        % out_dets = MultiScaleDetections.slice(out_dets, idxs);
        out_dets.unLab = unLab;
        prev_dets = copy_detections(out_dets);
        % people = bbox_compute_final_posetrack_predictions( out_dets );
        people = out_dets;
        people.origin_index = origin_index;
        save(predFname, 'people');
    end 
    % visualise predictions
    % bbox_vis_people(expidx, vIdx);
end  

fprintf('done\n');

if (isdeployed)
    close all;
end
end

function [outClusters] = pruneClusters(clusters, frameIndexes, labels, minLen)
    outClusters = [];
    for c = 1:length(clusters)
        cl = clusters(c);
        idxs = labels == cl;
        frameLen = length(unique(frameIndexes(idxs)));
        if(frameLen > minLen)
            outClusters = [outClusters;cl];
        end
    end
end

function [unLab_new, idxs] = pruneDetections(unLab, detections, cidxs, minLen)
    
    clusters = unique(unLab(:, 2));
    clusters = pruneClusters(clusters, detections.frameIndex, unLab(:,2), minLen);
    idxs = [];
    
    stIdx = min(detections.frameIndex);
    endIdx = max(detections.frameIndex);
    
    for fIdx = stIdx:endIdx
        
        %get the detections in current frame and suppress those with status 0
        cfIdxs = find(bitand(detections.frameIndex == fIdx, logical(unLab(:,1))));         
        
        for j = 1:length(clusters)
            cl = clusters(j);
            cDets  = unLab(cfIdxs, 2) == cl;
            labels = detections.partClass(cfIdxs);
            for k = 1:length(cidxs)
                cidx = cidxs(k);
                bundle = find(cDets & labels == cidx);
                if isempty(bundle)
                    continue;
                end
                probs = detections.unProb(cfIdxs(bundle));
                [~, I] = max(probs);
                idxs = [idxs; cfIdxs(bundle(I))];
            end
        end 
    end
    
    idxs = sort(idxs);
    
    unLab_new = unLab(idxs, :);
    for j = 1:length(clusters)
        cl = clusters(j);
        I = unLab_new == cl;
        unLab_new(I) = j-1;
    end
        
    %idxs
end

function dets = copy_detections(dets_src)
    dets = struct();
    dets.unPos = dets_src.unPos;
    % dets.unPos_sm = dets_src.unPos_sm;
    dets.unProb = dets_src.unProb;
    % dets.locationRefine = dets_src.locationRefine;
    % dets.nextReg = dets_src.nextReg;
    % dets.unProbNoThresh = dets_src.unProbNoThresh;
    if isfield(dets_src, 'unLab')
        dets.unLab = dets_src.unLab;
    end
    if isfield(dets_src, 'scale')
        dets.scale = dets_src.scale;
    end
    if isfield(dets_src, 'frameIndex')
        dets.frameIndex = dets_src.frameIndex;
    end
    if isfield(dets_src, 'index')
        dets.index = dets_src.index;
    end
    if isfield(dets_src, 'partClass')
        dets.partClass = dets_src.partClass;
    end
end


