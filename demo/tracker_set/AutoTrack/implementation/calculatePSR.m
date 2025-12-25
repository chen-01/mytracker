% 用来判断跟踪是否置信。如果 PSR 很低，说明主峰不明显，可能跟丢了。
function PSR = calculatePSR(response_cf)
    cf_max = max(response_cf(:));
    cf_average = mean(response_cf(:)); % 均值
    cf_sigma = sqrt(var(response_cf(:))); % 标准差
    PSR = (cf_max - cf_average) / cf_sigma;
end


