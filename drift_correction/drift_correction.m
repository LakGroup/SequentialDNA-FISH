function drift_correction()
addpath([pwd,'/PointSourceDetection'])  
addpath([pwd,'/PointSourceDetection/mex'])  
figure()
set(gcf,'name','Drift Correction','NumberTitle','off','color','w','units','normalized','position',[0.2 0.15 0.6 0.7],'menubar','none','toolbar','none')

uicontrol('style','pushbutton','units','normalized','position',[0,0.95,0.1,0.05],'string','Load Image(s)','ForegroundColor','b','Callback',{@load_image_callback},'FontSize',12);

psf_sigma = uicontrol('style','edit','units','normalized','position',[0.1,0.95,0.1,0.05],'string','Sigma (2)','ForegroundColor','b','Callback',{@psf_sigma_callback},'FontSize',12);

alpha_edit = uicontrol('style','edit','units','normalized','position',[0.2,0.95,0.1,0.05],'string','Alpha (0.0001)','ForegroundColor','b','Callback',{@alpha_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0.3,0.95,0.1,0.05],'string','Detect Spots','ForegroundColor','b','Callback',{@localization_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0.4,0.95,0.2,0.05],'string','Select Spot for Drift Correction','ForegroundColor','b','Callback',{@select_spot_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0.6,0.95,0.1,0.05],'string','Shift Values','ForegroundColor','b','Callback',{@shift_values_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0.7,0.95,0.1,0.05],'string','Check Shift','ForegroundColor','b','Callback',{@check_shift_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0.8,0.95,0.1,0.05],'string','Shift Images','ForegroundColor','b','Callback',{@shift_images_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0,0,0.3,0.05],'string','Select All Spots for Drift Correction','ForegroundColor','b','Callback',{@select_all_spots_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0.3,0,0.2,0.05],'string','All Spots Shift Values','ForegroundColor','b','Callback',{@all_spots_shift_values_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0.5,0,0.2,0.05],'string','All Spots Check Shift','ForegroundColor','b','Callback',{@all_spots_check_shift_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0.7,0,0.3,0.05],'string','All Spots Shift Images','ForegroundColor','b','Callback',{@all_spots_shift_images_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0,0.05,0.1,0.05],'string','save video','Callback',{@save_video_callback});

image_slider_value = 1;
image_slider = uicontrol('style','slider','units','normalized','position',[0.97,0.05,0.03,0.95],'value',image_slider_value,'min',1,'max',2,'sliderstep',[0 0],'Callback',@image_slider_callback);

