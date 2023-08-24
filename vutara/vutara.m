function vutara()
addpath([pwd,'/PointSourceDetection'])  
addpath([pwd,'/PointSourceDetection/mex'])  
figure('CloseRequestFcn',@my_closereq);
set(gcf,'name','Vutara','NumberTitle','off','color','w','units','normalized','position',[0.2 0.15 0.6 0.7],'menubar','none','toolbar','figure')

    function my_closereq(~,~)
        selection = questdlg('Close the Software?','Close Software?','Yes','No','Yes');
        switch selection
            case 'Yes'
                delete(gcf)
            case 'No'
                return
        end
    end

uicontrol('style','pushbutton','units','normalized','position',[0.1,0.95,0.05,0.05],'string','Down','BackgroundColor','w','Fontsize',12,'callback',@move_down);
uicontrol('style','pushbutton','units','normalized','position',[0.15,0.95,0.05,0.05],'string','Up','BackgroundColor','w','Fontsize',12,'callback',@move_up);

file_menu = uimenu('Text','File');
uimenu(file_menu,'Text','Load Session','Callback',{@load_session});
uimenu(file_menu,'Text','Save Session','Callback',{@save_session});

edit_menu = uimenu('Text','Edit');
uimenu(edit_menu,'Text','Rename File(s)','Callback',{@rename_callback});

help_menu = uimenu('Text','Help');
uimenu(help_menu,'Text','About','Callback',{@about_callback});

    function about_callback(~,~,~)
        dos('explorer https://www.arianarab.com');       
    end

    function move_up(~,~,~)
        listbox_value = listbox.Value;
        temp_one = data(1:listbox_value(1)-1);
        temp_two = data(listbox_value);
        temp_three = data(listbox_value(end)+1:end);
        try
            data_move = [temp_one(1:end-1) temp_two temp_one(end) temp_three];
            data = [];
            data = data_move;
            listbox.Value = listbox_value-1;
        end
        listbox = set_listbox_names(listbox,data);
    end

    function move_down(~,~,~)
        listbox_value = listbox.Value;
        temp_one = data(1:listbox_value(1)-1);
        temp_two = data(listbox_value);
        temp_three = data(listbox_value(end)+1:end);
        try
            data_move = [temp_one temp_three(1) temp_two temp_three(2:end)];
            data = [];
            data = data_move;
            listbox.Value = listbox_value+1;
        end
        listbox = set_listbox_names(listbox,data);
    end

uicontrol('style','pushbutton','units','normalized','position',[0,0.95,0.1,0.05],'string','Load Image(s)','ForegroundColor','b','Callback',{@load_image_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0.2,0.95,0.1,0.05],'string','Max Projection','ForegroundColor','b','Callback',{@project_images_callback},'FontSize',12);

psf_sigma = uicontrol('style','edit','units','normalized','position',[0.3,0.95,0.1,0.05],'string','Sigma (2)','ForegroundColor','b','Callback',{@psf_sigma_callback},'FontSize',12);

alpha_edit = uicontrol('style','edit','units','normalized','position',[0.4,0.95,0.1,0.05],'string','Alpha (0.0001)','ForegroundColor','b','Callback',{@alpha_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0.5,0.95,0.1,0.05],'string','Detect Spots','ForegroundColor','b','Callback',{@localization_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0.6,0.97,0.1,0.03],'string','Find Tracks','ForegroundColor','b','Callback',{@find_tracks_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0.6,0.94,0.1,0.03],'string','Plot Tracks','ForegroundColor','b','Callback',{@plot_tracks_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0.7,0.97,0.08,0.03],'string','Find Z','ForegroundColor','b','Callback',{@find_z_callback},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0.7,0.94,0.08,0.03],'string','Plot X,Y,Z','ForegroundColor','b','Callback',{@plot_xyz},'FontSize',12);

uicontrol('style','pushbutton','units','normalized','position',[0,0.05,0.2,0.05],'string','Delete Image(s)','ForegroundColor','b','Callback',{@delete_images_callback},'FontSize',12);

listbox = uicontrol('style','listbox','units','normalized','position',[0,0.1,0.2,0.85],'string','NaN','ForegroundColor','b','backgroundcolor','w','Callback',@listbox_callback,'Max',100,'FontSize',12);

