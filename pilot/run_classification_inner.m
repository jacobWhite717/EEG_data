%% Jacob White (jrw111@mun.ca) DEAP DB tests
% only run this one within the outer script for batch processing of results

%% global variables and conatiners 
t_start = tic;
num_subjects = length(participant_pool);
verbose = false;


results_kfold_table = cell(num_subjects, 1);
results_block_table = cell(num_subjects, 1);


%%
if isempty(gcp('nocreate'))
    parpool(num_threads);
end
for s = participant_pool
    % make the folder and file name by participant
    mkdir([pwd, '\results\participant\', char(sprintf("%i\\%s", s, classifier_str))]);
    mat_name = ['results\participant\', char(sprintf("%i\\%s\\", s, classifier_str)), file_name, '.mat'];

    %% load pre-saved features in TrialContainer
    fprintf('Working on subject %i\n', s);
    
    foldername = sprintf('%s/bandpower/%i/', data_folder, s);
    power_features = load([foldername load_file_name]).features;

    foldername = sprintf('%s/mean/%i/', data_folder, s);
    mean_features = load([foldername load_file_name]).features;

    foldername = sprintf('%s/variance/%i/', data_folder, s);
    var_features = load([foldername load_file_name]).features;

    foldername = sprintf('%s/rms/%i/', data_folder, s);
    rms_features = load([foldername load_file_name]).features;
    
    
    %% separate out features by class
%     trials_read = trials_features.getTrialsByClass(1);
%     trials_rest = trials_features.getTrialsByClass(0);
%     trials_read_rest = trials_read.appendTrialContainer(trials_rest);

    trials_read_rest = power_features;
    trials_read_rest = trials_read_rest.combineTrialContainerEpochs(mean_features);
    trials_read_rest = trials_read_rest.combineTrialContainerEpochs(var_features);
    trials_read_rest = trials_read_rest.combineTrialContainerEpochs(rms_features);
    
    
    %% classification params
    cv = CrossValidator(optimize_single_run);
    folds = 6;
    runs = 5;

    if randomization_flag == 0 
        % k-fold classification
        disp('Performing k-fold classification...')
        % lda
        results_kfold = cv.kfold(classifier_func, trials_read_rest, folds, ...
            num_filtered_features=feature_num, ...
            runs=runs);
        results_kfold_table{s} = results_kfold.makeResultsTable();
    
        
        % blocked CV
        disp('Performing blocked classification...')
        % lda
        results_block = cv.block(classifier_func, trials_read_rest, folds, ...
            num_filtered_features=feature_num, ...
            runs=runs);
        results_block_table{s} = results_block.makeResultsTable();
    else
        % k-fold classification
        disp('Performing k-fold classification...')
        % lda
        results_kfold = cv.kfold_random(classifier_func, trials_read_rest, folds, ...
            num_filtered_features=feature_num, ...
            runs=runs);
        results_kfold_table{s} = results_kfold.makeResultsTable();
    
        
        % blocked CV
        disp('Performing blocked classification...')
        % lda
        results_block = cv.block_random_kfold_classify(classifier_func, trials_read_rest, folds, ...
            num_filtered_features=feature_num, ...
            runs=runs);
        results_block_table{s} = results_block.makeResultsTable();
    end

    participant_results_kfold = results_kfold_table{s};
    participant_results_block = results_block_table{s};
    save(mat_name, "participant_results_kfold", "participant_results_block");
end

run_time = toc(t_start);
sprintf("Total run time was %.3fs", run_time)


%% Helper functions
function split_class_trials = split_single_class_trials(trial_cont)
    arguments
        trial_cont TrialContainer
    end

    if trial_cont.getLabelsOfTrials() == -1
        error("Trials are not uniformly classed") ;
    end

    if mod(length(trial_cont.trials), 2)
        error("Odd number of trials");
    end

    inds_perm1 = randperm(trial_cont.numTrials());
    for i = inds_perm1(1:ceil(length(inds_perm1)/2))
        swapped_trial = trial_cont.trials{i};
        for j = 1:length(swapped_trial)
            swapped_trial(j).class = 1;
        end
        split_class_trials{i} = swapped_trial;
    end
    for i = inds_perm1( ceil(length(inds_perm1)/2)+1:length(inds_perm1) )
        swapped_trial = trial_cont.trials{i};
        for j = 1:length(swapped_trial)
            swapped_trial(j).class = 2;
        end
        split_class_trials{i} = swapped_trial;
    end
    split_class_trials = TrialContainer(trials=split_class_trials);
end