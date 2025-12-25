% 用来判断跟踪是否置信。如果 PSR 很低，说明主峰不明显，可能跟丢了。
function PSR = calculatePSR(response_cf)
    cf_max = max(response_cf(:));
    cf_average = mean(response_cf(:)); % 均值
    cf_sigma = sqrt(var(response_cf(:))); % 标准差
    PSR = (cf_max - cf_average) / cf_sigma;
end

% 取值
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

function is_lost = checkFB(gamma_spr)
    %% --- 创新点 2 & 3: 自适应触发反向校验与形变感知 ---
    spr_threshold = 0.75; % SPR触发阈值
    need_fb_check = (gamma_spr > spr_threshold);
    fb_error = 0;

    if need_fb_check
        % 执行反向校验：用当前特征回溯前一帧
        % 这里的 backward_track 是你需要简单封装的函数，利用当前位置 patch 去前一帧找原位
        [back_pos, ~] = backward_track(current_feat, img_prev, target_pos_prev);
        fb_error = norm(back_pos - target_pos_prev);

        if fb_error > fb_threshold
            % 判定为漂移或遮挡
            is_lost = true;
        else
            % 判定为“良性形变”：响应低但路径一致
            if max_val < 0.4 * mean_max_val_history
                % 创新点 4: 存储为关键帧模板
                if numel(gallery) < max_gallery_size
                    gallery{end + 1} = current_feat;
                end

            end

            is_lost = false;
        end

    end

end

function [back_pos] = backward_track(current_feat, img_prev, pos_prev, target_sz, config)
    % current_feat: 当前帧在跟踪位置提取到的特征 (通常是 HOG+CN)
    % img_prev: 前一帧的原始图像
    % pos_prev: 前一帧目标的中心坐标 [y, x]
    % target_sz: 目标尺寸 [h, w]
    % config: 包含 search_area_scale (搜索区域倍数) 等参数

    % 1. 在前一帧 pos_prev 位置提取搜索区域
    % 使用 AutoTrack 内部的 get_subwindow 函数
    patch_prev_search = get_subwindow(img_prev, pos_prev, config.model_sz, ...
        config.search_sz, config.current_scale_factor);

    % 2. 提取该区域的特征
    % 使用 AutoTrack 内部的 get_features 函数
    feat_prev_search = get_features(patch_prev_search, config.features, config.cos_window);

    % 3. 进行频域互相关计算 (Fast Correlation)
    % 这里的 current_feat 作为“临时模板”，在 feat_prev_search 搜索区域内滑动
    % 计算公式：IFFT2( FFT2(Template) * conj(FFT2(Search_Area)) )
    current_feat_fft = fft2(current_feat);
    search_feat_fft = fft2(feat_prev_search);

    % 融合多通道特征响应
    response_cf = real(ifft2(sum(current_feat_fft .* conj(search_feat_fft), 3)));
    response_cf = fftshift(response_cf); % 将零频移到中心

    % 4. 寻找响应最大值点 (即反向追踪到的位置)
    [max_val, max_idx] = max(response_cf(:));
    [row, col] = ind2sub(size(response_cf), max_idx);

    % 5. 将相对偏移转换为图像绝对坐标
    % 计算相对于中心点的偏移
    center = size(response_cf) / 2;
    disp_y = (row - center(1)) * config.current_scale_factor;
    disp_x = (col - center(2)) * config.current_scale_factor;

    % 反向追踪到的坐标
    back_pos = [pos_prev(1) + disp_y, pos_prev(2) + disp_x];
end
