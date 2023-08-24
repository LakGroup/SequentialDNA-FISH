function plot_distance_matrix_table(data,N_Up,N_Down,N,Average_Distance)
figure()
set(gcf,'name','Distance Matrix','NumberTitle','off','color','w','units','normalized','position',[0 0.1 1 0.5],'menubar','none','toolbar','figure')

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
        data_to_plot = data{slider_value};
        uitable('Data',data_to_plot,'units','normalized','position',[0.03 0 0.5 1],'FontSize',12);
        title([num2str(slider_value),'/',num2str(length(data))])
        
        subplot(1,2,2)
        ax = gca;cla(ax);
        imagesc(data_to_plot)
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on        
        colormap(hot)
        colorbar()
        xlabel('Steps','interpreter','latex','fontsize',18)
        ylabel('Steps','interpreter','latex','fontsize',18)
        axis equal
        xlim([0.5 size(data_to_plot,1)+0.5])
        ylim([0.5 size(data_to_plot,1)+0.5])
    end

figure()
subplot(1,2,1)
set(gcf,'name','Distance Matrix Altogether','NumberTitle','off','color','w','units','normalized','position',[0 0.1 1 0.5],'menubar','none','toolbar','figure')
uitable('Data',Average_Distance,'units','normalized','position',[0 0 0.5 1],'FontSize',12);
title('Total Distance')
subplot(1,2,2)
imagesc(Average_Distance)
set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
box on
colormap(hot)
colorbar()
xlabel('Steps','interpreter','latex','fontsize',18)
ylabel('Steps','interpreter','latex','fontsize',18)
title('Total Distance Average','interpreter','latex')
axis equal
xlim([0.5 size(Average_Distance,1)+0.5])
ylim([0.5 size(Average_Distance,1)+0.5])

% figure()
% [x,y,z] = meshgrid(1:size(matrix_added,1),1:size(matrix_added,1),1:length(data));
% hold on
% for i = 1:length(data)
% surf(x(:,:,i),y(:,:,i),z(:,:,i),data{i},'edgecolor','none')
% end
% xlim([1 size(matrix_added,1)])
% ylim([1 size(matrix_added,1)])
% zlim([1 length(data)])
% pbaspect([1 1 1])
% set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
% box on
% colormap(hot)
% xlabel('Steps','interpreter','latex','fontsize',18)
% ylabel('Steps','interpreter','latex','fontsize',18)
% zlabel('Trace','interpreter','latex','fontsize',18)
% view(50,20);

figure()
uitable('Data',N_Down,'units','normalized','position',[0 0 1 0.94],'FontSize',12);
title('Number of Traces Below and Equal the Distance Threshold')

figure()
uitable('Data',N_Up,'units','normalized','position',[0 0 1 0.94],'FontSize',12);
title('Number of Traces Above the Distance Threshold')

figure()
uitable('Data',N,'units','normalized','position',[0 0 1 0.94],'FontSize',12);
title('Number of Traces')
end