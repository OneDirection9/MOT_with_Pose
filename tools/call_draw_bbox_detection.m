expidx = 2;
p = bbox_exp_params(expidx);

videos_dir = p.vidDir;
detection_dir = p.matDetectionsDir;

annolist_file = p.trainGT;
save_dir = '/media/sensetime/1C2E42932E4265BC/pose_track_data/MOT_exp002_gt/videos_bbox_detection/train';
% draw_bbox_detection(videos_dir, annolist_file, detection_dir, save_dir);


annolist_file = p.testGT;
save_dir = '/media/sensetime/1C2E42932E4265BC/pose_track_data/MOT_exp002_gt/videos_bbox_detection/test';
draw_bbox_detection(videos_dir, annolist_file, detection_dir, save_dir);