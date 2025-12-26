function [firtSpr,max_val,response]= positionCheck(response_cf,psr)
    next_response = response_cf;
    [spr,max_val, ~] = calculateSPR(next_response);
    firtSpr = spr;
    % while spr > 0.9 && psr > 7.5
    %     [spr, next_response] = calculateSPR(next_response);
    % end
    response = next_response;
end

function [SPR,max_val, next_response] = calculateSPR(response_cf)
    [max_val, max_idx] = max(response_cf(:));
    [row, col] = ind2sub(size(response_cf), max_idx);

    next_response = response_cf;
    r_range = max(1, row - 5):min(size(response_cf, 1), row + 5);
    c_range = max(1, col - 5):min(size(response_cf, 2), col + 5);
    next_response(r_range, c_range) = 0;
    [sub_max_val, ~] = max(next_response(:));

    SPR = sub_max_val / max_val;
end
