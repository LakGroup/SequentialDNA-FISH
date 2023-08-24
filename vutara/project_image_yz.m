function projected_image = project_image_yz(image)
projected_image = zeros(length(image),size(image{1},1));
for k = 1:length(image)
    projected_image(k,:) = sum(image{k},2)';
    projected_image(k,:) = projected_image(k,:)-min(projected_image(k,:));
    projected_image(k,:) = projected_image(k,:)/max(projected_image(k,:));
end
projected_image = projected_image-min(projected_image(:));
projected_image = projected_image/max(projected_image(:));
end