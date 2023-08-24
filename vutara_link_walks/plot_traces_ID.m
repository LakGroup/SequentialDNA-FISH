function plot_traces_ID(data,IDs)
figure();
set(gcf,'name','Selected Traces','NumberTitle','off','color','w','units','normalized','position',[0.3 0.2 0.4 0.5],'menubar','none','toolbar','figure')

data = data(IDs);

plot_inside()

    function plot_inside()
        for j = 1:size(data,1)
            data_to_plot = data{j};
            plot(data_to_plot(:,1),data_to_plot(:,2),'-o','color',[0 0 0],'MarkerFaceColor','black')
            hold on
        
            bluedata = data_to_plot((data_to_plot(:,6)~=0 & data_to_plot(:,7)~=0 & data_to_plot(:,8)~=0),:);
            for i = 1:size(bluedata,1)
                plot([bluedata(i,1) bluedata(i,6)],[bluedata(i,2) bluedata(i,7)],'color','b')
            end
            text(max(data_to_plot(:,1))+5,max(data_to_plot(:,2)),[num2str(IDs(j))],'Color','k')
        end
        axis square
        axis([1 2048 1 2048])
        set(gca,'YDir','reverse')
    end
end