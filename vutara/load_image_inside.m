function data = load_image_inside()
[file_names,path] = uigetfile({'*.tif;*.tiff;*.mat'},'Select SMLM Image','MultiSelect','on');
if isequal(file_names,0)
    data = [];
else
    file_names = cellstr(file_names);
    info = imfinfo(fullfile(path,file_names{1}));
    N = numel(info); 
    load_images = inputdlg({'Load Images:','Crop X:','Crop Y:'},'Input',[1 35],{['1:2:',num2str(N)],['1:',num2str(info(1).Width)],['1:',num2str(info(1).Height)]});
    if ~isempty(load_images)
        to_load = eval(load_images{1});
        to_crop_x = load_images{2};
        to_crop_y = load_images{3};
        
        to_crop_y = strsplit(to_crop_y,':');
        to_crop_x = strsplit(to_crop_x,':');
        
        f = waitbar(0,'Loading Images....');
        for k = 1:length(file_names)   
            try
                image_to_load = cell(length(to_load),1);                
                for i = 1:length(to_load)
                    image_to_load{i} =  double(imread(fullfile(path,file_names{k}),to_load(i),'PixelRegion',{[str2double(to_crop_y{1}) str2double(to_crop_y{2})],[str2double(to_crop_x{1}) str2double(to_crop_x{2})]}));
                    image_to_load{i} = image_to_load{i}-min(image_to_load{i}(:));
                    image_to_load{i} = image_to_load{i}/max(image_to_load{i}(:));
                end
                data{k}.image = image_to_load;
                data{k}.name = file_names{k};
                data{k}.projected_image = project_image(data{k}.image);  
                data{k}.projected_image_xz = project_image_xz(data{k}.image); 
                data{k}.projected_image_yz = project_image_yz(data{k}.image); 
                clear image_to_load
                waitbar(k/length(file_names),f,['Loading Images....',num2str(k),'/',num2str(length(file_names))])
            catch
                data{k} = [];                
            end
        end
        close(f)
    else
        data = [];
    end
end
if ~isempty(data)
    data = data(~cellfun('isempty',data));
end
end