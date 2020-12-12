%% Birth Certificate
% ===================================== %
% DATE OF BIRTH:    2020.12.11
% NAME OF FILE:     customPicTokGen
% FILE OF PATH:     /CustomizedPic
% FUNC:
%   根据自定义图片生成token，保存在txt文件中。
% ===================================== %

clc;
addpath('../Function')
%% 全局变量
% 图片名称
PIC_NAME = uigetfile('*.jpg;*.png','Select an image','0.png');

if isequal(PIC_NAME,0) || ~contains(PIC_NAME, {'.jpg';'.png'})
    error('Error: 无效图片名');
end

% 存储txt文件名
TXT_NAME = sprintf('%s %s.txt',erase(PIC_NAME,{'.jpg';'.png'}),...
    string(datetime).replace(':','-'));

%% 图片处理
imgOrigin = imread(PIC_NAME);

% 转换为灰度图片
I = rgb2gray(imgOrigin);

% 转换为二值图片
I = I > (otsuMethod(I) * 255);

%% 字符token
% 行列token存储cell
tokStrCell = cell(sum(size(I)), 1);
for ii = 1:size(I, 2)
    % 列token
    tokStrCell{ii} = tokGenLR(I(:,ii));
end
for ii = 1:size(I, 1)
    % 行token
    tokStrCell{ii + size(I, 2)} = tokGenLR(I(ii,:));
end
% 合并
tokStr = strcat(tokStrCell{:});
tokStr(end) = [];

%% 存储
fid = fopen(TXT_NAME,'w');
fprintf(fid, tokStr);
fclose(fid);

%% 结果显示
fprintf('%s\n',repmat('=',[1 40]));
fprintf('\t成功转换文件%s\n',PIC_NAME);
fprintf('\t图片信息:\n\t高度:%d\t\t宽度:%d\n',size(I,1), size(I,2));
fprintf('\t点数占比:%f\n',nnz(I) / numel(I));
fprintf('%s\n',repmat('=',[1 40]));
%%
function tokStr = tokGenLR(I2)
% TOKGENLR 单行/列token字符输出
% I2 = [1 0 1 0 1 1];
% tokStr = '1.1.2/'

d = diff([0;I2(:);0]);
cc = find(d == -1) - find(d == 1);

if(~isempty(cc))
    tokStr = sprintf('%d.', cc);
    tokStr(end) = '/';
else
    tokStr = '/';
end

end


