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
        
        tokLine             % 列Token，大小cell(nGWidthLine,1)
        tokRow              % 行Token，大小cell(nGHeightRow,1)
        
        tokLenLine          % 列Token个体长度
        tokLenRow           % 行Token个体长度
        
        
        nGMatrix            % 结果矩阵
        nGMatrixTemp        % 结果暂存矩阵
        
        startTokLine        % 列起点逻辑元组
        startTokRow         % 行起点逻辑元组
        
        isFinLine           % 列是否完成标签
        isFinRow            % 行是否完成标签
        
        newBlcLine          % 列新增黑色位置
        newWhtLine      	% 列新增白色位置
        newBlcRow       	% 行新增黑色位置
        newWhtRow         	% 行新增白色位置
        
    end
    
    methods
        function obj = NonoGram(strTokenArg)
            %NONOGRAM 构造此类的实例
            %   输入参数:
            %       strTokenArg     Token字符串
            
            % 函数处理字符串
            [obj.nGWidthLine,obj.nGHeightRow,obj.tokLine,obj.tokRow,...
                obj.tokLenLine,obj.tokLenRow,~,~] ...
                = nGTokenResolve(strTokenArg);
            
            % 结果矩阵初始化
            obj.nGMatrix = obj.uTypeUnN * zeros(obj.nGHeightRow, obj.nGWidthLine);
            obj.nGMatrixTemp = obj.uTypeUnN * zeros(obj.nGHeightRow, obj.nGWidthLine);
            
            % 起点逻辑元组初始化
            obj.startTokLine = cell(obj.nGWidthLine,1);
            obj.startTokRow = cell(obj.nGHeightRow,1);
            
            
            % 初始化行列是否完成标签
            obj.isFinLine = false(obj.nGWidthLine,1);
            obj.isFinRow = false(obj.nGHeightRow,1);
            
            % 初始化新增位置元组
            obj.newBlcLine = cell(obj.nGWidthLine,1);
            obj.newWhtLine = cell(obj.nGWidthLine,1);
            obj.newBlcRow = cell(obj.nGHeightRow,1);
            obj.newWhtRow = cell(obj.nGHeightRow,1);
            
            
        end
        
        function obj = Genesis(obj)
            %GENESIS 求解主循环
            % 1 - 起点逻辑矩阵初始化
            % 2 - 根据更新起点逻辑矩阵确定新加入的B/W
            % 3 - 新加入的B/W改写起点逻辑矩阵
            % 4 - 回到2
            
            % 1 - 起点逻辑矩阵初始化
            for ii = 1:obj.nGWidthLine
                obj.startTokLine{ii} = InitStartPosTok(obj.nGHeightRow,obj.tokLine{ii});
            end
            for ii = 1:obj.nGHeightRow
                obj.startTokRow{ii} = InitStartPosTok(obj.nGWidthLine,obj.tokRow{ii});
            end
            
            for iter = 1:25
                % 2 - 根据更新起点逻辑矩阵确定新加入的B/W
                for ii = 1:obj.nGWidthLine
                    obj = obj.refreshLine(ii);
                end
				
                for ii = 1:obj.nGHeightRow
                    obj = obj.refreshRow(ii);
                end
                % 临时矩阵传入结果矩阵
                % obj.nGMatrix = obj.nGMatrixTemp;
                
                % 3 - 根据新加入的B/W改写起点逻辑矩阵
                for ii = 1:obj.nGWidthLine
                    obj = obj.addWhiteLine(ii);
                    obj = obj.addBlackLine(ii);
                end
                for ii = 1:obj.nGHeightRow
                    obj = obj.addWhiteRow(ii);
                    obj = obj.addBlackRow(ii);
                end
                % obj.nGMatrix
            end
        end
        
        function obj = addWhiteLine(obj, index)
            %ADDWHITELINE 依据第index列新增白色更新起点坐标
            
            % 赋值
            obj.nGMatrix(obj.newWhtLine{index}, index) = obj.uTypeWhite;
            
            
            % 对每一个添加的点(行数indexRow)处理
            for kk = 1:length(obj.newWhtLine{index})
                for ii = length(obj.tokLine{index}):-1:1
                    indexRow = obj.newWhtLine{index}(kk);
                    % 每一个token元素在加入白色点前token个方格置false
                    obj.startTokLine{index}(max(1, indexRow - obj.tokLine{index}(ii) + 1):indexRow, ii) = false;
                end
            end
            
            % 间隔式收缩
            for ii = length(obj.tokLine{index})-1:-1:1
                tIndex = find(obj.startTokLine{index}(:,ii+1),1,'last') - obj.tokLine{index}(ii);
                obj.startTokLine{index}(tIndex:end,ii) = false;
            end
            
            for ii = 1:length(obj.tokLine{index}) - 1
                sIndex = find(obj.startTokLine{index}(:,ii),1,'first') + obj.tokLine{index}(ii);
                obj.startTokLine{index}(1:sIndex,ii+1) = false;
            end
            
            % 清空
            obj.newWhtLine{index} = [];
            
        end
        
        function obj = addWhiteRow(obj, index)
            %ADDWHITEROW 依据第index行新增白色更新起点坐标
            
            % 赋值
            obj.nGMatrix(index, obj.newWhtRow{index}) = obj.uTypeWhite;
            
            % 对每一个添加的点(列数indexLine)处理
            for kk = 1:length(obj.newWhtRow{index})
                for ii = length(obj.tokRow{index}):-1:1
                    indexLine = obj.newWhtRow{index}(kk);
                    % 每一个token元素在加入白色点前token个方格置false
                    obj.startTokRow{index}(max(1, indexLine - obj.tokRow{index}(ii) + 1):indexLine, ii) = false;
                end
                
            end
            
            % 间隔式收缩
            for ii = length(obj.tokRow{index})-1:-1:1
                tIndex = find(obj.startTokRow{index}(:,ii+1),1,'last') - obj.tokRow{index}(ii);
                obj.startTokRow{index}(tIndex:end,ii) = false;
            end
            
            for ii = 1:length(obj.tokRow{index}) - 1
                sIndex = find(obj.startTokRow{index}(:,ii),1,'first') + obj.tokRow{index}(ii);
                obj.startTokRow{index}(1:sIndex,ii+1) = false;
            end
            
            % 清空
            obj.newWhtRow{index} = [];
        end
        
        function obj = refreshLine(obj, index)
            %REFRESHLINE 更新第index列
            % 输入参数
            %       index      列序号
            % 黑色部分: 任一个Token元素延申重叠区域
            % 白色部分: 所有Token元素延申均不重叠区域
            blackIndexs = false(obj.nGHeightRow,1);
            whiteIndexs = true(obj.nGHeightRow,1);
            for ii = 1:length(obj.tokLine{index})
                % 利用卷积确定延申部分(默认full,仅取前nGHeight个)
                C = conv(obj.startTokLine{index}(:,ii), true(obj.tokLine{index}(ii),1));
                
                % 黑色部分
                blackIndexs = blackIndexs | ...
                    C(1:obj.nGHeightRow) == sum(obj.startTokLine{index}(:,ii));
                
                % 白色部分
                whiteIndexs = whiteIndexs & (~C(1:obj.nGHeightRow));
            end
            
            % 错误检测
            if(any(blackIndexs & obj.nGMatrix(:,index) == obj.uTypeWhite))
                error('Error: 检测到在白色位置写入黑色');
            end
            if(any(whiteIndexs & obj.nGMatrix(:,index) == obj.uTypeBlack))
                error('Error: 检测到在黑色位置写入白色');
            end
            
            % 多个行新增一个元素：列位置index
            indexsBlcRow = find(blackIndexs & obj.nGMatrix(:,index) == obj.uTypeUnN);
            indexsWhtRow = find(whiteIndexs & obj.nGMatrix(:,index) == obj.uTypeUnN);
            for ii = 1:length(indexsBlcRow)
                obj.newBlcRow{indexsBlcRow(ii)}(end+1) = index;
            end
            for ii = 1:length(indexsWhtRow)
                obj.newWhtRow{indexsWhtRow(ii)}(end+1) = index;
            end
           
            
        end
        
        function obj = refreshRow(obj, index)
            %REFRESROW 更新第ii行
            % 输入参数
            %       index      行序号
            blackIndexs = false(obj.nGWidthLine,1);
            whiteIndexs = true(obj.nGWidthLine,1);
            for ii = 1:length(obj.tokRow{index})
                % 利用卷积确定延申部分(默认full,仅取前nGHeight个)
                C = conv(obj.startTokRow{index}(:,ii), true(obj.tokRow{index}(ii),1));
                
                % 黑色部分
                blackIndexs = blackIndexs | ...
                    C(1:obj.nGWidthLine) == sum(obj.startTokRow{index}(:,ii));
                
                % 白色部分
                whiteIndexs = whiteIndexs & (~C(1:obj.nGWidthLine));
            end
            
            % 错误检测
            if(any(blackIndexs & obj.nGMatrix(index,:) == obj.uTypeWhite))
                error('Error: 检测到在白色位置写入黑色');
            end
            if(any(whiteIndexs & obj.nGMatrix(index,:) == obj.uTypeBlack))
                error('Error: 检测到在黑色位置写入白色');
            end
            
            % 列新增位置(B/W下标是列向量，原始矩阵需要转置)
            indexsBlcLine = find(blackIndexs & obj.nGMatrix(index,:)' == obj.uTypeUnN);
            indexsWhtLine = find(whiteIndexs & obj.nGMatrix(index,:)' == obj.uTypeUnN);
            
            for ii = 1:length(indexsBlcLine)
                obj.newBlcLine{indexsBlcLine(ii)}(end+1) = index;
            end
            for ii = 1:length(indexsWhtLine)
                obj.newWhtLine{indexsWhtLine(ii)}(end+1) = index;
            end
            
        end
        
        function obj = addBlackLine(obj, index)
            %ADDBLACKLINE 第index列添加黑色单元
            % 输入参数
            %        index   列序号
            
            % 新增的黑色单元存储在obj.newBlcLine{index}中
            % 原始序列为obj.nGMatrix(:,index)
            
            % 计算更新的黑色连续对
            pairs = pairsNewSeek(obj.nGMatrix(:,index), obj.newBlcLine{index});
            
            % 赋值
            obj.nGMatrix(obj.newBlcLine{index}, index) = obj.uTypeBlack;
            
            
            % 每一个连续对范围pairs(ii,1)~pairs(ii,2)
            for ii = 1:size(pairs,1)
                % 可能属于哪一(几)个token元素
                pTokId = [];
                for jj = 1:obj.tokLenLine(index)
                    % pairs(ii,2)前tokLen至pairs(ii,1)范围是否有一个true
                    span = max(1, pairs(ii,2) - obj.tokLine{index}(jj)) : pairs(ii,1);
                    if(any(obj.startTokLine{index}(span, jj)))
                        % 确认可能
                        pTokId = cat(1, pTokId, jj);
                    end
                end
                
                % 对pTokId个数判断
                if(isempty(pTokId))
                    error('Error: 加入黑色方格无法定位到任何Token')
                elseif(length(pTokId) == 1)
                    % 单个元素，pTokId为true范围被限制
                    span = max(1, pairs(ii,2) - obj.tokLine{index}(pTokId)) : pairs(ii,1);
                    x = false(obj.nGHeightRow, 1);
                    x(span) = true;
                    obj.startTokLine{index}(:, pTokId) = obj.startTokLine{index}(:, pTokId) & x;
                else
                    % 多个元素
                    % 可能token值最大最小值
                    
                    NM = minmax(obj.tokLine{index}(pTokId)');
                    
                    if(NM(1) < pairs(ii,2) - pairs(ii,1) + 1)
                        warning('Warning:可能错误')
                        continue
                    end
                    
                    % 寻找到黑色连续对前后的-1
                    leftAdd = find(obj.nGMatrix(pairs(ii,1)+NM(1)-1:-1:pairs(ii,2), index) == -1 ,1,'first');
                    rightAdd = find(obj.nGMatrix(pairs(ii,2)-NM(1)+1:pairs(ii,1), index) == -1 ,1,'first');
                    
                    % 新增黑色
                    % obj.nGMatrix(pairs(ii,1) - leftAdd:pairs(ii,2)+rightAdd,index) = 1;
                    indexsRow = obj.nGMatrix(:,index) == obj.uTypeUnN;
                    for jj = pairs(ii,1) - leftAdd:pairs(ii,2) + rightAdd
                        if(indexsRow(jj) == true)
                            obj.newBlcRow{jj} = cat(1, obj.newBlcRow{jj}, index);
                        end
                    end
                    % 特别的，如果最大最小相同，且连续块长度即为此值，新增白色
                    if(NM(1) == NM(2) && NM(1) == pairs(ii,2) - pairs(ii,1) + 1)
                        if(pairs(ii,1) ~= 1)
                            obj.newWhtLine{index}(end+1) = pairs(ii,1) - 1;
                            obj.newWhtRow{pairs(ii,1)-1}(end+1) = index;
                        end
                        if(pairs(ii,2) ~= obj.nGHeightRow)
                            obj.newWhtLine{index}(end+1) = pairs(ii,2) + 1;
                            obj.newWhtRow{pairs(ii,2)+1}(end+1) = index;
                        end
                    end
                        
                end
            end
            
            % 间隔式收缩
            for ii = length(obj.tokLine{index}) - 1:-1:1
                tIndex = find(obj.startTokLine{index}(:,ii+1),1,'last') - obj.tokLine{index}(ii);
                obj.startTokLine{index}(tIndex:end,ii) = false;
            end
            
            for ii = 1:length(obj.tokLine{index}) - 1
                sIndex = find(obj.startTokLine{index}(:,ii),1,'first') + obj.tokLine{index}(ii);
                obj.startTokLine{index}(1:sIndex,ii+1) = false;
            end
            
            % 清空obj.newBlcLine{index}
            obj.newBlcLine{index} = [];
        end
        
        function obj = addBlackRow(obj, index)
            %ADDBLACKROW 第index行添加黑色单元
            % 输入参数
            %        index   行序号
            
            % 新增的黑色单元存储在obj.newBlcRow{index}中
            % 原始序列为obj.nGMatrix(index,:)
            
            % 计算更新的黑色连续对
            pairs = pairsNewSeek(obj.nGMatrix(index,:), obj.newBlcRow{index});
            
            % 赋值
            obj.nGMatrix(index, obj.newBlcRow{index}) = obj.uTypeBlack;
            
            
            % 每一个连续对范围pairs(ii,1)~pairs(ii,2)
            for ii = 1:size(pairs,1)
                % 可能属于哪一(几)个token元素
                pTokId = [];
                for jj = 1:obj.tokLenRow(index)
                    % pairs(ii,2)前tokLen至pairs(ii,1)范围是否有一个true
                    span = max(1, pairs(ii,2) - obj.tokRow{index}(jj)) : pairs(ii,1);
                    if(any(obj.startTokRow{index}(span, jj)))
                        % 确认可能
                        pTokId = cat(1, pTokId, jj);
                    end
                end
                
                % 对pTokId个数判断
                if(isempty(pTokId))
                    error('Error: 加入黑色方格无法定位到任何Token')
                elseif(length(pTokId) == 1)
                    % 单个元素，pTokId为true范围被限制
                    span = max(1, pairs(ii,2) - obj.tokRow{index}(pTokId)) : pairs(ii,1);
                    x = false(obj.nGWidthLine, 1);
                    x(span) = true;
                    obj.startTokRow{index}(:, pTokId) = obj.startTokRow{index}(:, pTokId) & x;
                else
                    % 多个元素
                    % 可能token值最大最小值
                    
                    NM = minmax(obj.tokRow{index}(pTokId)');
                    
                    if(NM(1) < pairs(ii,2) - pairs(ii,1) + 1)
                        warning('Warning:可能错误')
                        continue
                    end
                    
                    % 寻找到黑色连续对前后的-1
                    leftAdd = find(obj.nGMatrix(index, pairs(ii,1)+NM(1)-1:-1:pairs(ii,2)) == -1 ,1,'first');
                    rightAdd = find(obj.nGMatrix(index, pairs(ii,2)-NM(1)+1:pairs(ii,1)) == -1 ,1,'first');
                    
                    
                    
                    % 新增黑色
                    indexsLine = obj.nGMatrix(index,:) == obj.uTypeUnN;
                    for jj = pairs(ii,1) - leftAdd:pairs(ii,2) + rightAdd
                        if(indexsLine(jj) == true)
                            obj.newBlcLine{jj} = cat(1, obj.newBlcLine{jj}, index);
                        end
                    end
                    % 特别的，如果最大最小相同，且连续块长度即为此值，新增白色
                    if(NM(1) == NM(2) && NM(1) == pairs(ii,2) - pairs(ii,1) + 1)
                        if(pairs(ii,1) ~= 1)
                            obj.newWhtRow{index}(end+1) = pairs(ii,1) - 1;
                            obj.newWhtLine{pairs(ii,1)-1}(end+1) = index;
                        end
                        if(pairs(ii,2) ~= obj.nGWidthLine)
                            obj.newWhtRow{index}(end+1) = pairs(ii,2) + 1;
                            obj.newWhtLine{pairs(ii,2)+1}(end+1) = index;
                        end
                    end
                        
                end
            end
            
            % 间隔式收缩
            for ii = length(obj.tokRow{index})-1:-1:1
                tIndex = find(obj.startTokRow{index}(:,ii+1),1,'last') - obj.tokRow{index}(ii);
                obj.startTokRow{index}(tIndex:end,ii) = false;
            end
            
            for ii = 1:length(obj.tokRow{index}) - 1
                sIndex = find(obj.startTokRow{index}(:,ii),1,'first') + obj.tokRow{index}(ii);
                obj.startTokRow{index}(1:sIndex,ii+1) = false;
            end
            
            % 清空obj.newBlcRow{index}
            obj.newBlcRow{index} = [];
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
    end
end

function pairs = pairsNewSeek(a, indexs)
%PAIRNEWSEEK 计算新加入下标序列indexs后，变化的连续对
%   输入参数
%       a           原序列
%       indexs      新增黑色下标

% =/ 定义 /= 连续段的起始终点位置
% a = [1 0 0 1 0 1 1];
% s = [1 4 6];
% e = [1 4 7];

% 新加入位置设置为1
indexs = unique(indexs);
a(a == -1) = 0;
a(indexs) = 1;

% 更新序列连续段起始终点位置
aD = diff([0; a(:); 0]);
s = find(aD == 1);
e = find(aD == -1) - 1;

% 段序列下标
eIndex = 1;

pairs = [];
for ii = 1:length(indexs)
    % 所处连续块起始位置
    if(e(eIndex) >= indexs(ii))
        pairs = cat(1,pairs, [s(eIndex) e(eIndex)]);
        if(eIndex == length(e))
            break
        end
        eIndex = eIndex + 1;
        % 段序列下标终点后移到indexs(ii)后
        while(e(eIndex) <= indexs(ii))
            eIndex = eIndex + 1;
        end
    end
end

end

