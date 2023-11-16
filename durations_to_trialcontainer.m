clear;
tic
for SUBJECT_NUM = 5:16
% SUBJECT_NUM = mod(SUBJECT_NUM-1, 6)+1;
durations = [5, 15, 60];

datapath = ['E:\\EEG_working\\EEG_data\\participants\\' char(sprintf("%i", SUBJECT_NUM)) '\\cleaned\\'];
save_to_folder_path = 'E:\EEG_working\EEG_data\prepared_features\no_ica\';

% feature_func_list = {@GetBandPower, @GetMean, @GetVariance, @GetRMS};
% feature_folder_names = {'bandpower', 'mean', 'variance', 'rms'};

feature_func_list = {@GetSpectralEntropy};
feature_folder_names = {'pentropy'};


%% calc features
for dur = 1:3
    loadfile = char(sprintf("%is_clean.set", durations(dur)));

    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_loadset('filename',loadfile,'filepath',datapath );
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    EEG = eeg_checkset( EEG );
    base_eeg = EEG;
    
    set_name = char(sprintf("%is_read", durations(dur)));
    EEG = pop_selectevent( base_eeg, 'type',{'R  1'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'setname',set_name,'gui','off'); 
    read = EEG;

    set_name = char(sprintf("%is_listen", durations(dur)));
    EEG = pop_selectevent( base_eeg, 'type',{'L  1'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'setname',set_name,'gui','off'); 
    listen = EEG;
    
    set_name = char(sprintf("%is_rest", durations(dur)));
    EEG = pop_selectevent( base_eeg, 'type',{'N  1'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'setname',set_name,'gui','off'); 
    rest = EEG;

    for i = 1:size(read.data, 3)
        read_individuals(1,i) = pop_select( read, 'trial',i);
        listen_individuals(1,i) = pop_select( listen, 'trial',i);
        rest_individuals(1,i) = pop_select( rest, 'trial',i);

        % sub epoch duration
        if not(dur==1)
            read_sub_epochs(1,i) = eeg_regepochs(read_individuals(1,i), 'recurrence', 5, 'limits', [0 5]);
            listen_sub_epochs(1,i) = eeg_regepochs(listen_individuals(1,i), 'recurrence', 5, 'limits', [0 5]);
            rest_sub_epochs(1,i) = eeg_regepochs(rest_individuals(1,i), 'recurrence', 5, 'limits', [0 5]);

            % for adding epochs with overlap
%             read_sub_epochs(1,i) = eeg_regepochs(read_individuals(1,i), 'recurrence', 0.5, 'limits', [-0.5 4.5]);
%             listen_sub_epochs(1,i) = eeg_regepochs(listen_individuals(1,i), 'recurrence', 0.5, 'limits', [-0.5 4.5]);
%             rest_sub_epochs(1,i) = eeg_regepochs(rest_individuals(1,i), 'recurrence', 0.5, 'limits', [-0.5 4.5]);
        else % leave 5s trials be
            read_sub_epochs = read_individuals;
            listen_sub_epochs = listen_individuals;
            rest_sub_epochs = rest_individuals;
        end
    end

    for func = 1:length(feature_func_list)
        features = TrialContainer();
        feature_func = feature_func_list{func};
        func_folder_path = [save_to_folder_path feature_folder_names{func} '\'];

        temp_cell = {};
        % read
        parfor i = 1:length(read_sub_epochs) 
            current_eeg = read_sub_epochs(i);
            calced_features = feature_func(current_eeg);
            feat_epochs = Epoch.FromMatrix(calced_features, label=1);
            temp_cell{i} = feat_epochs;
        end
        for i = 1:length(temp_cell)
            features = features.addTrialFromEpochs(temp_cell{i});
        end

        temp_cell = {};
        % listen
        parfor i = 1:length(listen_sub_epochs) 
            current_eeg = listen_sub_epochs(i);
            calced_features = feature_func(current_eeg);
            feat_epochs = Epoch.FromMatrix(calced_features, label=2);
            temp_cell{i} = feat_epochs;
        end
        for i = 1:length(temp_cell)
            features = features.addTrialFromEpochs(temp_cell{i});
        end
        
        temp_cell = {};
        % rest
        parfor i = 1:length(rest_sub_epochs) 
            current_eeg = rest_sub_epochs(i);
            calced_features = feature_func(current_eeg);
            feat_epochs = Epoch.FromMatrix(calced_features, label=0);
            temp_cell{i} = feat_epochs;
        end
        for i = 1:length(temp_cell)
            features = features.addTrialFromEpochs(temp_cell{i});
        end
    
        savepath = [func_folder_path char(sprintf("%i", SUBJECT_NUM)) '\'];
        mkdir([func_folder_path char(sprintf("%i", SUBJECT_NUM))])
        savename = char(sprintf("%is_features.mat", durations(dur)));
        save([savepath savename], "features");
    
    end
    clear read_individuals read_sub_epochs listen_individuals listen_sub_epochs rest_individuals rest_sub_epochs
end
end
toc

%% helper functions
function [delta, theta, alpha, beta, gamma] = GetSubBands (EEG)
    arguments
        EEG
    end
    delta = pop_eegfiltnew(EEG, 'locutoff', 1, 'hicutoff', 4);
    theta = pop_eegfiltnew(EEG, 'locutoff', 4, 'hicutoff', 8);
    alpha = pop_eegfiltnew(EEG, 'locutoff', 8, 'hicutoff', 12);
    beta  = pop_eegfiltnew(EEG, 'locutoff', 12, 'hicutoff', 30);
    gamma = pop_eegfiltnew(EEG, 'locutoff', 30, 'hicutoff', 50);
end


% takes a single trials data, i.e. run in loop for all trials
% feats = epochs/features (r/c) 
function feats = GetBandPower(EEG)
    arguments
        EEG
    end
    num_electrodes = size(EEG.data, 1);
    num_epochs = size(EEG.data, 3);
    feats = [];
    [delta, theta, alpha, beta, gamma] = GetSubBands(EEG);
    for electrode = 1:num_electrodes
        electrode_feats = [];
        delta_electrode_data = cast(squeeze(delta.data(electrode,:,:)), 'double');
        theta_electrode_data = cast(squeeze(theta.data(electrode,:,:)), 'double');
        alpha_electrode_data = cast(squeeze(alpha.data(electrode,:,:)), 'double');
        beta_electrode_data  = cast(squeeze(beta.data(electrode,:,:)),  'double');
        gamma_electrode_data = cast(squeeze(gamma.data(electrode,:,:)), 'double');
        if num_epochs == 1
            delta_DE = bandpower(delta_electrode_data(:));
            theta_DE = bandpower(theta_electrode_data(:));
            alpha_DE = bandpower(alpha_electrode_data(:));
            beta_DE  = bandpower(beta_electrode_data(:));
            gamma_DE = bandpower(gamma_electrode_data(:));
            electrode_feats = [electrode_feats; delta_DE, theta_DE, alpha_DE, beta_DE, gamma_DE];
        else
            for epoch = 1:num_epochs
                delta_DE = bandpower(delta_electrode_data(:,epoch));
                theta_DE = bandpower(theta_electrode_data(:,epoch));
                alpha_DE = bandpower(alpha_electrode_data(:,epoch));
                beta_DE  = bandpower(beta_electrode_data(:,epoch));
                gamma_DE = bandpower(gamma_electrode_data(:,epoch));
                electrode_feats = [electrode_feats; delta_DE, theta_DE, alpha_DE, beta_DE, gamma_DE];
            end
        end
        feats = [feats, electrode_feats];
    end
end

% takes a single trials data, i.e. run in loop for all trials
% feats = epochs/features (r/c) 
function feats = GetSpectralEntropy(EEG)
    arguments
        EEG
    end
    num_electrodes = size(EEG.data, 1);
    num_epochs = size(EEG.data, 3);
    feats = [];
    delta = pop_eegfiltnew(EEG, 'locutoff', 1, 'hicutoff', 4);
    for electrode = 1:num_electrodes
        electrode_feats = [];
        delta_electrode_data = cast(squeeze(delta.data(electrode,:,:)), 'double');
        if num_epochs == 1
            delta_DE = pentropy(delta_electrode_data(:), 250, Instantaneous=false);
            electrode_feats = [electrode_feats; delta_DE];
        else
            for epoch = 1:num_epochs
                delta_DE = pentropy(delta_electrode_data(:,epoch), 250, Instantaneous=false);
                electrode_feats = [electrode_feats; delta_DE];
            end
        end
        feats = [feats, electrode_feats];
    end
end

% takes a single trials data, i.e. run in loop for all trials
% feats = epochs/features (r/c) 
function feats = GetMean(EEG)
    arguments
        EEG
    end
    num_electrodes = size(EEG.data, 1);
    num_epochs = size(EEG.data, 3);
    feats = [];
    for electrode = 1:num_electrodes
        electrode_feats = [];
        electrode_data = cast(squeeze(EEG.data(electrode,:,:)), 'double');
        if num_epochs == 1
            electrode_epoch_mean = mean(electrode_data(:));
            electrode_feats = [electrode_feats; electrode_epoch_mean];
        else
            for epoch = 1:num_epochs
                electrode_epoch_mean = mean(electrode_data(:,epoch));
                electrode_feats = [electrode_feats; electrode_epoch_mean];
            end
        end
        feats = [feats, electrode_feats];
    end
end

% takes a single trials data, i.e. run in loop for all trials
% feats = epochs/features (r/c) 
function feats = GetVariance(EEG)
    arguments
        EEG
    end
    num_electrodes = size(EEG.data, 1);
    num_epochs = size(EEG.data, 3);
    feats = [];
    for electrode = 1:num_electrodes
        electrode_feats = [];
        electrode_data = cast(squeeze(EEG.data(electrode,:,:)), 'double');
        if num_epochs == 1
            electrode_epoch_feat = var(electrode_data(:));
            electrode_feats = [electrode_feats; electrode_epoch_feat];
        else
            for epoch = 1:num_epochs
                electrode_epoch_feat = var(electrode_data(:,epoch));
                electrode_feats = [electrode_feats; electrode_epoch_feat];
            end
        end
        feats = [feats, electrode_feats];
    end
end

% takes a single trials data, i.e. run in loop for all trials
% feats = epochs/features (r/c) 
function feats = GetRMS(EEG)
    arguments
        EEG
    end
    num_electrodes = size(EEG.data, 1);
    num_epochs = size(EEG.data, 3);
    feats = [];
    for electrode = 1:num_electrodes
        electrode_feats = [];
        electrode_data = cast(squeeze(EEG.data(electrode,:,:)), 'double');
        if num_epochs == 1
            electrode_epoch_feat = rms(electrode_data(:));
            electrode_feats = [electrode_feats; electrode_epoch_feat];
        else
            for epoch = 1:num_epochs
                electrode_epoch_feat = rms(electrode_data(:,epoch));
                electrode_feats = [electrode_feats; electrode_epoch_feat];
            end
        end
        feats = [feats, electrode_feats];
    end
end