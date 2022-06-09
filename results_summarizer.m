clear;
%% run parameters

%todo: make this work when participant_pool isnt starting at 1
participant_pool = 1:4;
load_file_names = {'5s_features.mat'};
classifier_funcs = {@fitcsvm};
feature_nums = {30};
randomization_flags = {0};

run_params_set = [];
for i = 1:length(load_file_names)
    for j = 1:length(classifier_funcs)
        for k = 1:length(feature_nums)
            for l = 1:length(randomization_flags)
                run_params.dur = load_file_names{i};
                run_params.classifier = classifier_funcs{j};
                run_params.feature_num = feature_nums{k};
                run_params.randomization_flag = randomization_flags{l};
                run_params_set = [run_params_set run_params];
            end
        end
    end
end

for i = 1:length(run_params_set)
    classifier_func = run_params_set(i).classifier;
    file_name = run_params_set(i).dur;
    feature_num = run_params_set(i).feature_num;
    randomization_flag = run_params_set(i).randomization_flag;

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
    excel_name = ['results\', char(sprintf("%s\\", classifier_str)), file_name,'.xlsx'];

    results_kfold_table = {};
    results_block_table = {};
    for s = participant_pool
        mat_file = ['results\participant\', char(sprintf("%i\\%s\\", s, classifier_str)), file_name, '.mat'];
        results_kfold_table{s} = load(mat_file).participant_results_kfold;
        results_block_table{s} = load(mat_file).participant_results_block;
    end
    summary_kfold = make_results_summary(results_kfold_table);
    summary_block = make_results_summary(results_block_table);


    sheet_name = "Summary";
    col1_name = "kfold - Read/Rest Classification";
    col2_name = "block - Read/Rest Classification";
    
    writematrix("classifier", excel_name, 'Sheet', sheet_name, 'Range', 'B2');
    % writematrix("LDA classifier", excel_name, 'Sheet', sheet_name, 'Range', 'B2');
    writematrix(col1_name, excel_name, 'Sheet', sheet_name, 'Range', 'B3');
    writetable(summary_kfold, excel_name, 'Sheet', sheet_name, 'Range', 'B4', 'WriteRowNames', true);
    
    writematrix("classifier", excel_name, 'Sheet', sheet_name, 'Range', 'G2');
    % writematrix("LDA classifier", excel_name, 'Sheet', sheet_name, 'Range', 'G2');
    writematrix(col2_name, excel_name, 'Sheet', sheet_name, 'Range', 'G3');
    writetable(summary_block, excel_name, 'Sheet', sheet_name, 'Range', 'G4', 'WriteRowNames', true);
    
    for s = participant_pool
        sheet_name = sprintf('Sub %02i', s);
        writematrix("RF classifier", excel_name, 'Sheet', sheet_name, 'Range', 'B2');
        writematrix(col1_name, excel_name, 'Sheet', sheet_name, 'Range', 'B3');
        writetable(results_kfold_table{s}, excel_name, 'Sheet', sheet_name, 'Range', 'B4', 'WriteRowNames', true);
        
        writematrix(col2_name, excel_name, 'Sheet', sheet_name, 'Range', 'G3');
        writetable(results_block_table{s}, excel_name, 'Sheet', sheet_name, 'Range', 'G4', 'WriteRowNames', true);
    end
    
end

%%
function summary = make_results_summary(results)
    summary = zeros(length(results)+2,3);
    for i = 1:length(results)
        summary(i,1) = results{i}.Accuracy(end-1);
        summary(i,2) = results{i}.Sensitivity(end-1);
        summary(i,3) = results{i}.Specificity(end-1);
    end
    summary(end-1,1) = mean(summary(1:end-2,1));
    summary(end-1,2) = mean(summary(1:end-2,2));
    summary(end-1,3) = mean(summary(1:end-2,3));

    summary(end,1) = std(summary(1:end-2,1));
    summary(end,2) = std(summary(1:end-2,2));
    summary(end,3) = std(summary(1:end-2,3));
    
    col_names = [ "Accuracy", "Sensitivity", "Specificity" ];
    row_names = [];
    for i = 1:length(results)
        row_names = [row_names, string(sprintf('Sub %i', i))];
    end
    row_names = [row_names, "mean", "std"];
    summary = array2table(summary, 'RowNames', row_names, 'VariableNames', col_names);
end