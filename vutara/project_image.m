function projected_image = project_image(image)
projected_image = zeros(size(image{1},1),size(image{1},2));
for k = 1:length(image)
    projected_image = projected_image+image{k};
end
projected_image = projected_image-min(projected_image(:));
projected_image = projected_image/max(projected_image(:));
end