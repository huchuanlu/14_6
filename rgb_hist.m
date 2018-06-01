function hist = rgb_hist(cimg,bin)
%function Hist = rgb_hist(r,g,b,bin)
%extract RGB histgram from an image block 
%--------------------------------------------
r = cimg(:,:,1);
g = cimg(:,:,2);
b = cimg(:,:,3);
[height,width]=size(r);
hist=zeros(1,bin^3);
%Hist=[];
for i=1:width
    for j=1:height
        %tc=double(imageblock(j,i,:));
        rn=floor(r(j,i,1)/(256/bin));
        gn=floor(g(j,i,1)/(256/bin));
        bn=floor(b(j,i,1)/(256/bin));
        tmp = uint16(rn*bin*bin+gn*bin+bn+1);
        if tmp > 0 && tmp <= bin^3
            hist(tmp)=hist(tmp)+1;
        end
    end
end
hist=hist/sum(hist);   %normalise