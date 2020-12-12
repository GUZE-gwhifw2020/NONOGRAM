function [nGWidthLine,nGHeightRow,tok,tokLen,tokSum]...
    = nGTokenResolve2(taskTokenStr)

%NGTOKENRESOLVE2 token字符串生成token矩阵
%   Ouput:
%       nGWidthLine   	:宽度(列个数)
%       nGHeightRow     :高度(行个数)
%     	tok             :每列token
%    	tokLen          :列token长度
%     	tokSum          :每列token和

% 分割每行/列字符
tokenTemp = strsplit(taskTokenStr,'/');

% 字符串处理函数
funT = @(x) str2double(strsplit(x,'.')');

% 处理为存储token数字的cell
tok = cellfun(funT, tokenTemp, 'UniformOutput', false);

% 求token长度与和
tokLen = cellfun(@length, tok);
tokSum = cellfun(@sum, tok);

% 求累计和确定行列
nGWidthLine = find(cumsum(tokSum) == sum(tokSum) / 2, 1, 'first');
if(isempty(nGWidthLine))
    error('Error: 无法确定行列大小');
end
nGHeightRow = length(tokenTemp) - nGWidthLine;

end

