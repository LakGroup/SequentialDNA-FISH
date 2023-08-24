function crop_images()
[file_names,path] = uigetfile({'*.tif;*.tiff;*.mat'},'Select SMLM Image','MultiSelect','on');
if ~isequal(file_names,0)    
    file_names = cellstr(file_names);
    info = imfinfo(fullfile(path,file_names{1}));
    N = numel(info);
    load_images = inputdlg({'Load Images:','Crop X:','Crop Y:'},'Input',[1 35],{['1:2:',num2str(N)],['1:',num2str(info(1).Width)],['1:',num2str(info(1).Height)]});
    if ~isempty(load_images)
        to_load = eval(load_images{1});
        to_crop_x = eval(load_images{2});
        to_crop_y = eval(load_images{3});
        for k = 1:length(file_names)
            try
                image_to_load = cell(length(to_load),1);
                f = waitbar(0,'loading images');
                for i = 1:length(to_load)
                    image_to_load{i} = double(imread(fullfile(path,file_names{k}),to_load(i)));
                    image_to_load{i} = image_to_load{i}(to_crop_y,to_crop_x);
                    image_to_load{i} = image_to_load{i}-min(image_to_load{i}(:));
                    image_to_load{i} = image_to_load{i}/max(image_to_load{i}(:));
                    waitbar(i/length(to_load),f,['Loading Images...',num2str(k),'/',num2str(length(file_names))])
                end
                close(f)
                
                f = waitbar(0,'saving images');
                for i = 1:length(image_to_load)
                    imwrite(image_to_load{i},[path,'\',file_names{k}(1:end-4),'_cropped.tif'], 'Compression', 'none','WriteMode', "append");
                    waitbar(i/length(image_to_load),f,['Saving Images...',num2str(k),'/',num2str(length(file_names))])
                end
                close(f) 
                clear image_to_load
            catch
                close(f)
            end
        end
    end
end
end