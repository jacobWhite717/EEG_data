function s_features_comparison(data_folder, subject_range, classification_selection, save_flag)

    classification_ranges = {1:3, 4:6, 7:9};
    classification_range = classification_ranges{classification_selection};
    classification_names = ["High Seperability Classes (Read/Rest)", "Low Seperability Classes (Listen/Rest)", "High Seperability Classes (Read/Listen)"];
    classification_name = classification_names(classification_selection);
    save_names = ["Read/Rest", "Listen/Rest", "Read/Listen"];
    save_name = save_names(classification_selection);
    
    feature_cat_options = ["bandpower", "mean", "rms", "variance"]; % all/bandpower/mean/rms/variance
    
    k_m = [];
    k_s = [];
    b_m = [];
    b_s = [];
    
    for i = 1:length(feature_cat_options)
        feature_cat = feature_cat_options(i); 
        
        [svm_k_m, svm_k_s, svm_b_m, svm_b_s] = get_clasifier_feature_data(data_folder, subject_range, @fitcsvm, feature_cat, classification_range);
        [discr_k_m, discr_k_s, discr_b_m, discr_b_s] = get_clasifier_feature_data(data_folder, subject_range, @fitcdiscr, feature_cat, classification_range);
        [knn_k_m, knn_k_s, knn_b_m, knn_b_s] = get_clasifier_feature_data(data_folder, subject_range, @fitcknn, feature_cat, classification_range);
        
        k_m = [k_m, mean([svm_k_m; discr_k_m; knn_k_m])];
        k_s = [k_s, mean([svm_k_s; discr_k_s; knn_k_s])];
        b_m = [b_m, mean([svm_b_m; discr_b_m; knn_b_m])];
        b_s = [b_s, mean([svm_b_s; discr_b_s; knn_b_s])];
    end
    
    tick_labels = {'5','15', '60', '5', '15', '60', '5', '15', '60', '5', '15', '60', '5', '15', '60'};
    
    %% graphing
    f = figure;
    hold on;
    % 30/95 for option 2
    if classification_selection == 2
        ymin = 30;
        ymax = 95;
    else
        ymin = 40;
        ymax = 105;
    end
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
    % title_str = sprintf("%s Classification (True Labels) Feature Performance Comparison", classification_name);
    title_str = sprintf("Comparison of Feature Performance Using %s with True Labels", classification_name);
    title(title_str)
    set(gca, 'xtick', [1:15], 'xticklabel', tick_labels)
    ylabel("Accuracy (%)")
    xlabel("Trial Duration (s)")
    ylim([ymin ymax])
    xlim([0.5 12.5]) % 15.5 for 'All'
    text(2, ymax-2, "Bandpower", 'HorizontalAlignment', 'center', 'fontweight','bold')
    text(5, ymax-2, "Mean", 'HorizontalAlignment', 'center', 'fontweight','bold')
    text(8, ymax-2, "RMS", 'HorizontalAlignment', 'center', 'fontweight','bold')
    text(11, ymax-2, "Variance", 'HorizontalAlignment', 'center', 'fontweight','bold')
    % text(14, ymax-2, "All", 'HorizontalAlignment', 'center', 'fontweight','bold')
    plot([0.5 3.5], [k_m(1) k_m(1)], '--k')
    plot([3.5 6.5], [k_m(4) k_m(4)], '--k')
    plot([6.5 9.5], [k_m(7) k_m(7)], '--k')
    plot([9.5 12.5], [k_m(10) k_m(10)], '--k')
    % plot([12.5 15.5], [k_m(13) k_m(13)], '--k')
    
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
    set(f,'Position',[10 10 1050 440])
    
    if save_flag
        mkdir("results/plots/all_feat_comparison")
        plot_savename = char(sprintf("results/plots/all_feat_comparison/s %s.png", strrep(save_name, '/', '_')));
        saveas(f , plot_savename);
    end

end