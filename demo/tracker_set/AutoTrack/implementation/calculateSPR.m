function SPR = calculateSPR(response_cf)
    [max_val, max_idx] = max(response_cf(:));
    [row, col] = ind2sub(size(response_cf), max_idx);

    temp_response = response_cf;
    r_range = max(1, row - 5):min(size(response_cf, 1), row + 5);
    c_range = max(1, col - 5):min(size(response_cf, 2), col + 5);
    temp_response(r_range, c_range) = 0;
    [sub_max_val, ~] = max(temp_response(:));

    SPR = sub_max_val / max_val;
end