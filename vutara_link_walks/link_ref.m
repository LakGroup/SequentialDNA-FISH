function walks = link_ref(data)
input_values = inputdlg({'XY Range Search:','Z Range Search:','Gaps Allowed:'},'',1,{'5','5','2'});
if ~isempty(input_values)
    xy_range_search = str2double(input_values{1});
    z_range_search = str2double(input_values{2});    
    gaps = str2double(input_values{3});  
    
    all_spots = vertcat(data{:});
    xy_search = rangesearch(all_spots(:,1:2),all_spots(:,1:2),xy_range_search);
    walks = {};
    logical_var = true(size(all_spots,1),1);
    i = 0;
    f = waitbar(0,'Linking Reference Data');
    while true
        if all(logical_var==0)
            break
        else
            i = i +1;
           
            to_search = xy_search{i};
            to_search = to_search(logical_var(to_search));            
            if ~isempty(to_search)
                wanted = all_spots(to_search,1:5);
                [wanted,sorted_idx] = sortrows(wanted,5);
                
                I = check_for_wanted(wanted,z_range_search,gaps);
                I = sorted_idx(I);
                idx = to_search(I);
                
                id = logical_var(idx);
                walks{end+1,1} = all_spots(idx(id),:);
                logical_var(idx) = 0;
            end
        end
    end
    close(f)
    walks = walks(~cellfun('isempty',walks));
else
    walks = [];
end
end

function idx = check_for_wanted(wanted,z_range_search,gap)
start = wanted(1,3);
walk = wanted(1,5);
idx = 1;
if size(wanted,1)>1
    for i = 2:size(wanted,1)
        if abs(wanted(i,3)-start)<=z_range_search && wanted(i,5)>walk && wanted(i,5)<=walk+gap+1
            idx(end+1) = i;
        else
            break
        end
        start = wanted(i,3);  
        walk = wanted(i,5);
    end
end
end

% function walks = link_walks(data)
% input_values = inputdlg({'XY Range Search:','Z Range Search:'},'',1,{'5','3'});
% if ~isempty(input_values)
%     xy_range_search = str2double(input_values{1});
%     z_range_search = str2double(input_values{2});    
%     
%     all_spots = vertcat(data{:});
%     walks = {};
%     start_bar = size(all_spots,1);
%     f = waitbar(0,'Linking Reference Data');
%     while ~isempty(all_spots)
%         idx_xy = rangesearch(all_spots(1,1:2),all_spots(:,1:2),xy_range_search);
%         idx_xy = find(~cellfun(@isempty,idx_xy));
%         wanted = all_spots(idx_xy,1:5);        
%         I = check_for_wanted(wanted,z_range_search);           
%         walks{end+1,1} = all_spots(idx_xy(I),:);
%         all_spots(idx_xy(I),:) = [];
%         clear idx wanted I
%         waitbar(1-size(all_spots,1)/start_bar,f,'Linking Reference Data');
%     end
%     close(f) 
% else
%     walks = [];
% end
% end
% 
% function idx = check_for_wanted(wanted,z_range_search)
% start = wanted(1,3);
% walk = wanted(1,5);
% idx = 1;
% if size(wanted,1)>1
%     for i = 2:size(wanted,1)
%         if abs(wanted(i,3)-start)<=z_range_search && wanted(i,5)==walk+1
%             idx(end+1) = i;
%         else
%             break
%         end
%         start = wanted(i,3);
%         walk = wanted(i,5);
%     end
% end
% end