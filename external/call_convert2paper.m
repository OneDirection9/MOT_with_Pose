% image save dir if isSave = 1
save_dir = '/media/sensetime/1C2E42932E4265BC/challenge/tmp';
% image path prefix.
prefix = '/media/sensetime/1C2E42932E4265BC/challenge';
isSave = 0;

if isSave
    if exist(save_dir)
        rmdir(save_dir, 's');
        fprintf('Save dir `%s` alredy exists. Deleted!\n', save_dir);
    end
    mkdir(save_dir);
end

source_dir = './data/source_annotations/train';
save_mat_file = './data/annolist/train/annolist';
% convert_train2paper(source_dir, save_mat_file, save_dir, prefix, isSave);

source_dir = './data/source_annotations/val';
save_mat_file = './data/annolist/test/annolist';
convert_val2paper(source_dir, save_mat_file, save_dir, prefix, isSave);

fprintf('Done!\n');