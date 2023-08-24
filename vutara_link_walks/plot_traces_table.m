function plot_traces_table(data)
figure();
set(gcf,'name','Traces Table','NumberTitle','off','color','w','units','normalized','position',[0.2 0.1 0.7 0.5],'menubar','none','toolbar','figure')

slider_value = 1;
slider = uicontrol('style','slider','units','normalized','position',[0.97,0.05,0.03,0.95],'value',slider_value,'min',1,'max',1,'sliderstep',[0 0],'Callback',@slider_callback);

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

    function slider_callback(~,~,~)
        slider_value = round(slider.Value);
        plot_inside()
    end

    function plot_inside()
        data_to_plot = data{slider_value}; 
        ax = gca;cla(ax);
        column_width = {100};
        column_names = {'X_Ref','Y_Ref','Z_Ref','I_Ref','Step_Ref','X_Walk','Y_Walk','Z_Walk','I_Walk','Step_Walk'};
        uitable('Data',data_to_plot,'units','normalized','position',[0 0 0.97 0.93],'ColumnName',column_names,'FontSize',12,'columnwidth',column_width);
        title([num2str(slider_value),'/',num2str(length(data))])
    end
plot_inside()
end