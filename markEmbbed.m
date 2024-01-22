function [label_map,vertemb] = markEmbbed(vertex0, face, bit_len)
%MARKEMBBED 函数记录每个嵌入集顶点可嵌入数据的长度
%% Separate Vertexes into 2 Sets
[num_face, ~] = size(face);
[num_vert,~] =size(vertex0);
face = int32(face);
%% ty修改后的
%% 获取face的频率排序 升序排列
Vertemb = int32([]);
Vertnoemb = int32([]);
s_info = repmat(struct('id',[],'num',[],'ref',[],'status',[]),num_vert,1);
%% 为每个点找寻相关点 并去除低频索引点
i = 1;
while i <= num_vert
    s_info(i).id =i ;
    location = mod(find(i==face),num_face);% 找到结点在face中出现的所有行数
    location(location==0) = num_face; %  修正因为mod处理带来的0值
    [num_location,~] = size(location);
    for m = 1:num_location
        one = face(location(m),1);
        two = face(location(m),2);
        three = face(location(m),3);
        v1 = isempty(find(one==i))==0;
        v2 = isempty(find(two==i))==0; 
        v3 = isempty(find(three==i))==0;
        if(v1==1)
            Vertnoemb = [Vertnoemb two, three];
        elseif(v2==1)
            Vertnoemb = [Vertnoemb one, three];
        elseif(v3==1)
            Vertnoemb = [Vertnoemb one, two];
        end
    end
    Vertnoemb = unique(Vertnoemb);
    [~,num] = size(Vertnoemb);
    s_info(i).ref = Vertnoemb;
    s_info(i).num = num;
    s_info(i).status= 0;
    Vertnoemb = [];
    i = i+1;
end
% 构建新的索引表信息  筛选奇数点里的偶数点索引(偶数点里的奇数点索引)（这里以奇数点为例子）
[~,ind]=sort([s_info.id],'ascend');
new_info=s_info(ind);

Vertemb_even = int32([]);  % 选出一些更适合嵌入的偶数点
for j = 1:num_vert
    if (mod((new_info(j).id),2)==0)% 若当前节点是预测集的偶数点   
        % 判断他周围奇数点数目是不是多于偶数点 如果是 这个偶数点用于预测更好 反之用于嵌入 因为偶数点多 预测更好
        even = find(mod(new_info(j).ref,2)==0);% 周围的偶数点数目
        temp = setdiff(new_info(j).ref(even),Vertemb_even);
        even = temp;
        odd = find(mod(new_info(j).ref,2)==1); % 周围的奇数点数目
        if(((length(odd)<2*length(even))&&(length(even)>=2)))
            Vertemb_even = [Vertemb_even new_info(j).id];
        end
    end
end

for k = 1:num_vert
    if (mod((new_info(k).id),2)~=0)% 若当前节点是奇数顶点
        Vertemb = [Vertemb new_info(k).id];
%         mid = find(mod(new_info(k).ref,2)==0);
%         new_info(k).ref = new_info(k).ref(mid);
%         new_info(k).ref = setdiff(new_info(k).ref(:),Vertemb_even(:));% 去除奇数嵌入点的预测集中偶数嵌入点的顶点
    elseif (sum(ismember(Vertemb_even, new_info(k).id)))
        Vertemb = [Vertemb new_info(k).id];
%         mid = find(mod(new_info(k).ref,2)==0);
%         new_info(k).ref = new_info(k).ref(mid);
%         new_info(k).ref = setdiff(new_info(k).ref(:),Vertemb_even(:));
    end
end

% 嵌入集再筛选
[~,count_init]= size(Vertemb);
location_abanden = [];
for v = 1:count_init
    refer_vex = new_info(Vertemb(v)).ref;
    refer_vex = unique(refer_vex);
    refer_vex = setdiff(refer_vex(:),Vertemb(:))';
    [~,refer_num] = size(refer_vex);
    if refer_num ==0
        location_abanden = [location_abanden v];
    end
end
Vertemb(location_abanden) = [];

%% 输出嵌入集顶点
vertemb = Vertemb;
%% Calculate and record prediction error
[~,count]= size(Vertemb);
label_map = [];
for v = 1:count
    refer_vex = [];
    refer_vex = new_info(Vertemb(v)).ref;
    refer_vex = unique(refer_vex);
    refer_vex = setdiff(refer_vex(:),Vertemb(:))';
    [~,refer_num] = size(refer_vex);
    if refer_num>0  % 将索引点的三个坐标化为二进制表示
        bin1 = int32(dec2binPN( vertex0(Vertemb(v),1), bit_len)');
        bin2 = int32(dec2binPN( vertex0(Vertemb(v),2), bit_len)');
        bin3 = int32(dec2binPN( vertex0(Vertemb(v),3), bit_len)');
        % 将该索引点的相关点进行统计
        refer_bin1 = int32(zeros(1, bit_len));
        refer_bin2 = int32(zeros(1, bit_len));
        refer_bin3 = int32(zeros(1, bit_len));
        for j = 1:refer_num
            refer_bin1 = refer_bin1 + int32(dec2binPN( vertex0(refer_vex(j),1), bit_len)');
            refer_bin2 = refer_bin2 + int32(dec2binPN( vertex0(refer_vex(j),2), bit_len)');
            refer_bin3 = refer_bin3 + int32(dec2binPN( vertex0(refer_vex(j),3), bit_len)');
        end
        % 将所有的预测索引点进行求和 再除以预测点数目 获得预测值
        refer_bin1 = int32(refer_bin1/refer_num);
        refer_bin2 = int32(refer_bin2/refer_num);
        refer_bin3 = int32(refer_bin3/refer_num);
        % t值为预测准确的二进制个数
        t1=0;   
        t2=0;
        t3=0;
        % 通过三个for循环 获取预测点与嵌入点的预测准确度
        for k1 = 1:bit_len
            if bin1(k1) == refer_bin1(k1)
                t1 = k1;
            else
                break;
            end
        end
        for k2 = 1:bit_len
            if bin2(k2) == refer_bin2(k2)
                t2 = k2;
            else
                break;
            end
        end
        for k3 = 1:bit_len
            if bin3(k3) == refer_bin3(k3)
                t3 = k3;
            else
                break;
            end
        end
        t0 = [t1 t2 t3];
        t = min(t0);
        label_map = [label_map t];
        if t == 0
            xxx=15;
        end
    else
        label_map = [label_map 0];
        continue;
    end
end
end
