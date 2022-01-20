function [StartTime,PeakTime,EndTime,tm] = method1_rs(signal,fs, complex)
    sample = signal;
    [~,locs,~, tm] = find_RPeaks(sample,fs);                %FUNCTION 1 --> wavelet transform 
    [locs] = R_Correction(sample,tm,fs,locs);                       %FUNCTION 2 --> Correction wavelet transform 
    % rS ENDTIME SEGMENTATION 
    [EndTime] = rs_EndTime(sample,locs,fs,tm,complex);                  %FUNCTION 3 --> Find the end time of the rS 
    % rS STARTTIME SEGMENTATION
    [StartTime] = rs_StartTime(sample,locs,fs,tm,complex);               %FUNCTION 4 --> Find the end time of the rS 
    PeakTime = locs(complex);
end

