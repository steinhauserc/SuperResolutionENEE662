clc
clear 
close all

setupPaths
%% Prepare the reference image
im = imread('campuspicture.jpg');
im = rgb2gray(im);
im = im2double(im);
im = im;
%% Simulate the low-resolution images
numImages = 100;
blurSigma = 2;
scaleFactor = 2;

[ images offsets croppedOriginal ] = SynthDataset(im, numImages, blurSigma, scaleFactor);
%%
[A , b, G] = formulateProblemV2(images, offsets, scaleFactor, blurSigma );

%% solve with gradient descent for comparison

[ lhs, rhs  ] = SREquations(images, offsets, blurSigma);
K = sparse(1 : size(lhs, 2), 1 : size(lhs, 2), sum(lhs, 1));
initialGuess = K \ lhs' * rhs; % This is an 'average' image produced from the LR images.

HR = GradientDescent(lhs, rhs, initialGuess);
highResGradDesc = reshape(HR, sqrt(numel(HR)), sqrt(numel(HR)));

%%
[highResL2, residualsL2] = solveQuadprog(A, b, G, 3e-3, 2, size(images{1}));

%%
[highResL1, residualsL1] = solveQuadprog(A, b, G, 2e-3, 1, size(images{1}));

%%
figure
subplot(2,2,1)
imagesc(croppedOriginal, [0, 1])
title('Original Image')
axis image

subplot(2,2,2)
imagesc(highResGradDesc, [0,1])
title(sprintf('Gradient Descent (mse = %.1d)', mean((highResGradDesc(:) - croppedOriginal(:)).^2)))
axis image

subplot(2,2,3)
imagesc(highResL2, [0, 1])
title(sprintf('L-2 gradient regularization (mse = %.1d)', mean((highResL2(:) - croppedOriginal(:)).^2)))
axis image

subplot(2,2,4)
imagesc(highResL1, [0, 1])
title(sprintf('L-1 gradient regularization (mse = %.1d)', mean((highResL1(:) - croppedOriginal(:)).^2)))
colorbar
axis image
%% Visulaise the effect of lamda on MSE

max=1; %specify keeping in mind max value of lamda = 10^{max}
itermax=10*3; %keep it a multiple of 3 so that it can be easily displayed on the plot

[L1mat,L2mat,lam]=multilamsol(A,b,G,size(images{1}),max,itermax);
[errorL1,errorL2]=multilamvis(L1mat,L2mat,croppedOriginal,lam);

%% Compare the effectiveness of l-1 and l-2 vs the average image

avgimg=averageimage(images, offsets,im);
avgerror=visualiseavg(avgimg,croppedOriginal,highResL1,highResL2)

%% Compare the effectiveness of l-1 and l-2 vs the imresize
resizerror = resizevis(images,croppedOriginal,highResL1,highResL2)
%% Plot to compare the numimages vs MSE for average image
minnumimages=8;
maxnumimages=100;
iter=24;
img=numavg(highResL1,highResL2,croppedOriginal,maxnumimages,minnumimages,iter,im);
