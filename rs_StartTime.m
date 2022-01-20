function [StartTime] = rs_StartTime(sample,locs,fs,tm,num)
peakLoc = locs(num)+1/fs
slope = zeros(1,40)
for x=1:1:length(slope)
    slope(x)= (sample(fix(peakLoc*fs)-(x-1))-sample(fix(peakLoc*fs)-(x-3)))/(tm(fix(peakLoc*fs)-(x-1))-tm(fix(peakLoc*fs)-(x-3)))
end 
slopeMin = islocalmin(slope)
temp = 1000000
xValue = 0 
for j=1:1:length(slopeMin)
    minmumSlope = abs(slope(j)*slopeMin(j))
    if (slopeMin(j)==1 &&minmumSlope < temp)
        if(minmumSlope == 0)
            xValue = (peakLoc*fs)-j
            break
        end
        temp = minmumSlope
        xValue = (peakLoc*fs)-j
        if(sample(fix(xValue)) < (1.2*sample(fix(xValue)-1)) && sample(fix(xValue)) < (1.2*sample(fix(xValue)-2)) && sample(fix(xValue)) < (1.2*sample(fix(xValue)-3)) && sample(fix(xValue)) < (1.2*sample(fix(xValue)-4)) && sample(fix(xValue)) < (1.2*sample(fix(xValue)-5)))
            break
        end
    end
end
StartTime = tm(fix(xValue))
end

