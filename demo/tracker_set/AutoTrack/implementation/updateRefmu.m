function [ref_mu, occ] = updateRefmu(response_diff, init_mu, p, frame)

    [ref_mu, occ] = varphiFunction(response_diff, init_mu, p, frame);
end

function [y, occ] = varphiFunction(response_diff, init_mu, p, frame)
    %         global eta_list;
    phi = 0.3; %0.3
    m = init_mu;
    % norm函数是用来计算向量或矩阵的范数的。
    % 范数是衡量向量大小的一种方法，它可以被视为向量空间中点到原点的距离。
    % 对于矩阵，范数可以用来衡量矩阵的某些属性，如其最大奇异值。
    % 这个值越大，表示当前帧和参考帧之间的差异越大；反之，差异越小。
    eta = norm(response_diff, 2) / 1e4;
    %         eta_list(frame)=eta;
    if eta < phi
        y = m / (1 + log(p * eta + 1));
        occ = false;
    else
        y = 50;
        occ = true;
    end

end
