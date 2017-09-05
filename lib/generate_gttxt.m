function [] = generate_gttxt( annolist_file, save_dir, usage )
    
    load(annolist_file);
    
    if exist(save_dir, 'dir')
        rmdir(save_dir, 's');
    end
    mkdir(save_dir);
        
    num_videos = size(annolist, 1);
    
    for vidx = 1:num_videos
        fprintf('Generating gt.txt. `%s: %s`. Videos: %d/%d\n', usage, annolist(vidx).name, vidx, num_videos);
        
        % video information.
        vinfo = annolist(vidx,:);
        vname = vinfo.name;
        num_frames = vinfo.num_frames;
        num_persons = vinfo.num_persons;
        fbbox = vinfo.bbox;
        
        % generate img1 , det.
        mkdir(fullfile(save_dir, vname, 'det'));
        mkdir(fullfile(save_dir, vname, 'img1'));
        % save in the gt/gt.txt
        save_result_dir = fullfile(save_dir, vname, 'gt');
        mkdir_if_missing(save_result_dir);
        save_file = fullfile(save_result_dir, 'gt.txt');
        fsave = fopen(save_file, 'w');

        for pidx = 1:num_persons
            for fidx = 1:num_frames
                % skip empty entry
                pbox = fbbox{pidx, fidx};
                if(isempty(pbox))
                    continue;
                end
                % frameid, objid, x, y, w, h, flag, X, Y, Z
                fprintf(fsave, [num2str(fidx), ',']); % frame id
                fprintf(fsave, [num2str(pidx), ',']); % object id
                fprintf(fsave, [num2str(pbox.x), ',']); % x
                fprintf(fsave, [num2str(pbox.y), ',']); % y
                fprintf(fsave, [num2str(pbox.w), ',']); % w
                fprintf(fsave, [num2str(pbox.h), ',']); % h
                fprintf(fsave, [num2str(1), ',']); % flag: 1(evaluate), 0(not evaluate)
                fprintf(fsave, [num2str(1), ',']); % X
                fprintf(fsave, [num2str(1), ',']); % Y
                fprintf(fsave, [num2str(1), ',']); % Z
                fprintf(fsave, '\n');
            end
        end
        fclose(fsave);
    end
    fprintf('Generate gt.txt done.\n');
end