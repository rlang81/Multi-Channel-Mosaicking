function mosaic = stitchImages(img1,img2)
%% RGB2Gray conversion
if size(img1, 3) == 3
    rgb = true;
    img1g = rgb2gray(img1);
    img2g = rgb2gray(img2);
else
    rgb = false;
    img1g = img1;
    img2g = img2;
end

%% Stitching part
img1g(isnan(img1g)) = 0 ;
img2g(isnan(img2g)) = 0 ;

active = img1g>0&img2g>0;
sz = size(img1g);

Aregion=[1 sz(1) 1 sz(2)];
active = single(active);
active(img1g>0) = 2;
active(img2g>0) = 1;

% img1g = max(0,img1g-0.001);
% img2g = max(0,img2g-0.001);

tic
active(Aregion(1):Aregion(2),Aregion(3):Aregion(4)) = Frame_Blend(img1g(Aregion(1):Aregion(2),Aregion(3):Aregion(4)),img2g(Aregion(1):Aregion(2),Aregion(3):Aregion(4))); 
L = active;

display(['Blending took ',num2str(toc),' secs']);

if rgb
    L = repmat(L, 1,1,3);
end

if range(L(:))>0
    mosaic = (img1.*(L==1)) + (img2.*(L==2));
%      close all
%  imshowpair(img1.*(L==1), (img2.*(L==2)));
%  pause(0.1);
    mosaic = im2uint8(mosaic);
    mosaic(L==0) = NaN;
else
    mosaic = im2uint8(img1);
end
A = uint8(abs(imfilter(L,fspecial('log',[3,3])))>10^-1);
if rgb
    mosaic = mosaic-(mosaic.*A)+(imfilter(mosaic,fspecial('gaussian',[15,15],2)).*A);
%     [x,y,c] = find(mosaic);
%     mosaic = mosaic(1:max(x),1:max(y),1:max(c));
else
    mosaic = mosaic-(mosaic.*A)+(imfilter(mosaic,fspecial('gaussian',[15,15],2)).*A);
%     [x,y] = find(mosaic);
%     mosaic = mosaic(1:max(x),1:max(y));
end


