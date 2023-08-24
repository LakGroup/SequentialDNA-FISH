function tracks = find_z(tracks,min_intensity)
for i = 1:length(tracks)
    [val_max,I_max] = max(tracks{i}(:,4));
    x = tracks{i}(I_max,1);
    y = tracks{i}(I_max,2);
    z = tracks{i}(I_max,3);
    tracks{i} = zeros(1,4);
    tracks{i} = [x y z val_max];
end
tracks = vertcat(tracks{:});
tracks = sortrows(tracks,3);

I = tracks(:,4)>=min_intensity;
tracks = tracks(I,:);
end