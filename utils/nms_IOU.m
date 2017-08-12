function [ pick ] = nms_IOU( proposals, nms_threshold )
%NMS_IOU Summary of this function goes here
%   Detailed explanation goes here

if isempty(proposals)
  pick = [];
  return;
end

proposal_bbox = proposals(:, 1:4);
s = proposals(:,end);

[vals, I] = sort(s);

pick = s*0;
counter = 1;
while ~isempty(I)
  last = length(I);
  i = I(last);
  if s(i) < 1e-3
      break;
  end
  pick(counter) = i;
  counter = counter + 1;
  
  bbox_cur = proposal_bbox(i, :);
  IOUs = boxoverlap_one2one(proposal_bbox, bbox_cur);
  I = I(find(IOUs<nms_threshold));
end

pick = pick(1:(counter-1));
end

