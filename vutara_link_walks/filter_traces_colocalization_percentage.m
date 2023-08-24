function data = filter_traces_colocalization_percentage(data)
input_values = inputdlg({'Minimum Colocalization Percentage:'},'',1,{'70'});
if ~isempty(input_values)
    min_coloc = str2double(input_values{1});
    
    for i = 1:length(data)
        I = find(data{i}(:,6) ~= 0);
        J = find(data{i}(:,7) ~= 0);
        idx = intersect(I,J);
        colocalized_percentage(i) = length(idx)/size(data{i},1);
        clear I J idx
    end
    
    I = colocalized_percentage>=min_coloc/100;
    data = data(I);
end
end