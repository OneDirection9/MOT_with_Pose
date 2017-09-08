if (~isdeployed)
%     addpath('../posetrack/lib');
%     addpath('../posetrack/flow_lib');
%     addpath('../posetrack/kpt_lib');
%     addpath('../posetrack/utils');
%     addpath('../posetrack/eval');
    addpath('../deepcut/lib/pose');
    addpath('../deepcut/lib/pose/multicut');
    addpath('../deepcut/lib/utils');
    addpath('../deepcut/lib/vis');
    addpath('../deepcut/lib/multicut');
    addpath('../deepcut/lib/multicut/hdf5');
    addpath('./lib');
    addpath('./external');
    addpath('./flow_lib');
    addpath('./devkit');
    addpath('./devkit/utils');
    addpath('./utils');
    addpath('./tools');
    caffe_dir = '../deepcut/external/caffe/matlab/';
    if exist(caffe_dir) 
        addpath(caffe_dir);
    else
        warning('Please install Caffe in ./external/caffe');
    end
    addpath('../deepcut/external/liblinear-1.94/matlab/')
    fprintf('Track setup done\n');
end
