function s_classifier_average_for_feature(data_folder, subject_range, feature_cat, c_disp, save_flag)

    [svm_k_m, svm_k_s, svm_b_m, svm_b_s] = get_clasifier_feature_data(data_folder, subject_range, @fitcsvm, feature_cat);
    [discr_k_m, discr_k_s, discr_b_m, discr_b_s] = get_clasifier_feature_data(data_folder, subject_range, @fitcdiscr, feature_cat);
    [knn_k_m, knn_k_s, knn_b_m, knn_b_s] = get_clasifier_feature_data(data_folder, subject_range, @fitcknn, feature_cat);
    
    k_m = mean([svm_k_m; discr_k_m; knn_k_m]);
    k_s = mean([svm_k_s; discr_k_s; knn_k_s]);
    b_m = mean([svm_b_m; discr_b_m; knn_b_m]);
    b_s = mean([svm_b_s; discr_b_s; knn_b_s]);
    
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
    means = [k_m; b_m]';
    b = bar(means, 0.9, 'grouped');
    b(1).FaceColor = [0 0.4470 0.7410];
    b(2).FaceColor = [0.6350 0.0780 0.1840];
    % labeling
    expression = '(^|\.)\s*.';
    replace = '${upper($0)}';
    feature_cat_title = regexprep(feature_cat,expression,replace);
    title_str = sprintf("Across-Classifier Averaged Accuracies Using %s Features with True Labels", feature_cat_title);
    title(title_str)
    set(gca, 'xtick', [1:9], 'xticklabel', tick_labels)
    ylabel("Accuracy (%)")
    xlabel("Trial Duration (s)")
    ylim([ymin ymax])
    if c_disp == 2
        xlim([0.5 6.5])
    elseif c_disp == 3
        xlim([0.5 9.5])
    end
    text(2, ymax-2, "High Class Seperability", 'HorizontalAlignment', 'center', 'fontweight','bold')
    text(2, ymax-5, "(Read/Rest)", 'HorizontalAlignment', 'center')
    text(5, ymax-2, "Low Class Seperability", 'HorizontalAlignment', 'center', 'fontweight','bold')
    text(5, ymax-5, "(Listen/Rest)", 'HorizontalAlignment', 'center')
    if c_disp == 3
        text(8, ymax-2, "High Class Seperability", 'HorizontalAlignment', 'center', 'fontweight','bold')
        text(8, ymax-5, "(Read/Listen)", 'HorizontalAlignment', 'center')
    end
        % plot([0 10], [50 50], '--k')
    plot([0.5 3.5], [k_m(1) k_m(1)], '--k')
    plot([3.5 6.5], [k_m(4) k_m(4)], '--k')
    plot([6.5 9.5], [k_m(7) k_m(7)], '--k')
    
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
    if c_disp == 2
        set(f,'Position',[10 10 700 440])
    elseif c_disp == 3
        set(f,'Position',[10 10 850 440])
    end

    if save_flag
        mkdir("results/plots/classifier_averaged")
        plot_savename = char(sprintf("results/plots/classifier_averaged/s %s %i class.png", feature_cat, c_disp));
        saveas(f , plot_savename);
    end

end