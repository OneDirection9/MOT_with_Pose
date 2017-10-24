function [ ] = update_evaltxt( annolist, save_file )
%UPDATE_EVALTXT Summary of this function goes here
%   Detailed explanation goes here
    
    fprintf('Start generate eval.txt .\n');
    fsave = fopen(save_file, 'w');
    fprintf(fsave, 'name\n');
    
    load(annolist, 'annolist');
    num_videos = size(annolist, 1);
    for vidx = 1:num_videos
        name = annolist(vidx).name;
        fprintf(fsave, name);
        fprintf(fsave, '\n');
    end
    fprintf('Generate eval.txt, done.\n');
end

