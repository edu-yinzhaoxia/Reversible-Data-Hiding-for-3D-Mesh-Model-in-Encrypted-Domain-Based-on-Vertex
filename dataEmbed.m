function [vertex2,message] = dataEmbed(vertex1,Room_2,label_bin,label_map,bit_len,vertemb,magnify)
%DATAEMBED 此处显示有关此函数的摘要
%   此处显示详细说明
% 算术编码压缩
vertex2 = vertex1;
[n,~] = size(vertex1);
len_sum = sum(label_map);
cPos_x = cell(1,1);
cPos_x{1} = label_bin;
tic
loc_Com =  arith07(cPos_x);
toc
bin_index = 8;
[compress_bit,compress_len] = dec_transform_bin(loc_Com, bin_index);
% compress_bit = double(compress_bit);
% 生成利用密钥生成附加数据 
k_emb = 54321;
m=ceil(log2(9*n));
message = double(logical(pseudoGenerate(3*len_sum-compress_len-m, k_emb))');
Room_2 = double(Room_2);
ver2_int = [];
len_label = zeros(1,m);%记录压缩的标签的长度
compress_label_bit = BinaryConversion_10_2(compress_len,m);
len_label = compress_label_bit;
mess_total = [len_label compress_bit message Room_2];
for i = 1:length(mess_total)/bit_len
    ver2_temp_bin = mess_total((i-1)*bit_len+1: i*bit_len);
    ver2_temp = BinaryConversion_2_10(ver2_temp_bin,bit_len);
    ver2_int = [ver2_int; ver2_temp];
end
for i = 1:length(mess_total)/bit_len/3
    vertex2(vertemb(i), 1) = ver2_int(3*(i-1)+1);
    vertex2(vertemb(i), 2) = ver2_int(3*(i-1)+2);
    vertex2(vertemb(i), 3) = ver2_int(3*(i-1)+3);
end 
%vertex2 = double(vertex2)/magnify;
end

