function plot_final_traces(data)
figure()
set(gcf,'name','Final Traces','NumberTitle','off','color','w','units','normalized','position',[0.2 0.1 0.35 0.5],'menubar','none','toolbar','figure')

slider_value = 1;
slider = uicontrol('style','slider','units','normalized','position',[0,0,0.05,1],'value',slider_value,'min',1,'max',2,'sliderstep',[0 0],'Callback',@image_slider_callback);

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
        I = ~isnan(data_to_plot);
        idx = find(I(:,1));
        wanted = data_to_plot(idx,:);
        wanted(:,4) = idx;
        plot3(wanted(:,1),wanted(:,2),wanted(:,3),'k')
        hold on
        scatter3(wanted(:,1),wanted(:,2),wanted(:,3),10,'b','filled')
        for i = 1:size(wanted,1)
            text(wanted(i,1),wanted(i,2),wanted(i,3),num2str(wanted(i,4)))
        end
        title([num2str(slider_value),'/',num2str(length(data))],'interpreter','latex')
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
        pbaspect([1 1 1])
        xlabel('Pixels','interpreter','latex','fontsize',18)
        ylabel('Pixels','interpreter','latex','fontsize',18)
        zlabel('Image Number','interpreter','latex','fontsize',18)
    end

end