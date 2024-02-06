function [threshImageFull, threshVal] = imthresh(image)

%Set inital guess threshold with Otsu method
threshVal = graythresh(image);

%SHOW ORIGINAL AND THRESHOLDED IMAGES
threshImage = im2bw(image,threshVal);
threshWord = strcat('Threshold = ', num2str(threshVal));
FigHandle = figure('Position', [100, 100, 1600, 800]);
subplot(1,2,1), imshow(image);
subplot(1,2,2), imshow(threshImage), text(-10,-10,threshWord);

%MANUALLY ADJUST THRESHOLD VALUE
button = 1;
while isempty(button) ~= 1
       
     [x,y,button] = ginput(1);

    % arrow keys to adjust threshold value
    if button == 30 % up arrow
        threshVal = threshVal + .04;
        if threshVal > 1
            threshVal = .99;
        end
    end
    if button == 31 % down arrow
        threshVal = threshVal - .04;
        if threshVal <= 0
            threshVal = 0.01;
        end
    end
    if button == 28 % left arrow
        threshVal = threshVal - .005;
        if threshVal <= 0
            threshVal = 0.01;
        end
    end
    if button == 29 % right arrow
        threshVal = threshVal + .005;
         if threshVal > 1
            threshVal = .99;
        end
    end
    threshVal;
    button;
    threshImage = im2bw(image,threshVal);
    threshImageFull = imfill(threshImage,'holes');
    threshWord = strcat('Threshold = ', num2str(threshVal));
    imshow(threshImageFull);
    text(-10, -10, threshWord);
end

close
