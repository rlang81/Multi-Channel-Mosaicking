%% Test script for multi-channel mosaicking project
% Mosaics multi-channel data using methods described in *INSERT PAPER*

clear all; close all; clc;
%% Import data - see README for instructions on Data Directory structure

Data_dir = 'Test_Data'; % Data Directory
channel_dirs = dir(Data_dir);
% Data Directory has a sub-folder for each data channel
n_channels = length(channel_dirs) - 2;

for i = 1:n_channels
    current_ch_dir = dir([Data_dir '/' channel_dirs(i+2).name]);
    n_frames = length(current_ch_dir) - 2;
    for j = 1:n_frames
        original_frames(:,:,i,j) = imread([Data_dir '/' channel_dirs(i+2).name '/frame' num2str(j-1) '.tif']);
    end
end

original_frames = double(original_frames)/255;

yres = size(original_frames,  1);
xres = size(original_frames,  2);

% If a GPU device is available, use it for increased calculation speed

try
   canUseGPU = parallel.gpu.GPUDevice.isAvailable;
catch ME
   canUseGPU = false;
end

if canUseGPU
    original_frames_GPU = gpuArray(original_frames);
end

%% Allocate variables for mosaicking
mosaics = original_frames(:,:,:,1);
dx = 0; dy = 0; dxt = 0; dyt = 0;
trustvector = normalize(double(ones(1,n_channels)),'norm', 1);

%% Calculate mosaics
for f = 1:n_frames-1
    dxp = dx;
    dyp = dy;
    
    I1 = original_frames(:,:,:,f);
    I2 = original_frames(:,:,:,f+1);
    
    if canUseGPU
        I1_GPU = original_frames_GPU(:,:,:,f);
        I2_GPU = original_frames_GPU(:,:,:,f+1);
        [dy, dx, err] = mchannel_nxcorr_reg_GPU(I1_GPU, I2_GPU, trustvector);
    else
        [dy, dx, err] = mchannel_nxcorr_reg_GPU(I1, I2, trustvector);
    end       

    % Only include next line if you want dynamic weighted averaging based on individual error rates
    % trustvector = 0*trustvector + 1./(err+1);
    
    dxt = dxt + dx;
    dyt = dyt + dy;

    tform = affine2d;
    tform.T = double([1 0 0; 0 1 0; dxt dyt 1]);

    imageSize = size(mosaics(:,:,1));
    Mind = mosaics;
    mosaics = [];
    Mtind = [];
    I2t = [];
    
    [xlim, ylim] = outputLimits(tform, [1 xres], [1 yres]);
    xMin = min([1; xlim(:)]);
    xMax = max([imageSize(2); xlim(:)]);
    yMin = min([1; ylim(:)]);
    yMax = max([imageSize(1); ylim(:)]);
    width = round(xMax-xMin);
    height = round(yMax-yMin);

    xLimits = [xMin xMax];
    yLimits = [yMin yMax];
    panoramaView = imref2d([height width], xLimits, yLimits);
    
    for j = 1:n_channels
        Mtind(:,:,j) = imwarp(Mind(:,:,j), affine2d, 'nearest', 'OutputView', panoramaView);
        I2t(:,:,j) = imwarp(I2(:,:,j), tform, 'OutputView', panoramaView);
        mosaics(:,:,j) = double(stitchImages(Mtind(:,:,j), I2t(:,:,j)))/255;
    end
end

montage(mosaics, 'Size', [1 n_channels]);