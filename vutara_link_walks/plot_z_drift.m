function plot_z_drift(data)
figure()
set(gcf,'name','Z Drift','NumberTitle','off','color','w','units','normalized','position',[0.2 0.1 0.7 0.5],'menubar','none','toolbar','figure')

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
        subplot(1,2,1)
        ax = gca;cla(ax);
        plot(data{slider_value}(:,5),data{slider_value}(:,3),'k')
        title([num2str(slider_value),'/',num2str(length(data))],'interpreter','latex')
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
        xlabel('Walk Step','interpreter','latex','fontsize',18)
        ylabel('Z','interpreter','latex','fontsize',18)
    end

for i = 1:length(data)
    data_to_plot{i} = [data{i}(:,3),data{i}(:,5)];
end
wanted = vertcat(data_to_plot{:});
wanted = sortrows(wanted,2);
start = wanted(1,2);
mean_vals{1} = wanted(1,1);
mean_counter = 1;
for i = 2:size(wanted,1)
    if wanted(i,2) == start
        mean_vals{mean_counter}(end+1) = wanted(i,1);
    else
        mean_counter = mean_counter+1;
        mean_vals{mean_counter} = wanted(i,1);
        start = wanted(i,2);
    end
end
mean_values = cellfun(@mean,mean_vals);
if length(data_to_plot)>1000
    I = randi(length(data_to_plot),1000,1);
    I = unique(I);
else
    I = 1:length(data_to_plot);
end
subplot(1,2,2)
hold on
for i = 1:length(I)
    plot(data_to_plot{I(i)}(:,2),data_to_plot{I(i)}(:,1),'k')
end
plot(mean_values,'b','linewidth',5)
set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
box on
xlabel('Walk Step','interpreter','latex','fontsize',18)
ylabel('Z','interpreter','latex','fontsize',18)
end