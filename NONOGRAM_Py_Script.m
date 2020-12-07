%% py文件：读取四顶点坐标
system('NONOGRAM_MOUSE_SIMULATION_1.py');

%% 读取文件
apex = readmatrix(...
    'dataTempNonogramScript.xls',...
    'Sheet','PointsLoc',...
    'Range','A1:B4');

%% 屏幕像素显示比例
% 显示设置缩放与布局中找到
screenPixelRatio = 2.5;

%% 处理数据
% 左右像素边界
xBound = sort(round(twoFromFour(apex(:,1))));
yBound = sort(round(twoFromFour(apex(:,2))));

% 单位间隔
xIntv = diff(xBound) / (nonoWidthLine);
yIntv = diff(yBound) / (nonoHeightRow);

fprintf('\t x方向像素间隔: %d \n',round(xIntv));
fprintf('\t y方向像素间隔: %d \n',round(yIntv));

if(round(xIntv) ~= round(yIntv))
    warning('顶点定位出现问题。可能引发不确定错误。')
end


%% 导出鼠标坐标
% 三个参数，x位置，y位置，是否填空
xyMouseClickPos = zeros(nonoWidthLine * nonoHeightRow,3);
% 偏置
xyBias = -[xIntv * 0.5 yIntv * 0.5] + ...
    [xBound(1) yBound(1)];

% 利用meshgrid直接生成行列信息
[X,Y] = meshgrid(1:nonoHeightRow,1:nonoWidthLine);
xyMouseClickPos(:,1:2) = [Y(:)*yIntv X(:)*xIntv];

% 修正因子
xyMouseClickPos(:,1:2) = xyMouseClickPos(:,1:2);

% 添加总偏置与250%缩放(因电脑而异)
xyMouseClickPos(:,1:2) = round((xyMouseClickPos(:,1:2) + xyBias) / screenPixelRatio);

% 点击属性设置
xyMouseClickPos(:,3) = nonoGramMatrix(:);
% xyMouseClickPos(:,3) = 0;

% 写入
writematrix(xyMouseClickPos,'dataTempNonogramScript.xls','Sheet','xyMouseClickPos','Range','A1');

%%
system('NONOGRAM_MOUSE_SIMULATION_2.py');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function twoArray = twoFromFour(fourArray)
% 从大小为4的数组中取出其中独立的两个

twoArray = zeros(2,1);
twoArray(1) = mean(fourArray(fourArray > mean(fourArray)));
twoArray(2) = mean(fourArray(fourArray < mean(fourArray)));

end