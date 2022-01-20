function [locs] = R_Correction(sample,tm,fs,locs)
    %%Correction of R 
    correct = true
    for x= 1:length(locs)
        if sample(fix(locs(x)*fs))< sample(fix((locs(x)*fs))-1)
            while correct
                if sample(fix(locs(x)*fs)) < sample(fix((locs(x)*fs))-1)
                    locs(x) = locs(x)-1/fs
                else 
                    if sample(fix(locs(x)*fs)) < sample(fix((locs(x)*fs))-10)
                        locs(x) = locs(x)-1/fs
                    else
                        correct = false
                    end 
                end
            end          
        elseif sample(fix(locs(x)*fs))< sample(fix((locs(x)*fs))+1)   
            while correct
                if sample(fix(locs(x)*fs)) < sample(fix((locs(x)*fs))+1)
                    locs(x) = locs(x)+1/fs
                else
                    if sample(fix(locs(x)*fs)) < sample(fix((locs(x)*fs))+10)
                        locs(x) = locs(x)+1/fs
                    else
                        correct = false
                    end 
                    
                end
            end
        end
        correct = true
    end
end