data = [];
spot_data = [];
sigma = 2;
alpha = 0.0001;
total_shift = [];

    function load_image_callback(~,~,~)
        data = load_image_inside();
        if ~isempty(data)
            spot_data = [];
            total_shift = [];
            if length(data)>1
                image_slider.Max = length(data);
                image_slider.Min = 1;
                image_slider.Value = 1;
                image_slider.SliderStep = [1/(length(data)-1) 1/(length(data)-1)];
            else
                image_slider.Max = 2;
                image_slider.Min = 1;
                image_slider.Value = 1;
                image_slider.SliderStep = [0 0];
            end
            plot_image()
        end
    end

    function psf_sigma_callback(~,~,~)
        sigma = str2double(psf_sigma.String);
    end

    function alpha_callback(~,~,~)
        alpha = str2double(alpha_edit.String);
    end

    function localization_callback(~,~,~)
        if ~isempty(data)
            f = waitbar(0,'Detecting Spots...');
            for i = 1:length(data)
                if isfield(data{i},'xy')
                    [x_spot,y_spot,mask,A_est,c_est] = find_localizations(data{i}.xy,sigma,alpha);
                    if ~isempty(x_spot)
                        data{i}.pstruct = fit_gaussian(data{i}.xy,x_spot,y_spot,mask,alpha,A_est,sigma,c_est);
                    else
                        data{i}.pstruct = [];
                    end
                    clear x_spot y_spot mask A_est c_est
                    waitbar(i/length(data),f,['Detecting Spots.....',num2str(i),'/',num2str(length(data))])
                else
                    data{i}.pstruct = [];
                end
            end
            close(f)
        end
        plot_image()
    end

    function plot_image()        
        if ~isempty(data)
            if isfield(data{image_slider_value},'xy')
                image = data{image_slider_value}.xy;
                ax = gca; cla(ax);
                imagesc(image)                
                colormap(gray)
                axis off                
                pbaspect([1 1 1])     
                xlim([1 size(image,2)])
                ylim([1 size(image,1)])
            end
            
            if isfield(data{image_slider_value},'pstruct')
                hold on
                scatter_data = data{image_slider_value}.pstruct;
                if ~isempty(scatter_data)
                    scatter(scatter_data.x,scatter_data.y,10,'r','filled')
                    title({'',['Number of Spots = ',num2str(length(scatter_data.x))]})
                end
            end
            
            if ~isempty(spot_data)
                hold on 
                scatter(spot_data(image_slider_value,1),spot_data(image_slider_value,2),10,'b','filled')
                text(spot_data(image_slider_value,1),spot_data(image_slider_value,2),['[',num2str(spot_data(image_slider_value,1)),',',num2str(spot_data(image_slider_value,2)),']'],'color','w')
            end
        end
    end

    function image_slider_callback(~,~,~)
        image_slider_value = round(image_slider.Value);
        plot_image();
    end

    function select_spot_callback(~,~,~)
        spot_data = [];
        try
            coordinates = getrect();
            for i = 1:length(data)
                if isfield(data{i},'pstruct')
                    locs(:,1) = data{i}.pstruct.x;
                    locs(:,2) = data{i}.pstruct.y;
                    poly_shape = polyshape([coordinates(1) coordinates(1)+coordinates(3) coordinates(1)+coordinates(3) coordinates(1)],[coordinates(2) coordinates(2) coordinates(2)+coordinates(4) coordinates(2)+coordinates(4)]);
                    poly_center = [mean(poly_shape.Vertices(:,1)) mean(poly_shape.Vertices(:,2))];
                    idx = find(inpolygon(locs(:,1),locs(:,2),poly_shape.Vertices(:,1),poly_shape.Vertices(:,2)));
                    distances = pdist2(locs(idx,:),poly_center);
                    [~,min_d_idx] = min(distances);
                    idx = idx(min_d_idx);
                    if ~isempty(idx)
                        spot_data(i,:) = locs(idx,:);
                    else
                        spot_data(i,:) = [0 0];
                    end                    
                else
                    spot_data(i,:) = [0 0];
                end
                clear locs poly_shape poly_center idx distances min_d_idx
            end
        catch
            spot_data = [];
        end
        plot_image()
    end

    function shift_values_callback(~,~,~)
        if ~isempty(spot_data)
            shift = zeros(size(spot_data,1)-1,2);
            for i = 1:size(shift,1)
                shift(i,:) = spot_data(i+1,:)-spot_data(i,:);
            end
            figure('name','Shift Values','NumberTitle','off','units','normalized','position',[0 0.1 1 0.4],'ToolBar','none','MenuBar', 'none');
            column_width = {200};
            uitable('Data',shift,'units','normalized','position',[0 0 1 1],'FontSize',12,'ColumnName',{'X Shift','Y Shift'},'columnwidth',column_width);
        end        
    end

    function check_shift_callback(~,~,~)
        if ~isempty(data) && ~isempty(spot_data)
            spot_data = spot_data(~all(spot_data == 0, 2),:);
            if size(spot_data,1)==length(data)
                shift = zeros(size(spot_data,1)-1,2);
                for i = 1:size(shift,1)
                    shift(i,:) = spot_data(i+1,:)-spot_data(i,:);
                end
                check_shift(data,shift)
            else
                msgbox('Number of Spots and the Number of Images are not Equal')
            end
        end                       
    end

    function shift_images_callback(~,~,~)
        if ~isempty(data) && ~isempty(spot_data)            
            spot_data = spot_data(~all(spot_data == 0, 2),:);
            if size(spot_data,1)==length(data)
                for i = 1:length(data)
                    file_names{i} = data{i}.name;
                    path{i} = data{i}.path;
                end                
                shift = zeros(size(spot_data,1)-1,2);
                for i = 1:size(shift,1)
                    shift(i,:) = spot_data(i+1,:)-spot_data(i,:);
                end
                shift_images(path,file_names,shift)
            else
                msgbox('Number of Spots and the Number of Images are not Equal')
            end
        end                
    end

    function select_all_spots_callback(~,~,~)
        total_shift = [];
        for i = 1:length(data)
            if isfield(data{i},'pstruct')
                locs{i}(:,1) = data{i}.pstruct.x;
                locs{i}(:,2) = data{i}.pstruct.y;
            else
                msgbox('At Least One Image Does not Contain Fit Information')
                locs = [];
                break
            end
        end
        if ~isempty(locs)
            input_values = inputdlg({'Search Radius:'},'',1,{'3'});
            if ~isempty(input_values)
                search_radius = str2double(input_values{1});                
                [total_shift,tracks] = find_total_shift(locs,search_radius);

                [x,y] = meshgrid(1:size(data{1}.xy,2),1:size(data{1}.xy,1));
                z = x-x;
                figure()
                set(gcf,'color','w')
                hold on
                for i = 1:length(tracks)
                    plot3(tracks{i}(:,1),tracks{i}(:,2),1:size(tracks{i},1))
                end
                surf(x,y,z+1,data{1}.xy,'EdgeColor','none','FaceAlpha',0.8)
                surf(x,y,z+length(data),data{length(data)}.xy,'EdgeColor','none','FaceAlpha',0.8)
                
                for i = 1:length(data)
                    image_v_1(:,i) = data{i}.xy(:,1);
                    image_v_2(:,i) = data{i}.xy(:,end);
                    image_h(:,i) = data{i}.xy(end,:)';
                end
                [y,z] = meshgrid(1:length(data),1:size(image_v_1,1));
                surf(y-y+1,z,y,image_v_1,'EdgeColor','none','FaceAlpha',0.5)
                surf(y-y+size(image_v_1,1),z,y,image_v_2,'EdgeColor','none','FaceAlpha',0.5)
                
                [y,z] = meshgrid(1:length(data),1:size(image_h,1));
                surf(z,y-y+size(image_v_1,1),y,image_h,'EdgeColor','none','FaceAlpha',0.5)
                
                colormap(gray)
                title({'',['Number of Tracks = ',num2str(length(tracks))]},'interpreter','latex','fontsize',14)
                box on
                set(gca,'color','w','boxstyle','full')
                view(30,30)
                xlim([1 size(data{1}.xy,2)])
                ylim([1 size(data{1}.xy,1)])    
            end
        end
    end

    function all_spots_shift_values_callback(~,~,~)
        if ~isempty(total_shift)
            figure('name','Shift Values (Total)','NumberTitle','off','units','normalized','position',[0 0.1 1 0.4],'ToolBar','none','MenuBar', 'none');
            column_width = {200};
            uitable('Data',total_shift,'units','normalized','position',[0 0 1 1],'FontSize',12,'ColumnName',{'X Shift','Y Shift','Sigma X','Sigma Y'},'columnwidth',column_width);
        end        
    end

    function all_spots_check_shift_callback(~,~,~)        
        if ~isempty(data) && ~isempty(total_shift)
            check_shift(data,total_shift(:,1:2))
        end
    end

    function all_spots_shift_images_callback(~,~,~)
        if ~isempty(data) && ~isempty(total_shift)            
            for i = 1:length(data)
                file_names{i} = data{i}.name;
                path{i} = data{i}.path;
            end            
            shift_images(path,file_names,total_shift(:,1:2))            
        end
    end

    function save_video_callback(~,~,~)        
        [file,path] = uiputfile('*.avi');
        if file~=0
            v = VideoWriter([path,file]);
            v.Quality = 100;
            v.FrameRate = 10;
            open(v);
            figure('Resize','off')
            for i = 1:length(data)  
                image_slider_value = i;
                plot_image()
                f = getframe(gcf);
                writeVideo(v, f);
                drawnow
            end
            close(v)
        end
    end
