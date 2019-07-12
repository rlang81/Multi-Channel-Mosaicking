function [dy,dx, err] = mchannel_nxcorr_reg_GPU(frame1, frame2, weights)
%n_channel_nxcorr_reg Computes normalized cross-correlation and finds
%maximum for n channels of pairwise frames
%   frame1, frame2 are yres by xres by n_channels multi-channel frames
%   frames can be type gpuArray for increased computational speed
%   if no weights are given the average will be unweighted

n_ch = double(size(frame1,3)); 
xres = int16(size(frame1,2)); 
yres = int16(size(frame1,1));
xcrop = int16(xres/3);          
ycrop = int16(yres/3);

frame2c = frame2(ycrop:(yres-ycrop), xcrop:(xres-xcrop),:);

if ~exist('weights','var')
    weights = double(ones(1,n_ch))/n_ch;
end

for i = 1:n_ch
    corrMap = normxcorr2(frame2c(:,:,i), frame1(:,:,i)); 
    corrMap = corrMap(ycrop:yres, xcrop:xres);
    [~,imax] =  max(corrMap(:));
    [yg(i), xg(i)] = ind2sub(size(corrMap),imax(1));
    corrMapSum(:,:,i) = corrMap*weights(i);
end

corrMapSum = sum(corrMapSum, 3);

[~,imax] = max(corrMapSum(:));
[ygs, xgs] = ind2sub(size(corrMapSum), imax(1));
errg = sqrt((ygs-yg).^2 + (xgs-xg).^2);

err = gather(errg);
y = gather(ygs); x = gather(xgs);
dy = y - xcrop;
dx = x - ycrop;
end

