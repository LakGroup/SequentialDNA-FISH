function vutara_link_walks()
figure('CloseRequestFcn',@my_closereq);
set(gcf,'name','Vutara Link Walks to Ref','NumberTitle','off','color','w','units','normalized','position',[0.1 0.15 0.8 0.7],'menubar','none','toolbar','figure')

uicontrol('style','text','string','Reference Data','units','normalized','position',[0.19 0.04 0.2 0.1],'Backgroundcolor','w','fontsize',24)
uicontrol('style','text','string','Walk Data','units','normalized','position',[0.64 0.04 0.2 0.1],'Backgroundcolor','w','fontsize',24)

uicontrol('style','text','string','Number of Traces:','units','normalized','position',[0.05 0 0.2 0.05],'Backgroundcolor','w','fontsize',14)
number_of_traces = uicontrol('style','text','string','0','units','normalized','position',[0.25 0 0.1 0.05],'Backgroundcolor','w','fontsize',14);

    function my_closereq(~,~)
        selection = questdlg('Close the Software?','Close Software?','Yes','No','Yes');
        switch selection
            case 'Yes'
                delete(gcf)
            case 'No'
                return
        end
    end

xx = [0 1];
yy = [0 1];

image_slider_value = 1;
image_slider = uicontrol('style','slider','units','normalized','position',[0,0,0.03,1],'value',image_slider_value,'min',1,'max',2,'sliderstep',[0 0],'Callback',@ref_image_slider_callback);


uicontrol('style','pushbutton','string','Load Ref Data','units','normalized','position',[0.19 0.94 0.2 0.05,],'Backgroundcolor','w','fontsize',16,'Callback',@load_ref_data)
uicontrol('style','pushbutton','string','Load Walk Data','units','normalized','position',[0.64 0.94 0.2 0.05,],'Backgroundcolor','w','fontsize',16,'Callback',@load_walk_data)


analysis_menu = uimenu('Text','Analysis');   
uimenu(analysis_menu,'Text','Link Walks to Reference Data','Callback',{@link_walks_to_reference_data});
uimenu(analysis_menu,'Text','Link Reference Data to Find Traces','Callback',{@link_ref_data});
uimenu(analysis_menu,'Text','Trace Length Histogram','Callback',{@trace_length_histogram});
uimenu(analysis_menu,'Text','Filter Traces (Minimum Walk Length)','Callback',{@filter_traces_minimum_length_callback});
uimenu(analysis_menu,'Text','Filter Traces (Colocalization Percentage)','Callback',{@filter_traces_colocalization_percentage_callback});
uimenu(analysis_menu,'Text','Correct Z Drift','Callback',{@correct_z_drift_callback});
uimenu(analysis_menu,'Text','Find Final Traces','Callback',{@find_final_traces_callback});

plot_menu = uimenu('Text','Plot');
uimenu(plot_menu,'Text','Plot Tracess','Callback',{@plot_traces_callback});
uimenu(plot_menu,'Text','Plot Traces_ID','Callback',{@plot_traces_ID_callback});
uimenu(plot_menu,'Text','Traces Table','Callback',{@plot_traces_table_callback});
uimenu(plot_menu,'Text','Plot Z Drift','Callback',{@plot_z_drift_callback});
uimenu(plot_menu,'Text','Plot Final Traces','Callback',{@plot_final_traces_callback});
uimenu(plot_menu,'Text','Final Traces Table','Callback',{@plot_final_traces_table_callback});
%uimenu(plot_menu,'Text','Plot Distance Matrix','Callback',{@plot_distance_matrix_callback});
uimenu(plot_menu,'Text','Distance Matrix Table','Callback',{@plot_distance_matrix_table_callback});


data_menu = uimenu('Text','Trace Data');
uimenu(data_menu,'Text','Save Traces','Callback',{@save_traces});
uimenu(data_menu,'Text','Load Traces','Callback',{@load_traces});
uimenu(data_menu,'Text','Save Final Traces','Callback',{@save_final_traces});
uimenu(data_menu,'Text','Load Final Traces','Callback',{@load_final_traces});
uimenu(data_menu,'Text','Save Distance Matrix','Callback',{@save_distance_matrix});

