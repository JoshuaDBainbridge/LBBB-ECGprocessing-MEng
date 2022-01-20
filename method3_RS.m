function [NUMBER_OF_COMPLEX,COMPLEX, QRSTIME, tm, sample_smooth] = method3_RS(signal, sampleFreq,complex,plots)
%%STEP 1: SETUP 
    fs = sampleFreq;
    sample = signal;                                                          
    sample_smooth = movmean(sample,10);
    sample_too_smooth = movmean(sample,20);
%%STEP 2: R Peaks, Number of Complexes
    [~,locs,~, tm] = find_RPeaks(sample_smooth,fs);                  %FUNCTION 1 --> wavelet transform 
    [locs_smooth] = R_Correction(sample_smooth,tm,fs,locs);                     %FUNCTION 2 --> Correction wavelet transform
    [locs] = R_Correction(sample,tm,fs,locs);                                   %FUNCTION 2 --> Correction wavelet transform
    NUMBER_OF_COMPLEX = length(locs);
    COMPLEX = zeros(5,1);
%%STEP 3: All Start times
    [STARTTIME] = BIGRS_StartTime(sample_too_smooth,locs_smooth,fs,tm,complex);
    if plots(1)
        figure 
        hold on 
        plot(tm, sample_smooth)
        for x=1:1:length(locs_smooth)
            xline(locs(x))
        end
        xline(STARTTIME)
    end 
%%STEP 4: R to R Peak Segmentation 
%     number_of_peaks = length(locs);
%     RR_LocsSeg = zeros(1,2);                                      %Declare 2D arrray 2 by N                                                         %-->            Seg1 ... SegN
%                                                                                     %--> SegStart 
%     QRS_StartSegment = zeros(1,number_of_peaks+1);                                   %--> SegEnd
%     for x=1:1:number_of_peaks
%         QRS_StartSegment(x) = BIGRS_StartTime(sample_too_smooth,locs_smooth,fs,tm,x);            %Create array of all RS start times
%     end
%     QRS_StartSegment(number_of_peaks+1) = tm(length(tm));                       %Add sample end time to array 
    
    RR_LocsSeg(1) = locs_smooth(complex);
    if complex+1 > length(locs_smooth)
        RR_LocsSeg(2) = tm(length(tm));
    else
        RR_LocsSeg(2) = BIGRS_StartTime(sample_too_smooth,locs_smooth,fs,tm,complex+1); 
    end
   
    number_of_steps = fix((RR_LocsSeg(2)-RR_LocsSeg(1))*fs);
    RR_Segment = ones(1,number_of_steps);            
    RR_TimeSegment = ones(number_of_steps,1);           
    
    seg_vals = sample(fix(RR_LocsSeg(1)*fs)+1:fix(RR_LocsSeg(2)*fs)+1);
    seg_time = tm(fix(RR_LocsSeg(1)*fs)+1:fix(RR_LocsSeg(2)*fs)+1);
    RR_Segment(1:length(seg_vals)) = seg_vals;                            %LENGTH OF SEGMENT-->((RR_LocsSeg(x,2)-RR_LocsSeg(x,1))*fs)+1
    RR_TimeSegment(1:length(seg_time),1) = seg_time;                        

    
    if plots(2)
        figure()
        hold on
        steps =fix((RR_LocsSeg(2)-RR_LocsSeg(1))*fs);
        plot(RR_TimeSegment(1:steps,1),RR_Segment(1:steps))
        xline(RR_LocsSeg(1))
        xline(RR_LocsSeg(2))
        title("STEP 2: RAW R-R Segment")    
    end

