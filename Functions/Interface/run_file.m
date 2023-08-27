function xl = run_file(hObject,eventdata, handles,filePath,savePath)
%function xl = run_directory(handles,dirPath,savePath)

% Compile image, run the full processing/analysis stack
% specified by the current GUI parameters, save results to csv and save
% visualizations to folder with image file's name

%hwaitfile = waitbar(0,'Running File...');
[FolderPath0,fileName_wo_ext,fileExt] = fileparts(filePath);
fileName = [fileName_wo_ext,fileExt];
set(handles.fileNameBox,'String',fileName);

imdir = CompileImg(filePath);
numIms = 1;

% Initialize the Cell for the csv file
xl = cell(numIms+1,7);
xl{1,1} = 'Image Name';
xl{1,2} = 'Sfull fit';
xl{1,3} = 'Correlation Length (nm)';
xl{1,4} = 'Average Orientation (degrees)';
xl{1,5} = 'Fiber Length Density (1/um)';
xl{1,6} = 'Mean Fiber Length (nm)';
xl{1,7} = 'Mean Fiber Width (nm)';


for i = 1:numIms
    
%    waitbar(i/numIms,hwaitfile,['Processing ', imdir(i).name]);
    
    imfilei = filePath;
%     addpath(genpath(pwd));
    
    % Initialize image data structure
    ims = initImgData(imfilei);
    ims.settings = get_settings(handles);
    ims = pix_settings(ims);
    
    if ims.settings.figSave
        mkdir(ims.imNamePath);  % make the directory to save the results figures
    end
    
    % Run the filter bank at the current settings
    handles.ims=ims;
    handles = main_filter(handles);
    ims=handles.ims;
    
    % Stitch fiber segments and calculate length
    ims = StitchFibers2(ims);
    handles.ims = ims;
    [FolderPath0,fileName_wo_ext,fileExt] = fileparts(filePath);
    fileName = [fileName_wo_ext,fileExt];

    % Write data to csv cell
    xl{i+1,1} = fileName;
    xl{i+1,2} = ims.op2d.Sfull;
    xl{i+1,3} = ims.op2d.decayLen;
    xl{i+1,4} = ims.ODist.director;
    xl{i+1,5} = ims.fibLengthDensity;
    xl{i+1,6} = mean(ims.FLD);
    xl{i+1,7} = mean(ims.FWD);
    
    % Save figures if specified
    if ims.settings.figSave
        ODist_plot(ims,1);
        plotS2D(ims,1);
        handles = FiberVecPlot_stitch(handles,1);
        FLD_hist(ims,1);
        FWD_hist(ims,1);
    end
    
end

cell2csv(savePath, xl, ',', 1999, '.');

%Export_Callback(hObject, eventdata, handles); % call Export_Callback function from menu
[outputFolderName,name0, ext0] = fileparts(handles.ims.imPath);
disp(['exporting length and width in ', outputFolderName]);
fileNameLength = fullfile(outputFolderName,strcat(handles.ims.imName,'_FLD.txt'));
fileNameWidth = fullfile(outputFolderName,strcat(handles.ims.imName,'_FWD.txt'));
writematrix(handles.ims.FLD, fileNameLength);
disp(['list of length was saved in', fileNameLength]);
writematrix(transpose(handles.ims.FWD), fileNameWidth);
disp(['list of width was saved in', fileNameWidth]);

disp("Export finished for the single image results.");

end

function out = CompileImg(filePath)
disp(filePath);

[FolderPath,fileName_wo_ext,fileExt] = fileparts(filePath);
CurIms = [fileName_wo_ext,fileExt];

out = fullfile(FolderPath,fileName_wo_ext);

end
