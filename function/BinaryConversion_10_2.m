function [bin2] = BinaryConversion_10_2(value,m)
% 函数说明：将十进制灰度像素值转换成8位二进制数组
% 输入：value（十进制灰度像素值）
% 输出：bin2（m位二进制数组）

bin2 = dec2bin(value)-'0';
if length(bin2) < m
    len = length(bin2);
    B = bin2;
    bin2 = zeros(1,m);
    for i=1:len
        bin2(m-len+i) = B(i); %不足8位前面补充0
    end 
end