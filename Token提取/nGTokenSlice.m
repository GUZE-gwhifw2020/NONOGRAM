function [nGWidth,nGHeight,ImgSetPatchLine,ImgSetPatchRow] = ...
    nGTokenSlice(IMG_FILE_NAME, Unit_Pixel, isDisplay)
%% Birth Certificate
% ===================================== %
% DATE OF BIRTH:    2020.11.16
% NAME OF FILE:     nGTokenSlice
% FILE OF PATH:     \NONOGRAM\Token提取
% FUNC:
%   Locate the number characters in the PNG and slice them into minor
%   matrixs for further Classification.
% ===================================== %

%% Detailed Function
% An example:
%       1   
%       2   3
%  4 5  #   #
%  6 7  #   #
%
%   Based on the exsiting token mechanism, the row tokens will be added
%   first. The tokenStr should be '1.2/3/4.5/6.7'.
%   The slice procedure will follow the same sequence.

%   The procudure will produce two ImgSetCells (row and line respectively)
%   Each cell element has the shape of 
%       Unit_Pixel * Unit_Pixel * 1 * k
%   k is the token number in corresponding row(line)


%   nGWidth             :宽度(列个数)
%   nGHeight            :高度(行个数)
%   ImgSetPatchLine     :列token图片集合
%   ImgSetPatchRow      :行token图片集合

clear sumDivide
%% Global Variables
% Global Variables will soon become the function arguments.
% 图片地址
% IMG_FILE_NAME = '00.png';

% 像素单位
% Unit_Pixel = 64;

% 是否展示参考线
% isDisplay = true;

if(nargin < 3)
    isDisplay = true;
    if(nargin < 2)
        Unit_Pixel = 64;
    end
end

%% 读取照片
% 修正为灰度图片(0为黑色，255为白色)
imageOrig = rgb2gray(imread(IMG_FILE_NAME));

% % 利用统计信息去除周围黄色部分
% [N,~] = histcounts(imageOrig,linspace(0,255,64));
% imageBW = imageOrig < 4 * (find(diff(N) > 0,1,'first') + 1);
try
    imageBW = 1 - imbinarize(imageOrig, graythresh(imageOrig));
catch ME
    if(strcmp(ME.identifier, 'MATLAB:UndefinedFunction'))
        warning('Warning: 缺少Image Processing Toolbox，替换计算方法。');
        imageBW = imageOrig < 128;
    end
end


%% 计算题面长宽
% 逐列求和，得出行token的分割线
[nGWidth,LocsGridLineS,LocsGridLineE,nGIntervalRow] = ...
    sliceLocate(sum(imageBW,1),isDisplay);

if(mod(nGWidth,5) ~= 0)
    warning('Warning: 宽度不是5的倍数，进行修正。');
    % 对LocsGridLineS与LocsGridLineE修正
    [nGWidth, LocsGridLineS, LocsGridLineE] = sliceLocateRevise(sum(imageBW,1),LocsGridLineS);
    
    if(mod(nGWidth,5) ~= 0)
        error('Warning: 修正后宽度不是5的倍数。');
    end
end

% 逐行求和，得出列token的分割线
[nGHeight,LocsGridRowS,LocsGridRowE,nGIntervalLine] = ...
    sliceLocate(sum(imageBW,2),isDisplay);
if(mod(nGHeight,5) ~= 0)
    warning('Warning: 高度不是5的倍数，进行修正。');
    % 对LocsGridLineS与LocsGridLineE修正
    [nGHeight, LocsGridRowS, LocsGridRowE] = sliceLocateRevise(sum(imageBW,2),LocsGridRowS);
    if(mod(nGHeight,5) ~= 0)
        error('Warning: 修正后高度不是5的倍数。');
    end
end

if(isDisplay)
    try
        close('分割线演示');
    catch ME
        if(~strcmp(ME.identifier, 'MATLAB:close:WindowNotFound'))
            rethrow(ME);
        end
    end
    figure('Name','分割线演示');
    % 原始图片
    imshow(imageOrig);
    hold on
    for ii = 1:length(nGIntervalRow)
        % 行token竖向分割线
        line(nGIntervalRow([ii ii]),[LocsGridRowE(1) LocsGridRowS(end)],...
            'Color','red');
    end
    for ii = 1:length(nGIntervalLine)
        % 列token横向分割线
        line([LocsGridLineE(1) LocsGridLineS(end)],nGIntervalLine([ii ii]),...
            'Color','red');
    end
