function [L] = Frame_Blend(im1int,im2int)
sz = size(im1int);

im1int = imresize(im1int,0.1,'nearest');
im2int = imresize(im2int,0.1,'nearest');
% mask1 = imresize(mask1,0.1,'cubic');
% mask2 = imresize(mask2,0.1,'cubic');

% initial images should be uint8
im1int = uint8(im1int*255);im2int = uint8(im2int*255);
[nr,nc] = size(im1int);
mask1 = imfill(im1int~=0,'holes'); %Find the active pixels in each image
mask2 = imfill(im2int~=0,'holes');

% get the gradient of each image
h = fspecial('gaussian',[3,1]);
diffV = sqrt((double(im1int)-double(im2int)).^2);
diffH = imfilter(diffV,h');
diffV = imfilter(diffV,h);

% give "nan" pixels very high cost
DCl1 = zeros(nr,nc);%50./abs(256-double(im1int));%100*ones(nr,nc);%1-imfilter(medfilt2(im2double(im1int)),h1);%
DCl2 = zeros(nr,nc);%50./abs(256-double(im2int));%ones(nr,nc);%1-imfilter(medfilt2(im2double(im2int)),h1);% 
DCl1(~mask1) = 10000;
DCl2(~mask2) = 10000;

% % high gradient pixels have low cost
DCmat = zeros(nr,nc,2);
DCmat(:,:,1) = (DCl1);
DCmat(:,:,2) = (DCl2);

% compute the vertical pairwise cost
GCvC = abs(100*diffV);%conv2(diffV,fspecial('gaussian',[15,15],1)','same'));

% compute the horizontal pairwise cost
GChC = abs(100*diffH);%conv2(diffH,fspecial('gaussian',[15,15],1),'same'));

% [GCvC1,GChC1] = gradient(diffV);
gch = GraphCut('open',DCmat,[0.2 0.8; 0.8 0.2],GChC,GCvC);

% tic
[gch, L] = GraphCut('expand',gch);
% toc

%imagesc(L);
[gch] = GraphCut('close', gch);
%imagesc(L)
L(L==1)=2;
L(L==0)=1;
L = imresize(L,sz,'nearest');
