% Script to extract density stats from a iba1 microscopy image

% Start with a folder and get a list of all subfolders.
% Finds and prints names of all PNG, JPG, and TIF images in 
% that folder and all of its subfolders.
clc;   
workspace;
format longg;
format compact;

% Define a starting folder.
start_path = 'C:\Users\Usuario\Desktop';
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
numberOfFolders = length(listOfFolderNames)

loop=1;

% Process all image files in those folders.
for k = 1 : numberOfFolders
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
	% Now we have a list of all files in this folder.
	
	if and(numberOfImageFiles >= 1,isempty(strfind(thisFolder,'thresholded')))
        
        for f = 1 : numberOfImageFiles
            parts = strsplit(thisFolder, '\');
            ROI = parts{end};
 			fullFileName = fullfile(thisFolder, baseFileNames(f).name);
			fprintf('\n     Deleting densities and objects %s\n', fullFileName);
            
            %%%%% DELETE num_objects & files (if there is any)
            if or(~isempty(strfind(baseFileNames(f).name,'num_objects')),~isempty(strfind(baseFileNames(f).name,'density')))
                fullFileName = fullfile(thisFolder, baseFileNames(f).name);
                delete(fullFileName)
            end
        end
    end
    
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
	
	if and(numberOfImageFiles >= 1,isempty(strfind(thisFolder,'thresholded')))
             
        h=waitbar(0,'Processing images...');
	% Go through all those image files and compute the analysis.
	for f = 1 : numberOfImageFiles
        	parts = strsplit(thisFolder, '\');
        	ROI = parts{end};
        	waitbar(f/numberOfImageFiles,h,sprintf('Processing images of %s (%d/%d)...',ROI,f,numberOfImageFiles))
		fullFileName = fullfile(thisFolder, baseFileNames(f).name);
		fprintf('\n     Processing image file %s\n', fullFileName);
		
		% Read the image
        	S(loop).images(f).I = imread(fullFileName);
		% Compute analysis and extract the binarized, number of objects and density 
        	[S(loop).images(f).CCjoin, S(loop).images(f).BW, S(loop).images(f).density] = compute_density(S(loop).images(f).I);
        	S(loop).images(f).name = fullFileName;
		% Save the binarized density image
        	imwrite(S(loop).images(f).BW,strcat(thisFolder,'\density_',baseFileNames(f).name))
        end
        delete(h)
        loop=loop+1;
	else
		fprintf('     Folder %s has no image files in it.\n', thisFolder);
	end
end

images = S(1).images;
for i=2:length(S)
    images = [images,S(i).images];
end
    
% export to an excel file    
excel_export(images,length(images),topLevelFolder)
           
