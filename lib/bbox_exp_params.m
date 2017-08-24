function p = bbox_exp_params(expidx)

p = [];

p.code_dir = pwd();

p.dependencyDir = '/media/sensetime/1C2E42932E4265BC/pose_track_data/bonn-multiperson-posetrack';
p.expDir = fullfile(p.code_dir, 'data');
p.ptSolver  = fullfile(p.code_dir, 'solver/pt-solver-callback');

p.useIncludeUnvisiable = 1; % 1: use unvisiable keypoint to regress bbox.
p.scale = 1.1;
p.useGT = 0; % 1: true. 0: false.
p.updateGT = 0; % 1: true. 0: false.
p.flow = 0;

p.cidx = 0;
p.usedCidx = 0; % 0 or 13.
p.pruneThresh = 10;
p.maxFrameDist = 2;
p.IOUThresh = 0.5;
p.NMSThresh = 0.5;

p.liblinear_predict = true;
p.gurobi_license_file = ['/home/sensetime/gurobi.lic'];

switch expidx
    case 1
        p.name = 'Multiple Object Tracking';
        
        p.temporalWinSize = 11;
        p.trackMinLen = 0;
        
        p.testGT = fullfile(p.expDir, '/annolist/test/annolist');
        p.testPad = 0;

        p.trainGT = fullfile(p.expDir, '/annolist/train/annolist');
        p.trainPad = 0;
        
        p.ptMulticutDir = fullfile(p.expDir, 'mot-multicut');
        p.txtDetectionsDir = fullfile(p.expDir, 'detections_txt');
        p.matDetectionsDir = fullfile(p.expDir, 'detections');
        p.motPredictionSaveDir = fullfile(p.expDir, 'res/data/pose_track/');
        p.ptPairwiseDir = fullfile(p.expDir, 'mot-pairwise');
        p.motDir = fullfile(p.expDir, 'videos_mot_framat/');
        p.evlSeqmaps = fullfile(p.expDir, 'seqmaps');
        p.detPreposals = fullfile(p.expDir, 'proposals');
        
        p.pairwise_relations = fullfile(p.code_dir, '/../deepcut/data/pairwise/all_pairs_stats_all.mat');
        p.net_dir = fullfile(p.code_dir, '../deepcut/data/caffe-models');
        p.net_def_file = 'ResNet-101-FCN_out_14_sigmoid_locreg_allpairs_test.prototxt';
        p.net_bin_file = 'ResNet-101-mpii-multiperson.caffemodel';
        
        p.ptFlowDir = fullfile(p.dependencyDir, 'flow');
        p.vidDir = fullfile(p.dependencyDir, 'videos');
        p.correspondences = fullfile(p.dependencyDir, 'correspondences');
        p.cropedDetections = fullfile(p.dependencyDir, 'detections_img');
        p.reid = fullfile(p.dependencyDir, 'reid');
        
        p.corresName = '%05d_%05d.txt';
        p.stride = 8;
        p.scale_factor = 1;
        p.multiscale = true;
        p.scales = 0.6:0.3:1.5;
        p.locref = true;
        p.nextreg = true;
        p.allpairs = true;
        p.patchSize   = 70;

	    p.res_net = true;

        p.nms_dist = 7.5;
        p.nms_locref = true;
        p.nms_locref_dist = 7.5;

        p.pidxs = [0 2 4 5 7 9 12 14 16 17 19 21 22 23];
        p.cidxs_full = 1:14;
        p.temporal_cidxs = [13];

        p.stagewise = true;
        p.split_threshold = 0.4;
        p.cidxs_stages = {[9 10 13 14], [9 10 13 14 7 8 11 12], [9 10 13 14 7 8 11 12 1 2 3 4 5 6]};
        p.correction_stages = [0 0 0];

        p.all_parts_on = false;
        p.nFeatSample = 10^2;

        p.dets_per_part = 20;

        p.ignore_low_scores = true;
        p.min_det_score = 0.2;
        p.min_det_score_face = 0.2;
        p.single_people_solver = false;
        p.high_scores_per_class = true;
        p.all_parts_on = false;
        p.multi_people = true;
        p.time_limit = 86400;
        
        p.colorIdxs = [5 1];
        p.refHeight = 400;

        p.multicut = true;
        
        p.maxDim   = 2000;
        p.maxDimDM = 1440;
        p.matchRadius = 100;
    case 2
        p = bbox_exp_params(1);
        p.name = 'Multiple Object Tracking';
end

p.res_net = isfield(p, 'res_net') && p.res_net;
p.rpn_detect = isfield(p, 'rpn_detect') && p.rpn_detect;
p.detcrop_recall = isfield(p, 'detcrop_recall') && p.detcrop_recall;
p.detcrop_image = isfield(p, 'detcrop_image') && p.detcrop_image;
p.histogram_pairwise = isfield(p, 'histogram_pairwise') && p.histogram_pairwise;
p.nms_locref = isfield(p, 'nms_locref') && p.nms_locref;
p.stagewise = isfield(p, 'stagewise') && p.stagewise;
if p.stagewise
    p.num_stages = length(p.cidxs_stages);
end
p.person_part = isfield(p, 'person_part') && p.person_part;
p.complete_clusters = isfield(p, 'complete_clusters') && p.complete_clusters;

p.locref_scale = sqrt(53);

p.mean_pixel = [104, 117, 123];

end
