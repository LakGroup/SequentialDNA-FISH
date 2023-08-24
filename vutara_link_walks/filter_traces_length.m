function data = filter_traces_length(data)
input_values = inputdlg({'Minimum Walk Length:'},'',1,{'10'});
if ~isempty(input_values)
    min_walk_length = str2double(input_values{1});    
    val_max = cellfun(@(x) size(x,1),data);
    val_max = val_max>=min_walk_length;
    data = data(val_max);
end
end