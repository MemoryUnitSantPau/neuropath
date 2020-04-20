% Script to extract small crops from a large image

% Start with a folder and get a list of all subfolders.
% Finds and prints names of all PNG, JPG, and TIF images in 
% that folder and all of its subfolders.
clc;    % Clear the command window.
workspace;  % Make sure the workspace panel is showing.
format longg;
format compact;

% Define a starting folder.
start_path = fullfile('E:\Marta\Projecte YKL40\GFAP_hipocamp');
% Ask user to confirm or change.
topLevelFolder = uigetdir(start_path);
if topLevelFolder == 0
	return;
end
% Get list of all subfolders.
allSubFolders = genpath(topLevelFolder);
% Parse into a cell array.
remain = allSubFolders;
listOfFolderNames = {};
while true
	[singleSubFolder, remain] = strtok(remain, ';');
	if isempty(singleSubFolder)
		break;
	end
	listOfFolderNames = [listOfFolderNames singleSubFolder];
end
numberOfFolders = length(listOfFolderNames);

loop=1;
saveoutput = strcat(topLevelFolder,'\Crops');


% Process all image files in those folders.
for k = 1 : numberOfFolders
    % Netejar variables
    clearvars bw I Icrop mask mask2 ROI
    
	% Get this folder and print it out.
	thisFolder = listOfFolderNames{k};
	fprintf('Processing folder %s\n', thisFolder);
	
	% Get PNG files.
	filePattern = sprintf('%s/*.png', thisFolder);
	baseFileNames = dir(filePattern);
	% Add on TIF files.
	filePattern = sprintf('%s/*.tif', thisFolder);
	baseFileNames = [baseFileNames; dir(filePattern)];
	% Add on JPG files.
	filePattern = sprintf('%s/*.jpg', thisFolder);
	baseFileNames = [baseFileNames; dir(filePattern)];
	numberOfImageFiles = length(baseFileNames);
        
    %Change parameters 'a tu gusto' --> CB many small size crops; Hip less number of crops and bigger  
    if(strfind(thisFolder, 'Cb'))
        numberloops = 20;
        sizerate = 1250;
    elseif(strfind(thisFolder, 'Hip'))
        numberloops = 12;
        sizerate = 2500;
    else
        numberloops = 6;
        sizerate = 5000;
    end
        
    for jj=1:numberOfImageFiles
	% Read image
        fprintf('Reading image %s...',baseFileNames(jj).name)
        I = imread(strcat(thisFolder,'/',baseFileNames(jj).name));
        directory = baseFileNames(jj).name(1:end-3);
	% Make dir with the basename of the image
	disp('Creating directories...')
        mkdir(saveoutput,strcat('\',directory));
        
        seq(jj).name = baseFileNames(jj).name;
	% binarize image to fit square ROIs only in the interest region (where there is info)
        bw = im2bw(I,0.999);
        mask = imcomplement(bw);
        mask = imfill(mask,'holes');

        [m,n] = size(bw);
        mask2 = true(size(mask));

	% iterative process to fit the squares into the main image to extract ROI
        disp('Fitting square to image...')
        fprintf('\nSizeRate = %i\n', sizerate);
        for i=1:numberloops 
            minim=0;
            j=1;

            while and(minim==0,j<500)
                x = randi(n-sizerate,1,1);
                y = randi(m-sizerate,1,1);

                rect{i} = [x y sizerate sizerate];

                Icrop = imcrop(mask,rect{i});
                minim = min(min(Icrop));
                j=j+1;    
            end

            fprintf(num2str(j));
            fprintf('\n');

            if j==500
              i=i-1;
              break
            end

            mask2(y:y+sizerate,x:x+sizerate) = false;
            mask = mask.*mask2;
            pause(0.01)
        end

	% Save ROIs in the created directory
        disp('Saving ROIs...')
        for k=1:i
            ROI = imcrop(I,rect{k});
            outputFileName = strcat(saveoutput,'\',directory,'\',directory,'ROI',num2str(k),'.tif');
            imwrite(ROI,outputFileName);
        end

    end
 
end
fprintf('Crops done!');
      fprintf('\n');

           
