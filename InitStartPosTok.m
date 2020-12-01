function startPosTok = InitStartPosTok(lineLength,token)
%INITSTARTPOSTOK 可能起始位置矩阵初始化
%   输入参数:
%       lineLength      行/列大小
%       token           某一行/列的Token，矩阵输入
%   输出参数:
%       startPosTok     bool型，每一列true代表Token中一个元素允许起始位置

% 空间初始化
startPosTok = false(lineLength,length(token));

% 滑动窗口大小
slideSize = lineLength - (length(token) - 1 + sum(token));

% 每个Token起始位置限制在大小为slideSize的窗口中
startIndex = 1;
for ii = 1:length(token)
    startPosTok(startIndex:startIndex+slideSize,ii) = true;
    startIndex = startIndex + token(ii) + 1;
end


%{
startPosTok = true(lineLength,length(token));
startPosTok(end - token(end) + 2:end,end) = false;
for ii = 1:length(token) - 1
    jj = length(token) - ii + 1;
    startPosTok(1:(find(startPosTok(:,ii),1,'first') + token(ii)),ii+1) = false;
    startPosTok((find(startPosTok(:,jj),1,'last') - token(jj - 1)):end,jj -1) = false;
end
%}

end