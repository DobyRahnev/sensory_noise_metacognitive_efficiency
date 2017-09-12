function gaborPatch = makeStimulus(window, contrastGrating)

time1 = GetSecs;

%Specify the outer bound of the annulus
width = degrees2pixels(4.5, 50, [], window);
innerWidth = degrees2pixels(1.5, 50, [], window);

%Diagonal pattern: contrast 10% with 2.29 cycles per degree 
%(10.305 = 4.5 * 2.29)
contrastNoise = .3;
nGaussianSDs = 10.305; 

% compute the pixels per grating period
pixelsPerGratingPeriod = width / nGaussianSDs;

spatialFrequency = 1 / pixelsPerGratingPeriod; % How many periods/cycles are there in a pixel?
radiansPerPixel = spatialFrequency * (2 * pi); % = (periods per pixel) * (2 pi radians per period)

% adjust contrast
gray = 127;

maxLuminance = 127 * contrastNoise; 

% adjust black and white according to the specified contrast
black = gray - maxLuminance;
white = gray + maxLuminance;

halfWidthOfGrid = width / 2;
widthArray = (-halfWidthOfGrid) : halfWidthOfGrid;  % widthArray is used in creating the meshgrid.

% Creates a two-dimensional square grid.  For each element i = i(x0, y0) of
% the grid, x = x(x0, y0) corresponds to the x-coordinate of element "i"
% and y = y(x0, y0) corresponds to the y-coordinate of element "i"
[x y] = meshgrid(widthArray, widthArray);

% Creates a sinusoidal grating, where the period of the sinusoid is 
% approximately equal to "pixelsPerGratingPeriod" pixels.
% Note that each entry of gratingMatrix varies between minus one and
% one; -1 <= gratingMatrix(x0, y0)  <= 1

% the grating is oriented horizontally unless otherwise specified.
absoluteDifferenceBetweenWhiteAndGray = abs(white - gray);

stimulusMatrix = (2*rand(width+1, width+1)-1);

gratingMatrix = sin(radiansPerPixel * x);
gratingMatrix = contrastGrating * gratingMatrix;

stimulusMatrix = stimulusMatrix + gratingMatrix;
stimulusMatrix = 2*Scale(stimulusMatrix)-1;

annulusMatrix = ones(width+1, width+1);
for i=1:width+1
    for j=1:width+1
        if ((width/2 - i)^2 + (width/2 - j)^2) < (innerWidth/2)^2 || ...
                ((width/2 - i)^2 + (width/2 - j)^2) > (width/2)^2
            annulusMatrix(i,j) = 0;
        end
    end
end

stimulusMatrix = stimulusMatrix .* annulusMatrix;

gaborPatch = gray + absoluteDifferenceBetweenWhiteAndGray * stimulusMatrix;
%gaborPatch(width/2, width/2) = 255;

time2 = GetSecs;

time_taken = time2-time1;