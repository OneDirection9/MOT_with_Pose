expidx = 2;
firstidx = 1;
nVids = 30;

scale = 1.2;
bbox_cache_deepmatching_features(expidx, 'train', firstidx, nVids, scale);
bbox_cache_deepmatching_features(expidx, 'test', firstidx, nVids, scale);

scale = 0.8;
bbox_cache_deepmatching_features(expidx, 'train', firstidx, nVids, scale);
bbox_cache_deepmatching_features(expidx, 'test', firstidx, nVids, scale);