%%STEP 5: Smooth R-R, Take Derivates and Graph

    steps =fix((RR_LocsSeg(2)-RR_LocsSeg(1))*fs);
    RR_SegmentSmooth = movmean(RR_Segment(1:steps),10);                       %Smooth R-R Segment 

    slope = zeros(1,steps-2); 
    for x=2:1:length(slope)
        slope(x-1) = (RR_SegmentSmooth(x+1)-RR_SegmentSmooth(x-1))/(2*(1/fs)*100); %Take first derivative 
    end

    RR_localMax = islocalmax(RR_SegmentSmooth);                                  %FOR TESTING PROGRAM ONLY 
    RR_localMin = islocalmin(RR_SegmentSmooth);
    Slope_localMax = islocalmax(slope);
    Slope_localMin = islocalmin(slope);
    
    if plots(3)
        figure()
        subplot(3,1,1)
        plot(RR_TimeSegment(1:steps,1),RR_Segment(1:steps))
        title(["STEP 3: RAW R-R Segment"])
        subplot(3,1,2)
        hold on
        plot(RR_TimeSegment(1:steps-2,1),RR_SegmentSmooth(1,1:steps-2))
        plot(RR_TimeSegment(1:steps-2,1),slope)
        plot(RR_TimeSegment(RR_localMax),RR_SegmentSmooth(RR_localMax), '*r') 
        plot(RR_TimeSegment(RR_localMin),RR_SegmentSmooth(RR_localMin), '*b')
        title(["STEP 3: Smooth R-R Segment"])
        subplot(3,1,3)
        hold on
        yline(0)
        yline(-11.8)
        plot(RR_TimeSegment(1:steps-2,1),RR_SegmentSmooth(1,1:steps-2),'--k')
        plot(RR_TimeSegment(1:steps-2,1),slope)
        plot(RR_TimeSegment(RR_localMax),RR_SegmentSmooth(RR_localMax), '*r') 
        plot(RR_TimeSegment(RR_localMin),RR_SegmentSmooth(RR_localMin), '*b')
        plot(RR_TimeSegment(Slope_localMax),slope(Slope_localMax), '*y') 
        plot(RR_TimeSegment(Slope_localMin),slope(Slope_localMin), '*m')
        title(["STEP 3: Smooth R-R Segment"])
    end
%%STEP 6: Segment S min to T max
    flag = true;

    RR_localMax = islocalmax(RR_SegmentSmooth)
    RR_localMax = RR_localMax .* RR_SegmentSmooth
    [S_max_value S_max_time] = max(RR_localMax);                                %Find the hightest point in the segment 

    RR_localMin = islocalmin(RR_SegmentSmooth);
    RR_localMin = RR_localMin .* RR_SegmentSmooth;
    while flag
        [S_min_value S_min_time] = min(RR_localMin);                            %Find the lowest point in the segment 
        if (S_min_time > S_max_time)
            RR_localMin(S_min_time) = 0; 
        else
            flag = false;
        end
    end
    ST_SegmentSmooth = RR_SegmentSmooth(S_min_time:S_max_time);
    ST_Slope = slope(S_min_time:S_max_time);

    S_max_time = S_max_time * 1/fs;                                             %Adjust times to be in seconds 
    S_min_time = S_min_time * 1/fs;                                             %Adjust times to be in seconds  


    second_slope = zeros(1,length(ST_Slope)-2);                                 %Take second derivative 
    for x=2:1:length(second_slope)
        second_slope(x-1) = -1*(ST_Slope(x+1)-ST_Slope(x-1))/(2*(1/fs)*100);
    end
    [T_end_value, T_end_time]= min(second_slope);                               %Find min --> reflects the largest change in slope, merger of S and T wave
    T_end_time = T_end_time * 1/fs;
    T_end_time = T_end_time + S_min_time+ RR_LocsSeg(1,1);

    if plots(4)
        figure()
        hold on 
        plot(RR_TimeSegment(1:steps-2,1),RR_SegmentSmooth(1,1:steps-2),'--k')
        plot(RR_TimeSegment(1:steps-2,1),slope)
        plot((S_min_time+1/fs+ RR_LocsSeg(1,1):1/fs:S_max_time-1/fs+ RR_LocsSeg(1,1)),second_slope)
        plot(T_end_time,RR_SegmentSmooth(fix((T_end_time-RR_LocsSeg(1,1))*fs)+1),'*y')
        xline(S_min_time + RR_LocsSeg(1,1))
        xline(S_max_time + RR_LocsSeg(1,1))
    end
%%Step 7: Segment R peak to S max
    RT_SegmentSmooth = RR_SegmentSmooth(1:S_min_time*fs);
    RT_Slope = slope(1:S_min_time*fs);

    RS_start_time = 0 ;
    [y pos] = min(RT_Slope);
    pos = pos + 5;
    SegSlope = RT_Slope(pos:length(RT_Slope));
    SegSlope = movmean(SegSlope, 5);
    for x=2:1:length(SegSlope)
        if SegSlope(x-1) <= SegSlope(x)
        else
            test = x;
            RS_start_time = (test+pos)*(1/fs)+ RR_LocsSeg(1);
            break
        end
    end
    
    if plots(5)
        figure()
        hold on 
        plot(RR_TimeSegment(1:S_min_time*fs,1),RT_SegmentSmooth,'--k')
        plot(RR_TimeSegment(1:S_min_time*fs,1),RT_Slope,'r')
        xline(RS_start_time)
    end