ref_data = [];   
walk_data = [];  
walk_data_linked_to_ref = [];
traces = [];
final_traces = [];

    function ref_image_slider_callback(~,~,~)
        image_slider_value = round(image_slider.Value);
        xx = xlim;
        yy = ylim;
        plot_();
    end

    function load_ref_data(~,~,~)
        [file_name,path] = uigetfile('*.mat','Select Session','MultiSelect','off');
        if file_name
            ref_data = [];
            walk_data_linked_to_ref = [];
            traces = [];
            final_traces = [];
            try
                ref_data = load(fullfile(path,file_name));
                ref_data = ref_data.data_to_save;
            catch
                ref_data = [];
            end
        end
        if ~isempty(ref_data)
            if length(ref_data)>1
                image_slider.Max = length(ref_data);
                image_slider.Min = 1;
                image_slider.Value = 1;
                image_slider.SliderStep = [1/(length(ref_data)-1) 1/(length(ref_data)-1)];
            else
                image_slider.Max = 2;
                image_slider.Min = 1;
                image_slider.Value = 1;
                image_slider.SliderStep = [0 0];
            end
            xx = ([1 size(ref_data{1}.image_xy,2)]);
            yy = ([1 size(ref_data{1}.image_xy,1)]);
        end
        plot_()
    end

    function load_walk_data(~,~,~)
        if ~isempty(ref_data)
            [file_name,path] = uigetfile('*.mat','Select Session','MultiSelect','off');
            if file_name
                walk_data =[];
                walk_data_linked_to_ref = [];
                traces = [];
                final_traces = [];
                try
                    walk_data = load(fullfile(path,file_name));
                    walk_data = walk_data.data_to_save;
                catch
                    walk_data = [];
                end
                if length(walk_data) ~= length(ref_data)
                    walk_data = [];
                    msgbox('Number of Walk Data and Ref Data are not Equal')
                else
                    plot_()
                end
            end
        else
            msgbox('First Load Reference Data')
        end        
    end   

    function link_walks_to_reference_data(~,~,~)
        if ~isempty(ref_data) && ~isempty(walk_data)
            if length(ref_data)==length(walk_data)
                traces = [];
                final_traces = [];
                walk_data_linked_to_ref = [];
                for i = 1:length(ref_data)
                    data_to_send{i}.xyz = {ref_data{i}.xyz,walk_data{i}.xyz};
                    data_to_send{i}.image = {ref_data{i}.image_xy,walk_data{i}.image_xy};
                    data_to_send{i}.name = ref_data{i}.name;
                end
                
                wanted = link_to_ref(data_to_send);
                for i = 1:length(wanted)
                    walk_data_linked_to_ref{i} = wanted{i}.link_to_ref_data;
                end
            else
                msgbox('Number of Walk Data Should be Equal to the Number of Ref Data')
            end
            plot_()
        end
    end

    function link_ref_data(~,~,~)        
        if ~isempty(walk_data_linked_to_ref)
            traces = [];
            final_traces = [];
            traces = link_ref(walk_data_linked_to_ref);
        end
        plot_()
    end

    function trace_length_histogram(~,~,~)
        if ~isempty(traces)
            length_walks = cellfun(@(x) size(x,1),traces);
            figure()
            hist(length_walks,10);
        end
    end

    function filter_traces_minimum_length_callback(~,~,~)
        if ~isempty(traces)
            traces = filter_traces_length(traces);
        end
        plot_()
    end

    function filter_traces_colocalization_percentage_callback(~,~,~)
        if ~isempty(traces)
            traces = filter_traces_colocalization_percentage(traces);
        end
        plot_()
    end

    function correct_z_drift_callback(~,~,~)
        if ~isempty(traces)
            traces = correct_z_drift(traces);
        end
    end

    function find_final_traces_callback(~,~,~)
        if ~isempty(traces)            
            final_traces = find_final_traces(traces);            
        end
    end

    function plot_traces_callback(~,~,~)
        if ~isempty(traces)
            plot_traces(traces)
        end
    end

    function plot_traces_ID_callback(~,~,~)
        [file_name_ID,path_ID] = uigetfile('*.mat','Select ID file','MultiSelect','off');
        if ~isempty(traces)
            try
                IDs = load(fullfile(path_ID,file_name_ID));
                IDs = IDs.IDs;
            catch
                IDs = (1:size(traces,1));
            end
            plot_traces_ID(traces,IDs)
        end
    end

    function plot_traces_table_callback(~,~,~)
        if ~isempty(traces)
            plot_traces_table(traces)
        end
    end

    function plot_z_drift_callback(~,~,~)
        if ~isempty(traces)
            plot_z_drift(traces)
        end
    end

    function plot_final_traces_callback(~,~,~)
        if ~isempty(final_traces)
            plot_final_traces(final_traces)
        end
    end

    function plot_final_traces_table_callback(~,~,~)
        if ~isempty(final_traces)
            plot_final_traces_table(final_traces)
        end
    end

