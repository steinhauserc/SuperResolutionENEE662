function [resizerror] = resizevis(images,croppedOriginal,highResL1,highResL2)
%visualiseavg Plots the Average image and gives the MSE for the avgimg.
%   Detailed explanation goes herR
    
    numImages=length(images);
    for i=1:numImages
        current=imresize(images{i},[size(croppedOriginal)]);
        errormat(i)=mean((current(:) - croppedOriginal(:)).^2);
    end

    [resizerror,ind]= min(errormat);
    resizeimg=imresize(images{i},[size(croppedOriginal)]);
    
    
    figure()
    subplot(2,2,3)
    imagesc(resizeimg, [0, 1])
    title(sprintf('Image using imresize (mse = %.1d)', resizerror))
    colormap(gray)
    axis image

    subplot(2,2,2)
    imagesc(highResL2, [0, 1])
    title(sprintf('L-2 gradient regularization (mse = %.1d)', mean((highResL2(:) - croppedOriginal(:)).^2)))
    colormap(gray)
    axis image

    subplot(2,2,4)
    imagesc(highResL1, [0, 1])
    title(sprintf('L-1 gradient regularization (mse = %.1d)', mean((highResL1(:) - croppedOriginal(:)).^2)))
    colormap(gray)
    axis image

    subplot(2,2,1)
    imagesc(croppedOriginal, [0, 1])
    colormap(gray)
    title('Original Image')
    axis image
end

