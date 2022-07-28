clear;
close all;
%% run parameters

participant_pool = 5:9;
load_file_names = {'5s_features.mat', '15s_features.mat', '60s_features.mat'};
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
        mat_name = ['results/participant/', char(sprintf("%i/%s/", s, classifier_str)), file_str, '.mat'];
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

block_means = [0, rn_b_mean_15, rn_b_mean_60, 0, ln_b_mean_15, ln_b_mean_60, 0, rl_b_mean_15, rl_b_mean_60];
block_stds = [0, rn_b_std_15, rn_b_std_60, 0, ln_b_std_15, ln_b_std_60, 0, rl_b_std_15, rl_b_std_60];

% block_means = [rn_b_mean_5, rn_b_mean_15, rn_b_mean_60, ln_b_mean_5, ln_b_mean_15, ln_b_mean_60, rl_b_mean_5, rl_b_mean_15, rl_b_mean_60];
% block_stds = [rn_b_std_5, rn_b_std_15, rn_b_std_60, ln_b_std_5, ln_b_std_15, ln_b_std_60, rl_b_std_5, rl_b_std_15, rl_b_std_60];

% tick_labels = {'read/rest 5s','read/rest 15s', 'read/rest 60s', 'listen/rest 5s', 'listen/rest 15s', 'listen/rest 60s', 'read/listen 5s', 'read/listen 15s', 'read/listen 60s'};
tick_labels = {'5','15', '60', '5', '15', '60', '5', '15', '60'};


%% graphing
f = figure;
hold on;
ymin = 40;
ymax = 105;
% shading
x = [3.5 3.5 6.5 6.5];
y = [0 ymax ymax 0];
patch(x, y, 'k', 'FaceColor', [40 40 40]/255, 'FaceAlpha', 0.1, 'EdgeColor', 'none')
patch(x+3, y, 'k', 'FaceColor', [40 40 40]/255, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
% bar data
means = [kfold_means; block_means]';
b = bar(means, 0.9, 'grouped');
b(1).FaceColor = [0 0.4470 0.7410];
b(2).FaceColor = [0.6350 0.0780 0.1840];
% b(2).FaceColor = 'Flat';
% b(2).CData(:,:) = ones(9,3).*[0.6350 0.0780 0.1840]; 
% b(2).CData([1 4 7],:) = ones(3,3).*[0.3 0.4470 0.7410]; 
% labeling
title("Classification (True Labels)")
set(gca, 'xtick', [1:9], 'xticklabel', tick_labels)
ylabel("Accuracy (%)")
xlabel("Trial Duration (s)")
ylim([ymin ymax])
xlim([0.5 9.5])
text(1, ymax-2, "Low Class Seperability", 'fontweight','bold')
text(1.5, ymax-5, "(Read/Rest)")
text(4, ymax-2, "High Class Seperability", 'fontweight','bold')
text(4.5, ymax-5, "(Listen/Rest)")
text(7, ymax-2, "Low Class Seperability", 'fontweight','bold')
text(7.5, ymax-5, "(Read/Listen)")
% plot([0 10], [50 50], '--k')
plot([0.5 3.5], [rn_k_mean_5 rn_k_mean_5], '--k')
plot([3.5 6.5], [ln_k_mean_5 ln_k_mean_5], '--k')
plot([6.5 9.5], [rl_k_mean_5 rl_k_mean_5], '--k')

% error bars
[ngroups, nbars] = size(means);
groupwidth = min(0.8, nbars/(nbars + 1.5));
errors = [kfold_stds; block_stds]';
for i = 1:nbars
    x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(x, means(:,i), errors(:,i), 'k', 'linestyle', 'none');
end

legend(["", "", "k-fold", "block", """Ground-truth"""], 'location', 'SE')

%set size
set(f,'Position',[10 10 850 440])










