function wanted = find_final_traces(data)
input_values = inputdlg({'Number of Steps:'},'',1,{'10'});
if ~isempty(input_values)
    number_of_steps = str2double(input_values{1});
    
    for i = 1:length(data)
        for j = 1:size(data{i},1)
            if data{i}(j,8)==0
                final{i}(j,:) = [0 0 0 0];
            else
                diff = data{i}(j,1:3)-data{i}(1,1:3);
                data{i}(j,1:3) = data{i}(j,1:3)-diff;
                final{i}(j,1:4) = [data{i}(j,6:8)-diff  data{i}(j,5)];               
            end
        end
    end
    
    for i = 1:length(final)
        wanted{i} = zeros(number_of_steps,3);
        for j = 1:size(final{i},1)
            if final{i}(j,4)~=0
                wanted{i}(final{i}(j,4),:) = final{i}(j,1:3);
            end
        end
    end
    
    for i = 1:length(wanted)
        for j = 1:size(wanted{i},1)
            if wanted{i}(j,1:3)==0
                wanted{i}(j,:) = [NaN NaN NaN];
            end
        end
    end
else
    wanted = [];
end
end