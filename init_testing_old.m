clc
clear 
close all
%% Prepare the reference image
im = imread('exampleImage.png');
im = rgb2gray(im);
im = imresize(im, [ 128 128 ]);
im = 1 - im2double(im);
%% Simulate the low-resolution images
numImages = 10;
blurSigma = 2;
[ images offsets croppedOriginal ] = SynthDataset(im, numImages, blurSigma);
%%
scaleFactor = 2;
[A , b, G] = formulateProblemV2(images, offsets, scaleFactor, blurSigma );


%% solve with gradient descent for comparison

[ lhs, rhs  ] = SREquations(images, offsets, blurSigma);
K = sparse(1 : size(lhs, 2), 1 : size(lhs, 2), sum(lhs, 1));
initialGuess = K \ lhs' * rhs; % This is an 'average' image produced from the LR images.

HR = GradientDescent(lhs, rhs, initialGuess);
highResGradDesc = reshape(HR, sqrt(numel(HR)), sqrt(numel(HR)));

%%
[highResL2, residualsL2] = solveCVX(A, b, G, 1e0, 2, size(images{1}));

%%
[highResL1, residualsL1] = solveCVX(A, b, G, 5e-3, 1, size(images{1}));


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
axis image