image_slider_value = 1;
image_slider = uicontrol('style','slider','units','normalized','position',[0.97,0.05,0.03,0.95],'value',image_slider_value,'min',1,'max',2,'sliderstep',[0 0],'Callback',@image_slider_callback);

image_number = uicontrol('style','text','units','normalized','position',[0.82,0.05,0.15,0.04],'string','Image Number','ForegroundColor','b','FontSize',12);
number_of_detected_spots = uicontrol('style','text','units','normalized','position',[0.82,0.09,0.15,0.04],'string','Detected Spots','ForegroundColor','b','FontSize',12);

play_button = uicontrol('style','pushbutton','units','normalized','position',[0.8,0,0.1,0.05],'string','play','Callback',{@play_callback});
pause_button = uicontrol('style','pushbutton','units','normalized','position',[0.8,-0.1,0.1,0.05],'string','pause','Callback',{@pause_callback});
uicontrol('style','pushbutton','units','normalized','position',[0.9,0,0.1,0.05],'string','save video','Callback',{@save_video_callback});

gaussian_amplitute_checkbox = uicontrol('Style','checkbox','String','Gaussian Amplitute','Value',0,'units','normalized','Position',[0.6 0 0.2 0.05],'Callback',@gaussian_amplitute_checkbox_callback);
xy_checkbox = uicontrol('Style','checkbox','String','XY Positions','Value',0,'units','normalized','Position',[0.4 0 0.2 0.05],'Callback',@xy_checkbox_callback);

brightness_slider_step = 0.01;
low_slider_value = 0;
high_slider_value = 1;
low_slider = uicontrol('style','slider','units','normalized','position',[0,0,0.2,0.05],'value',0,'min',0,'max',1-brightness_slider_step,'sliderstep',[1/99 1/99],'Callback',{@low_in_slider_callback});
high_slider = uicontrol('style','slider','units','normalized','position',[0.2,0,0.2,0.05],'value',1,'min',brightness_slider_step,'max',1,'sliderstep',[1/99 1/99],'Callback',{@high_in_slider_callback});

data = [];

