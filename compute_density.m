% Function to compte stats from an image 

function [CCjoin, DABbw, density] = compute_density(I)

% alternative set of standard values (HDAB from Fiji)
He = [ 0.6500286;  0.704031;    0.2860126 ];
DAB = [ 0.26814753;  0.57031375;  0.77642715];
Res = [ 0.7110272;   0.42318153; 0.5615672 ]; % residual

% combine stain vectors to deconvolution matrix
HDABtoRGB = [He/norm(He) DAB/norm(DAB) Res/norm(Res)]';
RGBtoHDAB = inv(HDABtoRGB);
    
% separate stains = perform color deconvolution
imageHDAB = SeparateStains(I,RGBtoHDAB);

% threshold
DABcolor = imcomplement(imageHDAB(:,:,2));

%%%% residuals (ojo aqui, descomentar)
[x3,y3]=meshgrid(1:size(DABcolor,1), 1:size(DABcolor,2));
y=y3(:,1);
x=x3(1,:);

[xout,yout,zout]=prepareSurfaceData(x,y,DABcolor);
[sf,gof,output] = fit([xout, yout],zout,'poly23');
%plot(sf,[xout,yout],zout)

I3norm = vec2mat(output.residuals,size(DABcolor,1));
I3norm=rot90(I3norm);
Inorm=flipud(I3norm);
%%%%% fi residuals

Ibw = imbinarize(Inorm, graythresh(Inorm));

% CMYK binary transformation
K = 255 - max(max(max(I)));
C = 255*(1-I(:,:,1)/(255-K));
M = 255*(1-I(:,:,2)/(255-K));
Y = 255*(1-I(:,:,3)/(255-K)); %Interest binarized channel (it will be used as a mask)
marker = logical(Y).*Ibw;
marker = imerode(marker, strel('disk',3));

DABcolor_dens = imreconstruct(marker, Inorm);
DABbw = imbinarize(DABcolor_dens, graythresh(DABcolor_dens)); 

% imshow(DABbw)

CCjoin = bwconncomp(DABbw);

% stats
TotalArea = sum(sum(DABbw));
[m,n,p] = size(I);
SizeImg = m*n;
density = TotalArea/SizeImg;

% figure; subplot(1,3,1); imshow(I)
% subplot(1,3,2); imshow(DABcolor2_inv)
% subplot(1,3,3); imshow(join)
