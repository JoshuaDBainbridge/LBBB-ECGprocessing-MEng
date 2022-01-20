function [QRS_CLASS] = QRS_Classification(SIGNAL,SAMPLE_FREQUENCY,SMOOTH_VALUE)
    fs = SAMPLE_FREQUENCY;
    
    if SMOOTH_VALUE < 10 || SMOOTH_VALUE > 50
        SMOOTH_VALUE = 10; 
    end 
    sample_smooth = movmean(SIGNAL,SMOOTH_VALUE);
    [locs] = find_RPeaks(sample_smooth,fs);
    QRS_CLASS = zeros(1,length(locs));
    for x=1:1:length(locs)
        if(sample_smooth(fix(locs(x)*fs)) < 50)
            QRS_CLASS(x) = 1;
        end
    end
end

