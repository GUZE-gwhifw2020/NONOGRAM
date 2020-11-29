% 2020/4/14
% 加入确定(黑色)位置blackPosArray序列
% 更新startPosTok

% Ver2
% 参数输入该行数据
% 每加入一个，对一并的黑色方块进行判断

function [startPosTok,nonoArray] = AddBlackV2(startPosTok,blackPosArray,token,nonoArray)

% 设黑色方块加入位置X
% 相当于nonoArray(blackPosArray) = 1;
% 则判断该黑色方块可能在哪一个token里面
% 如果是单个的话，token的范围被限制
% 如果是多个的话，………………

% 获取更改后黑色合并对信息
[blackPairs,pairsNum] = blackPairsUpdata(nonoArray,sort(blackPosArray));

for indexsPairNew = 1:pairsNum
    % 看看属于哪一个startPosTok
    inBlcIndex = blackPairs(indexsPairNew,:);
    % 与blackBlockIndex位置向上最近的黑色方块
    potentialTokenIndex = [];
    for ii = 1:length(token)
        % 起始到终止inBlcIndex(1):inBlcIndex(2)为是这个token的允许范围
        % 滑动窗口内是否为1
        if(any(startPosTok(max(1,(inBlcIndex(2)-token(ii)+1)):inBlcIndex(1),ii)))
            potentialTokenIndex(end+1) = ii;
        end
    end
    
    if(length(potentialTokenIndex) == 1)
        % 单个
        % potentialTokenIndex的范围被限制为滑动窗口移动范围
        indexsBool = false(size(startPosTok,1),1);
        indexsBool(max(1,(inBlcIndex(2)-token(potentialTokenIndex)+1)):inBlcIndex(1)) = true;
        startPosTok(:,potentialTokenIndex) = startPosTok(:,potentialTokenIndex) & indexsBool;
    elseif(isempty(potentialTokenIndex))
        error('错误：无法有效确定位置')
    else
%         token(potentialTokenIndex)
%         inBlcIndex
        % 多个token点，取最大最小值
        minmaxLength = minmax(token(potentialTokenIndex));
        if(minmaxLength(1) < inBlcIndex(2) - inBlcIndex(1) + 1)
           continue 
        end
        % blackPairs 确立起始位置
        % 寻找到最靠近 inBlcIndex(1)的前一个-1与最靠近 inBlcIndex(2)的后一个-1
        leftAdd = sum(find(nonoArray(inBlcIndex(1)+minmaxLength(1)-1:-1:inBlcIndex(2)) == -1 ,1,'first'));
        rightAdd = sum(find(nonoArray(inBlcIndex(2)-minmaxLength(1)+1:inBlcIndex(1)) == -1 ,1,'first'));
        
        nonoArray((inBlcIndex(1)-leftAdd):(inBlcIndex(2)+rightAdd)) = 1;
        %%%%%%%%%%%%%%%%%%%%55
%         nonoArray
%         nonoArray(inBlcIndex(1)+minmaxLength(1)-1:-1:inBlcIndex(2))
%         leftAdd
%         nonoArray(inBlcIndex(2)-minmaxLength(1)+1:inBlcIndex(1))
%         rightAdd
        %%%%%%%%%%%%%%%%%%%%%%%5
        if((minmaxLength(1) == minmaxLength(2)) && (minmaxLength(1) == leftAdd + rightAdd + inBlcIndex(2) - inBlcIndex(1) + 1))
            % 两者相等
            nonoArray(inBlcIndex(1) - leftAdd - 1) = -1;
            nonoArray(inBlcIndex(2) + rightAdd + 1) = -1;
        end
    end
end


% 间隔化操作
for ii = length(token):-1:2
    startPosTok((find(startPosTok(:,ii),1,'last')-token(ii-1)):end,ii-1) = false;
end

for ii = 1:length(token)-1
    startPosTok(1:(find(startPosTok(:,ii),1,'first')+token(ii)),ii+1) = false;
end

end


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