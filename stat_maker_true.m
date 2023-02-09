clear;
%% run parameters

participant_pool = 5:16;
classifier_funcs = {@fitcsvm, @fitcknn, @fitcdiscr};
feature_nums = {30};
randomization_flags = {0};
feature_types = {'bandpower', 'pentropy', 'variance', 'rms'};

results_sub_folder = 'no_ica'; 

run_params_set = [];
for j = 1:length(classifier_funcs)
    for k = 1:length(feature_nums)
        for l = 1:length(randomization_flags)
            for m = 1:length(feature_types)
                run_params.classifier = classifier_funcs{j};
                run_params.feature_num = feature_nums{k};
                run_params.randomization_flag = randomization_flags{l};
                run_params.feature_type = feature_types{m};
                run_params_set = [run_params_set run_params];
            end
        end
    end
end


for i = 1:length(run_params_set)
    col = 3 + 9*floor((i-1)/4);
    row = 3 + 9*mod(i-1,4);


    classifier_func = run_params_set(i).classifier;
    feature_num = run_params_set(i).feature_num;
    randomization_flag = run_params_set(i).randomization_flag;
    feature_type = run_params_set(i).feature_type;

    classifier_str = func2str(classifier_func);
    classifier_str = classifier_str(5:end);

    if randomization_flag == 0 
        randomization_str = "s";
    else
        randomization_str = "r";
    end

    stats_array = [];
    for dur_str = ["15s", "60s"]
        file_name = char(sprintf("%s %s %i feats", randomization_str, dur_str, feature_num));
        gt_file_name = char(sprintf("%s %s %i feats", randomization_str, '5s', feature_num));
                
        gt_hs = [];
        gt_ls = [];
        kfold_hs = [];
        kfold_ls = [];
        block_hs = [];
        block_ls = [];
        for s = participant_pool
            gt_mat_file = ['results/participant/', results_sub_folder, char(sprintf("/%i/%s/%s/", s, feature_type, classifier_str)), gt_file_name, '.mat'];
            mat_file = ['results/participant/', results_sub_folder, char(sprintf("/%i/%s/%s/", s, feature_type, classifier_str)), file_name, '.mat'];
    
            gt_temp = load(gt_mat_file).kfold.rn.Accuracy('mean');
            gt_hs = [gt_hs; gt_temp];
            gt_temp = load(gt_mat_file).kfold.ln.Accuracy('mean');
            gt_ls = [gt_ls; gt_temp];
    
            kfold_temp = load(mat_file).kfold.rn.Accuracy('mean');
            kfold_hs = [kfold_hs; kfold_temp];
            kfold_temp = load(mat_file).kfold.ln.Accuracy('mean');
            kfold_ls = [kfold_ls; kfold_temp];
    
            block_temp = load(mat_file).block.rn.Accuracy('mean');
            block_hs = [block_hs; block_temp];
            block_temp = load(mat_file).block.ln.Accuracy('mean');
            block_ls = [block_ls; block_temp];
        end
    
        [h_kh, p_kh] = ttest(gt_hs, kfold_hs, 'Alpha', 0.05);
        [h_kl, p_kl] = ttest(gt_ls, kfold_ls, 'Alpha', 0.05);
        
        [h_bh, p_bh] = ttest(gt_hs, block_hs, 'Alpha', 0.05);
        [h_bl, p_bl] = ttest(gt_ls, block_ls, 'Alpha', 0.05);
    
        stats_array_temp = [p_kh, h_kh;
                            p_bh, h_bh;
                            p_kl, h_kl;
                            p_bl, h_bl];
        stats_array = [stats_array, stats_array_temp];
    end

    excel_name = ['results/statistical_analysis/', 'stats','.xlsx'];
    stats_table_writer(stats_array, col, row, feature_type, classifier_str, excel_name);

end



%%
function xlcol_addr=num2xlcol(col_num)
% col_num - positive integer greater than zero
    n=1;
    while col_num>26*(26^n-1)/25
        n=n+1;
    end
    base_26=zeros(1,n);
    tmp_var=-1+col_num-26*(26^(n-1)-1)/25;
    for k=1:n
        divisor=26^(n-k);
        remainder=mod(tmp_var,divisor);
        base_26(k)=65+(tmp_var-remainder)/divisor;
        tmp_var=remainder;
    end
    xlcol_addr=char(base_26); % Character vector of xlcol address
end

function xlcol_num=xlcol2num(xlcol_addr)
% xlcol_addr - upper case character
    if ischar(xlcol_addr) && ~any(~isstrprop(xlcol_addr,"upper"))
        xlcol_num=0;
        n=length(xlcol_addr);
        for k=1:n
            xlcol_num=xlcol_num+(double(xlcol_addr(k)-64))*26^(n-k);
        end
    else
        error('not a valid character')
    end
end

function addr = change_excel_addr(start_col, start_row, col_change, row_change)
    arguments
        start_col int32
        start_row int32
        col_change int32
        row_change int32
    end
    end_row = start_row + row_change;
    end_col = start_col + col_change;
    end_col = num2xlcol(end_col);
    addr = [end_col char(int2str(end_row))];
end


function stats_table_writer(stats_arr, cell_col, cell_row, col_name, row_name, file_name)
arguments
    stats_arr
    cell_col int32
    cell_row int32
    col_name string
    row_name string
    file_name char
end
    starting_cell = change_excel_addr(cell_col, cell_row, 0, 0);
    col_names = ["p", "sig?", "p ", "sig? "];
    row_names = ["kfold/gt", "block/gt", "kfold/gt.", "block/gt."];
    stats_tbl = array2table(stats_arr, "RowNames", row_names, 'VariableNames', col_names);
    writetable(stats_tbl, file_name, 'Sheet', "true", 'Range', starting_cell, 'WriteRowNames', true);
    writematrix("Comparison", file_name, 'Sheet', "true", 'Range', starting_cell);

    active_cell = change_excel_addr(cell_col, cell_row, -1, 1);
    writematrix("High Sep", file_name, 'Sheet', "true", 'Range', active_cell);

    active_cell = change_excel_addr(cell_col, cell_row, -1, 3);
    writematrix("Low Sep", file_name, 'Sheet', "true", 'Range', active_cell);

    active_cell = change_excel_addr(cell_col, cell_row, 1, -1);
    writematrix("15s Trial", file_name, 'Sheet', "true", 'Range', active_cell);

    active_cell = change_excel_addr(cell_col, cell_row, 3, -1);
    writematrix("60s Trial", file_name, 'Sheet', "true", 'Range', active_cell);

    header_str = row_name + "/" + col_name;
    active_cell = change_excel_addr(cell_col, cell_row, -1, -1);
    writematrix(header_str, file_name, 'Sheet', "true", 'Range', active_cell);

end
























