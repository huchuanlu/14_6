function [ beta, model, d, tm ] = mkltrain( cfrm, param, nsize )
%%
train_num = 20;
nfeature = 3;
theta = [1,1,0,0,0,0];
gfrm = double(rgb2gray(cfrm));

%%--- postive sample ---%%
param.param = repmat(affparam2geom(param.est(:)), [1,train_num]);
param.param = param.param + randn(6,train_num) .* repmat(theta(:),[1,train_num]);
% wimgs = warpimg(gfrm, affparam2mat(param.param), nsize);                  
rwimgs = warpimg(double(cfrm(:,:,1)), affparam2mat(param.param), nsize);  
bwimgs = warpimg(double(cfrm(:,:,2)), affparam2mat(param.param), nsize);  
gwimgs = warpimg(double(cfrm(:,:,3)), affparam2mat(param.param), nsize); 
tmp = zeros([nsize, 3]);
%%--- feature extraction ---%%
rgb = []; hog = []; sifts = [];
for i = 1:train_num
    tmp(:,:,1) = rwimgs(:,:,i);
    tmp(:,:,2) = bwimgs(:,:,i);
    tmp(:,:,3) = gwimgs(:,:,i);
    [ trgb, thog, tsifts ] = extract_feature( tmp );
    rgb = [rgb; trgb];
    hog = [hog; thog];
    sifts = [sifts; tsifts];
end

%%--- negtive sample ---%%
% r1 = param.
neg = param.param + random('uniform',30,50,6,train_num) .* [2*rand(2,train_num); zeros(4,train_num)];
% wimgs = warpimg(gfrm, affparam2mat(param.param), nsize);                  
rwimgs = warpimg(double(cfrm(:,:,1)), affparam2mat(neg), nsize);  
bwimgs = warpimg(double(cfrm(:,:,2)), affparam2mat(neg), nsize);  
gwimgs = warpimg(double(cfrm(:,:,3)), affparam2mat(neg), nsize);
%%--- feature extraction ---%%
n_rgb = []; n_hog = []; n_sifts = [];
for i = 1:train_num
    tmp(:,:,1) = rwimgs(:,:,i);
    tmp(:,:,2) = bwimgs(:,:,i);
    tmp(:,:,3) = gwimgs(:,:,i);
    [ trgb, thog, tsifts ] = extract_feature( tmp );
    n_rgb = [n_rgb; trgb];
    n_hog = [n_hog; thog];
    n_sifts = [n_sifts; tsifts];
end

%%--- data arrangement ---%%
data.rgb = [rgb; n_rgb];
data.hog = [hog; n_hog];
data.sift = [sifts; n_sifts];
label.rgb = [ones(train_num,1); -ones(train_num,1)];
label.hog = [ones(train_num,1); -ones(train_num,1)];
label.sift = [ones(size(sifts,1),1); -ones(size(n_sifts,1),1)];
datanum = [size(data.rgb,1) size(data.hog,1) size(data.sift,1)];

%%--- train mkl ---%%
[ beta, model, tm ] = boost_mkl( data, label, nfeature, datanum);

%%--- compute distribution ---%%
d = distribution( model );

