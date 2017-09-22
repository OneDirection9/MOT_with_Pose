function [ ] = convert_test2paper( source_dir, save_mat_file, save_dir, prefix, isSave )
%CONVERT_TEST2PAPER Summary of this function goes here
%   Detailed explanation goes here

source_files = dir([source_dir, '/*.mat']);
num_videos = size(source_files, 1);

pre = [];
for i = 1:num_videos
    file_name = source_files(i).name;
    full_file = fullfile(source_dir, file_name);
    
    load(full_file, 'annolist');
    num_frames = size(annolist, 2);
    
    [~, only_name, ~] = fileparts(full_file);
    
    cur = struct();
    cur.num_frames = num_frames;
    cur.name = only_name;
    
    if isempty(pre)
        pre = cur;
    else
        pre = cat(1, pre, cur);
    end
end

annolist = pre;
save(save_mat_file, 'annolist');

end