end

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
        f = waitbar(0,'Loading Images');
        for k = 1:length(file_names)
            try
                data{k}.xy = double(imread(fullfile(path,file_names{k}),to_load(1),'PixelRegion',{[str2double(to_crop_y{1}) str2double(to_crop_y{2})],[str2double(to_crop_x{1}) str2double(to_crop_x{2})]}));
                for i = 2:length(to_load)
                    data{k}.xy = data{k}.xy + double(imread(fullfile(path,file_names{k}),to_load(i),'PixelRegion',{[str2double(to_crop_y{1}) str2double(to_crop_y{2})],[str2double(to_crop_x{1}) str2double(to_crop_x{2})]}));
                end
                data{k}.name = file_names{k};
                data{k}.path = path;
                waitbar(k/length(file_names),f,['Loading Images...',num2str(k),'/',num2str(length(file_names))])
            catch
                data{k} = [];
            end
        end
        close(f)
    else
        data = [];
    end
end
end

function shift_images(path,file_names,shift)
for i = 1:length(file_names)
    info = imfinfo(fullfile(path{i},file_names{i}));
    N = numel(info);
    f = waitbar(0,'Loading Images');
    for k = 1:N
        image_to_load{k} = imread(fullfile(path{i},file_names{i}),k);
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
            imwrite(imtranslate(image_to_load{j},-val),[path{i},'\',file_names{i}(1:end-4),'_drift_corrected.tif'], 'Compression', 'none','WriteMode', "append");
            waitbar(j/length(image_to_load),f,['Saving Drift Corrected Images...',num2str(i),'/',num2str(length(file_names))])
        end
        close(f)
    else
        f = waitbar(0,'Saving Drift Corrected Images');
        for j = 1:length(image_to_load)
            imwrite(image_to_load{j},[path{i},'\',file_names{i}(1:end-4),'_drift_corrected.tif'], 'Compression', 'none','WriteMode', "append");
            waitbar(j/length(image_to_load),f,['Saving Drift Corrected Images...',num2str(i),'/',num2str(length(file_names))])
        end
        close(f)
    end
    clear image_to_load
end
end

function [total_shift,to_save] = find_total_shift(locs,search_radius)
counter = 0;
to_save = [];
f = waitbar(0,'Finding Total Shifts...');
start_length = size(locs{1},1);
while ~isempty(locs{1})
    waitbar(1-size(locs{1},1)/start_length,f,'Finding Total Shifts...')
    wanted = [];
    start = locs{1}(1,:);
    locs{1}(1,:) = [];
    wanted(end+1,:) = start;
    for i = 2:length(locs)
        if ~isempty(locs{i})
            idx = search_nearest_neighbor(start,locs{i},search_radius);
            if ~isempty(idx)
                wanted(end+1,:) = locs{i}(idx,:);
                start = locs{i}(idx,:);
                locs{i}(idx,:) = [];
            else
                break
            end
        else
            break
        end
    end
    
    if size(wanted,1)==length(locs)
        counter = counter+1;
        to_save{counter} = wanted;
    end        
end

shift =[];
total_shift = [];
if ~isempty(to_save)
    for i = 1:length(to_save)
        for j = 1:size(to_save{i},1)-1
            shift{i}(j,:) = to_save{i}(j+1,:)-to_save{i}(j,:);
        end
    end
    
    for i = 1:length(locs)-1
        vals = cellfun(@(x) x(i,:),shift,'UniformOutput',false);
        vals = vertcat(vals{:});
        std_vals(i,:) = std(vals);
        vals = mean(vals);        
        total_shift(i,:) = vals;        
        clear vals
    end
    total_shift = [total_shift,std_vals];
else
    total_shift = zeros(length(locs)-1,2);
    to_save = [];
end
close(f)
end

function idx = search_nearest_neighbor(core,locs,search_radius)
idx = rangesearch(core,locs,search_radius);
idx = find(~cellfun(@isempty,idx));
if ~isempty(idx)
    idx = idx(1);
end
end

function check_shift(data,shift)
image_shifted = cell(length(data),1);
for i = 1:length(data)
    if i>=2
        val = shift(1:i-1,:);
        if size(val,1)>1
            val = cumsum(val);
            val = val(end,:);
        end
        image_shifted{i} = imtranslate(data{i}.xy,-val);        
    else        
        image_shifted{i} = data{i}.xy;        
    end
end
check_shift_plot(image_shifted)
end

function check_shift_plot(data)
figure()
set(gcf,'name','Shiftted Images','NumberTitle','off','color','w','units','normalized','position',[0.2 0.15 0.4 0.5],'menubar','none','toolbar','none')
image_slider_value = 1;
image_slider = uicontrol('style','slider','units','normalized','position',[0.97,0.05,0.03,0.95],'value',image_slider_value,'min',1,'max',2,'sliderstep',[0 0],'Callback',@image_slider_callback);

if length(data)>1
    image_slider.Max = length(data);
    image_slider.Min = 1;
    image_slider.Value = 1;
    image_slider.SliderStep = [1/(length(data)-1) 1/(length(data)-1)];
else
    image_slider.Max = 2;
    image_slider.Min = 1;
    image_slider.Value = 1;
    image_slider.SliderStep = [0 0];
end

    function plot_image()
        if ~isempty(data)            
            image = data{image_slider_value};
            ax = gca; cla(ax);
            imagesc(image)
            colormap(gray)
            axis off
            pbaspect([1 1 1])
            xlim([1 size(image,2)])
            ylim([1 size(image,1)]) 
        end
    end

    function image_slider_callback(~,~,~)
        image_slider_value = round(image_slider.Value);
        plot_image();
    end
plot_image()
end