function allMets=evaluateTracking( seqmap, resDir, dataDir, vidDir, isShowFP )
%% evaluate CLEAR MOT and other metrics
% concatenate ALL sequences and evaluate as one!
%
% SETUP:
%
% define directories for tracking results...
% resDir = fullfile('res','data',filesep);
% ... and the actual sequences
% dataDir = fullfile('..','data','2DMOT2015','train',filesep);
%
%

addpath(genpath('.'));

% read sequence map
% seqmapFile=fullfile('seqmaps',seqmap);
seqmapFile = seqmap;
allSeq = parseSequences(seqmapFile);

fprintf('Sequences: \n');
disp(allSeq')

% concat gtInfo
gtInfo=[];
gtInfo.X=[];
allFgt=zeros(1,length(allSeq));

% Find out the length of each sequence
% and concatenate ground truth
gtInfoSingle=[];
seqCnt=0;
for s=allSeq
    seqCnt=seqCnt+1;
    seqName = char(s);
    seqFolder= [dataDir,seqName,filesep];
    
    assert(isdir(seqFolder),'Sequence folder %s missing',seqFolder);
    
    gtFile = fullfile(dataDir,seqName,'gt','gt.txt');
    gtI = convertTXTToStruct(gtFile,seqFolder);
    
    [Fgt,Ngt] = size(gtInfo.X);
    [FgtI,NgtI] = size(gtI.Xi);
    newFgt = Fgt+1:Fgt+FgtI;
    newNgt = Ngt+1:Ngt+NgtI;
    
    gtInfo.Xi(newFgt,newNgt) = gtI.Xi;
    gtInfo.Yi(newFgt,newNgt) = gtI.Yi;
    gtInfo.W(newFgt,newNgt) = gtI.W;
    gtInfo.H(newFgt,newNgt) = gtI.H;
    
    gtInfoSingle(seqCnt).wc=0;
    
    % fill in world coordinates if they exist
    if isfield(gtI,'Xgp') && isfield(gtI,'Ygp')
        gtInfo.Xgp(newFgt,newNgt) = gtI.Xgp;
        gtInfo.Ygp(newFgt,newNgt) = gtI.Ygp;
        gtInfoSingle(seqCnt).wc=1;
    end
    
    % check if bounding boxes available in solution
    imCoord=1;
    if all(gtI.Xi(find(gtI.Xi(:)))==-1)
        imCoord=0;
    end
    
    gtInfo.X=gtInfo.Xi;gtInfo.Y=gtInfo.Yi;
    if ~imCoord 
        gtInfo.X=gtInfo.Xgp;gtInfo.Y=gtInfo.Ygp; 
    end
    
    allFgt(seqCnt) = FgtI;
    
    gtInfoSingle(seqCnt).gtInfo=gtI;
    
end
gtInfo.frameNums=1:size(gtInfo.Xi,1);

allMets=[];

mcnt=1;


fprintf('Evaluating ... \n');


clear stInfo
stInfo.Xi=[];

evalMethod=1;

% flags for entire benchmark
% if one seq missing, evaluation impossible
eval2D=1;
eval3D=1;

seqCnt=0;

% iterate over each sequence
for s=allSeq
    
    seqCnt=seqCnt+1;
    seqName = char(s);
    
    fprintf('\t... %s\n',seqName);
    
    % if a result is missing, we cannot evaluate this tracker
    resFile = fullfile(resDir,[seqName '.txt']);
    if ~exist(resFile,'file')
        fprintf('WARNING: result for %s not available!\n',seqName);
        eval2D=0;
        eval3D=0;
        continue;
    end
    
    % if MOT16, preprocess (clean)
    if ~isempty(strfind(seqName,'MOT16'))
	resFile = preprocessResult(resFile, seqName, dataDir);
    end

    
    
    stI = convertTXTToStruct(resFile);
%     stI.Xi(find(stI.Xi(:)))=-1;
    % check if bounding boxes available in solution
    imCoord=1;
    if all(stI.Xi(find(stI.Xi(:)))==-1)
        imCoord=0;
    end
    
    worldCoordST=0; % state
    if isfield(stI,'Xgp') && isfield(stI,'Ygp')
        worldCoordST=1;
    end
    
    [FI,NI] = size(stI.Xi);
    
    
    % if stateInfo shorter, pad with zeros
    % GT and result must be equal length
    if FI<allFgt(seqCnt)
        missingFrames = FI+1:allFgt(seqCnt);
        stI.Xi(missingFrames,:)=0;
        stI.Yi(missingFrames,:)=0;
        stI.W(missingFrames,:)=0;
        stI.H(missingFrames,:)=0;
        stI.X(missingFrames,:)=0;
        stI.Y(missingFrames,:)=0;
        if worldCoordST
            stI.Xgp(missingFrames,:)=0; stI.Ygp(missingFrames,:)=0;
        end
        [FI,NI] = size(stI.Xi);
    % if stateInfo longer, crop
    elseif FI>allFgt(seqCnt)
        stI.Xi=stI.Xi(1:allFgt(seqCnt),:);
        stI.Yi=stI.Yi(1:allFgt(seqCnt),:);
        stI.W=stI.W(1:allFgt(seqCnt),:);
        stI.H=stI.H(1:allFgt(seqCnt),:);
        stI.X=stI.X(1:allFgt(seqCnt),:);
        stI.Y=stI.Y(1:allFgt(seqCnt),:);
        if worldCoordST
            stI.Xgp=stI.Xgp(1:allFgt(seqCnt),:); stI.Ygp=stI.Ygp(1:allFgt(seqCnt),:);
        end
        [FI,NI] = size(stI.Xi);
        
    end
    
    % get result for one sequence only
    [mets, mInf, additionalInfo ]=CLEAR_MOT_HUN(gtInfoSingle(seqCnt).gtInfo,stI);
    
    allMets(mcnt).mets2d(seqCnt).name=seqName;
    allMets(mcnt).mets2d(seqCnt).m=mets;
    
    allMets(mcnt).mets3d(seqCnt).name=seqName;
    allMets(mcnt).mets3d(seqCnt).m=zeros(1,length(mets));
    
    if imCoord        
        fprintf('*** 2D (Bounding Box overlap) ***\n'); printMetrics(mets); fprintf('\n');
    else
        fprintf('*** Bounding boxes not available ***\n\n');
        eval2D=0;
    end
    
    % draw false positives.
    if(isShowFP)
        drawFP(gtInfoSingle(seqCnt).gtInfo, stI, additionalInfo.allfalsepos, vidDir, seqName);
    end
    
    % if world coordinates available, evaluate in 3D
    if  gtInfoSingle(seqCnt).wc &&  worldCoordST
        evopt.eval3d=1;evopt.td=1;
        [mets, mInf]=CLEAR_MOT_HUN(gtInfoSingle(seqCnt).gtInfo,stI,evopt);
            allMets(mcnt).mets3d(seqCnt).m=mets;
                
        fprintf('*** 3D (in world coordinates) ***\n'); printMetrics(mets); fprintf('\n');            
    else
        eval3D=0;
    end
    
    
    [F,N] = size(stInfo.Xi);
    newF = F+1:F+FI;
    newN = N+1:N+NI;
    
    % concat result
    stInfo.Xi(newF,newN) = stI.Xi;
    stInfo.Yi(newF,newN) = stI.Yi;
    stInfo.W(newF,newN) = stI.W;
    stInfo.H(newF,newN) = stI.H;
    if isfield(stI,'Xgp') && isfield(stI,'Ygp')
        stInfo.Xgp(newF,newN) = stI.Xgp;stInfo.Ygp(newF,newN) = stI.Ygp;
    end
    stInfo.X=stInfo.Xi;stInfo.Y=stInfo.Yi;
    if ~imCoord 
        stInfo.X=stInfo.Xgp;stInfo.Y=stInfo.Ygp; 
    end
    
end
stInfo.frameNums=1:size(stInfo.Xi,1);

if eval2D
    fprintf('\n');
    fprintf(' ********************* Your Benchmark Results (2D) ***********************\n');

    [m2d, mInf]=CLEAR_MOT_HUN(gtInfo,stInfo);
    allMets.bmark2d=m2d;
    
    evalFile = fullfile(resDir, 'eval2D.txt');
    
    printMetrics(m2d);
    dlmwrite(evalFile,m2d);
end    

if eval3D
    fprintf('\n');
    fprintf(' ********************* Your Benchmark Results (3D) ***********************\n');

    evopt.eval3d=1;evopt.td=1;
       
    [m3d, mInf]=CLEAR_MOT_HUN(gtInfo,stInfo,evopt);
    allMets.bmark3d=m3d;
    
    evalFile = fullfile(resDir, 'eval3D.txt');
    
    printMetrics(m3d);
    dlmwrite(evalFile,m3d);    
end
if ~eval2D && ~eval3D
    fprintf('ERROR: results cannot be evaluated\n');
end
end

function [] = drawFP(gtinfo, stI, allfalsepos, vidDir, seqName)
    colors = {'r','g','b','c','m','y'};
    lineWidth = 3;

    video_dir = fullfile(vidDir, seqName);
    fn = dir([video_dir, '/*.jpg']);

    num_frames = size(allfalsepos, 1);
    for fidx = 1 : num_frames
        fr_fn = fullfile(video_dir, fn(fidx).name);
        img = imread(fr_fn);
        figure(1), imshow(img); hold on;
        
        num_person = size(gtinfo.X,2);
        for pidx = 1:num_person
            color = colors{mod(pidx, length(colors))+1};
            xi = gtinfo.Xi(fidx, pidx);
            yi = gtinfo.Yi(fidx, pidx);
            w = gtinfo.W(fidx, pidx);
            h = gtinfo.H(fidx, pidx);
            x = xi - w/2;
            y = yi - h;
            pos = [x, y, w, h];
            rectangle('Position', pos, 'EdgeColor', color, 'LineWidth', lineWidth);
            text(pos(1)+5, pos(2)+15, num2str(pidx), 'FontSize', 20);
        end
        
        falsepos = find(allfalsepos(fidx, :) ~= 0);
        if(isempty(falsepos))
            continue;
        end

        for falidx = falsepos
            color = colors{mod(falidx, length(colors))+1};
            xi = stI.Xi(fidx, falidx);
            yi = stI.Yi(fidx, falidx);
            w = stI.W(fidx, falidx);
            h = stI.H(fidx, falidx);
            x = xi - w/2;
            y = yi - h;
            pos = [x, y, w, h];
            rectangle('Position', pos, 'EdgeColor', color, 'LineWidth', lineWidth);
            text(pos(1)+5, pos(2)+15, 'fp', 'FontSize', 20);
        end
        pause(0.001);
    end
    close all;
end