clear;clc;close all;
translation_step = 0.05;
translation = -5:translation_step:5;
start_percentage = 20/100;
finish_percentage = 80/100;
write_images = 0;

[data,file_names,path] = load_image_inside();
if~isempty(data)
    for i = 1:length(data)-1
        x_shift(i) = find_shift(sum(data{i}.xz),sum(data{i+1}.xz),translation,translation_step,start_percentage,finish_percentage);
        y_shift(i) = find_shift(sum(data{i}.yz),sum(data{i+1}.yz),translation,translation_step,start_percentage,finish_percentage);
    end
    shift = [x_shift' y_shift'];
    if write_images
        shift_images(path,file_names,shift)
    end
end

function shift_images(path,file_names,shift)
for i = 1:length(file_names)
    info = imfinfo(fullfile(path,file_names{i}));
    N = numel(info);
    f = waitbar(0,'Loading Images');
    for k = 1:N
        image_to_load{k} = imread(fullfile(path,file_names{i}),k);
        waitbar(k/N,f,['Loading Images...',num2str(i),'/',num2str(length(file_names))])
    end
    close(f)
    
    if i>=2
        val = shift(1:i-1,:);
        if size(val,1)>1
            val = cumsum(val);
            val = val(end,:);
        end
        f = waitbar(0,'Saving Drift Corrected Images');
        for j = 1:length(image_to_load)
            imwrite(imtranslate(image_to_load{j},-val),[path,'\',file_names{i}(1:end-4),'_drift_corrected.tif'], 'Compression', 'none','WriteMode', "append");
            waitbar(j/length(image_to_load),f,['Saving Drift Corrected Images...',num2str(i),'/',num2str(length(file_names))])
        end
        close(f)
    else
        f = waitbar(0,'Saving Drift Corrected Images');
        for j = 1:length(image_to_load)
            imwrite(image_to_load{j},[path,'\',file_names{i}(1:end-4),'_drift_corrected.tif'], 'Compression', 'none','WriteMode', "append");
            waitbar(j/length(image_to_load),f,['Saving Drift Corrected Images...',num2str(i),'/',num2str(length(file_names))])
        end
        close(f)
    end
    clear image_to_load
end
end

function [data,file_names,path] = load_image_inside()
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
                data{k}.xy = project_image(image_to_load);
                data{k}.xz = project_image_xz(image_to_load);
                data{k}.yz = project_image_yz(image_to_load);
                data{k}.name = file_names{k}; 
                clear image_to_load
            catch
                data{k} = [];
                close(f)
            end
        end
    else
        data = [];
    end
end
if ~isempty(data)
    data = data(~cellfun('isempty',data));
end
end

function shift = find_shift(x,y,translation,translation_step,start_percentage,finish_percentage)
x = interp1(1:length(x),x,linspace(1,length(x),length(x)/translation_step));
y = interp1(1:length(y),y,linspace(1,length(y),length(y)/translation_step));
translation = round(translation/translation_step);

start = ceil(length(x)*start_percentage);
finish = floor(length(x)*finish_percentage);

x_plot = x(start:finish);
x_plot = smooth(x_plot);

wanted = zeros(length(translation),1);

% v = VideoWriter('peaks.avi');
% open(v);
% f = figure();
% hold on
for i = 1:length(translation) 
    start_y = start+translation(i);
    finish_y = finish+translation(i);    
    if start_y<1
        start_y = 1;
    end
    if finish_y>length(y)
        finish_y = length(y);
    end    
    
    y_plot = y(start_y:finish_y);    
    y_plot = smooth(y_plot);   
    
    wanted(i) = sum(abs(x_plot-y_plot)); 
    
%     ax = gca;cla(ax);
%     plot(x_plot,'r')
%     plot(y_plot,'b')
%     drawnow
%     frame = getframe(gcf);
%     writeVideo(v,frame);
end
% close(f)
% close(v)
[~,idx] = min(wanted);
shift = translation(idx);
figure()
hold on
plot(x_plot)
start_y = start+shift;
finish_y = finish+shift; 
y_plot = y(start_y:finish_y);
plot(y_plot)

translation = translation*translation_step;
shift = translation(idx);
end