function corres_pts = pt_load_flow_correspondences(corres_fn)

try
    
if(~exist(corres_fn, 'file'))
    error('File for flow_correspondences does not exists. %s', corres_fn);
end

corres_pts = get_flow_corres(corres_fn);
num_cols=size(corres_pts,2);

% from h,w to x,y
corres_pts(:, [2,1,4,3]) = corres_pts(:, [1,2,3,4]);

% discard all-zero rows
zero_idx = logical(max(corres_pts, [], 2));
corres_pts = corres_pts(zero_idx, :);

if(num_cols < 4)
    error('Incorrect data in file: %s', corres_fn);
end

if(num_cols > 4)
    corres_pts = corres_pts(:,1:4);
end

catch 
    keyboard();
end

end