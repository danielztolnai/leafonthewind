clc; clear all; %#ok<CLSCR>

%% Parameters
displayResult  = 0;
bankSizeBits   = 4;
numberOfImages = 4;
defaultValue   = [0 0 0];
fileType       = '.png';
bankName       = '../bitmap.txt';

%% Calculate further parameters
bankSize       = 2 ^ bankSizeBits;
numberOfPixels = 16*16*bankSize;

%% Process images
bitmapFile = fopen(bankName,'w');
currentPixel = 1;

for n = 1:1:numberOfImages
   fileName = strcat( sprintf('%02d',n), fileType );
   img = imread(fileName); 
   
   imgSixBits  = uint8(floor(double(img) / 64));
   
   height = size(imgSixBits,1);
   width  = size(imgSixBits,2);
   
   for v = 1:1:height
      for h = 1:1:width
         r = imgSixBits(v,h,1) * 16;
         g = imgSixBits(v,h,2) *  4;
         b = imgSixBits(v,h,3) *  1;
         pixel = r + g + b;
         fprintf(            [dec2hex(pixel, 2), ' '] );
         fprintf(bitmapFile, [dec2hex(pixel, 2), '\n'] );
         currentPixel = currentPixel + 1;
      end
      fprintf('\n');
   end
   fprintf('\n');
   
   % Show converted image
   if(displayResult)
      imgRestored = imgSixBits * 85;
      figure(n)
      subplot(2,1,1);
      imshow(img);
      title('Original');
      subplot(2,1,2);
      imshow(imgRestored);
      title('Preview');
   end
end

%% Fill remaining pixels
for i = currentPixel:1:numberOfPixels
   r = defaultValue(1) * 16;
   g = defaultValue(2) *  4;
   b = defaultValue(3) *  1;
   pixel = r + g + b;
   fprintf(bitmapFile, [dec2hex(pixel, 2), '\n'] );
end

fclose(bitmapFile);
