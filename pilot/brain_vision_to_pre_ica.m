clear;

%% setup
SUBJECT_NUM = 5;
trial_perms = flip(perms([5, 15, 30, 60]));
trial_perm = trial_perms(SUBJECT_NUM,:);

starting_block = 2;
blocks_per_dur = 3;

resample_rate = 250;

%%
dur_num_points = zeros(4,1);

[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
for dur = 1:4
    for block = 1:blocks_per_dur 
        folder_loc = ['E:\EEG_working\EEG_data\participants\' sprintf('%i', SUBJECT_NUM) '\'];
        file_loc = char(sprintf('bl%04i.vhdr', (dur-1)*blocks_per_dur+starting_block-1+block));
        EEG = pop_loadbv(folder_loc, file_loc);
        set_name = sprintf('%is_b%i', trial_perm(dur), block);
        [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'setname',set_name,'gui','off'); 
        EEG = eeg_checkset( EEG );
        dur_num_points(dur) = dur_num_points(dur)+EEG.pnts;
    end
end
down_sampled_points = dur_num_points/2;

EEG = pop_mergeset( ALLEEG, [1:4*blocks_per_dur], 0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'setname','all_data','gui','off'); 

EEG = pop_resample( EEG, resample_rate);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'setname','all_data_resampled','gui','off'); 

EEG = pop_eegfiltnew(EEG, 'locutoff',0.5,'hicutoff',55,'plotfreqz',0);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'setname','all_data_fir','gui','off'); 

EEG = clean_artifacts(EEG, 'Highpass', 'off', 'WindowCriterion', 0.35);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'setname','raw_cleaned','gui','off'); 

EEG = pop_interp(EEG, ALLEEG(end-1).chanlocs, 'spherical');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'setname','raw_cleaned_chans_restored','gui','off'); 

EEG = pop_reref(EEG, []);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'setname','raw_cleaned_complete','gui','off'); 
cleaned_all = EEG;

file_path = ['E:\\EEG_working\\EEG_data\\participants\\' char(sprintf("%i", SUBJECT_NUM)) '\\cleaned\\'];
mkdir(file_path);
save_name = char('all.set');
EEG = pop_saveset( cleaned_all, 'filename',save_name,'filepath',file_path);

file_path = ['E:\\EEG_working\\EEG_data\\participants\\' char(sprintf("%i", SUBJECT_NUM)) '\\cleaned\\'];
save_name = 'durations.mat';
save([file_path save_name], "down_sampled_points");


% EEG = pop_loadset('filename','all.set','filepath','E:\\EEG_working\\EEG_data\\participants\\1\\cleaned\\');
% [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, length(ALLEEG) );
% cleaned_all = EEG;

%%
% set 1 split
% for dur = 1:4
%     if dur == 1
%         start_point = 1;
%         end_point = down_sampled_points(1);
%     else
%         start_point = end_point+1;
%         end_point = start_point+down_sampled_points(dur)-1;
%     end
% 
%     % cut off data section by duration
%     set_name = char(sprintf("%is_cleaned", trial_perm(dur)));
%     EEG = pop_select( cleaned_all, 'point',[start_point, end_point] );
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'setname',set_name,'gui','off'); 
%     EEG = eeg_checkset( EEG );
%     
%     % select only relevant events
% %     set_name = char(sprintf("%is_events", trial_perm(dur)));
% %     EEG = pop_selectevent( EEG, 'type',{'N  1','R  1'},'deleteevents','on');
% %     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'setname',set_name,'gui','off'); 
% %     EEG = eeg_checkset( EEG );
%     
%     % get relevant epochs
%     set_name = char(sprintf("%is_epochs", trial_perm(dur)));
%     EEG = pop_epoch( EEG, { 'N  1'  'R  1' }, [0  trial_perm(dur)], 'newname', set_name, 'epochinfo', 'yes');
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, length(ALLEEG),'gui','off'); 
%     EEG = eeg_checkset( EEG );
%     
%     save_name = char(sprintf("%is_clean.set", trial_perm(dur)));
%     file_path = ['E:\\EEG_working\\EEG_data\\participants\\' char(sprintf("%i", SUBJECT_NUM)) '\\cleaned\\'];
%     if dur == 1
%         mkdir(file_path);
%     end
%     EEG = pop_saveset( EEG, 'filename',save_name,'filepath',file_path);
%     [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
% end


