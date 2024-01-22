clc
clear
%% 数据集测试对比
% version 1: 默认绘图
y = [0.36 6 16 7.68 1.06 14.25 25.65 33.24];
width = 0.5;
h = bar(y, width);
ylim([0,36]);
color_matrix = [];
set(gca, 'XTickLabel',{'Jiang et al.[4]','Shah et al.[9]','van Rensburg et al.[13]','Tsai.[12]','Xu et al.[14]','Yin et al.[17]','Lyu et al.[5]','Ours'});
for i = 1:8
    b = bar(i,y(i),0.75,'stacked');  %0.75是柱形图的宽，可以更改
    set(b(1),'facecolor',color_matrix(i,:))
end