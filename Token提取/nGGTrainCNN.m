%% Birth Certificate
% ===================================== %
% DATE OF BIRTH:    2020.12.10
% NAME OF FILE:     nGGTrainCNN
% FILE OF PATH:     \NONOGRAM\Token提取
% FUNC:
%   Train CNN Network.
% ===================================== %

% 读取网络层结构
load layerGraph.mat lgraph

% 读取数据标签
load nGCNNTrainData.mat nGImgLabel nGImgSet

% 图像拓展为[64 64 1 sampleNum]
newDim = [size(nGImgSet,1:2) 1 size(nGImgSet,3)];
nGImgSet = reshape(nGImgSet,newDim);

% 个位标签
nGImgLabel0 = categorical(mod(nGImgLabel,10));
% 十位标签(默认数字不超过99)
nGImgLabel1 = categorical(floor(nGImgLabel/10));

% 训练网络参数
opts = trainingOptions('adam', ...
    'MaxEpochs',64, ...
    'InitialLearnRate',0.01, ...
    'LearnRateDropFactor',0.5,...
    'LearnRateDropPeriod',8,...
    'LearnRateSchedule','piecewise',...
    'MiniBatchSize',128,...
    'VerboseFrequency',2000,...
    'ExecutionEnvironment','gpu');

net0 = trainNetwork(nGImgSet, nGImgLabel0, lgraph, opts);
net1 = trainNetwork(nGImgSet, nGImgLabel1, lgraph, opts);

save cnnNet net0 net1