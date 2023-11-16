% TODO implement c_disp like in s version

function r_classifier_average_for_feature(data_folder, subject_range, feature_cat, c_disp, save_flag)

    [svm_k_m, svm_k_s, svm_b_m, svm_b_s, svm_b2_m, svm_b2_s] = get_rand_clasifier_feature_data(data_folder, subject_range, @fitcsvm, feature_cat);
    [discr_k_m, discr_k_s, discr_b_m, discr_b_s, discr_b2_m, discr_b2_s] = get_rand_clasifier_feature_data(data_folder, subject_range, @fitcdiscr, feature_cat);
    [knn_k_m, knn_k_s, knn_b_m, knn_b_s, knn_b2_m, knn_b2_s] = get_rand_clasifier_feature_data(data_folder, subject_range, @fitcknn, feature_cat);
    
    k_m = mean([svm_k_m; discr_k_m; knn_k_m]);
    k_m = k_m([2,3,5,6,8,9]);
    k_s = mean([svm_k_s; discr_k_s; knn_k_s]);
    k_s = k_s([2,3,5,6,8,9]);
    b_m = mean([svm_b_m; discr_b_m; knn_b_m]);
    b_m = b_m([2,3,5,6,8,9]);
    b_s = mean([svm_b_s; discr_b_s; knn_b_s]);
    b_s = b_s([2,3,5,6,8,9]);
    b2_m = mean([svm_b2_m; discr_b2_m; knn_b2_m]);
    b2_m = b2_m([2,3,5,6,8,9]);
    b2_s = mean([svm_b2_s; discr_b2_s; knn_b2_s]);
    b2_s = b2_s([2,3,5,6,8,9]);
    
    tick_labels = {'15', '60', '15', '60', '15', '60'};
    
    %% graphing
    f = figure;
    hold on;
    ymin = 25;
    ymax = 98;
    % shading
    x = [2.5 2.5 4.5 4.5];
    y = [0 ymax ymax 0];
    patch(x, y, 'k', 'FaceColor', [40 40 40]/255, 'FaceAlpha', 0.1, 'EdgeColor', 'none')
    patch(x+2, y, 'k', 'FaceColor', [40 40 40]/255, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    % bar data
    % means = [k_m; b_m; b2_m]';
    means = [b_m; b2_m; k_m]';
    b = bar(means, 0.9, 'grouped');
    b(1).FaceColor = [0.6350 0.0780 0.1840];
    b(2).FaceColor = [0.9290 0.6940 0.1250];
    b(3).FaceColor = [0 0.4470 0.7410];
    % labeling
    expression = '(^|\.)\s*.';
    replace = '${upper($0)}';
    feature_cat_title = regexprep(feature_cat,expression,replace);
    title_str = sprintf("Across-Classifier Averaged Accuracies Using %s Features with Randomized Labels", feature_cat_title);
    title(title_str)
    set(gca, 'xtick', [1:6], 'xticklabel', tick_labels)
    ylabel("Accuracy (%)")
    xlabel("Trial Duration (s)")
    ylim([ymin ymax])
    if c_disp == 2
        xlim([0.5 4.5])
    elseif c_disp == 3
        xlim([0.5 6.5])
    end
    text(1.5, ymax-2, "High Class Seperability", 'HorizontalAlignment', 'center', 'fontweight','bold')
    text(1.5, ymax-5, "(Read/Rest)", 'HorizontalAlignment', 'center')
    text(3.5, ymax-2, "Low Class Seperability", 'HorizontalAlignment', 'center', 'fontweight','bold')
    text(3.5, ymax-5, "(Listen/Rest)", 'HorizontalAlignment', 'center')
    if c_disp == 3
        text(5.5, ymax-2, "High Class Seperability", 'HorizontalAlignment', 'center', 'fontweight','bold')
        text(5.5, ymax-5, "(Read/Listen)", 'HorizontalAlignment', 'center')
    end
    plot([0 10], [50 50], '--r')
    
    % error bars
    [ngroups, nbars] = size(means);
    groupwidth = min(0.8, nbars/(nbars + 1.5));
    errors = [k_s; b_s; b2_s]';
    for i = 1:nbars
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        errorbar(x, means(:,i), errors(:,i), 'k', 'linestyle', 'none');
    end
    
    f_leg = legend(["", "", "trial random/k-fold", "trial random/block-wise", "epoch random/k-fold", "chance"], 'location', 'SW');
    f_leg.BoxFace.ColorType='truecoloralpha';
    f_leg.BoxFace.ColorData=uint8(255*[1 1 1 0.6]');
    
    %set size
    if c_disp == 2
        set(f,'Position',[10 10 700 440])
    elseif c_disp == 3
        set(f,'Position',[10 10 850 440])
    end

    if save_flag
        mkdir("results/plots/classifier_averaged")
        plot_savename = char(sprintf("results/plots/classifier_averaged/r %s %i class.png", feature_cat, c_disp));
        saveas(f , plot_savename);
    end

end