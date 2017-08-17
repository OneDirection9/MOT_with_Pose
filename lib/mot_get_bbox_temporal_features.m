function [X_pos, X_neg] = mot_get_bbox_temporal_features(expidx,cidx)

RandStream.setGlobalStream ...
        (RandStream('mt19937ar','seed',42));

p = bbox_exp_params(expidx);

[~,parts] = util_get_parts24();
nFeatSample = p.nFeatSample;

save_file = [p.ptPairwiseDir sprintf('/feat_temporal_with_dist_idx_%d.mat', cidx)];

if exist(save_file, 'file') == 2
    fprintf('Loading feature file: %s\n', save_file);
    load(save_file);
    fprintf('Loaded %s\n',save_file);
    return;
end

fprintf('Loading annotations from: %s\n', p.trainGT);
load(p.trainGT, 'annolist');

num_videos = length(annolist);

num_frames = 0;
num_persons = 0;
for s=1:num_videos
    num_frames  = num_frames  + annolist(s).num_frames;
    num_persons = num_persons + annolist(s).num_persons;        
end

if p.flow
    dim = 14;
else
    dim = 11;
end

% initialize the arrays, otherwise too slow when using cat
X_pos = zeros(num_frames*num_persons*nFeatSample*p.maxFrameDist,dim,'single');
X_neg = zeros(num_frames*num_persons*nFeatSample*p.maxFrameDist,dim,'single');

% example counter for each class
n_pos = 0;
n_neg = 0;
for vIdx=1:num_videos
    fprintf('Computing temporal features.\t Video %d/%d\n', vIdx, num_videos);
    ann = annolist(vIdx);
    vid_name    = ann.name;
    vid_dir = fullfile(p.vidDir, vid_name);
    num_frames  = ann.num_frames;
    num_persons = ann.num_persons;        
    fn = dir([vid_dir,'/*.jpg']);
    
    frame_pairs = bbox_build_frame_pairs(num_frames, p.maxFrameDist);

    corres_dir = fullfile(p.correspondences, vid_name);
    if(p.flow)
        flows_dir = fullfile(p.ptFlowDir, vid_name);
    end

    proposals_dir = fullfile(p.detPreposals, vid_name);
    assert(size(dir(proposals_dir), 1) - 2 == num_frames, 'Proposal files != num_frames');
    
    if num_persons == 1
        nFeatSamplePers = nFeatSample;
    else
        nFeatSamplePers = uint16(nFeatSample/5);
    end

    for fIdx=1:size(frame_pairs,1);
    
        pair = frame_pairs(fIdx, :);
        
        fr_fn1 = fullfile(vid_dir, fn(pair(1)).name);
        fr_fn2 = fullfile(vid_dir, fn(pair(2)).name);

        [~,fr_name1,~] = fileparts(fr_fn1);
        [~,fr_name2,~] = fileparts(fr_fn2);

        corres_fn = fullfile(corres_dir, [fr_name1,'_',fr_name2,'.txt']);
        corres_dm_pts = bbox_load_dm_correspondences(corres_fn);
        corres_dm_pts1 = corres_dm_pts(:,1:2);
        corres_dm_pts2 = corres_dm_pts(:,3:4);        
        
        if p.flow
            flow_fn = fullfile(flows_dir, [fr_name1,'_',fr_name2,'.flo']);
            corres_flow_pts = pt_load_flow_correspondences(flow_fn);
            corres_flow_pts1 = corres_flow_pts(:,1:2);
            corres_flow_pts2 = corres_flow_pts(:,3:4);
        end

        proposal_fn1 = fullfile(proposals_dir, fr_name1);
        proposal_fn2 = fullfile(proposals_dir, fr_name2);
        
        for pIdx = 1:num_persons
            
            gt_bbox1 = ann.bbox{pIdx, pair(1)};
            if(isempty(gt_bbox1))
                continue;
            end
            
            for ppIdx = 1:num_persons
                
                gt_bbox2 = ann.bbox{ppIdx, pair(2)};
                if(isempty(gt_bbox2))
                    continue;
                end
                
                if (isnan(gt_bbox1.x) || isnan(gt_bbox2.x))
                    continue;
                end
                
                proposals1 = mot_generate_proposal_candidates(proposal_fn1, p, gt_bbox1);
                proposals2 = mot_generate_proposal_candidates(proposal_fn2, p, gt_bbox2);
                
                idxs_proposal1 = (1: size(proposals1, 1));
                idxs_proposal2 = (1: size(proposals2, 1));
                [pi, pj] = meshgrid(idxs_proposal1, idxs_proposal2);
                idxAllProposal = [pi(:) pj(:)];
                
                if(pIdx == ppIdx) % positive features
                    nFeat = min(nFeatSamplePers, size(idxAllProposal, 1));
                    idxs_rnd = randperm(size(idxAllProposal, 1));
                    idxsPair = idxs_rnd(1:nFeat);
                    idxs_bbox_pair = idxAllProposal(idxsPair, :);
                    feat_dm = bbox_get_temporal_features_img_dm(p, proposals1, corres_dm_pts1, proposals2, corres_dm_pts2, idxs_bbox_pair);
                    if p.flow
                        feat_flow = bbox_get_temporal_features_img_dm(p, proposals1, corres_flow_pts1, proposals2, corres_flow_pts2, idxs_bbox_pair);
                        feat = cat(2, feat_dm, feat_flow(:,1));
                        feat = cat(2, feat, feat_flow(:, 3:4));
                    else
                        feat = feat_dm;
                    end
                    idxs = n_pos+1:n_pos+size(feat,1);
                    X_pos(idxs,:) = feat;
                    n_pos = n_pos + size(feat,1);
                    
                else  % negative features
                    nFeat = min(nFeatSamplePers/3, size(idxAllProposal, 1));
                    idxs_rnd = randperm(size(idxAllProposal, 1));
                    idxsPair = idxs_rnd(1:nFeat);
                    idxs_bbox_pair = idxAllProposal(idxsPair, :);
                    feat_dm = bbox_get_temporal_features_img_dm(p, proposals1, corres_dm_pts1, proposals2, corres_dm_pts2, idxs_bbox_pair);
                    if p.flow
                        feat_flow = bbox_get_temporal_features_img_dm(p, proposals1, corres_flow_pts1, proposals2, corres_flow_pts2, idxs_bbox_pair);
                        feat = cat(2, feat_dm, feat_flow(:,1));
                        feat = cat(2, feat, feat_flow(:, 3:4));
                    else
                        feat = feat_dm;
                    end
                    idxs = n_neg+1:n_neg+size(feat,1);
                    X_neg(idxs,:) = feat;
                    n_neg = n_neg + size(feat,1);
                end
            end
        end
    end
    
    check = 1;
end

% remove unused bins
X_pos(n_pos+1:end,:) = [];
X_neg(n_neg+1:end,:) = [];

mkdir_if_missing(p.ptPairwiseDir);
save(save_file, 'X_pos', 'X_neg', '-v7.3');

end
% ------------------------------------------------------------------------