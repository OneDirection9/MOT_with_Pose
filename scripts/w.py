from utils import remove_group_box

filename = 'det_results_posetrack.txt'
fout = open(filename + '_rmgroup.txt', 'wt')
fout2 = open(filename + '_removed.txt', 'wt')

dets = []
im_name = ''


with open(filename, 'rt') as f:
  for line in f:
    line = line[:-1]
    cur_name, x1, y1, w, h, score = line.split(' ')
    x1, y1, w, h, score = float(x1), float(y1), float(w), float(h), float(score)
    if im_name == '':
      im_name = cur_name
    if cur_name != im_name and im_name != '':
      keep_boxes = []
      removed_boxes = []
      keep_boxes, removed_boxes = remove_group_box(dets,score_thresh=0.4)
      # print '====='
      # print keep_boxes
      # print(keep_boxes)
      # print 1
      for box in keep_boxes:
        x1_, y1_, w_, h_, score_ = box
        fout.write('%s %.2f %.2f %.2f %.2f %.5f\n' % (im_name, x1_, y1_, w_, h_, score_))
      for box in removed_boxes:
        x1_, y1_, w_, h_, score_ = box
        fout2.write('%s %.2f %.2f %.2f %.2f %.5f\n' % (im_name, x1_, y1_, w_, h_, score_))
      dets = []
      im_name = cur_name
      print(im_name)
    dets.append([x1, y1, w, h, score])

keep_boxes, removed_boxes = remove_group_box(dets,score_thresh=0.4)
for box in keep_boxes:
  fout.write('%s %.2f %.2f %.2f %.2f %.5f\n' % (im_name, x1, y1, w, h, score))
