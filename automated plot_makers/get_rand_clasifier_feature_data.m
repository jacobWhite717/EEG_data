function [kfold_means, kfold_stds, block_means, block_stds, block2_means, block2_stds] = get_rand_clasifier_feature_data(data_folder, subject_range, classifier_func_handle, feature_cat, data_range)
    arguments
        data_folder
        subject_range (1,:) {mustBeNumeric,mustBeReal}
        classifier_func_handle function_handle
        feature_cat string
        data_range (1,:) {mustBeNumeric,mustBeReal} = 1:9
    end
    participant_pool = subject_range;
    feature_category_str = feature_cat;
    load_file_names = {'5s_features.mat', '15s_features.mat', '60s_features.mat'};
    classifier_funcs = {classifier_func_handle}; % @fitcsvm / @fitcknn / @fitcdiscr 
    feature_nums = {30};
    randomization_flags = {1};
    
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
    
    rn_k_acc_5 = [];
    rn_k_acc_15 = [];
    rn_k_acc_60 = [];
    rn_b_acc_5 = [];
    rn_b_acc_15 = [];
    rn_b_acc_60 = [];
    rn_b2_acc_5 = [];
    rn_b2_acc_15 = [];
    rn_b2_acc_60 = [];
    
    ln_k_acc_5 = [];
    ln_k_acc_15 = [];
    ln_k_acc_60 = [];
    ln_b_acc_5 = [];
    ln_b_acc_15 = [];
    ln_b_acc_60 = [];
    ln_b2_acc_5 = [];
    ln_b2_acc_15 = [];
    ln_b2_acc_60 = [];
    
    rl_k_acc_5 = [];
    rl_k_acc_15 = [];
    rl_k_acc_60 = [];
    rl_b_acc_5 = [];
    rl_b_acc_15 = [];
    rl_b_acc_60 = [];
    rl_b2_acc_5 = [];
    rl_b2_acc_15 = [];
    rl_b2_acc_60 = [];
    
    for i = 1:length(run_params_set)
        classifier_func = run_params_set(i).classifier;
        file_str = run_params_set(i).dur;
        feature_num = run_params_set(i).feature_num;
        randomization_flag = run_params_set(i).randomization_flag;
    
        classifier_str = func2str(classifier_func);
        classifier_str = classifier_str(5:end);
    
        dur_str = split(file_str, '_');
        dur_str = dur_str{1};
    
        if randomization_flag == 0 
            randomization_str = "s";
        else
            randomization_str = "r";
        end
    
        file_str = char(sprintf("%s %s %i feats", randomization_str, dur_str, feature_num));
    
        for s = participant_pool
            mat_name = ['results/participant/', data_folder, char(sprintf("/%i/%s/%s/", s, feature_category_str, classifier_str)), file_str, '.mat'];
            kfold = load(mat_name).kfold;
            block = load(mat_name).block;
            block2 = load(mat_name).block2;
            
            %% rn
            switch dur_str
                case '5s'
                    rn_k_acc_5 = [rn_k_acc_5, kfold.rn.Accuracy("mean")];
                    rn_b_acc_5 = [rn_b_acc_5, block.rn.Accuracy("mean")];
                    rn_b2_acc_5 = [rn_b2_acc_5, block2.rn.Accuracy("mean")];
                case '15s'
                    rn_k_acc_15 = [rn_k_acc_15, kfold.rn.Accuracy("mean")];
                    rn_b_acc_15 = [rn_b_acc_15, block.rn.Accuracy("mean")];
                    rn_b2_acc_15 = [rn_b2_acc_15, block2.rn.Accuracy("mean")];
                case '60s'
                    rn_k_acc_60 = [rn_k_acc_60, kfold.rn.Accuracy("mean")];
                    rn_b_acc_60 = [rn_b_acc_60, block.rn.Accuracy("mean")];
                    rn_b2_acc_60 = [rn_b2_acc_60, block2.rn.Accuracy("mean")];
            end
    
            %% ln        
            switch dur_str
                case '5s'
                    ln_k_acc_5 = [ln_k_acc_5, kfold.ln.Accuracy("mean")];
                    ln_b_acc_5 = [ln_b_acc_5, block.ln.Accuracy("mean")];
                    ln_b2_acc_5 = [ln_b2_acc_5, block.ln.Accuracy("mean")];
                case '15s'
                    ln_k_acc_15 = [ln_k_acc_15, kfold.ln.Accuracy("mean")];
                    ln_b_acc_15 = [ln_b_acc_15, block.ln.Accuracy("mean")];
                    ln_b2_acc_15 = [ln_b2_acc_15, block2.ln.Accuracy("mean")];
                case '60s'
                    ln_k_acc_60 = [ln_k_acc_60, kfold.ln.Accuracy("mean")];
                    ln_b_acc_60 = [ln_b_acc_60, block.ln.Accuracy("mean")];
                    ln_b2_acc_60 = [ln_b2_acc_60, block2.ln.Accuracy("mean")];
            end
    
            %% rl        
            switch dur_str
                case '5s'
                    rl_k_acc_5 = [rl_k_acc_5, kfold.rl.Accuracy("mean")];
                    rl_b_acc_5 = [rl_b_acc_5, block.rl.Accuracy("mean")];
                    rl_b2_acc_5 = [rl_b2_acc_5, block2.rl.Accuracy("mean")];
                case '15s'
                    rl_k_acc_15 = [rl_k_acc_15, kfold.rl.Accuracy("mean")];
                    rl_b_acc_15 = [rl_b_acc_15, block.rl.Accuracy("mean")];
                    rl_b2_acc_15 = [rl_b2_acc_15, block2.rl.Accuracy("mean")];
                case '60s'
                    rl_k_acc_60 = [rl_k_acc_60, kfold.rl.Accuracy("mean")];
                    rl_b_acc_60 = [rl_b_acc_60, block.rl.Accuracy("mean")];
                    rl_b2_acc_60 = [rl_b2_acc_60, block2.rl.Accuracy("mean")];
            end
        end
    end
    %% stats
    rn_k_mean_5 = mean(rn_k_acc_5);
    rn_k_mean_15 = mean(rn_k_acc_15);
    rn_k_mean_60 = mean(rn_k_acc_60);
    rn_b_mean_5 = mean(rn_b_acc_5);
    rn_b_mean_15 = mean(rn_b_acc_15);
    rn_b_mean_60 = mean(rn_b_acc_60);
    rn_b2_mean_5 = mean(rn_b2_acc_5);
    rn_b2_mean_15 = mean(rn_b2_acc_15);
    rn_b2_mean_60 = mean(rn_b2_acc_60);
    
    ln_k_mean_5 = mean(ln_k_acc_5);
    ln_k_mean_15 = mean(ln_k_acc_15);
    ln_k_mean_60 = mean(ln_k_acc_60);
    ln_b_mean_5 = mean(ln_b_acc_5);
    ln_b_mean_15 = mean(ln_b_acc_15);
    ln_b_mean_60 = mean(ln_b_acc_60);
    ln_b2_mean_5 = mean(ln_b2_acc_5);
    ln_b2_mean_15 = mean(ln_b2_acc_15);
    ln_b2_mean_60 = mean(ln_b2_acc_60);
    
    rl_k_mean_5 = mean(rl_k_acc_5);
    rl_k_mean_15 = mean(rl_k_acc_15);
    rl_k_mean_60 = mean(rl_k_acc_60);
    rl_b_mean_5 = mean(rl_b_acc_5);
    rl_b_mean_15 = mean(rl_b_acc_15);
    rl_b_mean_60 = mean(rl_b_acc_60);
    rl_b2_mean_5 = mean(rl_b2_acc_5);
    rl_b2_mean_15 = mean(rl_b2_acc_15);
    rl_b2_mean_60 = mean(rl_b2_acc_60);
    
    rn_k_std_5 = std(rn_k_acc_5);
    rn_k_std_15 = std(rn_k_acc_15);
    rn_k_std_60 = std(rn_k_acc_60);
    rn_b_std_5 = std(rn_b_acc_5);
    rn_b_std_15 = std(rn_b_acc_15);
    rn_b_std_60 = std(rn_b_acc_60);
    rn_b2_std_5 = std(rn_b2_acc_5);
    rn_b2_std_15 = std(rn_b2_acc_15);
    rn_b2_std_60 = std(rn_b2_acc_60);
    
    ln_k_std_5 = std(ln_k_acc_5);
    ln_k_std_15 = std(ln_k_acc_15);
    ln_k_std_60 = std(ln_k_acc_60);
    ln_b_std_5 = std(ln_b_acc_5);
    ln_b_std_15 = std(ln_b_acc_15);
    ln_b_std_60 = std(ln_b_acc_60);
    ln_b2_std_5 = std(ln_b2_acc_5);
    ln_b2_std_15 = std(ln_b2_acc_15);
    ln_b2_std_60 = std(ln_b2_acc_60);
    
    rl_k_std_5 = std(rl_k_acc_5);
    rl_k_std_15 = std(rl_k_acc_15);
    rl_k_std_60 = std(rl_k_acc_60);
    rl_b_std_5 = std(rl_b_acc_5);
    rl_b_std_15 = std(rl_b_acc_15);
    rl_b_std_60 = std(rl_b_acc_60);
    rl_b2_std_5 = std(rl_b2_acc_5);
    rl_b2_std_15 = std(rl_b2_acc_15);
    rl_b2_std_60 = std(rl_b2_acc_60);
    
    kfold_means = [rn_k_mean_5, rn_k_mean_15, rn_k_mean_60, ln_k_mean_5, ln_k_mean_15, ln_k_mean_60, rl_k_mean_5, rl_k_mean_15, rl_k_mean_60];
    kfold_stds = [rn_k_std_5, rn_k_std_15, rn_k_std_60, ln_k_std_5, ln_k_std_15, ln_k_std_60, rl_k_std_5, rl_k_std_15, rl_k_std_60];
    kfold_means = kfold_means(1,data_range);
    kfold_stds = kfold_stds(1,data_range);

    block_means = [0, rn_b_mean_15, rn_b_mean_60, 0, ln_b_mean_15, ln_b_mean_60, 0, rl_b_mean_15, rl_b_mean_60];
    block_stds = [0, rn_b_std_15, rn_b_std_60, 0, ln_b_std_15, ln_b_std_60, 0, rl_b_std_15, rl_b_std_60];
    block_means = block_means(1,data_range);
    block_stds = block_stds(1,data_range);

    block2_means = [0, rn_b2_mean_15, rn_b2_mean_60, 0, ln_b2_mean_15, ln_b2_mean_60, 0, rl_b2_mean_15, rl_b2_mean_60];
    block2_stds = [0, rn_b2_std_15, rn_b2_std_60, 0, ln_b2_std_15, ln_b2_std_60, 0, rl_b2_std_15, rl_b2_std_60];
    block2_means = block2_means(1,data_range);
    block2_stds = block2_stds(1,data_range);
end