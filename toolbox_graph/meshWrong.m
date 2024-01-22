function [vex_wrong] = meshWrong(vertex0, face, bit_len, embbed_len)
% Calculate and record prediction

%% Separate Vertexes into 2 Sets
[num_face, ~] = size(face);
face = int32(face);
Vertemb = int32([]);
Vertnoemb = int32([]);

for i = 1:num_face
    v1 = isempty(find(face(i, 1)==Vertemb))==0;
    v2 = isempty(find(face(i, 2)==Vertemb))==0;
    v3 = isempty(find(face(i, 3)==Vertemb))==0;
    v4 = isempty(find(face(i, 1)==Vertnoemb))==0;
    v5 = isempty(find(face(i, 2)==Vertnoemb))==0;
    v6 = isempty(find(face(i, 3)==Vertnoemb))==0;
    if(v1==0 && v2==0 && v3==0) %no adjacent vertexes
        if(v4==0 && v5==0 & v6==0)
            Vertemb = [Vertemb face(i, 1)];
            Vertnoemb = [Vertnoemb face(i, 2) face(i, 3)];
        elseif(v4==0 && v5==0 & v6==1)
            Vertemb = [Vertemb face(i, 1)];
            Vertnoemb = [Vertnoemb face(i, 2)];
        elseif(v4==0 && v5==1 & v6==0)
            Vertemb = [Vertemb face(i, 1)];
            Vertnoemb = [Vertnoemb face(i, 3)];
        elseif(v4==1 && v5==0 & v6==0)
            Vertemb = [Vertemb face(i, 2)];
            Vertnoemb = [Vertnoemb face(i, 3)];
        elseif(v4==0 && v5==1 & v6==1)
            Vertemb = [Vertemb face(i, 1)];
        elseif(v4==1 && v5==0 & v6==1)
            Vertemb = [Vertemb face(i, 2)];
        elseif(v4==1 && v5==1 & v6==0)
            Vertemb = [Vertemb face(i, 3)];
        elseif(v4==1 && v5==1 & v6==1)
        end
    else %some adjacent vertexes
        if(v1==0)
            Vertnoemb = [Vertnoemb face(i, 1)];
        end
        if(v2==0)
            Vertnoemb = [Vertnoemb face(i, 2)];
        end
        if(v3==0)
            Vertnoemb = [Vertnoemb face(i, 3)];
        end
    end
    Vertnoemb = unique(Vertnoemb);
end

%% Calculate and record prediction error
[~,count]= size(Vertemb);
vex_wrong = [];
for v = 1:count
    refer_vex = [];
    for i = 1:num_face
        v1 =(face(i, 1) == Vertemb(v));
        v2 =(face(i, 2) == Vertemb(v));
        v3 =(face(i, 3) == Vertemb(v));
        if v1 == 1
            refer_vex = [refer_vex, face(i,2),face(i,3)];
        end
        if v2 == 1
            refer_vex = [refer_vex, face(i,1),face(i,3)];
        end
        if v3 == 1
            refer_vex = [refer_vex, face(i,1),face(i,2)];
        end
    end
    refer_vex = unique(refer_vex);
    refer_vex = setdiff(refer_vex(:),Vertemb(:))';
    [~,refer_num] = size(refer_vex);
    
    bin1 = int32(dec2binPN( vertex0(Vertemb(v),1), bit_len)');
    bin2 = int32(dec2binPN( vertex0(Vertemb(v),2), bit_len)');
    bin3 = int32(dec2binPN( vertex0(Vertemb(v),3), bit_len)');
    
    refer_bin1 = int32(zeros(1, bit_len));
    refer_bin2 = int32(zeros(1, bit_len));
    refer_bin3 = int32(zeros(1, bit_len));
    for i = 1:refer_num
        refer_bin1 = refer_bin1 + int32(dec2binPN( vertex0(refer_vex(i),1), bit_len)');
        refer_bin2 = refer_bin2 + int32(dec2binPN( vertex0(refer_vex(i),2), bit_len)');
        refer_bin3 = refer_bin3 + int32(dec2binPN( vertex0(refer_vex(i),3), bit_len)');
    end
    refer_bin1 = int32(refer_bin1/refer_num);
    refer_bin2 = int32(refer_bin2/refer_num);
    refer_bin3 = int32(refer_bin3/refer_num);
    
    predict_1 = bin1(1:embbed_len) == refer_bin1(1:embbed_len);
    predict_2 = bin2(1:embbed_len) == refer_bin2(1:embbed_len);
    predict_3 = bin3(1:embbed_len) == refer_bin3(1:embbed_len);
    
    success = (predict_1 ~= 1) + (predict_2 ~= 1) + (predict_3 ~= 1);
    success = sum(success);
    
    if success ~= 0
       vex_wrong = [vex_wrong, Vertemb(v)];
    end
end
end

