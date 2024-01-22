function [label_Bin,num_label] = labelBinary(labelMap)
%LABELBINARY 将容量标签转换成二进制形式
%   此处显示详细说明
maplen = 6;
[~,col] = size(labelMap); %计算Map_origin_I的行列值
label_Bin = zeros();
t = 0; %计数，二进制数组的长度

for i=1:col
    label_Bin(t+1:t+maplen) = dec2bin(labelMap(i),maplen)-'0';
    t = t + maplen;
end 
[~,num_label] = size(label_Bin);
