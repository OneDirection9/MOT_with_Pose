function [ proposals ] = mot_generate_proposal_candidates( filename, p, gt_bbox )
%MOT_GENERATE_PROPOSAL_CANDIDATES Summary of this function goes here
%   Detailed explanation goes here

filename = [ filename '.txt' ];
[~, xs, ys, ws, hs, pred_scores] = textread(filename, '%s%f%f%f%f%f');

bbox = cat(2, xs, ys, ws, hs);
% x, y, w, h => x1, y1(top-left), x2, y2(bottom-right)
topleft_bottomdown = cat(2, xs, ys, xs + ws, ys + hs);

% ground truth: x, y, w, h => x1, y1, x2, y2.
gt_bbox_array = struct2array(gt_bbox);
gt_bbox_array(3) = gt_bbox_array(1) + gt_bbox_array(3);
gt_bbox_array(4) = gt_bbox_array(2) + gt_bbox_array(4);

% calculte IOU for each proposals.
IOU = boxoverlap_one2one(topleft_bottomdown, gt_bbox_array);
% only consider the proposals 
% whose IOU with ground truth not less than p.IOUThresh.
idxs = find(IOU >= p.IOUThresh);

locations = bbox(idxs, :);
scores = pred_scores(idxs);
scales = ones(size(idxs,1), 1);

proposals = cat(2, locations, idxs, scales, scores);

% NMS - not needed.
% proposals_nms = topleft_bottomdown(idxs, :);
% proposals_nms = cat(2, proposals_nms, scores);
% idx_nms = nms_IOU(proposals_nms, p.NMSThresh);
end

