clear
close all

%% Prepare the reference image
im = imread('mario.png');
im = im(:, 1:size(im,1), :);
im = rgb2gray(im);
im = imresize(im, [ 128 128 ], 'nearest');
im = im2double(im);

%%
figure
imagesc(im)
colormap gray

%% 
numImages = 10;
blurSigma = 2;

%% run at multiple scale factors to create plot with curves

scaleFactors = [1,2,3];
timesL1cvx = zeros(size(scaleFactors));
timesL2cvx = zeros(size(scaleFactors));
timesL1qp = zeros(size(scaleFactors));
timesL2qp = zeros(size(scaleFactors));

for ii = 1:length(scaleFactors)
    fprintf('Running with scale factor %d\n\n\n\n', scaleFactors(ii));
    
    im = imread('mario.png');
    im = rgb2gray(im);
    im = imresize(im, [ 64 64 ] * scaleFactors(ii));
    im = im2double(im);

    [ images, offsets, croppedOriginal ] = SynthDataset(im, numImages, blurSigma, scaleFactors(ii));

    [A , b, G] = formulateProblemV2(images, offsets, scaleFactors(ii), blurSigma );

    
    disp(size(A))
    disp(size(b))
    disp(size(G))
    % solve with CVX
    tic
    [highResL2CVX, residualsL2CVX] = solveCVX(A, b, G, 5e-2, 2, size(images{1}));
    timesL2cvx(ii) = toc;

    tic
    [highResL1CVX, residualsL1CVX] = solveCVX(A, b, G, 5e-3, 1, size(images{1}));
    timesL1cvx(ii) = toc;

    % solve with quadprog
    tic
    [highResL2QP, residualsL2QP] = solveQuadprog(A, b, G, 5e-2, 2, size(images{1}));
    timesL2qp(ii) = toc;

    tic
    [highResL1QP, residualsL1QP] = solveQuadprog(A, b, G, 5e-3, 1, size(images{1}));
    timesL1qp(ii) = toc;
    
    % visual inspection for each run
    figure
    subplot(2,2,1)
    imagesc(highResL1CVX, [0 1])
    axis image
    subplot(2,2,2)
    imagesc(highResL2CVX, [0 1])
    axis image
    subplot(2,2,3)
    imagesc(highResL1QP, [0 1])
    axis image
    subplot(2,2,4)
    imagesc(highResL2QP, [0 1])
    axis image
    
    drawnow
end

%%
figure('position', [397         509        1008         420])
subplot(1,2,1)
hold on
plot(scaleFactors, timesL1cvx,'o-','linewidth',2)
plot(scaleFactors, timesL1qp,'s-','linewidth',2)
xlabel('Scale Factor')
ylabel('Runtime [s]')
title('L-1 Regularization Runtimes')
box on
legend({'CVX','quadprog'}, 'location','northwest')
set(gca,'xtick', [1,2,3])
xlim([0.5 3.5])

subplot(1,2,2)
hold on
plot(scaleFactors, timesL2cvx,'o-','linewidth',2)
plot(scaleFactors, timesL2qp,'s-','linewidth',2)
xlabel('Scale Factor')
ylabel('Runtime [s]')
title('L-2 Regularization Runtimes')
box on
set(gca,'xtick', [1,2,3])
xlim([0.5 3.5])

% saveas(gcf,'figures/runtimes.png')