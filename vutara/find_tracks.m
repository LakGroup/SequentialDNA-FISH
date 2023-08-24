function tracks = find_tracks(pstruct,image,search_radius,track_length,gaps,name,show_tracks)
tracks = find_tracks_inside(pstruct,search_radius,gaps);

if ~isempty(tracks)
    val_max = cellfun(@(x) size(x,1),tracks);
    val_max = val_max>=track_length;
    tracks = tracks(val_max);
end
if show_tracks == 1
    plot_tracks(image,tracks,name)
end
end

function tracks = find_tracks_inside(pstruct,search_radius,gaps)
for i = 1:length(pstruct)
    if ~isempty(pstruct{i})
        all_spots{i} = [pstruct{i}.x' pstruct{i}.y' i*ones(length(pstruct{i}.x),1) pstruct{i}.A'];
    else
        all_spots{i} = [];
    end
end
all_spots = vertcat(all_spots{:});

xy_search = rangesearch(all_spots(:,1:2),all_spots(:,1:2),search_radius);
tracks = {};
logical_var = true(size(all_spots,1),1);
i = 0;
f = waitbar(0,'Finding Tracks');
while true
    if all(logical_var==0)
        break
    else
        i = i+1;
        
        to_search = xy_search{i};
        to_search = to_search(logical_var(to_search));     
        if ~isempty(to_search)
            wanted = all_spots(to_search,:);
            [wanted,sorted_idx] = sortrows(wanted,3);
            
            I = check_for_wanted(wanted,gaps);
            I = sorted_idx(I);
            idx = to_search(I);
            
            id = logical_var(idx);
            tracks{end+1,1} = all_spots(idx(id),:);
            logical_var(idx) = 0;
        end        
    end
end
close(f)
tracks = tracks(~cellfun('isempty',tracks));
end

function idx = check_for_wanted(wanted,gaps)
start = wanted(1,3);
idx = 1;
if size(wanted,1)>1
    for i = 2:size(wanted,1)
        if wanted(i,3) <= start+gaps+1
            idx(end+1) = i;
        else
            break
        end
        start = wanted(i,3);
    end
end
end