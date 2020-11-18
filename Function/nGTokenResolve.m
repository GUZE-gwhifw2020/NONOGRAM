function [nonoWidthLine,nonoHeightRow,...
    t_NonoTokenLine,t_NonoTokenRow,...
    t_NonoTokenLengthLine,t_NonoTokenLengthRow,...
    t_NonoTokenSumLine,t_NonoTokenSumRow] ...
    = nGTokenResolve(taskTokenStr)

%nGTokenResolve token�ַ�������token����
%       Ouput
%       nonoWidth                   :���(�и���)
%       nonoHeight                  :�߶�(�и���)
%       t_NonoTokenLine             :ÿ��token
%       t_NonoTokenRow              :ÿ��token
%       t_NonoTokenLengthLine       :��token����
%       t_NonoTokenLengthRow        :��token����
%       t_NonoTokenSumLine          :ÿ��token��
%       t_NonoTokenSumRow           :ÿ��token��
%       

% �ָ�ÿ��/���ַ�
tokenTemp = strsplit(taskTokenStr,'/');

% ȷ���������д�С
if(ismember(length(tokenTemp),[10;20;30;40;50;60;100]))
    % ���ܱ���
    nonoWidthLine = length(tokenTemp)/2;
    nonoHeightRow = length(tokenTemp)/2;
elseif(ismember(length(tokenTemp),[55]))
    % ���ܱ���
    nonoWidthLine = 25;
    nonoHeightRow = 30;
else
    
    % �޷�����ȷ��
    fprintf('\t�޷�����ʶ����������Ϊ%d\n',length(tokenTemp))
    nonoWidthLine = input("    ����Width: ");
    nonoHeightRow = input("    ����Height: ");
    
    % �����Ƿ���ȷ
    if(nonoWidthLine+nonoHeightRow ~= length(tokenTemp))
        fprintf('\n %d \t %d \t %d \n',nonoWidthLine,nonoHeightRow,length(tokenTemp));
        error('����������������')
    end
end

% ��Token��Token����,��СΪ�ܿ��
t_NonoTokenLine = cell(nonoWidthLine,1);
t_NonoTokenLengthLine = zeros(nonoWidthLine,1);
t_NonoTokenSumLine = zeros(nonoWidthLine,1);

% ��Token��Token����,��СΪ�ܸ߶�
t_NonoTokenRow = cell(nonoHeightRow,1);
t_NonoTokenLengthRow = zeros(nonoHeightRow,1);
t_NonoTokenSumRow = zeros(nonoHeightRow,1);

for ii = 1:length(tokenTemp)
    
    % �ָ�ÿ��token�ַ�
    tokenTemp2 = strsplit(tokenTemp{ii},'.');

    % STR����cellתdouble����
    tokenTemp3 = cellfun(@str2double,tokenTemp2)';
    
    % �ȸ�ֵ�У��ٸ�ֵ��
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
    error('������������')
end

end

