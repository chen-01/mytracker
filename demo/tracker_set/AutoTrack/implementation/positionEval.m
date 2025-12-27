function pospre = positionEval(im, pos, sz, features, g_f, cos_window, global_feat_params, featureRatio, currentScaleFactor, ky, kx, use_sz, interp_sz)
    %% 1.Translation Estimation
    pixel_template = get_pixels(im, pos, round(sz * currentScaleFactor), sz); %从当前帧提取像素模板
    xt = get_features(pixel_template, features, global_feat_params); %获取像素模板的特征
    xtf = fft2(bsxfun(@times, xt, cos_window)); %对特征进行加窗以减少边界效应和傅里叶变换
    %通过将之前训练得到的滤波器g_f与当前帧的特征频域表示xtf的共轭相乘并求和，得到频域响应。permute函数用于重新排列维度，以便后续处理
    responsef = permute(sum(bsxfun(@times, conj(g_f), xtf), 3), [1 2 4 3]);
    % if we undersampled features, we want to interpolate the
    % response so it has the same size as the image patch
    %果响应的尺寸小于图像补丁的尺寸（即特征被欠采样），则使用resizeDFT2函数对响应的频域表示进行插值，使其尺寸与图像补丁匹配。interp_sz是插值后的尺寸
    responsef_padded = resizeDFT2(responsef, interp_sz);
    % response in the spatial domain
    %使用ifft2函数将频域响应responsef_padded逆变换回空间域，得到空间域响应response。'symmetric'参数确保了逆变换结果的对称性
    response = ifft2(responsef_padded, 'symmetric');
    % find maximum peak
    %通过resp_newton函数寻找响应response的最大峰值的位置。ky和kx是用于构建网格的参数，newton_iterations是牛顿法的迭代次数。disp_row和disp_col表示相对于当前目标位置的最大响应位置的偏移量。
    [disp_row, disp_col] = resp_newton(response, responsef_padded, 5, ky, kx, use_sz);
    translation_vec = round([disp_row, disp_col] * featureRatio * currentScaleFactor);
    %update position
    pospre = pos + translation_vec;
end
