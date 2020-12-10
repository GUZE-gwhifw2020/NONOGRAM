%% Birth Certificate
% ===================================== %
% DATE OF BIRTH:    2020.11.29
% NAME OF FILE:     nGCase
% FILE OF PATH:     /NonoGram
% FUNC:
%   NonoGram类实例
% ===================================== %
% clc

%%
strToken = input('输入Token：','s');

%%
addpath('Function')
X = NonoGram(strToken);
%%
X = X.Genesis();
X.Display();