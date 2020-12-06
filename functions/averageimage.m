function [ avgimage ] = averageimage(images, offsets,im)

padRatio = 0.2;
numImages=length(images);
workingRowSub = round(0.5 * padRatio * size(im, 1)) : round((1 - 0.5 * padRatio) * size(im, 1));
workingColSub = round(0.5 * padRatio * size(im, 2)) : round((1 - 0.5 * padRatio) * size(im, 2));

% offsets(1, :) = 2 * rand(1,2) - 1; 

for i = 1 : numImages
%         offsets(i, :) = 2 * rand(1,2) - 1;
        offsetRowSub = workingRowSub - offsets(i, 2);
        offsetColSub = workingColSub - offsets(i, 1);
        [ x y ] = meshgrid(offsetColSub, offsetRowSub);
        x2= x(2 : 2 : end - 1, 2 : 2 : end - 1);
        y2=y(2 : 2 : end - 1, 2 : 2 : end - 1);
        x=x(2:end-1,2:end-1);
        y=y(2:end-1,2:end-1);
        avgimg{i} = interp2(x2, y2, images{i}, x, y);               
end

avgimage=zeros(size(avgimg{1}));
for i = 1 : numImages
    avgimage=avgimage+avgimg{i};
end

avgimage=avgimage/4;
end