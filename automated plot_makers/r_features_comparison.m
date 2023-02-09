function r_features_comparison(data_folder, subject_range, classification_selection, save_flag)

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
    b2_m = [];
    b2_s = [];
    
    for i = 1:length(feature_cat_options)
        feature_cat = feature_cat_options(i); 
        
        [svm_k_m, svm_k_s, svm_b_m, svm_b_s, svm_b2_m, svm_b2_s] = get_rand_clasifier_feature_data(data_folder, subject_range, @fitcsvm, feature_cat, classification_range);
        [discr_k_m, discr_k_s, discr_b_m, discr_b_s, discr_b2_m, discr_b2_s] = get_rand_clasifier_feature_data(data_folder, subject_range, @fitcdiscr, feature_cat, classification_range);
        [knn_k_m, knn_k_s, knn_b_m, knn_b_s, knn_b2_m, knn_b2_s] = get_rand_clasifier_feature_data(data_folder, subject_range, @fitcknn, feature_cat, classification_range);
           
        k_m = [k_m, mean([svm_k_m; discr_k_m; knn_k_m])];
        k_s = [k_s, mean([svm_k_s; discr_k_s; knn_k_s])];
        b_m = [b_m, mean([svm_b_m; discr_b_m; knn_b_m])];
        b_s = [b_s, mean([svm_b_s; discr_b_s; knn_b_s])];
        b2_m = [b2_m, mean([svm_b2_m; discr_b2_m; knn_b2_m])];
        b2_s = [b2_s, mean([svm_b2_s; discr_b2_s; knn_b2_s])];
    end
    
    k_m = k_m([2,3,5,6,8,9,11,12]);
    k_s = k_s([2,3,5,6,8,9,11,12]);
    b_m = b_m([2,3,5,6,8,9,11,12]);
    b_s = b_s([2,3,5,6,8,9,11,12]);
    b2_m = b2_m([2,3,5,6,8,9,11,12]);
    b2_s = b2_s([2,3,5,6,8,9,11,12]);
    
    tick_labels = {'15', '60', '15', '60', '15', '60', '15', '60', '15', '60'};
    
    %% graphing
    f = figure;
    hold on;
    ymin = 25;
    ymax = 98;
    % shading
    x = [2.5 2.5 4.5 4.5];
    y = [0 ymax ymax 0];
    patch(x, y, 'k', 'FaceColor', [40 40 40]/255, 'FaceAlpha', 0.1, 'EdgeColor', 'none')
    patch(x+4, y, 'k', 'FaceColor', [40 40 40]/255, 'FaceAlpha', 0.1, 'EdgeColor', 'none')
    % bar data
    means = [b_m; b2_m; k_m]';
    b = bar(means, 0.9, 'grouped');
    b(1).FaceColor = [0.6350 0.0780 0.1840];
    b(2).FaceColor = [0.9290 0.6940 0.1250];
    b(3).FaceColor = [0 0.4470 0.7410];
    % labeling
    % expression = '(^|\.)\s*.';
    % replace = '${upper($0)}';
    % feature_cat_title = regexprep(feature_cat,expression,replace);
    title_str = sprintf("Comparison of Feature Performance Using %s with True Labels", classification_name);
    title(title_str)
    set(gca, 'xtick', [1:15], 'xticklabel', tick_labels)
    ylabel("Accuracy (%)")
    xlabel("Trial Duration (s)")
    ylim([ymin ymax])
    xlim([0.5 8.5]) % 10.5 for 'All'
    text(1.5, ymax-2, "Bandpower", 'HorizontalAlignment', 'center', 'fontweight','bold')
    text(3.5, ymax-2, "Mean", 'HorizontalAlignment', 'center', 'fontweight','bold')
    text(5.5, ymax-2, "RMS", 'HorizontalAlignment', 'center', 'fontweight','bold')
    text(7.5, ymax-2, "Variance", 'HorizontalAlignment', 'center', 'fontweight','bold')
    % text(14, ymax-2, "All", 'HorizontalAlignment', 'center', 'fontweight','bold')
    plot([0 16], [50 50], '--r')
    
    % error bars
    [ngroups, nbars] = size(means);
    groupwidth = min(0.8, nbars/(nbars + 1.5));
    errors = [k_s; b_s; b2_s]';
    for i = 1:nbars
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        errorbar(x, means(:,i), errors(:,i), 'k', 'linestyle', 'none');
    end
    
    f_leg = legend(["", "", "trial random/k-fold", "trial random/block", "epoch random/k-fold", "chance"], 'location', 'SW');
    f_leg.BoxFace.ColorType='truecoloralpha';
    f_leg.BoxFace.ColorData=uint8(255*[1 1 1 0.6]');
    
    %set size
    set(f,'Position',[10 10 1050 440])
    
    if save_flag
        mkdir("results/plots/all_feat_comparison")
        plot_savename = char(sprintf("results/plots/all_feat_comparison/r %s.png", strrep(save_name, '/', '_')));
        saveas(f , plot_savename);
    end

end