function [ param, beta, model, d, tm ] = mkltrack( cfrm, beta, model, tm, d, param, opt, f )
%%
nfeature = 3;
sz = opt.nsize;
n = opt.numsample;
conf  = zeros(1,n);
rate = opt.update;
th = 0;

%%--- generate candidates ---%%
param.param = repmat(affparam2geom(param.est(:)), [1,n]);
param.param = param.param + randn(6,n).*repmat(opt.affsig(:),[1,n]);              
rwimgs = warpimg(double(cfrm(:,:,1)), affparam2mat(param.param), sz);  
bwimgs = warpimg(double(cfrm(:,:,2)), affparam2mat(param.param), sz);  
gwimgs = warpimg(double(cfrm(:,:,3)), affparam2mat(param.param), sz); 
tmp = zeros([sz, 3]);

%%--- candidate selection ---%%
for i = 1:n
    tmp(:,:,1) = rwimgs(:,:,i);
    tmp(:,:,2) = bwimgs(:,:,i);
    tmp(:,:,3) = gwimgs(:,:,i);
    [ rgb, hog, sifts ] = extract_feature( tmp );
    for j = 1:size(beta,1)
        idx = beta(j,2);
%         str = ['-t ', num2str(floor((idx-1)/3))];
        m = model(j);
        switch (floor((idx-1)/32))
            case 0;
                [pred_l, acc, dec] = svmpredict(1, rgb, m);
                prob = distribution_prob( d, rgb, j );
            case 1;
                [pred_l, acc, dec] = svmpredict(1, hog, m);
                prob = distribution_prob( d, hog, j );
            case 2;
                if size(sifts,1) ~= 0
                    l = ones(size(sifts,1),1);
                    [pred_l, acc, dec] = svmpredict(l, sifts, m);
                    dec = mean(dec);
                    prob = distribution_prob( d, sifts, j );
                    prob = mean(prob);
                else break;
                end
        end
        conf(i) = conf(i) + beta(j,1) * dec' * prob;
%         conf(i) = conf(i) + repmat(beta(j,1),size(dec,1),1)' * dec;
    end
end

%%--- object found ---%%
% ma = max(conf); mi = min(conf);
% conf = (conf-mi) / (ma-mi);
conf = exp(conf);
conf = conf / sum(conf);
conf(find(conf) == NaN) = 0;
[maxconf, maxidx] = max(conf); %% maximum
% param.est = affparam2mat(param.param(:,maxidx));

param.param = affparam2mat(param.param);
% [cc, idxsort]=sort(conf, 'descend');
% portion = 0.05 * n;
% cc = conf(idxsort(1:portion));
% maxprob = sum(cc);
% cc = cc / sum(cc);
% result = repmat(cc, 6, 1) .* param.param(:,idxsort(1:portion));  %% weighted sum
result = repmat(conf, 6, 1) .* param.param;  %% weighted sum
param.est = sum(result,2);

%%--- collect samples for update ---%%
if maxconf > th
    %-- postive sample --%
    tmp(:,:,1) = warpimg(double(cfrm(:,:,1)), param.est, sz);
    tmp(:,:,2) = warpimg(double(cfrm(:,:,2)), param.est, sz);  
    tmp(:,:,3) = warpimg(double(cfrm(:,:,3)), param.est, sz);  
    [ rgb, hog, sifts ] = extract_feature( tmp );
    sift_num = size(sifts,1);
    %-- negtive samples --%
    [ n_rgb, n_hog, n_sifts ] = extract_neg( cfrm, param, sz );
    n_sift_num = size(n_sifts,1);
    %-- data arrangement --%
    param.rgb = [param.rgb; rgb; n_rgb];
    param.l1 = [param.l1; 1; -ones(4,1)];
    param.hog = [param.hog; hog; n_hog];
    param.l2 = [param.l2; 1; -ones(4,1)];
    param.sift = [param.sift; sifts; n_sifts];
    param.l3 = [param.l3; ones(sift_num,1); -ones(n_sift_num,1)];
    
    %%--- tracker update ---%%
    if mod(f,rate) == 0
        datanum = [size(param.rgb,1) size(param.hog,1) size(param.sift,1)];
        tic;
        [ beta, model, d, tm ] = update( param, nfeature, datanum );
        toc
        param.rgb = []; param.hog = []; param.sift = [];
        param.l1 = []; param.l2 = []; param.l3 = [];
    end
end


%%--- implementation of negtive sample extraction ---%%
function [ rgb, hog, sifts ] = extract_neg( cfrm, param, sz )
%%
r = 50;
offset = [[r -r 0 0; 0 0 r -r]; zeros(4,4)]; 
tmpp = repmat(affparam2geom(param.est(:)), [1,4]);
tmpp = tmpp + offset;
rwimgs = warpimg(double(cfrm(:,:,1)), affparam2mat(tmpp), sz);  
bwimgs = warpimg(double(cfrm(:,:,2)), affparam2mat(tmpp), sz);  
gwimgs = warpimg(double(cfrm(:,:,3)), affparam2mat(tmpp), sz); 
tmp = zeros([sz, 3]);
rgb = []; hog = []; sifts = [];
for i = 1:4
    tmp(:,:,1) = rwimgs(:,:,i);
    tmp(:,:,2) = bwimgs(:,:,i);
    tmp(:,:,3) = gwimgs(:,:,i);
    [ trgb, thog, tsifts ] = extract_feature( tmp );
    rgb = [rgb; trgb];
    hog = [hog; thog];
    sifts = [sifts; tsifts];
end
%%--- end of extract_neg ---%%

