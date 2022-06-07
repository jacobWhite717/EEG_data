clear;

SUBJECT_NUM = 4;

trial_perms = flip(perms([5, 15, 30, 60]));
trial_perm = trial_perms(SUBJECT_NUM,:);

buffer_duration = [0, 2, 0, 0];
sampling_rate = 250;

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
filepath = ['E:\\EEG_working\\EEG_data\\participants\\' char(sprintf("%i", SUBJECT_NUM)) '\\cleaned\\'];
filename = 'all.set';
EEG = pop_loadset('filename',filename,'filepath',filepath);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, length(ALLEEG) );
cleaned_all = EEG;

loadname = sprintf("participants/%i/cleaned/durations.mat", SUBJECT_NUM);
load(loadname)

for dur = 1:4
    if dur == 1
        start_point = 1;
        end_point = down_sampled_points(1);
    else
        start_point = end_point+1;
        end_point = start_point+down_sampled_points(dur)-1;
    end

    % cut off data section by duration
    set_name = char(sprintf("%is_cleaned", trial_perm(dur)));
    EEG = pop_select( cleaned_all, 'point',[start_point, end_point] );
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'setname',set_name,'gui','off'); 
    EEG = eeg_checkset( EEG );
    
    % select only relevant events
    set_name = char(sprintf("%is_events", trial_perm(dur)));
    EEG = pop_selectevent( EEG, 'type',{'N  1','R  1'},'deleteevents','on');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'setname',set_name,'gui','off'); 
    EEG = eeg_checkset( EEG );
       
    % get relevant epochs
    set_name = char(sprintf("%is_epochs", trial_perm(dur)));
    EEG = pop_epoch( EEG, { 'N  1'  'R  1' }, [0  trial_perm(dur)+buffer_duration(SUBJECT_NUM)], 'newname', set_name, 'epochinfo', 'yes');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'gui','off'); 
    EEG = eeg_checkset( EEG );

    if not(buffer_duration(SUBJECT_NUM) == 0)
        % adjust latencies
        for i = 1:length(EEG.event)
            EEG = pop_editeventvals(EEG,'changefield',{i,'latency',buffer_duration(SUBJECT_NUM)*1000-1/sampling_rate});
            [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
        end
    
        % crop epochs
        set_name = char(sprintf("%is_epochs", trial_perm(dur)));
        EEG = pop_select( EEG, 'time',[buffer_duration(SUBJECT_NUM)-1/sampling_rate trial_perm(dur)+buffer_duration(SUBJECT_NUM)] );
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'setname',set_name,'gui','off'); 
    end
    
    save_name = char(sprintf("%is_clean.set", trial_perm(dur)));
    file_path = ['E:\\EEG_working\\EEG_data\\participants\\' char(sprintf("%i", SUBJECT_NUM)) '\\cleaned\\'];
    if dur == 1
        mkdir(file_path);
    end
    EEG = pop_saveset( EEG, 'filename',save_name,'filepath',file_path);
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
end