%% Step 8: FULL QRS SEGEMENT 
    [R_START] = BIGRS_StartTime(sample_too_smooth,locs_smooth,fs,tm,complex);
    R_PEAK = locs_smooth(complex);
    R_END = RS_start_time;
    S_MIN = S_min_time + locs_smooth(complex);
    S_END = T_end_time-1/fs;

    QRS_SEGMENTSMOOTH = sample_smooth(fix(R_START*fs):fix(S_END*fs));
    QRS_SEGMENTTIME = tm(fix(R_START*fs):fix(S_END*fs));
    QRS_total_time = S_END - R_START;

    if plots(6)
        figure()
        hold on
        plot(QRS_SEGMENTTIME,QRS_SEGMENTSMOOTH)
        xline(R_START,'g')
        xline(R_PEAK,'b')
        xline(R_END,'m')
        xline(S_MIN,'y')
        xline(S_END,'r')
    end
%%Step 9: Accending Side Slur
    SLURTIME_A = 0; 
    AccendingSegment = sample_smooth(fix(R_START*fs)+20:fix(R_PEAK*fs)-10);
    AccendingTime = tm(fix(R_START*fs)+20:fix(R_PEAK*fs)-10);
    AccendingSlope = zeros(1,length(AccendingSegment)-2); 
    for x=2:1:length(AccendingSlope)
        AccendingSlope(x-1) = (AccendingSegment(x+1)-AccendingSegment(x-1))/(2*(1/fs)*100); %Take first derivative 
    end

    for x=1:1:length(AccendingSlope)-1
        if abs(AccendingSlope(x)) > abs(AccendingSlope(x+1))
            if AccendingSlope(x) <= 1
                SLURTIME_A = AccendingTime(2) + (x*1/fs);
                break
            end
        end
    end 
    
    if plots(7)
        figure ()
        hold on 
        plot(AccendingTime,AccendingSegment)
        plot(AccendingTime(2:length(AccendingTime)-1),AccendingSlope)
        if SLURTIME_A > 0
            xline(SLURTIME_A)
        end
    end
%%Step 10: Decending Side Slur
    SLURTIME_D = 0; 
    AccendingSegment = sample_smooth(fix(R_PEAK*fs)+10:fix(R_END*fs)-10);
    AccendingTime = tm(fix(R_PEAK*fs)+10:fix(R_END*fs)-10);
    AccendingSlope = zeros(1,length(AccendingSegment)-2); 
    for x=2:1:length(AccendingSlope)
        AccendingSlope(x-1) = (AccendingSegment(x+1)-AccendingSegment(x-1))/(2*(1/fs)*100); %Take first derivative 
    end

    for x=1:1:length(AccendingSlope)-1
        if AccendingSlope(x+1) < AccendingSlope(x)
            if abs(AccendingSlope(x+1))-abs(AccendingSlope(x)) > 10
                SLURTIME_D = AccendingTime(2) + (x*1/fs);
                break
            end
        end
    end 

    if plots(8)
        figure ()
        hold on 
        plot(AccendingTime(2:length(AccendingTime)-1),AccendingSlope)
        plot(AccendingTime,AccendingSegment)
        plot(AccendingTime(2:length(AccendingTime)-1),AccendingSlope)
        if SLURTIME_D > 0
            xline(SLURTIME_D)
        end
    end
%%Step 11 

    [R_START] = BIGRS_StartTime(sample_too_smooth,locs_smooth,fs,tm,complex);
    R_PEAK = locs_smooth(complex);
    R_END = RS_start_time;
    S_MIN = S_min_time + locs_smooth(complex);
    S_END = T_end_time-1/fs;

    QRS_SEGMENTSMOOTH = sample_smooth(fix(R_START*fs):fix(S_END*fs));
    QRS_SEGMENTTIME = tm(fix(R_START*fs):fix(S_END*fs));
    QRS_total_time = S_END - R_START;

    if plots(9)
        figure()
        hold on
        plot(QRS_SEGMENTTIME,QRS_SEGMENTSMOOTH)
        xline(R_START,'g')
        xline(R_PEAK,'b')
        xline(R_END,'m')
        xline(S_MIN,'y')
        xline(S_END,'r')
        if SLURTIME_A > 0
            xline(SLURTIME_A,'r')
        end
        if SLURTIME_D > 0
            xline(SLURTIME_D,'r')
        end
    end
    
    COMPLEX(1)= R_START;
    COMPLEX(2)= R_PEAK;
    COMPLEX(3)= S_END;
    COMPLEX(4)= SLURTIME_A;
    COMPLEX(5)= SLURTIME_D;
    
    QRSTIME = QRS_total_time;
%%=========================================================================
end

