function plot_distance_matrix(data,distance_cutoff)
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

matrix_added = zeros(size(data{1}));
for i = 1:length(data)
    data{i}(isnan(data{i})) = 0;    
    data{i}(data{i}<=distance_cutoff & data{i}~=0) = -1;
    data{i}(data{i}~=-1) = 0;     
    matrix_added = matrix_added + data{i};
end
plot_()

    function image_slider_callback(~,~,~)
        slider_value = round(slider.Value);
        plot_();
    end

    function plot_()
        subplot(1,2,1)
        ax = gca;cla(ax);
        data_to_plot = data{slider_value};
        imagesc(data_to_plot)        
        title([num2str(slider_value),'/',num2str(length(data))],'interpreter','latex')
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
        colormap(hot)
        colorbar()
        xlabel('Steps','interpreter','latex','fontsize',18)
        ylabel('Steps','interpreter','latex','fontsize',18)
        
        hist_data = triu(data_to_plot);
        hist_data = reshape(hist_data,[size(hist_data,1)*size(hist_data,2) 1]);
        hist_data(isnan(hist_data)) = [];
        hist_data(hist_data==0) = [];
        subplot(1,2,2)
        ax = gca;cla(ax);
        hist(hist_data,10);
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
        xlabel('Total Distance','interpreter','latex','fontsize',18)
        ylabel('Counts','interpreter','latex','fontsize',18)
    end

figure()
set(gcf,'name','Distance Matrix Altogether','NumberTitle','off','color','w','units','normalized','position',[0.2 0.1 0.7 0.5],'menubar','none','toolbar','figure')
subplot(1,2,1)
imagesc(matrix_added)
set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
box on
colormap(hot)
colorbar()
xlabel('Steps','interpreter','latex','fontsize',18)
ylabel('Steps','interpreter','latex','fontsize',18)
title('Total Distance','interpreter','latex')
axis equal
xlim([1 size(matrix_added,1)])
ylim([1 size(matrix_added,1)])
for i = 1:length(data)
    hist_da = triu(data{i});
    hist_da = reshape(hist_da,[size(hist_da,1)*size(hist_da,2) 1]);
    hist_da(isnan(hist_da)) = [];
    hist_da(hist_da==0) = [];
    wanted{i} = hist_da;
end
wanted = vertcat(wanted{:});
subplot(1,2,2)
hist(wanted,10);
set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
box on
xlabel('Total Distance','interpreter','latex','fontsize',18)
ylabel('Counts','interpreter','latex','fontsize',18)
end