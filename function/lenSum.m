function [len_sum] = lenSum(label_map,vertemb)
%LENSUM 计算模型可嵌入长度
[~,num] = size(vertemb);
len_sum = 0;
for i = 1:num
    len_sum =len_sum + 3*label_map(i);
end

