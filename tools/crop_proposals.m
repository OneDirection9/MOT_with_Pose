function [ ] = crop_proposals( expidx )
%CROP_PROPOSALS Summary of this function goes here
%   Detailed explanation goes here

p = bbox_exp_params(expidx);

train_annolist_file = p.trainGT;
test_annolist_file = p.testGT;

croped_pro_dir = p.cropedProposals;
proposals_dir = p.detPreposals;
vidDir = p.vidDir;

dirs = dir(proposals_dir);
num_videos = size(dirs, 1);

for idx = 3:num_videos % skip ./ and ../
    vname = dirs(idx).name;
    
    p_dir = fullfile(proposals_dir, vname);
    v_dir = fullfile(vidDir, vname);
    
    proposals_per_frame = dir([p_dir, '/*.txt']);
    num_frames = size(proposals_per_frame, 1);
    for fidx = 1:num_frames
        fprintf('Processing videos %d/%d. Frames: %d/%d\n', idx-2, num_videos-2, fidx, num_frames);
        f_full_name = proposals_per_frame(fidx).name;
        f_full_path = fullfile(p_dir, f_full_name);
        [~, f_name, ~] = fileparts(f_full_path);
        save_dir = fullfile(croped_pro_dir, vname, f_name);
        if(exist(save_dir, 'dir'))
            rmdir(save_dir, 's');
        end
        mkdir(save_dir);
        
        [~, xs, ys, ws, hs, ~] = textread(f_full_path, '%s%f%f%f%f%f');
        f_v_file = fullfile(v_dir, [f_name '.jpg']);
        crop(xs, ys, ws, hs, save_dir, f_v_file);
    end
end

end


function [] = crop(xs, ys, ws, hs, save_dir, f_v_file)
    num_box_per_frame = size(xs, 1);
    
    for idx = 1:num_box_per_frame
        save_file = fullfile(save_dir, [num2str(idx) '.jpg']);
        fr_img = imread(f_v_file);
        p_img = imcrop(fr_img, [xs(idx), ys(idx), ws(idx), hs(idx)]);
        imwrite(p_img, save_file);
    end
end

