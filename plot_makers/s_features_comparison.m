clear;
save_flag = 0;

%% get data
subject_range = 5:13;
% choose ONE of the below
classification_selection = 3; % 1/2/3
classification_ranges = {1:3, 4:6, 7:9};
classification_range = classification_ranges{classification_selection};
classification_names = ["Read/Rest", "Listen/Rest", "Read/Listen"];
classification_name = classification_names(classification_selection);

feature_cat_options = ["bandpower", "mean", "rms", "variance", "all"]; % all/bandpower/mean/rms/variance

k_m = [];
k_s = [];
b_m = [];
b_s = [];

for i = 1:length(feature_cat_options)
    feature_cat = feature_cat_options(i); 
    
    [svm_k_m, svm_k_s, svm_b_m, svm_b_s] = get_clasifier_feature_data(subject_range, @fitcsvm, feature_cat, classification_range);
    [discr_k_m, discr_k_s, discr_b_m, discr_b_s] = get_clasifier_feature_data(subject_range, @fitcdiscr, feature_cat, classification_range);
    [knn_k_m, knn_k_s, knn_b_m, knn_b_s] = get_clasifier_feature_data(subject_range, @fitcknn, feature_cat, classification_range);
    
    k_m = [k_m, mean([svm_k_m; discr_k_m; knn_k_m])];
    k_s = [k_s, mean([svm_k_s; discr_k_s; knn_k_s])];
    b_m = [b_m, mean([svm_b_m; discr_b_m; knn_b_m])];
    b_s = [b_s, mean([svm_b_s; discr_b_s; knn_b_s])];
end

tick_labels = {'5','15', '60', '5', '15', '60', '5', '15', '60', '5', '15', '60', '5', '15', '60'};

%% graphing
f = figure;
hold on;
% ymin = 30;
% ymax = 95;
ymin = 40;
ymax = 105;
% shading
x = [3.5 3.5 6.5 6.5];
y = [0 ymax ymax 0];
patch(x, y, 'k', 'FaceColor', [40 40 40]/255, 'FaceAlpha', 0.1, 'EdgeColor', 'none')
patch(x+6, y, 'k', 'FaceColor', [40 40 40]/255, 'FaceAlpha', 0.1, 'EdgeColor', 'none')
% bar data
means = [k_m; b_m]';
b = bar(means, 0.9, 'grouped');
b(1).FaceColor = [0 0.4470 0.7410];
b(2).FaceColor = [0.6350 0.0780 0.1840];
% b(2).FaceColor = 'Flat';
% b(2).CData(:,:) = ones(9,3).*[0.6350 0.0780 0.1840]; 
% b(2).CData([1 4 7],:) = ones(3,3).*[0.3 0.4470 0.7410]; 
% labeling
title_str = sprintf("%s Classification (True Labels) Feature Performance Comparison", classification_name);
title(title_str)
% title("Classification (True Labels)")
set(gca, 'xtick', [1:15], 'xticklabel', tick_labels)
ylabel("Accuracy (%)")
xlabel("Trial Duration (s)")
ylim([ymin ymax])
xlim([0.5 15.5])
text(2, ymax-2, "Bandpower", 'HorizontalAlignment', 'center', 'fontweight','bold')
text(5, ymax-2, "Mean", 'HorizontalAlignment', 'center', 'fontweight','bold')
text(8, ymax-2, "RMS", 'HorizontalAlignment', 'center', 'fontweight','bold')
text(11, ymax-2, "Variance", 'HorizontalAlignment', 'center', 'fontweight','bold')
text(14, ymax-2, "All", 'HorizontalAlignment', 'center', 'fontweight','bold')
plot([0.5 3.5], [k_m(1) k_m(1)], '--k')
plot([3.5 6.5], [k_m(4) k_m(4)], '--k')
plot([6.5 9.5], [k_m(7) k_m(7)], '--k')
plot([9.5 12.5], [k_m(10) k_m(10)], '--k')
plot([12.5 15.5], [k_m(13) k_m(13)], '--k')

% error bars
[ngroups, nbars] = size(means);
groupwidth = min(0.8, nbars/(nbars + 1.5));
errors = [k_s; b_s]';
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, means(:,i), errors(:,i), 'k', 'linestyle', 'none');
end

legend(["", "", "k-fold", "block", """ground truth"""], 'location', 'SW')

%set size
set(f,'Position',[10 10 1150 440])

if save_flag
    mkdir("results/plots/all_feat_comparison")
    plot_savename = char(sprintf("results/plots/all_feat_comparison/s %s.png", strrep(classification_name, '/', '_')));
    saveas(f , plot_savename);
end

