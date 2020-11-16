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

%   The procudure will produce an ImgSet of the size of 
%   Unit_Pixel * Unit_Pixel * 1 * 7
%   as well as two vectors to identify the number of tokens in each row or
%   line, i.e. [2 1], [2 2]
%   

%   nGWidth             :宽度(列个数)
%   nGHeight            :高度(行个数)
%   nGLenLine        	:每列token长度(向量长度nGWidth)
%   nGLenRow            :每行token长度(向量长度nGHeight)
%   ImgSet              :图片集合

%% Global Variables
% Global Variables will soon become the function arguments.
% 图片地址
IMG_FILE_NAME = '3.png';

% 像素单位
Unit_Pixel = 64;

% 是否展示参考线
isDisplay = true;

%% 读取照片
% 修正为灰度图片(0为黑色，255为白色)
imageOrig = rgb2gray(imread(IMG_FILE_NAME));

% 利用统计信息去除周围黄色部分
[N,~] = histcounts(imageOrig,linspace(0,255,64));
imageBW = imageOrig < 4 * (find(diff(N) > 0,1,'first') + 1);

%% 计算题面长宽

% 逐列求和，得出行token的分割线
[nGWidth,LocsGridLineS,LocsGridLineE,nGIntervalRow] = ...
    sumDivide(sum(imageBW,1));

% 逐行求和，得出列token的分割线
[nGHeight,LocsGridRowS,LocsGridRowE,nGIntervalLine] = ...
    sumDivide(sum(imageBW,2));

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

%%
function [nGWidth,LocsGridLineS,LocsGridLineE,nGIntervalRow] = ...
    sumDivide(imgSumLine,isDisplay)
% 根据列求和信息，计算宽度、网格列位置（起始/终端）、行token分割线横线坐标

if(nargin < 2)
    isDisplay = true;
end

% 第一次以0.9倍极大值为双肩门限确定网格位置(竖向网格)
[~,LocsGridLineS,Width] = findpeaks(imgSumLine,...
    'MinPeakHeight',0.9 * max(imgSumLine));
LocsGridLineE = LocsGridLineS + round(Width) - 1;

% 确定题面宽度
nGWidth = length(LocsGridLineS) - 1;
if(mod(nGWidth,5) ~= 0)
    warning('Warning: 不是5的倍数');
end

% 获得平均周期门限
xPeriod = mean(diff(LocsGridLineS) - Width(1:end-1));

% 第二次对前半部分求峰值，峰位置间隔不小于0.5倍平均周期门限
[~,LocsInterval,WIDTHS2] = findpeaks(imgSumLine(1:LocsGridLineS(1)),...
    'MinPeakDistance',0.5 * xPeriod);

% 行token竖向分割线间隔
nGIntervalRow = linspace(LocsInterval(1) + WIDTHS2(1),LocsGridLineS(1) - 1,...
    length(LocsInterval));

if(isDisplay)
    try
        close('侧向求和分割结果');
    catch ME
        if(~strcmp(ME.identifier, 'MATLAB:close:WindowNotFound'))
            rethrow(ME);
        end
    end
    figure('Name','侧向求和分割结果');
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
