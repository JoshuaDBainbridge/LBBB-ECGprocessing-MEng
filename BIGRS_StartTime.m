function [STARTTIME] = BIGRS_StartTime(sample,locs,fs,tm,num)
    eleNum = 0 
        if (num == 1) 
            RRq_segment = sample(1:locs(num)*fs)
            RRq_segmentTime = tm(1:locs(num)*fs)
        else 
            RRq_segment = sample(locs(num-1)*fs:locs(num)*fs) 
            RRq_segmentTime = tm(locs(num-1)*fs:locs(num)*fs) 
        end
    for x=length(RRq_segment)-2:-1:2
        if(RRq_segment(x)>= RRq_segment(x-1))
        %%Check 10 timesetps after
        else
            if x >= 6
                if(RRq_segment(x)>= RRq_segment(x-5))
                else
                    eleNum = x
                    break;
                end
            else 
                eleNum = x
                break;
            end 
        end
    end
    STARTTIME = RRq_segmentTime(eleNum+1)
end

