clear;
SUBJECT_NUM = 2;

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
file_path = ['E:\\EEG_working\\EEG_data\\participants\\' char(sprintf("%i", SUBJECT_NUM)) '\\cleaned\\'];
EEG = pop_loadset('filename','all.set','filepath',file_path);
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

% define parameters
numprocs = 1; % # of nodes
max_threads = 8; % # of threads
num_models = 1; % # of models of mixture ICA
max_iter = 1500; % max number of learning steps

% run amica
outdir = [ pwd '\participants\' char(sprintf("%i", SUBJECT_NUM)) '\' 'amicaouttmp' '\' ];

[weights,sphere,mods] = runamica15(EEG.data, 'num_models',num_models, 'outdir',outdir, ...
'numprocs', numprocs, 'max_threads', max_threads, 'max_iter',max_iter);

savefile = sprintf("ica_temp/%i/output.mat", SUBJECT_NUM);
save(savefile)