function [avgerror] = visualiseavg(avgimg,croppedOriginal)
%visualiseavg Plots the Average image and gives the MSE for the avgimg.
%   Detailed explanation goes here
    furthercropped=croppedOriginal(2:end-1,2:end-1);
    figure()
    imagesc(avgimg, [0, 1])
    title(sprintf('Average Image (mse = %.1d)', mean((avgimg(:) - furthercropped(:)).^2)))
end

