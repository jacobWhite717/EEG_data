clear;
%% run parameters

participant_pool = 5:16;
load_file_names = {'5s_features.mat', '15s_features.mat', '60s_features.mat'};
% load_file_names = {'15s_features.mat'};
classifier_funcs = {@fitcsvm, @fitcknn, @fitcdiscr};
feature_nums = {30};
randomization_flags = {1};
feature_types = {'pentropy'};
% feature_types = {'bandpower', 'mean', 'variance', 'rms'};

results_sub_folder = 'no_ica'; 

run_params_set = [];
for i = 1:length(load_file_names)
    for j = 1:length(classifier_funcs)
        for k = 1:length(feature_nums)
            for l = 1:length(randomization_flags)
                for m = 1:length(feature_types)
                    run_params.dur = load_file_names{i};
                    run_params.classifier = classifier_funcs{j};
                    run_params.feature_num = feature_nums{k};
                    run_params.randomization_flag = randomization_flags{l};
                    run_params.feature_type = feature_types{m};
                    run_params_set = [run_params_set run_params];
                end
            end
        end
    end
end

for i = 1:length(run_params_set)
    classifier_func = run_params_set(i).classifier;
    file_name = run_params_set(i).dur;
    feature_num = run_params_set(i).feature_num;
    randomization_flag = run_params_set(i).randomization_flag;
    feature_type = run_params_set(i).feature_type;

    classifier_str = func2str(classifier_func);
    classifier_str = classifier_str(5:end);

    dur_str = split(file_name, '_');
    dur_str = dur_str{1};

    if randomization_flag == 0 
        randomization_str = "s";
    else
        randomization_str = "r";
    end

    file_name = char(sprintf("%s %s %i feats", randomization_str, dur_str, feature_num));
    excel_name = ['results/spreadsheets/', results_sub_folder, char(sprintf("/%s/%s/", feature_type, classifier_str)), file_name,'.xlsx'];
    
    mkdir(['results/spreadsheets/', results_sub_folder, char(sprintf("/%s/%s/", feature_type, classifier_str))])
    
    results_kfold_rn_table = {};
    results_block_rn_table = {};
    for s = participant_pool
        mat_file = ['results/participant/', results_sub_folder, char(sprintf("/%i/%s/%s/", s, feature_type, classifier_str)), file_name, '.mat'];
        kfold_rn = load(mat_file).kfold;
        kfold_rn = kfold_rn.rn;
        block_rn = load(mat_file).block;
        block_rn = block_rn.rn;
        block2_rn = load(mat_file).block2;
        block2_rn = block2_rn.rn;
        results_kfold_rn_table{s} = kfold_rn;
        results_block_rn_table{s} = block_rn;
        results_block2_rn_table{s} = block2_rn;

        kfold_ln = load(mat_file).kfold;
        kfold_ln = kfold_ln.ln;
        block_ln = load(mat_file).block;
        block_ln = block_ln.ln;
        block2_ln = load(mat_file).block2;
        block2_ln = block2_ln.ln;
        results_kfold_ln_table{s} = kfold_ln;
        results_block_ln_table{s} = block_ln;
        results_block2_ln_table{s} = block2_ln;

        kfold_rl = load(mat_file).kfold;
        kfold_rl = kfold_rl.rl;
        block_rl = load(mat_file).block;
        block_rl = block_rl.rl;
        block2_rl = load(mat_file).block2;
        block2_rl = block2_rl.rl;
        results_kfold_rl_table{s} = kfold_rl;
        results_block_rl_table{s} = block_rl;
        results_block2_rl_table{s} = block2_rl;
    end
    summary_kfold_rn = make_results_summary(results_kfold_rn_table, min(participant_pool)-1);
    summary_block_rn = make_results_summary(results_block_rn_table, min(participant_pool)-1);
    summary_block2_rn = make_results_summary(results_block2_rn_table, min(participant_pool)-1);

    summary_kfold_ln = make_results_summary(results_kfold_ln_table, min(participant_pool)-1);
    summary_block_ln = make_results_summary(results_block_ln_table, min(participant_pool)-1);
    summary_block2_ln = make_results_summary(results_block2_ln_table, min(participant_pool)-1);

    summary_kfold_rl = make_results_summary(results_kfold_rl_table, min(participant_pool)-1);
    summary_block_rl = make_results_summary(results_block_rl_table, min(participant_pool)-1);
    summary_block2_rl = make_results_summary(results_block2_rl_table, min(participant_pool)-1);


    sheet_name = "Summary";
    col1_name = "epoch-random/kfold";
    col2_name = "trial-random/kfold";
    col3_name = "trial-random/block";
    
    % Read/None classification tables
    writematrix("Read - Rest", excel_name, 'Sheet', sheet_name, 'Range', 'B2');
    writematrix(col1_name, excel_name, 'Sheet', sheet_name, 'Range', 'B3');
    writetable(summary_kfold_rn, excel_name, 'Sheet', sheet_name, 'Range', 'B4', 'WriteRowNames', true);
    
    writematrix("Read - Rest", excel_name, 'Sheet', sheet_name, 'Range', 'G2');
    writematrix(col2_name, excel_name, 'Sheet', sheet_name, 'Range', 'G3');
    writetable(summary_block_rn, excel_name, 'Sheet', sheet_name, 'Range', 'G4', 'WriteRowNames', true);

    writematrix("Read - Rest", excel_name, 'Sheet', sheet_name, 'Range', 'L2');
    writematrix(col3_name, excel_name, 'Sheet', sheet_name, 'Range', 'L3');
    writetable(summary_block2_rn, excel_name, 'Sheet', sheet_name, 'Range', 'L4', 'WriteRowNames', true);

    % Listen/None classification tables
    writematrix("Listen - Rest", excel_name, 'Sheet', sheet_name, 'Range', 'Q2');
    writematrix(col1_name, excel_name, 'Sheet', sheet_name, 'Range', 'Q3');
    writetable(summary_kfold_ln, excel_name, 'Sheet', sheet_name, 'Range', 'Q4', 'WriteRowNames', true);
    
    writematrix("Listen - Rest", excel_name, 'Sheet', sheet_name, 'Range', 'V2');
    writematrix(col2_name, excel_name, 'Sheet', sheet_name, 'Range', 'V3');
    writetable(summary_block_ln, excel_name, 'Sheet', sheet_name, 'Range', 'V4', 'WriteRowNames', true);

    writematrix("Listen - Rest", excel_name, 'Sheet', sheet_name, 'Range', 'AA2');
    writematrix(col3_name, excel_name, 'Sheet', sheet_name, 'Range', 'AA3');
    writetable(summary_block2_ln, excel_name, 'Sheet', sheet_name, 'Range', 'AA4', 'WriteRowNames', true);

    % Read/Listen classification tables
    writematrix("Read - Listen", excel_name, 'Sheet', sheet_name, 'Range', 'AF2');
    writematrix(col1_name, excel_name, 'Sheet', sheet_name, 'Range', 'AF3');
    writetable(summary_kfold_rl, excel_name, 'Sheet', sheet_name, 'Range', 'AF4', 'WriteRowNames', true);
    
    writematrix("Read - Listen", excel_name, 'Sheet', sheet_name, 'Range', 'AK2');
    writematrix(col2_name, excel_name, 'Sheet', sheet_name, 'Range', 'AK3');
    writetable(summary_block_rl, excel_name, 'Sheet', sheet_name, 'Range', 'AK4', 'WriteRowNames', true);

    writematrix("Read - Listen", excel_name, 'Sheet', sheet_name, 'Range', 'AP2');
    writematrix(col3_name, excel_name, 'Sheet', sheet_name, 'Range', 'AP3');
    writetable(summary_block2_rl, excel_name, 'Sheet', sheet_name, 'Range', 'AP4', 'WriteRowNames', true);
    
    for s = participant_pool
        sheet_name = sprintf('Sub %02i', s);
        % read/none
        writematrix("Read - Rest", excel_name, 'Sheet', sheet_name, 'Range', 'B2');
        writematrix(col1_name, excel_name, 'Sheet', sheet_name, 'Range', 'B3');
        writetable(results_kfold_rn_table{s}, excel_name, 'Sheet', sheet_name, 'Range', 'B4', 'WriteRowNames', true);
        
        writematrix(col2_name, excel_name, 'Sheet', sheet_name, 'Range', 'B13');
        writetable(results_block_rn_table{s}, excel_name, 'Sheet', sheet_name, 'Range', 'B14', 'WriteRowNames', true);

        % listen/none
        writematrix("Listen - Rest", excel_name, 'Sheet', sheet_name, 'Range', 'B24');
        writematrix(col1_name, excel_name, 'Sheet', sheet_name, 'Range', 'B25');
        writetable(results_kfold_rn_table{s}, excel_name, 'Sheet', sheet_name, 'Range', 'B26', 'WriteRowNames', true);
        
        writematrix(col2_name, excel_name, 'Sheet', sheet_name, 'Range', 'B35');
        writetable(results_block_rn_table{s}, excel_name, 'Sheet', sheet_name, 'Range', 'B36', 'WriteRowNames', true);

        % read/listen
        writematrix("Read - Listen", excel_name, 'Sheet', sheet_name, 'Range', 'B46');
        writematrix(col1_name, excel_name, 'Sheet', sheet_name, 'Range', 'B47');
        writetable(results_kfold_rn_table{s}, excel_name, 'Sheet', sheet_name, 'Range', 'B48', 'WriteRowNames', true);
        
        writematrix(col2_name, excel_name, 'Sheet', sheet_name, 'Range', 'B57');
        writetable(results_block_rn_table{s}, excel_name, 'Sheet', sheet_name, 'Range', 'B58', 'WriteRowNames', true);
    end
    
end

%%
function summary = make_results_summary(results, offset)
    arguments
        results
        offset {mustBeNonnegative} = 0
    end
    summary = zeros(length(results)+2-offset,3);
    for i = 1:length(results)-offset
        summary(i,1) = results{i+offset}.Accuracy(end-1);
        summary(i,2) = results{i+offset}.Sensitivity(end-1);
        summary(i,3) = results{i+offset}.Specificity(end-1);
    end
    summary(end-1,1) = mean(summary(1:end-2,1));
    summary(end-1,2) = mean(summary(1:end-2,2));
    summary(end-1,3) = mean(summary(1:end-2,3));

    summary(end,1) = std(summary(1:end-2,1));
    summary(end,2) = std(summary(1:end-2,2));
    summary(end,3) = std(summary(1:end-2,3));
    
    col_names = [ "Accuracy", "Sensitivity", "Specificity" ];
    row_names = [];
    for i = 1:length(results)-offset
        row_names = [row_names, string(sprintf('Sub %i', i+offset))];
    end
    row_names = [row_names, "mean", "std"];
    summary = array2table(summary, 'RowNames', row_names, 'VariableNames', col_names);
end