end
%% 取单元图片切片
% 列token，自上向下，自左向右处理
ImgSetPatchLine = cell(length(LocsGridLineS) - 1,1);
for ii = 1:length(LocsGridLineS) - 1
    for jj = 1:length(nGIntervalLine) - 1
        % 切片
        imgSet = imageOrig(nGIntervalLine(jj):nGIntervalLine(jj+1),...
            LocsGridLineE(ii):LocsGridLineS(ii+1));
        % 判断图片是否空
        if(~isEmptyUnit(imgSet))
            ImgSetPatchLine{ii} = cat(3, ImgSetPatchLine{ii},...
                imresize(imgSet,[Unit_Pixel,Unit_Pixel]));
            % imshow(imgSet);
            % pause(0.4)
        end
    end
end
% 行token，自左向右，自上向下处理
ImgSetPatchRow = cell(length(LocsGridRowS) - 1,1);
for ii = 1:length(LocsGridRowS) - 1
    for jj = 1:length(nGIntervalRow) - 1
        % 切片
        imgSet = imageOrig(LocsGridRowE(ii):LocsGridRowS(ii+1),...
            nGIntervalRow(jj):nGIntervalRow(jj+1));
        % 判断图片是否空
        if(~isEmptyUnit(imgSet))
            ImgSetPatchRow{ii} = cat(3, ImgSetPatchRow{ii},...
                imresize(imgSet,[Unit_Pixel,Unit_Pixel]));
            % imshow(imgSet);
            % pause(0.4)
        end
    end
end
end

%%
function x = isEmptyUnit(imgInput)
% 判断输入单元图片是否空

% 截取中心方块
imgInput = imgInput(round(end/5):round(3*end/4),...
    round(end/4):round(3*end/4));

x = mean(imgInput,'all') > 250;

end

%%
function [nGWidth,LocsGridLineS,LocsGridLineE,nGIntervalRow] = ...
    sliceLocate(imgSumLine,isDisplay)
% 根据列求和信息，计算宽度、网格列位置（起始/终端）、行token分割线横线坐标

if(nargin < 2)
    isDisplay = false;
end

persistent isDualFigure

% 第一次以0.9倍极大值为双肩门限确定网格位置(竖向网格)
[~,LocsGridLineS,Width] = findpeaks(imgSumLine,...
    'MinPeakHeight',0.9 * max(imgSumLine));
LocsGridLineE = LocsGridLineS + round(Width) - 1;

% 确定题面宽度
nGWidth = length(LocsGridLineS) - 1;

% 获得平均周期门限
xPeriod = mean(diff(LocsGridLineS) - Width(1:end-1));

% 第二次对前半部分求峰值，峰位置间隔不小于0.5倍平均周期门限
[~,LocsInterval,WIDTHS2] = findpeaks(imgSumLine(1:LocsGridLineS(1)),...
    'MinPeakDistance',0.5 * xPeriod);

% 行token竖向分割线间隔
nGIntervalRow = round(linspace(LocsInterval(1) + WIDTHS2(1),...
    LocsGridLineS(1) - 1, length(LocsInterval)));

if(isDisplay)
    if(isempty(isDualFigure))
        try
            close('侧向求和分割结果');
        catch ME
            if(~strcmp(ME.identifier, 'MATLAB:close:WindowNotFound'))
                rethrow(ME);
            end
        end
        figure('Name','侧向求和分割结果');
        subplot(2,1,1)
        isDualFigure = true;
    else
        isDualFigure = [];
        subplot(2,1,2)
    end
    
    % 侧向求和结果
    plot(imgSumLine,'LineWidth',0.8);
    hold on
    box off
    % 黑色条纹起点
    scatter(LocsGridLineS,imgSumLine(LocsGridLineS),'r');
    % 黑色条纹终点
    scatter(LocsGridLineE,imgSumLine(LocsGridLineE),'b');
    % token部分峰值点
    scatter(LocsInterval,imgSumLine(LocsInterval),'g');
    % token部分分割线
    for ii = 1:length(nGIntervalRow)
        xline(nGIntervalRow(ii),'Color','red','LineStyle','--')
    end
    % 图例
    legend('求和结果','条纹起点','条纹终点','token峰值点','token分割线',...
        'Location','northeastoutside');
end
end

%%
function [nGWidth, LocsGridLineS,LocsGridLineE] = sliceLocateRevise(imageSum,LocsGridLineS)
x = diff(LocsGridLineS);
interval = mean(x(x < 2*min(x)));

[~,LocsGridLineSV,WidthV] = findpeaks(imageSum);

jj = 1;
kIndex = false(length(LocsGridLineSV),1);
for ii = 1:length(LocsGridLineSV)
    if(LocsGridLineSV(ii) == LocsGridLineS(jj))
        jj = jj + 1;
        kIndex(ii) = true;
    elseif(mod(abs(LocsGridLineSV(ii) - LocsGridLineS(jj))/interval,1) < 0.1)
        kIndex(ii) = true;
    end
end
LocsGridLineS = LocsGridLineSV(kIndex);
LocsGridLineE = LocsGridLineSV(kIndex) + round(WidthV(kIndex));
nGWidth = length(LocsGridLineS);
end