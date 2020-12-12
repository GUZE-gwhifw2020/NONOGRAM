function level = otsuMethod(I)
%OTSUMETHOD 大津方法
%   二值化图片阈值计算
%   等效MATLAB::graythresh函数

% 图片拉伸为向量并转为uint8
I = uint8(I(:));

% 生成256个bin
num_bins = 256;
counts = histcounts(I,num_bins);

%% 大津方法
p = counts / length(I);
omega = cumsum(p);
mu = cumsum(p .* (1:num_bins));
mu_t = mu(end);

sigma_b_squared = (mu_t * omega - mu).^2 ./ (omega .* (1 - omega));

% 寻找sigma_b_squared最大位置
maxval = max(sigma_b_squared);
idx = mean(find(sigma_b_squared == maxval));
level = (idx - 1) / (num_bins - 1);

end

