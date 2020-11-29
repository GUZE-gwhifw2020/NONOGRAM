% 2020/4/14
% 依据startPosTok与token更新输出
function nonoGramRefershed = RefreshOutput(startPosTok,token,lengthArray)
    nonoGramRefershed = zeros(lengthArray,1);
    
    % 黑色的，均重叠的地方
    for ii = 1:length(token)
        X = conv(startPosTok(:,ii),true(token(ii),1));
        sum(startPosTok(:,ii))
        nonoGramRefershed(X(1:lengthArray) == sum(startPosTok(:,ii))) = 1;
    end
    
    % 白色的，均不重叠的地方
    nonoWhiteTemp = true(lengthArray,1);
    for ii = 1:length(token)
        X = conv(startPosTok(:,ii),true(token(ii),1));
        nonoWhiteTemp = nonoWhiteTemp & (~X(1:lengthArray));
    end
    nonoGramRefershed(nonoWhiteTemp) = -1;
end