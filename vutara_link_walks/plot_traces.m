function plot_traces(data)
figure();
set(gcf,'name','Traces','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.5],'menubar','none','toolbar','figure')

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
        
        dd = data;
        data_to_plot = data{slider_value};        
        ax = gca;cla(ax);
        hold on
        plot3(data_to_plot(:,1),data_to_plot(:,2),data_to_plot(:,3),'color','k')
        axis off
        scatter3(data_to_plot(:,1),data_to_plot(:,2),data_to_plot(:,3),10,'r','filled')
        
        for i = 1:size(data_to_plot,1)
            if data_to_plot(i,6)~=0 && data_to_plot(i,7)~=0 && data_to_plot(i,8)~=0
                plot3([data_to_plot(i,1) data_to_plot(i,6)],[data_to_plot(i,2) data_to_plot(i,7)],[data_to_plot(i,3) data_to_plot(i,8)],'color','b')
            end
        end
        title([num2str(slider_value),'/',num2str(length(data))])
        axis([1 2048 1 2048])
    end
plot_inside()

% number_of_walks = 4;
% figure()
% set(gcf,'color','w','units','normalized','position',[0.2 0.3 0.7 0.5])
% walks_to_plot = vertcat(walks{:});
% color_map = colormap(hsv);
% color_map = color_map(1:floor(256/number_of_walks):end,:);
% hold on
% for k = 1:length(walks)
%     plot3(walks{k}(:,1),walks{k}(:,2),walks{k}(:,3),'k')
% end
% scatter3(walks_to_plot(:,1),walks_to_plot(:,2),walks_to_plot(:,3),10,color_map(walks_to_plot(:,5),:),'filled')
% box on
% set(gca,'color','w','boxstyle','full')
% view(30,30)
% pbaspect([1 1 1])
% 
% figure()
% set(gcf,'color','w','units','normalized','position',[0.2 0.3 0.7 0.5])
% for k = 1:number_of_walks
%     names{k} = ['walk ',num2str(k)];
% end
% walks_statistics = cellfun(@(x) x(:,5),walks,'UniformOutput',false);
% walks_statistics = vertcat(walks_statistics{:});
% uv = unique(walks_statistics);
% n  = hist(walks_statistics,uv);
% b = bar(categorical(names),n,'FaceColor','flat');
% for k = 1:number_of_walks
%     b.CData(k,:) = color_map(k,:);
% end
end