%%
function [kfold_means, kfold_stds, block_means, block_stds] = get_clasifier_feature_data(subject_range, classifier_func_handle, feature_cat, data_range)
    arguments
        subject_range (1,:) {mustBeNumeric,mustBeReal}
        classifier_func_handle function_handle
        feature_cat string
        data_range (1,:) {mustBeNumeric,mustBeReal} = 1:9
    end
    participant_pool = subject_range;
    feature_catagory_str = feature_cat;
    load_file_names = {'5s_features.mat', '15s_features.mat', '60s_features.mat'};
    classifier_funcs = {classifier_func_handle}; % @fitcsvm / @fitcknn / @fitcdiscr 
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
    
    rn_k_acc_5 = [];
    rn_k_acc_15 = [];
    rn_k_acc_60 = [];
    rn_b_acc_5 = [];
    rn_b_acc_15 = [];
    rn_b_acc_60 = [];
    
    ln_k_acc_5 = [];
    ln_k_acc_15 = [];
    ln_k_acc_60 = [];
    ln_b_acc_5 = [];
    ln_b_acc_15 = [];
    ln_b_acc_60 = [];
    
    rl_k_acc_5 = [];
    rl_k_acc_15 = [];
    rl_k_acc_60 = [];
    rl_b_acc_5 = [];
    rl_b_acc_15 = [];
    rl_b_acc_60 = [];
    
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
            mat_name = ['results/participant/', char(sprintf("%i/%s/%s/", s, feature_catagory_str, classifier_str)), file_str, '.mat'];
            kfold = load(mat_name).kfold;
            block = load(mat_name).block;
            
            %% rn
            switch dur_str
                case '5s'
                    rn_k_acc_5 = [rn_k_acc_5, kfold.rn.Accuracy("mean")];
                    rn_b_acc_5 = [rn_b_acc_5, block.rn.Accuracy("mean")];
                case '15s'
                    rn_k_acc_15 = [rn_k_acc_15, kfold.rn.Accuracy("mean")];
                    rn_b_acc_15 = [rn_b_acc_15, block.rn.Accuracy("mean")];
                case '60s'
                    rn_k_acc_60 = [rn_k_acc_60, kfold.rn.Accuracy("mean")];
                    rn_b_acc_60 = [rn_b_acc_60, block.rn.Accuracy("mean")];
            end
    
            %% ln        
            switch dur_str
                case '5s'
                    ln_k_acc_5 = [ln_k_acc_5, kfold.ln.Accuracy("mean")];
                    ln_b_acc_5 = [ln_b_acc_5, block.ln.Accuracy("mean")];
                case '15s'
                    ln_k_acc_15 = [ln_k_acc_15, kfold.ln.Accuracy("mean")];
                    ln_b_acc_15 = [ln_b_acc_15, block.ln.Accuracy("mean")];
                case '60s'
                    ln_k_acc_60 = [ln_k_acc_60, kfold.ln.Accuracy("mean")];
                    ln_b_acc_60 = [ln_b_acc_60, block.ln.Accuracy("mean")];
            end
    
            %% rl        
            switch dur_str
                case '5s'
                    rl_k_acc_5 = [rl_k_acc_5, kfold.rl.Accuracy("mean")];
                    rl_b_acc_5 = [rl_b_acc_5, block.rl.Accuracy("mean")];
                case '15s'
                    rl_k_acc_15 = [rl_k_acc_15, kfold.rl.Accuracy("mean")];
                    rl_b_acc_15 = [rl_b_acc_15, block.rl.Accuracy("mean")];
                case '60s'
                    rl_k_acc_60 = [rl_k_acc_60, kfold.rl.Accuracy("mean")];
                    rl_b_acc_60 = [rl_b_acc_60, block.rl.Accuracy("mean")];
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
    
    ln_k_mean_5 = mean(ln_k_acc_5);
    ln_k_mean_15 = mean(ln_k_acc_15);
    ln_k_mean_60 = mean(ln_k_acc_60);
    ln_b_mean_5 = mean(ln_b_acc_5);
    ln_b_mean_15 = mean(ln_b_acc_15);
    ln_b_mean_60 = mean(ln_b_acc_60);
    
    rl_k_mean_5 = mean(rl_k_acc_5);
    rl_k_mean_15 = mean(rl_k_acc_15);
    rl_k_mean_60 = mean(rl_k_acc_60);
    rl_b_mean_5 = mean(rl_b_acc_5);
    rl_b_mean_15 = mean(rl_b_acc_15);
    rl_b_mean_60 = mean(rl_b_acc_60);
    
    rn_k_std_5 = std(rn_k_acc_5);
    rn_k_std_15 = std(rn_k_acc_15);
    rn_k_std_60 = std(rn_k_acc_60);
    rn_b_std_5 = std(rn_b_acc_5);
    rn_b_std_15 = std(rn_b_acc_15);
    rn_b_std_60 = std(rn_b_acc_60);
    
    ln_k_std_5 = std(ln_k_acc_5);
    ln_k_std_15 = std(ln_k_acc_15);
    ln_k_std_60 = std(ln_k_acc_60);
    ln_b_std_5 = std(ln_b_acc_5);
    ln_b_std_15 = std(ln_b_acc_15);
    ln_b_std_60 = std(ln_b_acc_60);
    
    rl_k_std_5 = std(rl_k_acc_5);
    rl_k_std_15 = std(rl_k_acc_15);
    rl_k_std_60 = std(rl_k_acc_60);
    rl_b_std_5 = std(rl_b_acc_5);
    rl_b_std_15 = std(rl_b_acc_15);
    rl_b_std_60 = std(rl_b_acc_60);
    
    kfold_means = [rn_k_mean_5, rn_k_mean_15, rn_k_mean_60, ln_k_mean_5, ln_k_mean_15, ln_k_mean_60, rl_k_mean_5, rl_k_mean_15, rl_k_mean_60];
    kfold_stds = [rn_k_std_5, rn_k_std_15, rn_k_std_60, ln_k_std_5, ln_k_std_15, ln_k_std_60, rl_k_std_5, rl_k_std_15, rl_k_std_60];
    kfold_means = kfold_means(1,data_range);
    kfold_stds = kfold_stds(1,data_range);

    block_means = [0, rn_b_mean_15, rn_b_mean_60, 0, ln_b_mean_15, ln_b_mean_60, 0, rl_b_mean_15, rl_b_mean_60];
    block_stds = [0, rn_b_std_15, rn_b_std_60, 0, ln_b_std_15, ln_b_std_60, 0, rl_b_std_15, rl_b_std_60];
    block_means = block_means(1,data_range);
    block_stds = block_stds(1,data_range);
end