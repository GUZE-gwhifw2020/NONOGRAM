%% Birth Certificate
% ===================================== %
% DATE OF BIRTH:    2020.11.17
% NAME OF FILE:     nGAddCNNTrainData
% FILE OF PATH:     \NONOGRAM\Token提取
% FUNC:
%   Load an image, slice the units, given the token string, save the pics.
% ===================================== %

% 添加函数目录夹
addpath('..\Function');

%% Global Variables
% 图片地址
IMG_FILE_NAME = '0.png';

% 像素单位
Unit_Pixel = 64;

% 是否展示参考线
isDisplay = false;

% 起始线
fprintf('\t%s\n',repmat('=',[40 1]));

%% 读取存储记录
if(exist('nGCNNTrainData.mat','file'))
    load nGCNNTrainData.mat
else
    nGImgSet = [];
    nGImgLabel = [];
    lastSave = [];
end
% 当前保存信息
currentSave = dir(IMG_FILE_NAME);

if(~isempty(lastSave))
    % 比较当前图片与最后一次保存图片信息对比
    if(strcmp(lastSave.date, currentSave.date) && ...
            lastSave.bytes == currentSave.bytes)
       error('Error: 检测到重复存储行为。');
    end
end

%% 图片切片
[nGWidth,nGHeight,ImgSetPatchLine,ImgSetPatchRow] = ...
    nGTokenSlice(IMG_FILE_NAME, Unit_Pixel, isDisplay);

fprintf('\t 成功读取图片%s\n', IMG_FILE_NAME);
fprintf('\t 宽度(列数):%d\n\t 高度(行数):%d\n',nGWidth,nGHeight);

%% 读取Token字符串并进行比较
tokenStr = input('     输入Nonogram的Token:','s');
% 解析Token字符串
[nGWidthT,nGHeightT,nGtok,nGTokLen,~] = nGTokenResolve2(tokenStr);

% 判断是否正确
if(nGWidth ~= nGWidthT || nGHeight ~= nGHeightT)
    fprintf('\t 宽度(列数):%d\n\t 高度(行数):%d\n',nGWidthT,nGHeightT);
    error('Error：网格大小图片与字符Token读取结果不对应。');
end
% 列Token
imgNumFun = @(imgSet) size(imgSet,3);
tokenNum = cellfun(imgNumFun,ImgSetPatchLine);
% tokenNumT = cellfun(@length,nGtok(1:nGWidthT));
tokenNumT = nGTokLen(1:nGWidthT);
if(~isequal(tokenNum,tokenNumT(:)))
    disp(tokenNum);
    disp(tokenNumT);
    error('Error：列Token信息图片与字符Token读取结果不对应。');
end
% 行Token
tokenNum = cellfun(imgNumFun,ImgSetPatchRow);
% tokenNumT = cellfun(@length,nGtok(nGWidthT+1:end));
tokenNumT = nGTokLen(nGWidthT+1:end);
if(~isequal(tokenNum,tokenNumT(:)))
    disp(tokenNum);
    disp(tokenNumT);
    error('Error：行Token信息图片与字符Token读取结果不对应。');
end

%% 载入图片
% 原数据集个数
dataSetNum = length(nGImgLabel);

% 列Token
nGImgLabel = cat(1, nGImgLabel, cell2mat(nGtok(1:nGWidthT)'));
for ii = 1:length(ImgSetPatchRow)
    nGImgSet = cat(3,nGImgSet,ImgSetPatchRow{ii});
end
% 行Token
nGImgLabel = cat(1, nGImgLabel, cell2mat(nGtok(nGWidthT+1:end)'));
for ii = 1:length(ImgSetPatchLine)
    nGImgSet = cat(3,nGImgSet,ImgSetPatchLine{ii});
end

% 存储文件信息
lastSave = currentSave;

fprintf('\t 添加单元数目：%d\n',length(nGImgLabel) - dataSetNum);
fprintf('\t 总单元数目：%d\n', length(nGImgLabel));
%% 随机显示
figure("Name", "样本随机显示")
for ii = 1:3
    subplot(2,3,ii)
    index = randi([max(dataSetNum,1) length(nGImgLabel)]);
    imshow(nGImgSet(:,:,index));
    title("序号:" + int2str(index) + "  标签:" + int2str(nGImgLabel(index)));
    subplot(2,3,ii+3)
    index = randi([1 length(nGImgLabel)]);
    imshow(nGImgSet(:,:,index));
    title("序号:" + int2str(index) + "  标签:" + int2str(nGImgLabel(index)));
end
%% 保存
save nGCNNTrainData.mat nGImgSet nGImgLabel lastSave

% 结束线
fprintf('\t%s\n',repmat('=',[40 1]));