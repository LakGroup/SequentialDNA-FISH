clear;clc;close all
data_to_load = 2:2:130;
to_crop_x = [1 2048];
to_crop_y = [1 2048];
sigma = 2;
alpha = 0.001;
%finding trakcs for detection z-location
search_radius = 5;
track_length = 5;
gaps = 0;

%finding z-spot (minimum intensity)
min_intensity = 0.1;
%--------------------------------------
addpath([pwd,'/PointSourceDetection'])  
addpath([pwd,'/PointSourceDetection/mex']) 
[file_names,path] = uigetfile({'*.tif;*.tiff;*.mat'},'Select SMLM Image','MultiSelect','on');
if isequal(file_names,0)
    data = [];
else
    file_names = cellstr(file_names);    
    for k = 1:length(file_names)
        disp([num2str(k),'/',num2str(length(file_names))])
        try     
            f = waitbar(0,'Loading Images...');
            for i = 1:length(data_to_load)
                images{i} =  double(imread(fullfile(path,file_names{k}),data_to_load(i),'PixelRegion',{[to_crop_y(1) to_crop_y(2)],[to_crop_x(1) to_crop_x(2)]}));
                images{i} = images{i}-min(images{i}(:));
                images{i} = images{i}/max(images{i}(:));
                waitbar(i/length(data_to_load),f,['Loading Images...',num2str(i),'/',num2str(length(data_to_load))])
            end     
            close(f)
        catch
            images = [];
            break
        end        
        
        if ~isempty(images)
            f = waitbar(0,'Detecting Spots in XY');
            for i = 1:length(images)
                [x_spot,y_spot,mask,A_est,c_est] = find_localizations(images{i},sigma,alpha);
                if ~isempty(x_spot)
                    pstruct{i} = fit_gaussian(images{i},x_spot,y_spot,mask,alpha,A_est,sigma,c_est);
                else
                    pstruct{i} = [];
                end
                clear x_spot y_spot mask A_est c_est
                waitbar(i/length(images),f,['Detecting Spots in XY.....',num2str(i),'/',num2str(length(images))])
            end
            close(f)
        end
        
        tracks = find_tracks(pstruct,images,search_radius,track_length,gaps,file_names{k},0);
        wanted = find_z(tracks,min_intensity);
        
        projected_image_xy = project_image(images);        
        
        data_to_save{k}.xyz = wanted;
        data_to_save{k}.image_xy = projected_image_xy;
        data_to_save{k}.name = file_names{k};
    end
    clearvars -except data_to_save
    [file,path] = uiputfile('*.mat');
    if file
        save(fullfile(path,file),'data_to_save')
    end
    clear;clc;
end