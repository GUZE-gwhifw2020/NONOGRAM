classdef NonoGram
    %NONOGRAM 逻辑游戏Nonogram求解工程
    %   此处显示详细说明
    
    properties (Constant)
        % 单元状态(禁止修改)
        uTypeUnN    = 0;
        uTypeBlack  = 1;
        uTypeWhite  = -1;
        
    end
    
    properties
        nGWidthLine         % 宽度，列个数
        nGHeightRow         % 高度，行个数
        nGWHLR              % 行列总数
        tok 				% 列行Token
        tokLength 			% 列行Token长度
        nGMatrix            % 结果矩阵
        startTok 			% 列行起点逻辑元组
        unfinIndexs 		% 列行未完成下标
        newBlc 				% 列行新增黑色位置
        newWht 				% 列行新增白色位置
        
    end
    
    methods
        function obj = NonoGram(strTokenArg)
            %NONOGRAM 构造此类的实例
            %   输入参数:
            %       strTokenArg     Token字符串
            
            % 函数处理字符串
            [obj.nGWidthLine,obj.nGHeightRow,tokLine,tokRow,...
                tokLenLine,tokLenRow,~,~] ...
                = nGTokenResolve(strTokenArg);
            
            obj.nGWHLR = obj.nGWidthLine + obj.nGHeightRow;
            obj.tok = cat(1, tokLine, tokRow);
            obj.tokLength = cat(1, tokLenLine, tokLenRow);
            
            
            % 结果矩阵初始化
            obj.nGMatrix = obj.uTypeUnN * zeros(obj.nGHeightRow, obj.nGWidthLine);
            
            % 起点逻辑元组初始化
            obj.startTok = cell(obj.nGWHLR, 1);
            
            % 初始化行列是否完成标签
            obj.unfinIndexs = 1:obj.nGWHLR;
            
            % 初始化新增位置元组
            obj.newBlc = cell(obj.nGWHLR, 1);
            obj.newWht = cell(obj.nGWHLR, 1);
            
        end
        
        function obj = InitStartPosTok(obj)
            %INITSTARTPOSTOK 列行起点逻辑元组初始化
            for ii = 1:obj.nGWHLR
                if(ii > obj.nGWidthLine)
                    arrSize = obj.nGWidthLine;
                else
                    arrSize = obj.nGHeightRow;
                end
                
                % 空间初始化
                obj.startTok{ii} = false(arrSize,obj.tokLength(ii));
                
                % 滑动窗口大小
                slideSize = arrSize - (obj.tokLength(ii) - 1 + sum(obj.tok{ii}));
                
                % 每个Token起始位置限制在大小为slideSize的窗口中
                startIndex = 1;
                for kk = 1:obj.tokLength(ii)
                    obj.startTok{ii}(startIndex:startIndex+slideSize,kk) = true;
                    startIndex = startIndex + obj.tok{ii}(kk) + 1;
                end
            end
            
        end
        
        function obj = Genesis(obj)
            %GENESIS 求解主循环
            % 1 - 起点逻辑矩阵初始化
            % 2 - 根据更新起点逻辑矩阵确定新加入的B/W
            % 3 - 新加入的B/W改写起点逻辑矩阵，回到2
            
            % 1 - 起点逻辑矩阵初始化
            obj = obj.InitStartPosTok();
            
            for iter = 1:50
                fprintf('\t%d',iter);
                if(~mod(iter,10))
                    fprintf('\n');
                end
                % 2 - 根据更新起点逻辑矩阵确定新加入的B/W
                for ii = obj.unfinIndexs
                        obj = obj.refreshLR(ii);
                end
                if(mod(iter,5) == 0)
                    for ii = obj.unfinIndexs
                        if(ii <= obj.nGWidthLine)
                            obj.newBlc{ii} = cat(2, obj.newBlc{ii}, transpose(find(obj.nGMatrix(:,ii) == obj.uTypeBlack)));
                            obj.newWht{ii} = cat(2, obj.newWht{ii}, transpose(find(obj.nGMatrix(:,ii) == obj.uTypeWhite)));
                        else
                            obj.newBlc{ii} = cat(2, obj.newBlc{ii}, find(obj.nGMatrix(ii - obj.nGWidthLine,:) == obj.uTypeBlack));
                            obj.newWht{ii} = cat(2, obj.newWht{ii}, find(obj.nGMatrix(ii - obj.nGWidthLine,:) == obj.uTypeWhite));
                        end
                    end
                end
                % 3 - 根据新加入的B/W改写起点逻辑矩阵
                for ii = obj.unfinIndexs
                    obj = obj.addWhiteLR(ii);
                end
                for ii = obj.unfinIndexs
                    obj = obj.addBlackLR(ii);
                end
            end
        end
        
        function obj = addWhiteLR(obj, index)
            %ADDWHITELR 依据第index列或第index-obj.nGWidthLine行新增白点更新起点坐标
            
            % 赋值
            if(index > obj.nGWidthLine)
                obj.nGMatrix(index - obj.nGWidthLine, obj.newWht{index}) = obj.uTypeWhite;
            else
                obj.nGMatrix(obj.newWht{index}, index) = obj.uTypeWhite;
            end
            
            % 对每一个添加的白点处理
            for kk = 1:length(obj.newWht{index})
                indexWht = obj.newWht{index}(kk);
                for ii = obj.tokLength(index):-1:1
                    % 每一个token元素在加入白色点前token个方格置false
                    obj.startTok{index}(max(1, indexWht - obj.tok{index}(ii) + 1):indexWht, ii) = false;
                end
            end
            
            % 间隔式收缩
            for ii = obj.tokLength(index)-1:-1:1
                tIndex = find(obj.startTok{index}(:,ii+1),1,'last') - obj.tok{index}(ii);
                obj.startTok{index}(tIndex:end,ii) = false;
            end
            
            for ii = 1:obj.tokLength(index) - 1
                sIndex = find(obj.startTok{index}(:,ii),1,'first') + obj.tok{index}(ii);
                obj.startTok{index}(1:sIndex,ii+1) = false;
            end
            
            % 清空
            obj.newWht{index} = [];
            
        end
        
        function obj = refreshLR(obj, index)
            %REFRESHLR 依据第index列或第index-obj.nGWidthLine行起点坐标确定新的白点和黑点
            
            if(index > obj.nGWidthLine)
                arrSize = obj.nGWidthLine;
                array = obj.nGMatrix(index-obj.nGWidthLine,:)';
                indexAdd = 0;
            else
                arrSize = obj.nGHeightRow;
                array = obj.nGMatrix(:,index);
                indexAdd = obj.nGWidthLine;
            end
            
            % 黑色部分: Token元素起点延申重叠等于起点数区域
            % 白色部分: 所有Token元素起点延申均不重叠区域
            blackIndexs = false(arrSize,1);
            whiteIndexs = true(arrSize,1);
            for indexB = 1:obj.tokLength(index)
                % 利用卷积确定延申部分(默认full,仅取前nGHeight个)
                C = conv(obj.startTok{index}(:,indexB), true(obj.tok{index}(indexB),1));
                
                % 黑色部分
                blackIndexs = blackIndexs | ...
                    C(1:arrSize) == sum(obj.startTok{index}(:,indexB));
                
                % 白色部分
                whiteIndexs = whiteIndexs & (~C(1:arrSize));
            end
            
            % 错误检测
            if(any(blackIndexs & array == obj.uTypeWhite))
                error('Error: 检测到在白色位置写入黑色');
            end
            if(any(whiteIndexs & array == obj.uTypeBlack))
                error('Error: 检测到在黑色位置写入白色');
            end
            
            % 判断是否完成
            unnIndexs = array == obj.uTypeUnN;
            if(~any(unnIndexs))
                obj.unfinIndexs(obj.unfinIndexs == index) = [];
            elseif(nnz(array == obj.uTypeBlack) == sum(obj.tok{index}))
                % obj.unfinIndexs(obj.unfinIndexs == index) = [];
                for indexW = transpose(find(unnIndexs))
                    obj.newWht{indexW + indexAdd}(end+1) = index + indexAdd - obj.nGWidthLine;
                end
            end
            
            % 多个行新增一个元素：列位置index
            for indexB = transpose(find(blackIndexs & unnIndexs))
                obj.newBlc{indexB + indexAdd}(end+1) = index + indexAdd - obj.nGWidthLine;
            end
            for indexW = transpose(find(whiteIndexs & unnIndexs))
                obj.newWht{indexW + indexAdd}(end+1) = index + indexAdd - obj.nGWidthLine;
            end
            
        end
        
        function obj = addBlackLR(obj, index)
            %ADDBLACKLR 依据第index列或第index-obj.nGWidthLine行新增黑点更新起点坐标
            
            % 新增的黑色单元存储在obj.newBlc{index}中
            % 原始序列为obj.nGMatrix(:,index)或obj.nGMatrix(index -
            % nGWidthLine,:)中
            
            if(index > obj.nGWidthLine)
                array = obj.nGMatrix(index - obj.nGWidthLine,:);
                obj.nGMatrix(index - obj.nGWidthLine, obj.newBlc{index}) = obj.uTypeBlack;
                arraySize = obj.nGWidthLine;
                indexAdd = 0;
            else
                array = obj.nGMatrix(:,index);
                obj.nGMatrix(obj.newBlc{index}, index) = obj.uTypeBlack;
                arraySize = obj.nGHeightRow;
                indexAdd = obj.nGWidthLine;
            end
            
            % 计算更新的黑色连续对
            pairs = pairsSeek(array, obj.newBlc{index});
            
            % 每一个连续对范围pairs(ii,1)~pairs(ii,2)
            for ii = 1:size(pairs,1)
                % 可能属于哪一(几)个token元素
                pTokId = [];
                for jj = 1:obj.tokLength(index)
                    % pairs(ii,2)前tokLen至pairs(ii,1)范围是否有一个true
                    span = max(1, pairs(ii,2) - obj.tok{index}(jj) + 1) : pairs(ii,1);
                    if(any(obj.startTok{index}(span, jj)))
                        % 确认可能
                        pTokId(end+1) = jj;
                    end
                end
                % 可能token值最大最小值
                NM = minmax(obj.tok{index}(pTokId)');
                
                % 对pTokId个数判断
                if(isempty(pTokId))
                    error('Error: 加入黑色方格无法定位到任何Token')
                elseif(length(pTokId) == 1)
                    % 单个元素，pTokId为true范围被限制
                    span = max(1, pairs(ii,2) - obj.tok{index}(pTokId)+1) : pairs(ii,1);
                    x = true(arraySize, 1);
                    x(span) = false;
                    obj.startTok{index}(x, pTokId) = false;
                else
                    % 多个元素
                    % 寻找到黑色连续对前后的白色方块
                    leftAdd = sum(find(array(pairs(ii,1)+NM(1)-1:-1:pairs(ii,2)) == obj.uTypeWhite,1,'first'));
                    rightAdd = sum(find(array(pairs(ii,2)-NM(1)+1:pairs(ii,1)) == obj.uTypeWhite,1,'first'));
                    
                    % 新增黑色
                    for jj = pairs(ii,1) - leftAdd:pairs(ii,2) + rightAdd
                        if(array(jj) == obj.uTypeUnN)
                            obj.newBlc{jj + indexAdd}(end+1) = index + indexAdd - obj.nGWidthLine;
                        end
                    end
                end
                % 特别的，如果且连续块长度即为最大可能token，新增白色，且当前starTok仅存留一个true
                if(NM(2) == pairs(ii,2) - pairs(ii,1) + 1)
                    if(pairs(ii,1) ~= 1)
                        obj.newWht{index}(end+1) = pairs(ii,1) - 1;
                        obj.newWht{pairs(ii,1)-1+indexAdd}(end+1) = index + indexAdd - obj.nGWidthLine;
                    end
                    if(pairs(ii,2) ~= arraySize)
                        obj.newWht{index}(end+1) = pairs(ii,2) + 1;
                        obj.newWht{pairs(ii,2)+1+indexAdd}(end+1) = index + indexAdd - obj.nGWidthLine;
                    end
                    if(length(pTokId) == 1)
                        obj.startTok{index}(:, pTokId) = false;
                        obj.startTok{index}(pairs(ii,1), pTokId) = true;
                    end
                end
            end
            
            % 间隔式收缩
            for ii = obj.tokLength(index) - 1:-1:1
                tIndex = find(obj.startTok{index}(:,ii+1),1,'last') - obj.tok{index}(ii);
                obj.startTok{index}(tIndex:end,ii) = false;
            end
            
            for ii = 1:obj.tokLength(index) - 1
                sIndex = find(obj.startTok{index}(:,ii),1,'first') + obj.tok{index}(ii);
                obj.startTok{index}(1:sIndex,ii+1) = false;
            end
            
            % 清空obj.newBlc{index}
            obj.newBlc{index} = [];
        end
        
        function Display(obj)
            %DISPLAY 绘图函数
            figure("Name","NonoGram")
            hold on
            
            % Black属性
            spy(obj.nGMatrix == obj.uTypeBlack,'k');
            % White属性
            spy(obj.nGMatrix == obj.uTypeWhite,'mx');
            
            % 水平网格线
            for ii = 0:floor(obj.nGHeightRow / 5)
                line([0 obj.nGWidthLine] + 0.5, 5 * ii + [0.5 0.5]);
            end
            % 竖直网格线
            for ii = 0:floor(obj.nGWidthLine / 5)
                line(5 * ii + [0.5 0.5], [0 obj.nGHeightRow] + 0.5);
            end
            
        end
        
        function mouseSimulate(obj)
            %MOUSESIMULATE 模拟鼠标操作
            
            % 运行py文件，获取四顶点坐标
            system('nGApex4.py');
            
            % 读取四顶点坐标
            load temp.mat apex
            
            % 屏幕像素显示比例
            screenPixelRatio = 2.5;
            
            % 左右像素边界
            apex = sort(apex);
            xBound = round(mean(reshape(apex(:,1), [2 2])));
            yBound = round(mean(reshape(apex(:,2), [2 2])));
            % 单位间隔
            xIntv = diff(xBound) / obj.nGWidthLine;
            yIntv = diff(yBound) / obj.nGHeightRow;
            if(round(xIntv) ~= round(yIntv))
                warning('顶点定位出现问题。可能引发不确定错误。')
            end
            
            % 中心坐标
            % 三个参数，x位置，y位置，是否填空
            clickPos = zeros(obj.nGWidthLine * obj.nGHeightRow,3);
            % 偏置
            xyBias = -[xIntv * 0.5 yIntv * 0.5] + [xBound(1) yBound(1)];
            % 利用meshgrid直接生成行列信息
            [X,Y] = meshgrid(1:obj.nGWidthLine, 1:obj.nGHeightRow);
            clickPos(:,1:2) = [X(:) * xIntv Y(:) * yIntv];
            
            % 添加总偏置与250%缩放(因电脑而异)
            clickPos(:,1:2) = round((clickPos(:,1:2) + xyBias) / screenPixelRatio);
            
            % 点击属性设置
            clickPos(:,3) = obj.nGMatrix(:);
            
            % 写入
            save('temp.mat','clickPos','-append');
            
            system('nGClick.py');
        end
    end
end

function pairs = pairsSeek(a, add)
%PAIRSSEEK 计算新加入下标序列add对应的新连续对
%   输入参数
%       a           原序列
%       add         新增黑色下标

% =/ 定义 /= 连续段的起始终点位置
% a = [1 0 0 1 0 1 1];
% s = [1 4 6];
% e = [1 4 7];

% Exp:
% a = [1 0 0 1 0 1 1];
% add = [2 5]
% pairs = [1 2;3 7];


% 新加入位置设置为1
add = unique(add);
a(a == -1) = 0;
a(add) = 1;

% 更新序列连续段起始终点位置
aD = diff([0; a(:); 0]);
s = find(aD == 1);
e = find(aD == -1) - 1;

% 段序列下标
eId = 1;
pairs = [];

for aId = 1:length(add)
    while(e(eId) < add(aId))
        eId = eId + 1;
        if(eId > length(e))
            break
        end
    end
    if(s(eId) > add(aId))
        continue
    end
    pairs = cat(1,pairs, [s(eId) e(eId)]);
    if(eId == length(e))
        break
    end
    eId = eId + 1;
end

end

