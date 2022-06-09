%% global params
clear;
optimize_single_run = true;
num_threads = 16;

%% run parameters
participant_pool = 1;
data_folder = 'prepared_features/no_ica';
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


%% 
for i = 1:length(run_params_set)
    classifier_func = run_params_set(i).classifier;
    load_file_name = run_params_set(i).dur;
    feature_num = run_params_set(i).feature_num;
    randomization_flag = run_params_set(i).randomization_flag;

    classifier_str = func2str(classifier_func);
    classifier_str = classifier_str(5:end);

    dur_str = split(load_file_name, '_');
    dur_str = dur_str{1};

    if randomization_flag == 0 
        randomization_str = "s";
    else
        randomization_str = "r";
    end

    % file_name formatting looks like: 'svm/r 60s 30 feats';
    file_name = char(sprintf("%s %s %i feats", randomization_str, dur_str, feature_num));

    run_classification_inner;

end
