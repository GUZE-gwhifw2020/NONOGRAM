% 2020/4/14
% 加入不可能(白色，cross)位置crossPosArray序列
% 更新startPosTok

function startPosTok = AddCross(startPosTok,crossPosArray,token)

% 设加入位置X,则每个token可能起始位置 max(1,X-tokenNum):X 置false
for indexNew = 1:length(crossPosArray)
    for ii = length(token):-1:1
    % for ii = find(startPosTok(crossPosArray(indexNew),:)) 有待优化
        X = crossPosArray(indexNew);
        startPosTok(max(1,X - token(ii) + 1):X,ii) = false;
    end
end

for ii = length(token)-1:-1:1
    startPosTok((find(startPosTok(:,ii+1),1,'last')-token(ii)):end,ii) = false;
end

for ii = 1:length(token)-1
    startPosTok(1:(find(startPosTok(:,ii),1,'first')+token(ii)),ii+1) = false;
end

end