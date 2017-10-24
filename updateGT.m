expidx = 2;
p = bbox_exp_params(expidx);

fprintf('Updating ground truth.\n');
videos_dir = p.vidDir;
scale = p.scale;
isSave = 1;
isShow = 1;
useIncludeUnvisiable = p.useIncludeUnvisiable;

% calculate bbox and save in annolist
annolist_train = p.trainGT;
video_save_dir = fullfile(p.expDir, 'videos_bbox_gt/train');
regress_bbox_gt(annolist_train, videos_dir, video_save_dir, scale, isSave, isShow, useIncludeUnvisiable );

annolist_test = p.testGT;
video_save_dir = fullfile(p.expDir, 'videos_bbox_gt/test');
regress_bbox_gt(annolist_test, videos_dir, video_save_dir, scale, isSave, isShow, useIncludeUnvisiable );
evalTxt = fullfile(p.evlSeqmaps, 'eval.txt');
update_evaltxt(annolist_test, evalTxt);

% update gt.txt
generate_gttxt(annolist_train, p.motDir, 'train');
generate_gttxt(annolist_test, p.motDir, 'test');