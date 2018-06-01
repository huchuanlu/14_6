function [ beta, model, d, tmodel ] = update( param, nfeature, datanum )
%%
%%--- mkl update ---%%
ntype = 32;
n_svm = nfeature * ntype;
th = 300;
tmodel = []; 
tlabel = cell(n_svm,1);
tdec = cell(n_svm,1); 
tbeta = []; model = []; beta = []; tt = [];
d1 = param.rgb; d2 = param.hog; d3 = param.sift;
l1 = param.l1; l2 = param.l2; l3 = param.l3;
pos = 0;

str = kernel_param( ntype );
for i = 1:nfeature
    d = eval(['d' num2str(i)]);
    l = eval(['l' num2str(i)]);
    for j = 1:ntype
        pos = pos + 1;
        s = str{j};
        m = svmtrain(l, d, s);
        [pred_l, acc, dec_v] = svmpredict(l, d, m);
        tmodel = [tmodel; m];
        tlabel{pos} = pred_l';
        tdec{pos} = dec_v';
    end
end

iter = 10;
D = cell(nfeature,1);
for j = 1:nfeature
    D{j} = ones(datanum(j),1) / datanum(j);
end
for t = 1:iter
    for j = 1:n_svm
        if sum(j==tt) ~= 0 
            tbeta = [tbeta; -inf];
            continue; 
        end
        fi = floor((j-1)/ntype)+1;
        l = eval(['l' num2str(fi)]);
        if ~isempty(tdec{j})
            y_dec = D{fi} .* abs(tdec{j}');
        else
            y_dec = D{fi};
        end
        b = 0.5 * log(sum(y_dec(tlabel{j}'==l))/(sum(y_dec(tlabel{j}'~=l))+eps));
%         err = sum(D(tlabel(j,:)'~=label));
%         b = 0.5 * log((1-err) / err);
        tbeta = [tbeta; b];
    end
    [var, idx] = max(tbeta);
    idx1 = find(tbeta == var);
    idx = idx1(end);
    if var<0 break; end
    beta = [beta; var];
    model = [model; tmodel(idx)];
    tt = [tt; idx];
    fi = floor((idx-1)/ntype)+1;
    l = eval(['l' num2str(fi)]);
%     D{fi} = D{fi} .* exp(-var * tlabel{idx}' .* l);
    if ~isempty(tdec{j})
        D{fi} = D{fi} .* exp(-var * tdec{idx}' .* l);
    else
        D{fi} = D{fi} .* exp(-var .* l);
    end
    D{fi} = D{fi} / sum(D{fi});
    tbeta = [];
    t = t + 1;
end
beta = [beta tt];
% n_svm = 12;
% nfeature = 3;
% type = n_svm ./ nfeature;
% th = 300;
% label = cell(n_svm,1);
% tlabel = cell(n_svm,1);
% tdec = cell(n_svm,1); 
% tbeta = []; model = []; beta = []; tt = [];
% pos = 0;
% datanum = zeros(n_svm,1);
% d1 = param.rgb; d2 = param.hog; d3 = param.sift;
% l1 = param.l1; l2 = param.l2; l3 = param.l3;
% for i = 1:type
%     str = ['-t ', num2str(i-1)];
%     for j = 1:nfeature
%         pos = pos + 1;
%         d = eval(['d' num2str(j)]);
%         l = eval(['l' num2str(j)]);
%         d = [d; tm(pos).SVs];
%         l = [l; sign(tm(pos).sv_coef)];
%         datanum(pos) = size(l,1);
%         m = svmtrain(l, d, str);
%         %%-- support vector refinement --%%
%         if size(m.SVs,1) > th
%             [y,p] = sort(abs(m.sv_coef),'descend');
%             m.SVs = m.SVs(p(1:th),:);
%             m.sv_coef = m.sv_coef(p(1:th));
%             m.nSV = [sum(m.sv_coef>0); sum(m.sv_coef<0)];
%             m.totalSV = size(m.sv_coef,1);
%         end
%         %%-- support vector refinement --%%
%         %%-- group --%%
%         [pred, acc, dec] = svmpredict(sign(m.sv_coef), m.SVs, m);
%         weight = exp(abs(dec)) / sum(exp(abs(dec)));
%         m.sv_coef = m.sv_coef .* weight;
%         ma = max(m.sv_coef); mi = min(m.sv_coef);
%         m.sv_coef = (m.sv_coef-0.5*(ma+mi)) * 2/(ma-mi);
%         %%-- group --%%
%         [pred_l, acc, dec_v] = svmpredict(l, d, m);
%         tm(pos) = m;
%         label{pos} = l;
%         tlabel{pos} = pred_l';
%         tdec{pos} = dec_v';
%     end
% end
% 
% iter = 10;
% D = cell(n_svm,1);
% for j = 1:n_svm
%     D{j} = ones(datanum(j),1) / datanum(j);
% end
% for t = 1:iter
%     for j = 1:n_svm
%         if sum(j==tt) ~= 0 
%             tbeta = [tbeta; -inf];
%             continue; 
%         end
% %         fi = mod(j-1,nfeature)+1;
%         l = label{j};
%         y_dec = D{j} .* abs(tdec{j}');
%         b = 0.5 * log(sum(y_dec(tlabel{j}'==l))/(sum(y_dec(tlabel{j}'~=l))+eps));
% %         err = sum(D(tlabel(j,:)'~=label));
% %         b = 0.5 * log((1-err) / err);
%         tbeta = [tbeta; b];
%     end
%     [var, idx] = max(tbeta);
%     if var<0 break; end
%     beta = [beta; var];
%     model = [model; tm(idx)];
%     tt = [tt; idx];
% %     fi = mod(idx-1,nfeature)+1;
%     l = label{idx};
% %     D{fi} = D{fi} .* exp(-var * tlabel{idx}' .* l);
%     D{idx} = D{idx} .* exp(-var * tdec{idx}' .* l);
%     D{idx} = D{idx} / sum(D{idx});
%     tbeta = [];
%     t = t + 1;
% end
% beta = [beta tt];

% [ beta, model, tm ] = boost_mkl( data, label, nfeature, datanum);

%%--- distribution update ---%%
d = distribution( model );                
