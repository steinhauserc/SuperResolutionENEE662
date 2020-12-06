function [outputArg1,outputArg2] = interpolatedAverage(lowRes, offsets, scaleFactor)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

finalSize = size(lowRes{1}) * scaleFactor + 1;

% TODO:
% translate each image based on corresponding value in offsets
% use imresize to scale up to image with finalSize
% average interpolated image to see what the solution looks like without
% super resolution

end

