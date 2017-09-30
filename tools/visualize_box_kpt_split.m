function [ ] = visualize_box_kpt_split(p, vIdx, people, boxs )
%VISUAL_BOX_AND_KPT Summary of this function goes here
%   Detailed explanation goes here 
vidDir = p.vidDir;
video_set = 'val';
load(p.([video_set 'GT']),'annolist');
colors = {'r','g','b','c','m','y'};
lineWidth = 3;

vinfo = annolist(vIdx);
vid_dir     = fullfile(vidDir, vinfo.name);
fn          = dir([vid_dir,'/*.jpg']);
assert(vinfo.num_frames == size(fn, 1));

num_persons = size(people, 1);

for fidx = 1:vinfo.num_frames 
    
    fprintf('Video name: %s(%d), Frame: %d/%d\n', vinfo.name, vIdx, fidx, vinfo.num_frames);
    fr_fn = fullfile(vid_dir, fn(fidx).name);
    
    img = imread(fr_fn);
    figure(fidx), imshow(img); hold on;
    
    for pid = 1:num_persons
        color = colors{mod(pid, length(colors))+1};
        
        box = boxs{pid, fidx};
        if isempty(box)
            continue;
        end
        rectangle('Position', box, 'EdgeColor', color, 'LineWidth', lineWidth);
        
        kpts = people{pid, fidx};
        is_nan = isnan(kpts);
        is_valid = sum(is_nan, 2) == 0;
        valid_kpts = kpts(is_valid, :);
        for kid = 1:size(valid_kpts)
            plot(valid_kpts(kid, 1), valid_kpts(kid, 2), [color '*']);
        end
    end
    pause();
    close all;
end

end
