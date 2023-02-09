clear;

save_flag = 0;
subject_range = 5:16;

data_folder = 'no_ica';%'5s_50p_over';

% TODO Nov8 test this with 'all' features
%% feature comparison plots
% for classification_selection = 1:2
%     s_features_comparison(data_folder, subject_range, classification_selection, save_flag);
%     r_features_comparison(data_folder, subject_range, classification_selection, save_flag);
% end

%% classifier averaged features
for feature_cat = ["bandpower"] %"pentropy" "rms" "variance"]%["mean"]
    s_classifier_average_for_feature(data_folder, subject_range, feature_cat, 2, save_flag);
    r_classifier_average_for_feature(data_folder, subject_range, feature_cat, 2, save_flag);
end

