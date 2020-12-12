% 存储 taskTokenStr 进入 taskTokenStrCell.m
try
    load taskTokenStrCell.mat taskTokenStrCell sizeArray
catch
    taskTokenStrCell = {};
    sizeArray = [];
end
% 比较函数
strcmpTemp = @(xStr) strcmp(xStr,taskTokenStr);
% 存储单元每一个比较
isEqualArray = cellfun(strcmpTemp,taskTokenStrCell);
% 无重复
if ~any(isEqualArray)
    % 写入
    taskTokenStrCell(end + 1) = {taskTokenStr};
    sizeArray(end+1,:) = [nGWidthLine nGHeightRow];
    fprintf('\t写入成功,存储总数: %d\n',length(taskTokenStrCell))
    save taskTokenStrCell.mat taskTokenStrCell sizeArray
end
