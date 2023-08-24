function data_ref = link_to_ref(data)
input_values = inputdlg({'XY Range Search:','Z Range Search:'},'',1,{'5','5'});
if ~isempty(input_values)
    xy_range_search = str2double(input_values{1});
    z_range_search = str2double(input_values{2});
    
    for i = 1:length(data)
        for j = 1:2
            data{i}.xyz{j}(:,5) = i;
        end
    end
    f = waitbar(0,'Linking Walks to Ref');
    for i = 1:length(data)
        data_ref{i}.link_to_ref_data = link_to_ref_inside(data{i}.xyz,xy_range_search,z_range_search);
        data_ref{i}.name = [data{i}.name,'_linked_to_ref'];
        data_ref{i}.image{1} = data{i}.image{2};
        data_ref{i}.image_one = data{i}.image{1};
        data_ref{i}.image_two = data{i}.image{2};
        waitbar(i/length(data),f,['Linking Walks to Ref...',num2str(i),'/',num2str(length(data))])
    end
    close(f)
else
    data_ref = [];
end
end

function data_ref = link_to_ref_inside(data,xy_range_search,z_range_search)
idx_xy = rangesearch(data{1}(:,1:2),data{2}(:,1:2),xy_range_search);
idx_z = rangesearch(data{1}(:,3),data{2}(:,3),z_range_search);

idx_intersection = cellfun(@intersect,idx_xy,idx_z,'UniformOutput',false);

temp  = idx_intersection{1};
if length(idx_intersection)>1
    for i = 2:length(idx_intersection)
        if ~isempty(idx_intersection{i})
            for n = 1:length(idx_intersection{i})
                if any(temp==idx_intersection{i}(n))
                    idx_intersection{i}(n) = 0;
                else
                    temp(end+1) = idx_intersection{i}(n);
                end
            end
        end
    end
end

for i = 1:length(idx_intersection)
    if ~isempty(idx_intersection{i})
        idx_intersection{i} = idx_intersection{i}(1);
    end
end

for i = 1:length(idx_intersection)
    if idx_intersection{i} == 0
        idx_intersection{i} = [];
    end
end

colocalized_data_two_idx = find(~cellfun(@isempty,idx_intersection));

colocalized_data_one_idx = idx_intersection(~cellfun(@isempty,idx_intersection));
colocalized_data_one_idx = cell2mat(colocalized_data_one_idx);
not_colocalized_data_one_idx = setxor(1:size(data{1},1),colocalized_data_one_idx);

data_ref_not_colocalized = data{1}(not_colocalized_data_one_idx,:);
data_ref_not_colocalized(:,6:10) = repmat([0 0 0 0 0],[size(data_ref_not_colocalized,1),1]); 

data_ref_colocalized = [data{1}(colocalized_data_one_idx,:) data{2}(int64(colocalized_data_two_idx),:)];

data_ref = [data_ref_not_colocalized;data_ref_colocalized];
data_ref = sortrows(data_ref,3);
end