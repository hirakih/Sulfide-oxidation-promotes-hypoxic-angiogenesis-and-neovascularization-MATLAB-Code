totalNumImgs = input('How many images in this condition?__');

% set hard coded variable numbers
minNucVol = 20;
maxNucVol = 2000;
firstSlice = 1;
lastSlice = 71;
nucClusterSens = 26; % 6 is minimum 3D connectivity

% get filename info
[nucFilename, pathname, filterIndex] = uigetfile('*.*', 'Open NUCLEAR Image');
cd(pathname)
if filterIndex == 0
    return
else
    charIndex = 0;
    filePrefix = [];
    curChar = '0';
    while curChar ~= '-'
        charIndex = charIndex + 1;
        curChar = nucFilename(charIndex);
        filePrefix = strcat(filePrefix,curChar);
    end
    fileIndex = str2num(nucFilename(length(filePrefix)+1:length(filePrefix)+2));
end

% determine filename for nuclei based off of actin file prefix
nucSuffix = '_DAPI.tif';

% set up nuclei count output matrix
nucOutput = zeros(totalNumImgs,1);

% start for loop for number of images to quantify number of nuclei/image
for i = 1:totalNumImgs
    % create image filenames
    if length(num2str(fileIndex)) == 1
        nucFilename = strcat(filePrefix,'0',num2str(fileIndex),nucSuffix);
    else
        nucFilename = strcat(filePrefix,num2str(fileIndex),nucSuffix);
    end
    
    % read in all slices of tiff image into 3D matrices
    zCount = 1;
    for k = firstSlice:lastSlice
        nucStackOrig(:,:,zCount) = im2double(imread(nucFilename,zCount));
        zCount = zCount + 1;
    end
    
    % manually threshold the first, middle, and last z slice of nuclei image
    [threshNucFirst,nucThreshValFirst] = imthreshfill(nucStackOrig(:,:,firstSlice));
    [threshNucMiddle,nucThreshValMiddle] = imthreshfill(nucStackOrig(:,:,(lastSlice-firstSlice)/2));
    [threshNucLast,nucThreshValLast] = imthreshfill(nucStackOrig(:,:,lastSlice));
    
    % linearly interpolate thresh values for both channels and apply to stacks
    % to binarize image stacks
    nucThreshVals = [linspace(nucThreshValFirst,nucThreshValMiddle,(lastSlice-firstSlice)/2-firstSlice), nucThreshValMiddle, linspace(nucThreshValMiddle,nucThreshValLast,lastSlice-(lastSlice-firstSlice)/2)];
    
    nucStackThresh = zeros(size(nucStackOrig));
    for k = 1:lastSlice
        nucStackThresh(:,:,k) = imbinarize(nucStackOrig(:,:,k),nucThreshVals(k));
    end
    
    % filter background from actin and nuclei image based on volume
    disp('Filtering structures by volume')
    filtNucMask = zeros(size(nucStackOrig));
    [nucLabel,numNuc] = bwlabeln(nucStackThresh,nucClusterSens);
    nucStats = regionprops3(nucLabel,'Volume','VoxelIdxList');
    for k = 1:numNuc
        if nucStats(k,1).Volume > minNucVol && nucStats(k,1).Volume < maxNucVol
            filtNucMask(cell2mat(nucStats(k,:).VoxelIdxList)) = 1;
        end
    end
    
    % display max proj image and draw rectangle ROI to delineate endothelium edge
    figure(1);
    imagesc(max(filtNucMask,[],3));
    h = drawrectangle;
    pause;
    mask = createMask(h);
    close(1)
    maskInv = ~mask;
    
    % extend mask to 3D and apply to both thresholded stacks
    cropMask = zeros(size(nucStackOrig));
    for k=1:lastSlice
        cropMask(:,:,k) = maskInv;
    end
    finalNucMask = cropMask.*filtNucMask;
    
    % find all nuclei centroid voxels in size filtered image
    [nucLabel,numNuc] = bwlabeln(finalNucMask,nucClusterSens);

    % add number of nuclei to output matrix
    nucOutput(i) = numNuc;
end

disp(nucOutput)
