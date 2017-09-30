function [ output_args ] = visualize_challenge_type( vidx )
%VISUALIZE_CHALLENGE_TYPE Summary of this function goes here
%   Detailed explanation goes here

vidDir = '/media/sensetime/1C2E42932E4265BC/challenge/videos';
predDir = '/home/sensetime/warmer/PoseTrack/challenge/data/evaluate_result';
anno_GT = './data/annolist/test/annolist';

load(anno_GT, 'annolist');
colors = {'r','g','b','c','m','y'};
lineWidth = 3;

vinfo = annolist(vidx);
vid_dir     = fullfile(vidDir, vinfo.name);
fn          = dir([vid_dir,'/*.jpg']);
assert(vinfo.num_frames == size(fn, 1));

pred_file = fullfile(predDir, [vinfo.name '.mat']);
a = load(pred_file);
a = a.annolist;
assert(size(a, 2) == vinfo.num_frames);

for fidx = 1:vinfo.num_frames 
    
    fprintf('Video name: %s(%d), Frame: %d/%d\n', vinfo.name, vidx, fidx, vinfo.num_frames);
    fr_fn = fullfile(vid_dir, fn(fidx).name);
    
    img = imread(fr_fn);
    figure(1), imshow(img); hold on;
    
    persons = a(fidx).annorect;
    num_persons = size(persons, 2);
    for pid = 1:num_persons
        color = colors{mod(pid, length(colors))+1};
        
        kpts = persons(pid).annopoints.point;
        for kid = 1:size(kpts, 2)
            plot(kpts(kid).x, kpts(kid).y, [color '*']);
        end
    end
    pause();
    close all;
end
end

