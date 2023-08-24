function plot_distance_matrix_table(data,distance_cutoff)
figure()
set(gcf,'name','Distance Matrix','NumberTitle','off','color','w','units','normalized','position',[0.2 0.1 0.7 0.5],'menubar','none','toolbar','figure')

slider_value = 1;
slider = uicontrol('style','slider','units','normalized','position',[0,0,0.03,1],'value',slider_value,'min',1,'max',2,'sliderstep',[0 0],'Callback',@image_slider_callback);

if length(data)>1
    slider.Max = length(data);
    slider.Min = 1;
    slider.Value = 1;
    slider.SliderStep = [1/(length(data)-1) 1/(length(data)-1)];
else
    slider.Max = 2;
    slider.Min = 1;
    slider.Value = 1;
    slider.SliderStep = [0 0];
end

plot_()

    function image_slider_callback(~,~,~)
        slider_value = round(slider.Value);
        plot_();
    end

    function plot_()       
        ax = gca;cla(ax);
        data_to_plot = data{slider_value};
        data_to_plot(data_to_plot>distance_cutoff)= [];
        uitable('Data',data_to_plot,'units','normalized','position',[0.1 0 0.5 0.5],'FontSize',12);
        title([num2str(slider_value),'/',num2str(length(data))])
    end

matrix_added = zeros(size(data{1}));
for i = 1:length(data)
    data{i}(isnan(data{i})) = 0;
    data{i}(data{i}>distance_cutoff) = 0;
    matrix_added = matrix_added + data{i};
end
figure()
set(gcf,'name','Distance Matrix Altogether','NumberTitle','off','color','w','units','normalized','position',[0.2 0.1 0.7 0.5],'menubar','none','toolbar','figure')
uitable('Data',matrix_added,'units','normalized','position',[0 0 0.97 0.93],'FontSize',12);
title([num2str(slider_value),'/',num2str(length(data))])
end