%     function plot_distance_matrix_callback(~,~,~)
%         if ~isempty(final_traces)
%             input_values = inputdlg({'Pixel Size (nm):','Z Step Size (nm):','Distance Cutoff (nm):'},'',1,{'180','200','200'});
%             if ~isempty(input_values)
%                 distance_cutoff = str2double(input_values{3});
%                 pixel_value = str2double(input_values{1});
%                 z_step = str2double(input_values{2});                
%                 
%                 distance_matrix = cell(length(final_traces),1);                
%                 for i = 1:length(final_traces)                   
%                     first = pdist2(final_traces{i}(:,1:2),final_traces{i}(:,1:2));
%                     first = first*pixel_value;                    
%                     second = pdist2(final_traces{i}(:,3),final_traces{i}(:,3));
%                     second = second*z_step;  
%                     distance_matrix{i} = sqrt(first.^2+second.^2);                                    
%                 end
%                 plot_distance_matrix(distance_matrix,distance_cutoff)
%             end
%         end
%     end

    function plot_distance_matrix_table_callback(~,~,~)
        if ~isempty(final_traces)
            input_values = inputdlg({'Pixel Size (nm):','Z Step Size (nm):','Cutoff Distance (nm):'},'',1,{'180','200','200'});
            if ~isempty(input_values)
                pixel_value = str2double(input_values{1});
                z_step = str2double(input_values{2});
                cutoff_distance = str2double(input_values{3});
                [Distances,N_Up,N_Down,N,Average_Distance] = calculate_distance_information(final_traces,pixel_value,z_step,cutoff_distance);
                
                plot_distance_matrix_table(Distances,N_Up,N_Down,N,Average_Distance)
            end
        end
    end

    function save_traces(~,~,~)
        if ~isempty(traces)
            [file,path] = uiputfile('*.mat');
            if file
                save(fullfile(path,file),'traces','walk_data_linked_to_ref');
            end
        end
    end

    function load_traces(~,~,~)
        [file_name,path] = uigetfile('*.mat','Select Session','MultiSelect','off');
        if file_name
            data = load(fullfile(path,file_name));
            traces = data.traces;
            walk_data_linked_to_ref = data.walk_data_linked_to_ref;
        end
        plot_()
    end

    function save_final_traces(~,~,~)
        if ~isempty(final_traces)
            [file,path] = uiputfile('*.mat');
            if file
                save(fullfile(path,file),'final_traces');
            end
        end
    end

    function load_final_traces(~,~,~)
        [file_name,path] = uigetfile('*.mat','Select Session','MultiSelect','off');
        if file_name
            data = load(fullfile(path,file_name));
            final_traces = data.final_traces;
        end
        plot_()
    end

    function save_distance_matrix(~,~,~)
        if ~isempty(final_traces)
            input_values = inputdlg({'Pixel Size (nm):','Z Step Size (nm):','Cutoff Distance (nm):'},'',1,{'180','200','200'});
            if ~isempty(input_values)
                pixel_value = str2double(input_values{1});
                z_step = str2double(input_values{2});
                cutoff_distance = str2double(input_values{3});
                [Distances,N_Up,N_Down,N,Average_Distance] = calculate_distance_information(final_traces,pixel_value,z_step,cutoff_distance);
                [file,path] = uiputfile('*.mat');
                if file
                    save(fullfile(path,file),'N_Up','N_Down','N','Average_Distance','Distances');
                end
            end
        end
    end

    function plot_()
        if isempty(walk_data_linked_to_ref)
            if ~isempty(ref_data)
                subplot(1,2,1)
                ax = gca;cla(ax);
                image = ref_data{image_slider_value}.image_xy;
                imagesc(image)
                colormap(gray)
                hold on
                xyz = ref_data{image_slider_value}.xyz;
                z = num2cell(xyz(:,3));
                textscatter(xyz(:,1),xyz(:,2),z,'TextDensityPercentage',100,'ColorData',[1 0 0 ]);
                title({'',[[num2str(image_slider_value),'/',num2str(length(ref_data)),'--'],regexprep(ref_data{image_slider_value}.name,'_',' ')],['Number of Spots = ',num2str(size(xyz,1))]},'interpreter','latex','fontsize',18)
                xlim(xx)
                ylim(yy)
                axis off
                pbaspect([1 1 1])
            end
        else
            subplot(1,2,1)
            ax = gca;cla(ax);
            image = ref_data{image_slider_value}.image_xy;
            imagesc(image)
            colormap(gray)
            hold on
            wanted = walk_data_linked_to_ref{image_slider_value};
            I = find(wanted(:,6) == 0);
            J = find(wanted(:,7) == 0);
            idx = intersect(I,J);
            not_idx = setdiff(1:size(wanted,1),idx);
            
            xyz_red = wanted(idx,:);
            z_red = num2cell(xyz_red(:,3));
            
            xyz_green = wanted(not_idx,:);
            z_green = num2cell(xyz_green(:,3));
            
            textscatter(xyz_green(:,1),xyz_green(:,2),z_green,'TextDensityPercentage',100,'ColorData',[0 1 0 ]);
            textscatter(xyz_red(:,1),xyz_red(:,2),z_red,'TextDensityPercentage',100,'ColorData',[1 0 0 ]);
            
            title({'','',[[num2str(image_slider_value),'/',num2str(length(ref_data)),'--'],regexprep(ref_data{image_slider_value}.name,'_',' ')],[['Number of Spots = ',num2str(size(wanted,1))],'--',['Number of Linked Spots = ',num2str(length(not_idx))]]},'interpreter','latex')
            xlim(xx)
            ylim(yy)
            axis off
            pbaspect([1 1 1])
        end
        
        if isempty(walk_data_linked_to_ref)
            if ~isempty(walk_data)
                subplot(1,2,2)
                ax = gca;cla(ax);
                image = walk_data{image_slider_value}.image_xy;
                imagesc(image)
                colormap(gray)
                hold on
                xyz = walk_data{image_slider_value}.xyz;
                z = num2cell(xyz(:,3));
                textscatter(xyz(:,1),xyz(:,2),z,'TextDensityPercentage',100,'ColorData',[1 0 0 ]);
                title({'','',[[num2str(image_slider_value),'/',num2str(length(walk_data)),'--'],regexprep(walk_data{image_slider_value}.name,'_',' ')],['Number of Spots = ',num2str(size(xyz,1))]},'interpreter','latex','fontsize',18)
                xlim(xx)
                ylim(yy)
                axis off
                pbaspect([1 1 1])
            end
        else
            subplot(1,2,2)
            ax = gca;cla(ax);
            image = walk_data{image_slider_value}.image_xy;
            imagesc(image)
            colormap(gray)
            hold on
            xyz = walk_data{image_slider_value}.xyz;
            z = num2cell(xyz(:,3));
            textscatter(xyz(:,1),xyz(:,2),z,'TextDensityPercentage',100,'ColorData',[1 0 0 ]);
            z_green = num2cell(xyz_green(:,8));
            textscatter(xyz_green(:,6),xyz_green(:,7),z_green,'TextDensityPercentage',100,'ColorData',[0 1 0 ]);
            title({'','',[[num2str(image_slider_value),'/',num2str(length(walk_data)),'--'],regexprep(walk_data{image_slider_value}.name,'_',' ')],['Number of Spots = ',num2str(size(xyz,1))]},'interpreter','latex')
            xlim(xx)
            ylim(yy)
            axis off
            pbaspect([1 1 1])
        end
        
        if ~isempty(traces)
            number_of_traces.String = num2str(length(traces));
        end
    end
end