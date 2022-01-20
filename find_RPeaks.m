function [qrspeaks,locs,iwt_y, tm] = find_RPeaks(ecgsig,fs)
    wt= modwt(ecgsig,4,'sym4')

    wtrec= zeros(size(wt))
    wtrec(3:4,:)=wt(3:4,:)
    iwt_y = imodwt(wtrec,'sym4');
    iwt_y = abs(iwt_y).^2;

    temp = 0:1/fs: (1/fs)*(length(iwt_y))-(1/fs)
    tm = reshape(temp,[length(temp),1])

    [qrspeaks,locs] = findpeaks(iwt_y,tm,'MinPeakHeight',8*mean(iwt_y),...
    'MinPeakDistance',0.150);
    if(locs(1)<0.08)
        locs = locs(2:length(locs))
    end
    if(abs(locs(length(locs))-tm(length(tm)))<0.08)
        locs = locs(1:length(locs)-1)
    end
end

