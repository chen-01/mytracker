function [M,hist_fg,hist_bg] = ...
    create_spatial_matrix_v2(img, bb, center, Y,...
    target_dummy_mask, target_dummy_area,...
    mask_diletation_type, mask_diletation_sz,...
    currentScaleFactor, template_size,...
    base_target_sz, init_mask,...
    use_segmentation, seg_colorspace, nbins,...
    frame, hist_lr,hist_fg,hist_bg)

%{
Create spatial mask matrix for the next frame.
    
Output:
    M(ask)                          spatial mask matrix
    hist(ogram)_f(ore)g(round)      histogram of the foreground info
    hist(ogram)_b(ack)g(round)      histogram of the background info
Input:
    frame                           image frame
    bb                              bounding box location [x y w h]
    center                          target center
    Y                               gaussian shaped labels
    target_dummy_mask               target dummy mask
    target_dummy_area               target dummy area
    mask_diletation_type            'disk'
    mask_diletation_sz              mask diletation size
    currentScaleFactor              scale factor
    template_size                   initial template size
    base_target_sz                  base target size
    init_mask                       initial mask for the first frame
                                    (if frame > 1, init_mask = [])
    use_segmentation                true or false
    seg_colorspace                  segmentation colorspace: 'hsv'(default) or 'rgb'
    nbins                           nbins used for segmentation
    [frame,hist_lr,hist_fg,hist_bg] For 1st frame: 1,tracker.hist_lr,[],[]
                                    For kth frame: tracker.frame,tracker.hist_lr,
                                               tracker.hist_fg,tracker.hist_bg
    %}
    %% function
    % 内部参量
    % seg_img
    % obj_reg
    % valid_pixels_mask
    % seg_patch
    % init_mask_padded
    % histogram_fg
    % histogram_bg
    %% 包含函数
    % mex_extractforeground
    % mex_extractbackground
    % mex_segment
    % get_patch
    % get_location_prior
    % binarize_softmask
    % mask_normal
    
    if use_segmentation % 置信度够高就进行转换
        % convert image in desired colorspace
        if strcmp(seg_colorspace, 'rgb')
            seg_img = img;
        elseif strcmp(seg_colorspace, 'hsv')
            seg_img = rgb2hsv(img);
            seg_img = seg_img * 255;
        else
            error('Unknown colorspace parameter');
        end
        % 框框的左上和右下的坐标，
        % 因为用到混编的mex函数，考虑c的数组从1开始
        % object rectangle region (to zero-based coordinates)
        obj_reg = [bb(1), bb(2), bb(1)+bb(3), bb(2)+bb(4)] - [1 1 1 1];
        
        % extract histograms 分别提出前景和背景的颜色直方图
        % 输入都是整张图片，目标框整体坐标，以及bin的数量
        histogram_fg = mex_extractforeground(seg_img, obj_reg, nbins);
        histogram_bg = mex_extractbackground(seg_img, obj_reg, nbins);
        if frame == 1
            hist_fg = histogram_fg;
            hist_bg = histogram_bg;
        elseif frame >= 1
            hist_fg = (1-hist_lr)*hist_fg + hist_lr*histogram_fg;
            hist_bg = (1-hist_lr)*hist_bg + hist_lr*histogram_bg;
        else
            error('Current frame is invalid');
        end
        % extract masked patch: mask out parts outside image
        % 提取出所需要分割的patch，以及patch中所有参数的置信度？
        % valid_pixels_mask第一帧框内所有像素全部置为1
        [seg_patch, valid_pixels_mask] = get_patch(seg_img, center, currentScaleFactor, template_size);
        
        % segmentation
        % 相当与直接增加先验信息
        % 仅仅作为尝试！！！
        % 分别是前景的概率以及背景的概率
        % 直接在上面调整
        % currentScaleFactor开始等于1
        [fg_p, bg_p] = get_location_prior([1 1 size(seg_patch, 2) size(seg_patch, 1)], currentScaleFactor*base_target_sz, [size(seg_patch,2), size(seg_patch, 1)]);
        [~, fg, ~] = mex_segment(seg_patch, hist_fg, hist_bg, nbins, fg_p, bg_p);
        
        % cut out regions outside from image
        % 直接就是分割x预先判断有效性的mask
        mask = single(fg).*single(valid_pixels_mask);
        % 二值化mask
        mask = binarize_softmask(mask);
        
        if frame == 1
            % use mask from init pose
            init_mask_padded = zeros(size(mask));
            pm_x0 = floor(size(init_mask_padded,2) / 2 - size(init_mask,2) / 2);
            pm_y0 = floor(size(init_mask_padded,1) / 2 - size(init_mask,1) / 2);
            init_mask_padded(pm_y0:pm_y0+size(init_mask,1)-1, pm_x0:pm_x0+size(init_mask,2)-1) = init_mask;
            % 一开始就是中间是目标，周围是背景，直接乘上，去除背景
            mask = mask.*single(init_mask_padded);
        end
        
        % resize to filter size
        % 尺寸resize
        mask = imresize(mask, size(Y), 'nearest');
        
        % check if mask is too small (probably segmentation is not ok then)
        % target_dummy_area原有中心目标像素总数
        % 判断是都出现NaN或是出现数量过少低于阈值则不正常
        if mask_normal(mask, target_dummy_area)
            if mask_diletation_sz > 0
                % strel——structuring element 运用各种形状和大小构造元素
                % 创建一个平坦的圆形结构元素，半径为R
                D = strel(mask_diletation_type, mask_diletation_sz);
                % imdilate函数用于对图像实现膨胀操作。（形态学）
                % 相当于向外腐蚀一圈
                M = imdilate(mask, D);
            end
        else
            M = target_dummy_mask;
        end
    else
        M = target_dummy_mask;
    end
end