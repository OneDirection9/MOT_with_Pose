vidDir = './videos1_2';
scale = 1.2;
dirs = dir(vidDir);
num_dirs = size(dirs, 1);
for vid = 3:num_dirs % skip ./ and ../
    fprintf('Videos: %d/%d. Scale: %f\n', vid-2, num_dirs-2, scale);
    video_name = dirs(vid).name;
    vid_dir = fullfile(vidDir, video_name);
    
    frames = dir([vid_dir, '/*.jpg']);
    num_frames = size(frames, 1);
    
    for fidx = 1:num_frames
        f_name = frames(fidx).name;
        ffile = fullfile(vid_dir, f_name);
        
        img = imread(ffile);
        re_img = imresize(img, scale, 'bicubic');
        imwrite(re_img, ffile);
    end
end

vidDir = './videos0_8';
scale = 0.8;
dirs = dir(vidDir);
num_dirs = size(dirs, 1);
for vid = 3:num_dirs % skip ./ and ../
    fprintf('Videos: %d/%d. Scale: %f\n', vid-2, num_dirs-2, scale);
    video_name = dirs(vid).name;
    vid_dir = fullfile(vidDir, video_name);
    
    frames = dir([vid_dir, '/*.jpg']);
    num_frames = size(frames, 1);
    
    for fidx = 1:num_frames
        f_name = frames(fidx).name;
        ffile = fullfile(vid_dir, f_name);
        
        img = imread(ffile);
        re_img = imresize(img, scale, 'bicubic');
        imwrite(re_img, ffile);
    end
end