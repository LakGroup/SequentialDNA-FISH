function data = correct_z_drift(data)
for i = 1:length(data)
    wanted{i} = [data{i}(:,3),data{i}(:,5)];
end
wanted = vertcat(wanted{:});
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
mean_values = round(mean_values);
mean_values = diff(mean_values);
mean_values = cumsum(mean_values);
for i = 1:length(data)
    for j = 2:size(data{i},1)
        data{i}(j,3) = data{i}(j,3)-mean_values(data{i}(j,5)-1);
        if data{i}(j,8)~=0
            data{i}(j,8) = data{i}(j,8)-mean_values(data{i}(j,10)-1);
        end
    end
end
end