sigma = 2;
alpha = 0.0001;
xx = [0 1];
yy = [0 1];

    function load_image_callback(~,~,~)
        data_load = load_image_inside();        
        if ~isempty(data_load)            
            data = set_data(data,data_load);
            listbox = set_listbox_names(listbox,data);   
        end        
    end

    function project_images_callback(~,~,~)
        if ~isempty(data)
            listbox_value = listbox.Value;            
            idx = listdlg('ListString',{'xy','xz','yz'});
            if ~isempty(idx)                
                for i = 1:length(listbox_value)
                    if idx == 1
                        if isfield(data{listbox_value(i)},'projected_image')
                            data_to_send{i}.image = {data{listbox_value(i)}.projected_image};
                            data_to_send{i}.name = [data{listbox_value(i)}.name,'_projected_image'];
                        else
                            data_to_send = [];
                            break
                        end
                    end
                    if idx == 2
                        if isfield(data{listbox_value(i)},'projected_image_xz')
                            data_to_send{i}.image = {data{listbox_value(i)}.projected_image_xz};
                            data_to_send{i}.name = [data{listbox_value(i)}.name,'_projected_image_xz'];
                        else
                            data_to_send = [];
                            break
                        end
                    end
                    if idx == 3
                        if isfield(data{listbox_value(i)},'projected_image_yz')
                            data_to_send{i}.image = {data{listbox_value(i)}.projected_image_yz};
                            data_to_send{i}.name = [data{listbox_value(i)}.name,'_projected_image_yz'];
                        else
                            data_to_send = [];
                            break
                        end
                    end                    
                end
                if ~isempty(data_to_send)
                    data = set_data(data,data_to_send);
                    listbox = set_listbox_names(listbox,data);
                end
            end
        end
    end

    function psf_sigma_callback(~,~,~)
        sigma = str2double(psf_sigma.String);
    end

    function alpha_callback(~,~,~)
        alpha = str2double(alpha_edit.String);
    end

    function localization_callback(~,~,~)
        listbox_value = listbox.Value;
        if ~isempty(data)
            for i = 1:length(listbox_value)
                if isfield(data{listbox_value(i)},'image')
                    f = waitbar(0,'Detecting Spots');
                    for k = 1:length(data{listbox_value(i)}.image)
                        [x_spot,y_spot,mask,A_est,c_est] = find_localizations(data{listbox_value(i)}.image{k},sigma,alpha);
                        if ~isempty(x_spot)
                            data{listbox_value(i)}.pstruct{k} = fit_gaussian(data{listbox_value(i)}.image{k},x_spot,y_spot,mask,alpha,A_est,sigma,c_est);
                        else
                            data{listbox_value(i)}.pstruct{k} = [];
                        end
                        clear x_spot y_spot mask A_est c_est
                        waitbar(k/length(data{listbox_value(i)}.image),f,['Detecting Spots.....',num2str(i),'/',num2str(length(listbox_value))])
                    end
                    close(f)
                end
            end
        end
        plot_image()
    end

    function find_tracks_callback(~,~,~)
        listbox_value = listbox.Value;
        if ~isempty(data)
            input_values = inputdlg({'Search Radius:','Minimum Track Length:','Gaps Allowed:','Show Tracks (0 or 1):'},'',1,{'5','5','2','0'});
            if ~isempty(input_values)
                search_radius = str2double(input_values{1});
                track_length = str2double(input_values{2});
                gaps = str2double(input_values{3});
                show_tracks = str2double(input_values{4});
                for i = 1:length(listbox_value)
                    if isfield(data{listbox_value(i)},'image') && isfield(data{listbox_value(i)},'pstruct')
                        data{listbox_value(i)}.tracks = find_tracks(data{listbox_value(i)}.pstruct,data{listbox_value(i)}.image,search_radius,track_length,gaps,data{listbox_value(i)}.name,show_tracks);
                    end
                end
            end
        end
    end

    function plot_tracks_callback(~,~,~)
        listbox_value = listbox.Value;
        if ~isempty(data)
            f = waitbar(0,'Ploting Tracks');
            for i = 1:length(listbox_value)
                if isfield(data{listbox_value(i)},'tracks') && isfield(data{listbox_value(i)},'image')
                    plot_tracks(data{listbox_value(i)}.image,data{listbox_value(i)}.tracks,data{listbox_value(i)}.name)
                end
                waitbar(i/length(listbox_value),f,['Ploting Tracks.....',num2str(i),'/',num2str(length(listbox_value))])
            end
            close(f)
        end
    end

    function find_z_callback(~,~,~)
        listbox_value = listbox.Value;
        if ~isempty(data)
            input_values = inputdlg({'Minimum Spot Intensity:','Show Spots (0 or 1):'},'',1,{'0.3','0'});
            if ~isempty(input_values)
                min_intensity = str2double(input_values{1});
                show_spots = str2double(input_values{2});
                f = waitbar(0,'Finding Max Intensity Spot');
                for i = 1:length(listbox_value)
                    if isfield(data{listbox_value(i)},'tracks') && isfield(data{listbox_value(i)},'projected_image')
                        data{listbox_value(i)}.wanted = find_z(data{listbox_value(i)}.tracks,min_intensity);
                        if show_spots ==1
                            figure()
                            imagesc(data{listbox_value(i)}.projected_image)
                            colormap(gray)
                            hold on
                            scatter(data{listbox_value(i)}.wanted(:,1),data{listbox_value(i)}.wanted(:,2),10,'r','filled')
                            for k = 1:size(data{listbox_value(i)}.wanted,1)
                                text(data{listbox_value(i)}.wanted(k,1),data{listbox_value(i)}.wanted(k,2),['  ',num2str(data{listbox_value(i)}.wanted(k,3))],'color','r')
                            end
                            title({'',data{listbox_value(i)}.name,['Number of Spots = ',num2str(length(data{listbox_value(i)}.wanted))]})
                            axis equal
                            axis off
                        end
                        waitbar(i/length(listbox_value),f,['Finding Max Intensity Spot.....',num2str(i),'/',num2str(length(listbox_value))])
                    end
                end
                close(f)
            end
        end
    end

    function plot_xyz(~,~,~)
        listbox_value = listbox.Value;
        if ~isempty(data)
            for i = 1:length(listbox_value)
                f = waitbar(0,'Ploting Spots');
                if isfield(data{listbox_value(i)},'wanted') && isfield(data{listbox_value(i)},'projected_image')
                    figure()
                    imagesc(data{listbox_value(i)}.projected_image)
                    colormap(gray)
                    hold on
                    z = num2cell(data{listbox_value(i)}.wanted(:,3));
                    textscatter(data{listbox_value(i)}.wanted(:,1),data{listbox_value(i)}.wanted(:,2),z,'TextDensityPercentage',100,'ColorData',[1 0 0 ]);
                    title({'',data{listbox_value(i)}.name,['Number of Spots = ',num2str(length(data{listbox_value(i)}.wanted))]})
                    axis equal
                    axis off
                    waitbar(i/length(listbox_value),f,['Ploting Spots.....',num2str(i),'/',num2str(length(listbox_value))])
                end
                close(f)
            end
        end
    end

    function listbox_callback(~,~,~)
        listbox = set_listbox_names(listbox,data);
        if isempty(data)~=1
            listbox_value = listbox.Value;
            if length(data{listbox_value(1)}.image)>1
                image_slider.Max = length(data{listbox_value(1)}.image);
                image_slider.Min = 1;
                image_slider.Value = 1;
                image_slider.SliderStep = [1/(length(data{listbox_value(1)}.image)-1) 1/(length(data{listbox_value(1)}.image)-1)];
            else
                image_slider.Max = 2;
                image_slider.Min = 1;
                image_slider.Value = 1;
                image_slider.SliderStep = [0 0];
            end
            image_slider_value = 1;
            xx = ([1 size(data{listbox_value(1)}.image{1},2)]);
            yy = ([1 size(data{listbox_value(1)}.image{1},1)]);          
            plot_image()            
        end
    end

    function plot_image() 
        listbox_value = listbox.Value;
        if ~isempty(data)            
            if isfield(data{listbox_value(1)},'image')
                image = data{listbox_value(1)}.image;
                ax = gca; cla(ax);
                imagesc(image{image_slider_value})
                caxis([low_slider_value high_slider_value])
                colormap(gray)
                xlim(xx)
                ylim(yy)                
                axis off
                image_number.String = [num2str(image_slider_value),'/',num2str(length(image))];
                pbaspect([1 1 1])
            end
            
            if isfield(data{listbox_value(1)},'pstruct')
                hold on
                scatter_data = data{listbox_value(1)}.pstruct;
                if ~isempty(scatter_data{image_slider_value})
                    scatter(scatter_data{image_slider_value}.x,scatter_data{image_slider_value}.y,10,'r','filled')
                    if gaussian_amplitute_checkbox.Value == 1
                        for i =1:length(scatter_data{image_slider_value}.y)
                            val = round(scatter_data{image_slider_value}.A(i),2);                            
                            text(scatter_data{image_slider_value}.x(i),scatter_data{image_slider_value}.y(i),['  ',num2str(val)],'color','r')
                        end
                    end
                    if xy_checkbox.Value == 1
                        for i =1:length(scatter_data{image_slider_value}.y)
                            val_x = round(scatter_data{image_slider_value}.x(i),2);                            
                            val_y = round(scatter_data{image_slider_value}.y(i),2);                            
                            text(scatter_data{image_slider_value}.x(i),scatter_data{image_slider_value}.y(i),['  [',num2str(val_x),',',num2str(val_y),']'],'color','r')
                        end
                    end
                    number_of_detected_spots.String = num2str(length(scatter_data{image_slider_value}.x));
                else
                    number_of_detected_spots.String = 0;
                end
            end
        end        
    end

    function image_slider_callback(~,~,~)
        image_slider_value = round(image_slider.Value);
        xx = xlim;
        yy = ylim;
        plot_image();
    end

    function gaussian_amplitute_checkbox_callback(~,~,~)
        plot_image()
    end

    function xy_checkbox_callback(~,~,~)
        plot_image()
    end

    function low_in_slider_callback(~,~,~)
        low_slider_value = low_slider.Value;        
        high_slider_value = high_slider.Value;
        if low_slider_value>high_slider_value
            high_slider_value = low_slider_value+brightness_slider_step;            
            high_slider.Value = high_slider_value;
        end  
        plot_image()
    end

    function high_in_slider_callback(~,~,~)
        high_slider_value = high_slider.Value;        
        low_slider_value = low_slider.Value;
        if high_slider_value<low_slider_value
            low_slider_value = high_slider_value-brightness_slider_step;            
            low_slider.Value = low_slider_value;
        end 
        plot_image()
    end    

    function play_callback(~,~,~)
        listbox_value = listbox.Value;
        global pause_call        
        pause_call = 0;        
        play_button.Position = [0.8,-0.1,0.1,0.05];
        pause_button.Position = [0.8,0,0.1,0.05];
        for k = image_slider_value:length(data{listbox_value(1)}.image)
            if pause_call == 0
                image_slider.Value = k;
                image_slider_value = round(image_slider.Value);
                plot_image()
                drawnow
            end
        end
        if image_slider.Value == length(data{listbox_value(1)}.image)
            play_button.Position = [0.8,0,0.1,0.05];
            pause_button.Position = [0.8,-0.1,0.1,0.05];
            image_slider_value = 1;
            image_slider.Value = image_slider_value;
            plot_image()
        end
    end

    function pause_callback(~,~,~)
        global pause_call
        pause_call = 1;
        image_slider_value = round(image_slider.Value);
        plot_image()
        play_button.Position = [0.8,0,0.1,0.05];
        pause_button.Position = [0.8,-0.1,0.1,0.05];
    end

    function save_video_callback(~,~,~)
        listbox_value = listbox.Value;
        [file,path] = uiputfile('*.avi');
        if file~=0            
            v = VideoWriter([path,file]);
            v.Quality = 100;
            v.FrameRate = 10;
            open(v);
            figure('Resize','off')
            for i = 1:length(data{listbox_value}.image)
                image_slider_value = i;
                plot_image()
                f = getframe(gcf);
                writeVideo(v, f);
                drawnow
            end
            close(v)            
        end
    end  

    function delete_images_callback(~,~,~)
        listbox_value = listbox.Value;
        if isempty(data)
            msgbox('List is empty')
            return
        else
            choice = questdlg('Are you sure you want to delete the selected files','Close','Yes','No','Yes');
            switch choice
                case 'Yes'
                    data(listbox_value) = [];
                    data = data(~cellfun('isempty',data));
                case 'No'
                    return
            end
        end
        listbox = set_listbox_names(listbox,data);
        listbox.Value = 1;
    end

    function save_session(~,~,~)
        if isempty(data)
            msgbox('List is empty')
            return
        else
            [file,path] = uiputfile('.mat','Save Session');
            if isequal(file,0)
                return
            else                
                f = waitbar(0,'Saving, Please Wait...');                
                save(fullfile(path,file),'data','-v7.3')
                waitbar(1,f,'Saving, Please Wait...')
                close(f)
            end
        end
    end

    function load_session(~,~,~)
        [file_name,path] = uigetfile('*.mat','Select Session','MultiSelect','on');
        if isequal(file_name,0)
            return            
        else
            file_name = cellstr(file_name);
            f = waitbar(0,'Loading...');
            for i = 1:length(file_name)
                waitbar(i/length(file_name),f,['Loading...',num2str(i),'/',num2str(length(file_name))])  
                try
                    data_load{i} = load(fullfile(path,file_name{i})); 
                    data_load{i} = data_load{i}.data;
                catch
                    data_load{i} = [];
                end
            end
            close(f)
            data_load = data_load(~cellfun('isempty',data_load));
            data_load = horzcat(data_load{:});
            data = set_data(data,data_load);
        end
        listbox = set_listbox_names(listbox,data);
        listbox.Value = 1;
    end

    function rename_callback(~,~,~)
        listbox_value = listbox.Value;
        if isempty(data)
            msgbox('List is empty')
            return
        else
            input_values = inputdlg('chnage name(s) to:','',1,{data{listbox_value(1)}.name});
            if isempty(input_values)==1
                return
            else
                new_name = input_values{1};
                for i=1:length(listbox_value)
                    data{listbox_value(i)}.name = new_name;
                end
            end
        end
        listbox = set_listbox_names(listbox,data);
    end
end

function data = set_data(data,data_load)
if isempty(data)==1
    data=data_load;
else
    data= horzcat(data,data_load);
end
end

function listbox = set_listbox_names(listbox,data)
if isempty(data)==1
    listbox.String = 'NaN';
else
    for i=1:length(data)
        names{i} = data{i}.name;        
    end
    listbox.String = names;
end
end