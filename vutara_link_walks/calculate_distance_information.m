function [Distances,N_Up,N_Down,N,Average_Distance] = calculate_distance_information(final_traces,pixel_value,z_step,cutoff_distance)
Distances = cell(length(final_traces),1);
for i = 1:length(final_traces)
    first = pdist2(final_traces{i}(:,1:2),final_traces{i}(:,1:2));
    first = first*pixel_value;
    second = pdist2(final_traces{i}(:,3),final_traces{i}(:,3));
    second = second*z_step;
    Distances{i} = sqrt(first.^2+second.^2);
end

matrix_added = zeros(size(Distances{1}));
for i = 1:length(Distances)
    matrix_added(:,:,i) = Distances{i};
end
for i = 1:size(matrix_added,1)
    for j = i+1:size(matrix_added,2)
        temp = matrix_added(i,j,:);
        temp = permute(temp,[3,1,2]);
        N_Up(i,j) = length(temp(temp>cutoff_distance));
        N_Down(i,j) = length(temp(temp<=cutoff_distance));
        N(i,j) = length(find(~isnan(temp)));
        if N(i,j)==0
            temp = 0;
        else
            temp(isnan(temp)) = [];
            temp = sum(temp)/(N(i,j));
        end
        Average_Distance(i,j) = temp;
        clear temp
    end    
end
end