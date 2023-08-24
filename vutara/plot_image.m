function plot_image(data)
figure();
set(gcf,'name','Image Data','NumberTitle','off','color','w','units','normalized','position',[0.2 0.15 0.6 0.7],'menubar','none','toolbar','figure')

image_slider_value = 1;
image_slider = uicontrol('style','slider','units','normalized','position',[0.97,0.05,0.03,0.95],'value',image_slider_value,'min',1,'max',2,'sliderstep',[0 0],'Callback',@image_slider_callback);

if length(data.image)>1
    image_slider.Max = length(data.image);
    image_slider.Min = 1;
    image_slider.Value = 1;
    image_slider.SliderStep = [1/(length(data.image)-1) 1/(length(data.image)-1)];
else
    image_slider.Max = 2;
    image_slider.Min = 1;
    image_slider.Value = 1;
    image_slider.SliderStep = [0 0];
end
   
image_number = uicontrol('style','text','units','normalized','position',[0.82,0.05,0.15,0.04],'string','Image Number','ForegroundColor','b','FontSize',12);
number_of_detected_spots = uicontrol('style','text','units','normalized','position',[0.82,0.09,0.15,0.04],'string','Detected Spots','ForegroundColor','b','FontSize',12);

gaussian_amplitute_checkbox = uicontrol('Style','checkbox','String','Gaussian Amplitute','Value',0,'units','normalized','Position',[0.6 0 0.2 0.05],'Callback',@gaussian_amplitute_checkbox_callback);
xy_checkbox = uicontrol('Style','checkbox','String','XY Positions','Value',0,'units','normalized','Position',[0.4 0 0.2 0.05],'Callback',@xy_checkbox_callback);

xx = ([1 size(data.image{1},2)]);
yy = ([1 size(data.image{1},1)]);

brightness_slider_step = 0.01;
low_slider_value = 0;
high_slider_value = 1;
low_slider = uicontrol('style','slider','units','normalized','position',[0,0,0.2,0.05],'value',0,'min',0,'max',1-brightness_slider_step,'sliderstep',[1/99 1/99],'Callback',{@low_in_slider_callback});
high_slider = uicontrol('style','slider','units','normalized','position',[0.2,0,0.2,0.05],'value',1,'min',brightness_slider_step,'max',1,'sliderstep',[1/99 1/99],'Callback',{@high_in_slider_callback});

plot_img()

    function image_slider_callback(~,~,~)
        image_slider_value = round(image_slider.Value);
        xx = xlim;
        yy = ylim;
        plot_img();
    end

    function plot_img() 
        if ~isempty(data)            
            if isfield(data,'image')
                image = data.image;
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
            
            if isfield(data,'pstruct')
                hold on
                scatter_data = data.pstruct;
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
                            val_y = round(scatter_data{image_slider_value}.x(i),2);                            
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
        

    function low_in_slider_callback(~,~,~)
        low_slider_value = low_slider.Value;
        high_slider_value = high_slider.Value;
        if low_slider_value>high_slider_value
            high_slider_value = low_slider_value+brightness_slider_step;
            high_slider.Value = high_slider_value;
        end
        plot_img()
    end

    function high_in_slider_callback(~,~,~)
        high_slider_value = high_slider.Value;
        low_slider_value = low_slider.Value;
        if high_slider_value<low_slider_value
            low_slider_value = high_slider_value-brightness_slider_step;
            low_slider.Value = low_slider_value;
        end
        plot_img()
    end

play_button = uicontrol('style','pushbutton','units','normalized','position',[0.8,0,0.1,0.05],'string','play','Callback',{@play_callback});
pause_button = uicontrol('style','pushbutton','units','normalized','position',[0.8,-0.1,0.1,0.05],'string','pause','Callback',{@pause_callback});
uicontrol('style','pushbutton','units','normalized','position',[0.9,0,0.1,0.05],'string','save video','Callback',{@save_video_callback});

    function play_callback(~,~,~)        
        global pause_call
        pause_call = 0;
        play_button.Position = [0.8,-0.1,0.1,0.05];
        pause_button.Position = [0.8,0,0.1,0.05];
        for k = image_slider_value:length(data.image)
            if pause_call == 0
                image_slider.Value = k;
                image_slider_value = round(image_slider.Value);
                plot_img()
                drawnow
            end
        end
        if image_slider.Value == length(data.image)
            play_button.Position = [0.8,0,0.1,0.05];
            pause_button.Position = [0.8,-0.1,0.1,0.05];
            image_slider_value = 1;
            image_slider.Value = image_slider_value;
            plot_img()
        end
    end

    function pause_callback(~,~,~)
        global pause_call
        pause_call = 1;
        image_slider_value = round(image_slider.Value);
        plot_img()
        play_button.Position = [0.8,0,0.1,0.05];
        pause_button.Position = [0.8,-0.1,0.1,0.05];
    end

    function save_video_callback(~,~,~)        
        [file,path] = uiputfile('*.avi');
        if file~=0
            v = VideoWriter([path,file]);
            v.Quality = 100;
            v.FrameRate = 10;
            open(v);
            figure('Resize','off')
            for i = 1:length(data.image)
                image_slider_value = i;
                plot_img()
                f = getframe(gcf);
                writeVideo(v, f);
                drawnow
            end
            close(v)
        end
    end

    function gaussian_amplitute_checkbox_callback(~,~,~)
        plot_image()
    end

    function xy_checkbox_callback(~,~,~)
        plot_image()
    end
end