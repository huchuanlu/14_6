%% Multiple Kernel Boosting Tracking %%
%% Copyright(C) Fan Yang %%
%% 2012.9 %%

clc;
clear; close all;
addpath('affine');
%% tracking parameters
trackparam;
warning('off');
rand('state',0);  randn('state',0);
imgs = dir(dataPath);
LoopNum = length(imgs) - 2;

%% load 1st frame
iframe = imread([dataPath '001.jpg']);
if size(iframe,3) ~= 3
    iiframe = repmat(iframe,[1,1,3]);
else
    iiframe = iframe;
end
frame = double(rgb2gray(iiframe));

%% initialization
opt.nsize = [32 32];
param = [];
param.est = param0; 
param.wimg = warpimg(frame, param0, opt.nsize);
param.rgb = []; param.hog = []; param.sift = [];
param.l1 = []; param.l2 = []; param.l3 = [];
rst = [];
drawopt = drawtrackresult([], 1, iiframe, param);

%% save result
imwrite(frame2im(getframe(gcf)), sprintf('result/%s/%s_0001.png', title, title));

%% train
[beta, model, d, tm] = mkltrain(iiframe, param, opt.nsize);

%% run tracker
duration = 0; tic; % timing
for f = 2:LoopNum-10
    imgName = sprintf('%s%03d.jpg', dataPath, f); 
    iframe = imread(imgName);
    if size(iframe,3) ~= 3
        iiframe = repmat(iframe,[1,1,3]);
    else
        iiframe = iframe;
    end
    [param, beta, model, d, tm] = mkltrack(iiframe, beta, model, tm, d, param, opt, f);
    rst = [rst; param.est'];
    drawopt = drawtrackresult(drawopt, f, iiframe, param);
    
    %% save results
    imwrite(frame2im(getframe(gcf)), sprintf('result/%s/%s_%04d.png', title, title, f)); 
end

duration = duration + toc;      
fprintf('%d frames took %.3f seconds : %.3fps\n',f,duration,f/duration);
fps = f/duration;
%% save tracking data
filename = sprintf('result/%s/%s.mat', title, title);
save(filename, 'rst');

