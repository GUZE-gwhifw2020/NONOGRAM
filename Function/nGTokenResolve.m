function [nonoWidthLine,nonoHeightRow,...
    t_NonoTokenLine,t_NonoTokenRow,...
    t_NonoTokenLengthLine,t_NonoTokenLengthRow,...
    t_NonoTokenSumLine,t_NonoTokenSumRow] ...
    = nGTokenResolve(taskTokenStr)

%nGTokenResolve token字符串生成token矩阵
%       Ouput
%       nonoWidth                   :宽度(列个数)
%       nonoHeight                  :高度(行个数)
%       t_NonoTokenLine             :每列token
%       t_NonoTokenRow              :每行token
%       t_NonoTokenLengthLine       :列token长度
%       t_NonoTokenLengthRow        :行token长度
%       t_NonoTokenSumLine          :每列token和
%       t_NonoTokenSumRow           :每行token和
%       

% 分割每行/列字符
tokenTemp = strsplit(taskTokenStr,'/');

% 确定矩阵行列大小
if(ismember(length(tokenTemp),[10;20;30;40;50;60;100]))
    % 智能辨认
    nonoWidthLine = length(tokenTemp)/2;
    nonoHeightRow = length(tokenTemp)/2;
elseif(ismember(length(tokenTemp),[55]))
    % 智能辨认
    nonoWidthLine = 25;
    nonoHeightRow = 30;
else
    
    % 无法智能确认
    fprintf('\t无法智能识别，行列总数为%d\n',length(tokenTemp))
    nonoWidthLine = input("    输入Width: ");
    nonoHeightRow = input("    输入Height: ");
    
    % 输入是否正确
    if(nonoWidthLine+nonoHeightRow ~= length(tokenTemp))
        fprintf('\n %d \t %d \t %d \n',nonoWidthLine,nonoHeightRow,length(tokenTemp));
        error('矩阵行列总数错误')
    end
end

% 列Token与Token长度,大小为总宽度
t_NonoTokenLine = cell(nonoWidthLine,1);
t_NonoTokenLengthLine = zeros(nonoWidthLine,1);
t_NonoTokenSumLine = zeros(nonoWidthLine,1);

% 行Token与Token长度,大小为总高度
t_NonoTokenRow = cell(nonoHeightRow,1);
t_NonoTokenLengthRow = zeros(nonoHeightRow,1);
t_NonoTokenSumRow = zeros(nonoHeightRow,1);

for ii = 1:length(tokenTemp)
    
    % 分割每个token字符
    tokenTemp2 = strsplit(tokenTemp{ii},'.');

    % STR类型cell转double类型
    tokenTemp3 = cellfun(@str2double,tokenTemp2)';
    
    % 先赋值列，再赋值行
    if(ii <= nonoWidthLine)
        t_NonoTokenLine{ii} = tokenTemp3;
        t_NonoTokenLengthLine(ii) = length(tokenTemp2);
        t_NonoTokenSumLine(ii) = sum(tokenTemp3);
    else
        t_NonoTokenRow{ii-nonoWidthLine} = tokenTemp3;
        t_NonoTokenLengthRow(ii-nonoWidthLine) = length(tokenTemp2);
        t_NonoTokenSumRow(ii-nonoWidthLine) = sum(tokenTemp3);
    end
    
end

if(sum(t_NonoTokenSumLine)~=sum(t_NonoTokenSumRow))
    fprintf('\n %d \t %d \t %d \n',nonoWidthLine,nonoHeightRow,length(tokenTemp));
    fprintf('\n %d \t %d \n',sum(t_NonoTokenSumLine),sum(t_NonoTokenSumRow));
    error('行列总数不等')
end

end

