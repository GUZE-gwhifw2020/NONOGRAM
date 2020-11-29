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
            [obj.nGWidthLine,obj.nGHeightRow,obj.tokLine,obj.tokRow,~,~,~,~] ...
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
            
            for iter = 1:5
                % 2 - 根据更新起点逻辑矩阵确定新加入的B/W
                for ii = 1:obj.nGWidthLine
                    obj = obj.refreshLine(ii);
                end
                for ii = 1:obj.nGHeightRow
                    obj = obj.refreshRow(ii);
                end
                % 临时矩阵传入结果矩阵
                obj.nGMatrix = obj.nGMatrixTemp;
                
                % 3 - 根据新加入的B/W改写起点逻辑矩阵
                for ii = 1:obj.nGWidthLine
                    obj = obj.addWhiteLine(ii);
                    % obj = obj.addBlackLine(ii);
                end
                for ii = 1:obj.nGHeightRow
                    obj = obj.addWhiteRow(ii);
                    % obj = obj.addBlackRow(ii);
                end
                
            end
        end
        
        function obj = addWhiteLine(obj, index)
            %ADDWHITELINE 依据第index列新增白色更新起点坐标
            % 对每一个添加的点(行数indexRow)处理
            for kk = 1:length(obj.newWhtLine{index})
                for ii = length(obj.tokLine{index}):-1:1
                    indexRow = obj.newWhtLine{index}(kk);
                    % 每一个token元素在加入白色点前token个方格置false
                    obj.startTokLine{index}(max(1, indexRow - obj.newWhtLine{index}(ii) + 1), ii) = false;
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
            
        end
        
        function obj = addWhiteRow(obj, index)
            %ADDWHITEROW 依据第index行新增白色更新起点坐标
            % 对每一个添加的点(列数indexLine)处理
            for kk = 1:length(obj.newWhtRow{index})
                for ii = length(obj.tokRow{index}):-1:1
                    indexLine = obj.newWhtRow{index}(kk);
                    % 每一个token元素在加入白色点前token个方格置false
                    obj.startTokRow{index}(max(1, indexLine - obj.newWhtRow{index}(ii) + 1), ii) = false;
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
            
            % 在临时矩阵中赋值赋值
            obj.nGMatrixTemp(blackIndexs, index) = obj.uTypeBlack;
            obj.nGMatrixTemp(whiteIndexs, index) = obj.uTypeWhite;
            
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
            
            % 在临时矩阵中赋值赋值
            obj.nGMatrixTemp(index, blackIndexs) = obj.uTypeBlack;
            obj.nGMatrixTemp(index, whiteIndexs) = obj.uTypeWhite;
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



