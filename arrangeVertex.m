function [Room_1,Room_2,vertex2] = arrangeVertex(vertex1,m,label_map,vertemb,bit_len)
%     magnify = 10^m;
    [vertex1, bit_len] = meshPrepro(m, vertex1);
    vertex2 = vertex1;
    [~,count] = size(vertemb);
    Room_1 = [];% 可嵌入空间  可用于替换的空间
    Room_2 = [];% 不可嵌入空间 即保持不变的空间
    for v = 1:count
        bin1 = int32(dec2binPN(vertex2(vertemb(v),1), bit_len)');
        bin_1 = bin1(1:label_map(v));% 可嵌入的位置
        bin_1_1 = bin1(label_map(v)+1:end);
        bin2 = int32(dec2binPN(vertex2(vertemb(v),2), bit_len)');
        bin_2= bin2(1:label_map(v));
        bin_2_2 = bin2(label_map(v)+1:end);
        bin3 = int32(dec2binPN(vertex2(vertemb(v),3), bit_len)');
        bin_3 = bin3(1:label_map(v));
        bin_3_3 = bin3(label_map(v)+1:end);
        Room_1 = [Room_1 bin_1 bin_2 bin_3];  
        Room_2 = [Room_2 bin_1_1 bin_2_2 bin_3_3];
    end
end

