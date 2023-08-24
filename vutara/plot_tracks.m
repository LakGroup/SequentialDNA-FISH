function plot_tracks(image,tracks,name)
[x,y] = meshgrid(1:size(image{1},2),1:size(image{1},1));
z = x-x;
figure()
set(gcf,'color','w')
hold on
for i = 1:length(tracks)
    plot3(tracks{i}(:,1),tracks{i}(:,2),tracks{i}(:,3))
end
surf(x,y,z+1,image{1},'EdgeColor','none','FaceAlpha',0.8)
surf(x,y,z+length(image),image{length(image)},'EdgeColor','none','FaceAlpha',0.8)

for i = 1:length(image)
    image_v_1(:,i) = image{i}(:,1);
    image_v_2(:,i) = image{i}(:,end);
    image_h(:,i) = image{i}(end,:)';
end
[y,z] = meshgrid(1:length(image),1:size(image_v_1,1));
surf(y-y+1,z,y,image_v_1,'EdgeColor','none','FaceAlpha',0.5)
surf(y-y+size(image_v_1,1),z,y,image_v_2,'EdgeColor','none','FaceAlpha',0.5)

[y,z] = meshgrid(1:length(image),1:size(image_h,1));
surf(z,y-y+size(image_v_1,1),y,image_h,'EdgeColor','none','FaceAlpha',0.5)

colormap(gray)
all_tracks = vertcat(tracks{:});
scatter3(all_tracks(:,1),all_tracks(:,2),all_tracks(:,3),5,'k','filled')
title({'',['Number of Tracks = ',num2str(length(tracks))],regexprep(name,'_',' ')},'interpreter','latex','fontsize',14)
box on
set(gca,'color','w','boxstyle','full')
view(30,30)
xlim([1 size(image{1},2)])
ylim([1 size(image{1},1)])
pbaspect([1 1 1])
end