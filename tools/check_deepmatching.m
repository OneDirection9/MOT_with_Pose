clear;
clc;

% % get parameters.
% expidx = 2;
% p = bbox_exp_params(expidx);

test_annolist_dir = './data/annolist/test/annolist';
% test_annolist_dir = './data/annolist/last/annolist';
correspondences = '/media/sensetime/1C2E42932E4265BC/challenge/correspondences';
vidDir = '/media/sensetime/1C2E42932E4265BC/challenge/videos';
max_dist = 3;

load(test_annolist_dir, 'annolist');
num_videos = size(annolist, 1);

for vidx = 1:num_videos
    vinfo = annolist(vidx, :);
    video_name = vinfo.name;
    
    fprintf('Verifying %s (%d/%d).\n', video_name, vidx, num_videos);
    
    dm_dir = fullfile(correspondences, video_name);
    assert(exist(dm_dir, 'dir') == 7, 'DeepMatching dir for %s does not exist.', video_name);
    
    vid_dir = fullfile(vidDir, video_name);
    assert(exist(vid_dir, 'dir') == 7, 'Video dir for %s does not exist.', video_name);
    
    frames = dir([vid_dir '/*.jpg']);
	video_frames = size(frames, 1);
    num_frames = vinfo.num_frames;
    assert(video_frames == num_frames, 'Frames for %s does not match.', video_name);
    
    % build frame pairs
    [q1,q2] = meshgrid(1:num_frames,1:num_frames);
    idxsAllrel = [q1(:) q2(:)];

    idxsExc = idxsAllrel(:,1) >= idxsAllrel(:,2);
    idxsRel = idxsAllrel(~idxsExc,:);

    idxsExc = abs(idxsRel(:,1) - idxsRel(:,2)) > max_dist;
    frame_pairs = idxsRel(~idxsExc,:);
    
    num_pairs = size(frame_pairs);
    for id = 1:num_pairs
        pair = frame_pairs(id, :);
        f1 = frames(pair(1)).name;
        f2 = frames(pair(2)).name;
        
        [~, f1_name, ~] = fileparts(f1);
        [~, f2_name, ~] = fileparts(f2);
        
        dm_file_name = [ f1_name '_' f2_name '.txt'];
        full_pair_file = fullfile(dm_dir, dm_file_name);
        assert(exist(full_pair_file, 'file') == 2, 'Deepmatch for %s does not exist.', full_pair_file);
    end
    
end