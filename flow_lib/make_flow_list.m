function make_flow_list(expidx, video_set, firstidx, nVids)

p = pt_exp_params(expidx);

if (nargin < 3)
    firstidx = 1;
elseif ischar(firstidx)
    firstidx = str2num(firstidx);
end

if strcmp(video_set, 'test')
    load(p.testGT)
    fid = fopen('test_list.txt', 'w');
else
    load(p.trainGT)
    fid = fopen('train_list.txt', 'w');
end

num_videos = length(annolist);

if (nargin < 4)
    nVids = num_videos;
elseif ischar(nVids)
    nVids = str2num(nVids);
end

lastidx = firstidx + nVids - 1;
if (lastidx > num_videos)
    lastidx = num_videos;
end

% params
overwrite = false;


for vid_idx = firstidx:lastidx

    vid_name = annolist(vid_idx).name;
    
    cache_dir = fullfile(p.ptFlowDir, vid_name);
    mkdir_if_missing(cache_dir);
    fprintf('save dir %s\n', cache_dir);
    
    vid_dir = fullfile(p.vidDir, vid_name);
    num_frames = annolist(vid_idx).num_frames;
    fn = dir([vid_dir,'/*.jpg']);
    
    assert(length(fn) == num_frames)

    frame_pairs = pt_build_frame_pairs(num_frames, p.maxFrameDist);

    num_pairs = length(frame_pairs);
    for idx =1:num_pairs
        
        
        pair = frame_pairs(idx,:);
        
        fr_fn1 = fullfile(vid_dir, fn(pair(1)).name);
        fr_fn2 = fullfile(vid_dir, fn(pair(2)).name);
        
        [~,fr_name1,~] = fileparts(fr_fn1);
        [~,fr_name2,~] = fileparts(fr_fn2);
        
        save_flow = fullfile(cache_dir, [fr_name1,'_',fr_name2,'.flo']);
            
        %if (exist([save_flow], 'file') == 2) && ~overwrite
        %    continue
        %end
        fprintf(fid, '%s %s %s\n', fr_fn1, fr_fn2, save_flow);
        

      
    end
end

end