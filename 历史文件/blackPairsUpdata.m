function [blackPairs,pairsNum] = blackPairsUpdata(originalOnes,addedOnes)

% blackPairs
% 返回的起始,终止位置对,
% 大小pairsNum * 2,数量不超过addedOnes长度

% 更新originalOnes,起始的1，新增的1合并
originalOnes(addedOnes) = 1;

% 仅留取addedOnes改变的部分
startIndexTemp = 0;
pairsNum = 0;
blackPairs = zeros(length(addedOnes),2);
for ii = 1:length(addedOnes)
    % 向前寻找
    startIndex = find([0 originalOnes(1:addedOnes(ii))] ~= 1,1,'last');
    % 重复删除
    if(startIndex == startIndexTemp)
        continue
    end
    pairsNum = pairsNum + 1;
    startIndexTemp = startIndex;
    % 向后寻找
    endIndex = find([originalOnes(addedOnes(ii):end) 0] ~= 1,1,'first')+addedOnes(ii)-2;
    blackPairs(pairsNum,:) = [startIndex endIndex];
end
blackPairs = blackPairs(1:pairsNum,:);


end