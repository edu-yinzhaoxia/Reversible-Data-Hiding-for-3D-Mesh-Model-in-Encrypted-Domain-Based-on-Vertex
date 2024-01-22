function [label_map] = labelInt(map_bin)
maplen = 6;
[col,~] = size(map_bin);
col = col/maplen;
label_map=zeros(col,maplen);
m={};
for i=1:col
label_map(i,:)=map_bin(1+maplen*(i-1):maplen*i);
end
for j=1:col
b=num2str(label_map(j,:));
b(findstr(' ',b))=[];
m{j}=b;
end
label_map = bin2dec(m);










