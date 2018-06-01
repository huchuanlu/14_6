function [ rgb, hog, sifts ] = extract_feature( cimg )
%%
%%--rgb--%%
bin = 4;
if size(cimg,3) == 3
    rgb = rgb_hist(cimg,bin);
else
    rgb = hist(cimg, 256);
end
%%--hog--%%
% gimg = rgb2gray(uint8(cimg));
gimg = im2single(rgb2gray(uint8(cimg)));
% profile on;
% hog = hog_block(gimg,8,[8 8]);
hog = vl_hog(gimg, 16, 'Variant', 'DalalTriggs', 'NumOrientations', 8);
hog = double(hog(:)');

%%--sift--%%
% [frame, sifts] = sift(gimg/256,'boundarypoint',0);
[frame, sifts] = vl_sift(gimg, 'Levels', 4);

% profile viewer;
sifts = double(sifts');
% sifts = sifts';
sifts = sifts ./ repmat(sum(sifts,2), 1, size(sifts,2));
% sifts = sifts ./ repmat(sum(sifts,2),1,128);
%%EOF%%