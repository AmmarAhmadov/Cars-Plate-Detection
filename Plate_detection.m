close all;
clear all;
% First we read the image from file: Number Plate Images using imread
% function
im = imread('Number Plate Images/S1.jpg');
figure;
imshow(im); % Here we show the original image using imshow function
title('Original image','color','r');
% Here we transform it to gray scale using rgb2gray function
imgray = rgb2gray(im);
figure();
imshow(imgray);
title('image in gray scale');
% Then to black and white using im2bw function
imbin = im2bw(imgray);
% Then we detect image edges using prewitt filter
im = edge(imgray, 'prewitt');
figure;
imshow(im); % showing image edges of binary image
title('Edge detection','color','red');
% filling image holes
figure;
im2 = imfill(im,'holes');
imshow(im2);
title('filling holes','color','r');
% remove connected regions lower than 8 pixels
se = strel('disk',8); 
% eroding the image using imerode function in order to keep plate region
% only
erodeim2 = imerode(im2,se);
figure();
imshow(erodeim2);
title('image after eroding','color','r');
% Now we want to show the car's plate with its numbers
figure();
plate_numbers = erodeim2.*im;
imshow(erodeim2.*im);
title('showing plate numbers','color','r');
%Below steps are to find location of number plate
%First we detect the regions in the image of car's palte
Iprops=regionprops(plate_numbers,'BoundingBox','Area', 'Image');
%area = Iprops.Area;
%count = numel(Iprops);
%maxa= area;
boundingBox = Iprops.BoundingBox; 
im_corped = imcrop(imbin, boundingBox);%crop the number plate area
figure;
imshow(im_corped);
title('corping plate form the binarized image','color','r');
[h, w] = size(im_corped); 
im_corped_remove = bwareaopen(~im_corped, 150); %remove some object if it width is too long or too small than 500
%im_corped_remove = im_corped;
[h, w] = size(im_corped_remove);
if(mod(h,2) == 0)
h1 = int64(h/2);
h2 = int64(h/2);
else
h1 = int64(h/2) - 1;
h2 = int64(h/2);    
end
C = mat2cell(im_corped_remove,[ h1 , h2],[w]);
Iprops=regionprops(C{2,1},'BoundingBox','Area', 'Image'); %read letter
figure;
imshow(C{2,1});
title('removing small regions from corped image','color','r');
[h, w] = size(C{2,1});
count = numel(Iprops);
Platenumber=[]; % Initializing the variable of number plate string.
if(count>8)
    count = 8;
end
for i=1:count
   ow = length(Iprops(i).Image(1,:));
   oh = length(Iprops(i).Image(:,1));
   if (ow<(h/2) & ow>(h/10)) 
       figure(i);
       imshow(Iprops(i).Image);
       letter=Letter_detection(Iprops(i).Image); % Reading the letter corresponding the binary image 'N'.
       if((letter == 'O' ||letter =='D')  && (i==2 || i==3 || i==4))
           letter = '0';
       end
       if(letter == 'O'  && (i==7 || i==5 || i==6))
               letter = 'D';
        end
       if(letter == 'U' && (i==2 || i==3 || i==4))
           letter = '0';
       end
       if(letter == 'B' && (i==2 || i==3 || i==4))
           letter = '5';
       end
         if(letter == '0' && i>4)
           letter = '';
         end
       Platenumber=[Platenumber letter] % Appending every subsequent character in noPlate variable.
   end
end