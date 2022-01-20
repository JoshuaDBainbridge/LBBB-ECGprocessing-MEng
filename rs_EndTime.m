function [EndTime] = rs_EndTime(sample,locs,fs,tm,num)
    
    if((num+1)>length(locs))
        RRwindow = sample(fix(locs(num)*fs):length(sample)-1)
        RRtime = locs(num):0.002:tm(length(tm))
    else 
        RRwindow = sample(locs(num)*fs:locs(num+1)*fs)
        RRtime = locs(num):0.002:locs(num+1)
    end 
    

    FindT= islocalmax(RRwindow);
    %Dicard last peak, use largest at peak of T wave 
    FindT_value = RRwindow(FindT)
    if((num+1)>length(locs))
        
    else
        FindT_value = FindT_value(1:length(FindT_value)-1)
    end
    %find max peak 
    TwavePeakValue = FindT_value(1)
    NumPeak = 1;
    for x=1:1:length(FindT_value)
        if(FindT_value(x) > TwavePeakValue)
            TwavePeakValue = FindT_value(x)
            NumPeak = x
        end
    end
    temp = RRtime(FindT)
    TwavePeakTime = temp(NumPeak)

    FindS = islocalmin(RRwindow)
    FindS_value = RRwindow(FindS)
    if(length(FindS_value)-1 == 0) %NEW 
    else 
    FindS_value = FindS_value(1:length(FindS_value)-1)
    end
    %find max peak 
    SwavePeakValue = FindS_value(1)
    SNumPeak = 1;
    for x=1:1:length(FindS_value)
        if(FindS_value(x) < SwavePeakValue)
            SwavePeakValue = FindS_value(x)
            SNumPeak = x
        end
    end
    temp = RRtime(FindS)
    SwavePeakTime = temp(SNumPeak)

    %% PLOT SLOPE 

    STwindow_value = RRwindow((SwavePeakTime-RRtime(1)+(1/fs))*fs:(TwavePeakTime-RRtime(1)+(1/fs))*fs)
    STwindow_time = RRtime((SwavePeakTime-RRtime(1)+(1/fs))*fs:(TwavePeakTime-RRtime(1)+(1/fs))*fs)
    slope = zeros(1,length(STwindow_value)-1)
    for x=6:1:length(STwindow_value)-5
        slope(x-5)= (STwindow_value(x+5)-STwindow_value(x-5))/(STwindow_time(x+5)-STwindow_time(x-5))
    end 
    slopeTime = 1:1:length(slope)
    slopeMin = islocalmin(slope)
    temp = 1000000
    xValue = 0 
    for j=1:1:length(slopeMin)
        minmumSlope = slope(j)*slopeMin(j)
        if(minmumSlope ~= 0 && minmumSlope < temp)
            temp = minmumSlope
            xValue = j
        end
    end
    %%FINAL 
    EndTime = STwindow_time(xValue)
end

