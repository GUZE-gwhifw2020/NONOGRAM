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
    isDisplay = false;
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

%% 分割坐标定位图片
try
    close('侧向求和分割结果');
catch ME
    if(~strcmp(ME.identifier, 'MATLAB:close:WindowNotFound'))
        rethrow(ME);
    end
end
h1 = figure('Name','侧向求和分割结果');
h1.Visible = 'off';

%% 计算题面长宽
% 逐列求和，得出行token的分割线
subplot(2,1,1);
[nGWidth,LocsGridLineS,LocsGridLineE,nGIntervalRow] = ...
    sliceLocate(sum(imageBW,1));

% 逐行求和，得出列token的分割线
subplot(2,1,2);
[nGHeight,LocsGridRowS,LocsGridRowE,nGIntervalLine] = ...
    sliceLocate(sum(imageBW,2));

% 标准差显示
fprintf('\t行列间隔标准差: %3f,%3f\n',...
    deviCal(LocsGridRowS,1.1),deviCal(LocsGridLineS,1.1));

% 列向求和修正
if(mod(nGWidth,5) ~= 0)
    warning('Warning: 宽度不是5的倍数，进行修正。');
    % 强制显示图片
    isDisplay = true;
    % 对LocsGridLineS与LocsGridLineE修正
    subplot(2,1,1);
    [nGWidth, LocsGridLineS, LocsGridLineE] = sliceLocateRevise(sum(imageBW,1),LocsGridLineS);
end

% 行向求和修正
if(mod(nGHeight,5) ~= 0)
    warning('Warning: 高度不是5的倍数，进行修正。');
    % 强制显示图片
    isDisplay = true;
    % 对LocsGridRowS与LocsGridRowE修正
    subplot(2,1,2);
    [nGHeight, LocsGridRowS, LocsGridRowE] = sliceLocateRevise(sum(imageBW,2),LocsGridRowS);
end

if(isDisplay)
    h1.Visible = 'on';
end

% 标准差显示
fprintf('\t行列间隔标准差: %3f,%3f\n',...
    deviCal(LocsGridRowS,1.1),deviCal(LocsGridLineS,1.1));

if(mod(nGWidth,5)~=0 || mod(nGHeight,5)~=0)
    error('Error: 修正后行列宽度(%d, %d)依然不为5的倍数。', nGWidth, nGHeight);
end

%% 分割线图片
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
ImgSetPatchLine = cell(nGWidth,1);
for ii = 1:nGWidth
    ySpan = LocsGridLineE(ii):LocsGridLineS(ii+1);
    for jj = 1:length(nGIntervalLine) - 1
        xSpan = nGIntervalLine(jj):nGIntervalLine(jj+1);
        % 切片
        imgSet = imageOrig(xSpan, ySpan);
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
ImgSetPatchRow = cell(nGHeight,1);
for ii = 1:nGHeight
    xSpan = LocsGridRowE(ii):LocsGridRowS(ii+1);
    for jj = 1:length(nGIntervalRow) - 1
        ySpan = nGIntervalRow(jj):nGIntervalRow(jj+1);
        % 切片
        imgSet = imageOrig(xSpan, ySpan);
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

% 截取部分
p = 0.6;

% 截取中心方块
imgInput = imgInput(round(end*(1-p)/2):round(end*(1+p)/2),...
    round(end*(1-p)/2):round(end*(1+p)/2));

x = mean(imgInput,'all') > 250;

end

%%
function [nGWidth,LocsGridLineS,LocsGridLineE,nGIntervalRow] = ...
    sliceLocate(imgSumLine)
% 根据列求和信息，计算宽度、网格列位置（起始/终端）、行token分割线横线坐标

% 第一次以0.9倍极大值为高度门限确定网格位置(竖向网格)
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

%%
function [nGWidth, LocsGridLineS,LocsGridLineE] = sliceLocateRevise(imageSum,LocsGridLineS)
% 根据原切分结果修正

% 计算平均间隔
x = diff(LocsGridLineS);
interval = mean(x(x < 1.5 * min(x)));

% 寻找所有的峰
[~,SV,WidthV] = findpeaks(imageSum);

% 寻找根据间隔均分的峰位置
jj = 1;
kIndex = false(length(SV),1);
for ii = find(SV >= LocsGridLineS(1),1,'first'):length(SV)
    z = abs(SV(ii) - LocsGridLineS(jj)) / interval;
    if(z == 0)
        jj = jj + 1;
        kIndex(ii) = true;
    elseif(abs(z - round(z)) < 0.1)
        kIndex(ii) = true;
    end
end

% 提取峰起始与结束位置
LocsGridLineS = SV(kIndex);
LocsGridLineE = SV(kIndex) + round(WidthV(kIndex));
nGWidth = length(LocsGridLineS) - 1;

% 图像中绘制
scatter(LocsGridLineS, repmat(1.1 * max(imageSum), size(LocsGridLineS)),...
    'CData',[0.4660 0.6740 0.1880],...
    'Marker','diamond','LineWidth',1,...
    'DisplayName','修正结果');

end

%%
function d = deviCal(LocsGrid, bias)
% 标准差显示
if(nargin < 2)
    bias = 1;
end
x = diff(LocsGrid);
% 对间隔修正
x(1:5:length(x)) = x(1:5:length(x)) / bias;
d = std(x);
end