def remove_group_box(boxes, overlap_thresh=0.5, score_thresh=0.5, cover_box_num_thresh=5):
  """
    boxes: [[x, y, w, h, score], ...]
  """

  keep_boxes = []
  removed_boxes = []

  for box in boxes:
    x1, y1, w, h, score = box
    x2, y2 = x1 + w - 1, y1 + h - 1
    cover_box_num = 0

    for box_t in boxes:
      x1t, y1t, wt, ht, st = box_t
      x2t, y2t = x1t + wt - 1, y1t + ht - 1
      if box_t != box and st > score_thresh and max(x1, x1t) < min(x2, x2t) and max(y1, y1t) < min(y2, y2t):
        overlap = (min(x2, x2t) - max(x1, x1t)) * (min(y2, y2t) - max(y1, y1t))
        overlap = overlap / (wt * ht)
        if overlap > overlap_thresh:
          cover_box_num += 1

    if score < score_thresh or cover_box_num >= cover_box_num_thresh:
      removed_boxes.append(box[:])
    else:
      keep_boxes.append(box[:])

  return keep_boxes, removed_boxes

