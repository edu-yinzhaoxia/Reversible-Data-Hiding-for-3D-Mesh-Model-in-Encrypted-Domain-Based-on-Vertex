function [ext_m, vertex3] = meshRecovery(m ,vertex2, face, vex_wrong, embbed_len)
%% Extract embbed information and recover the mesh 

%% Convert vertexes into bitstream
magnify = 10^m;
[vertex2, bit_len] = meshPrepro(m, vertex2);
vertex3 = vertex2;
%% Separate vertexes into 2 sets
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
Vertemb = sort(Vertemb);

%% Extract embbed information
[~, num_vertemb] = size(Vertemb); 
[~, num_wrong] = size(vex_wrong);
ext_m = [];
ext_num = 0;
for v = 1:num_vertemb
    ext = [];
    if isempty(find(vex_wrong == Vertemb(v), 1)) == 1
        for i = 1:3
            bin = int32(dec2binPN( vertex3(Vertemb(v),i), bit_len)');
            for j = 1:embbed_len
                ext = [bin(j), ext];
                ext_num = ext_num + 1;
            end
        end
    end
    ext = flipud(ext');
    ext_m = [ext_m, ext'];
end 
ext_m = ext_m';

%% Convert vertexes into bitstream to decrypt mesh
[~, enc_bin] = meshLength(vertex3, bit_len);
%Compute mesh length
[meshlen, ~] = meshLength(vertex3, bit_len);
k_enc = 12345;
sec_bin = logical(pseudoGenerate(meshlen, k_enc));
ver2_bin = xor(enc_bin, sec_bin);
ver2_int = [];
for i = 1:length(ver2_bin)/bit_len
    ver2_temp_bin = ver2_bin((i-1)*bit_len+1: i*bit_len);
    if(ver2_temp_bin(1)==1)
        if(bit_len<64)
            ver2_temp = 0;
            for j = 0:bit_len-1
                ver2_temp = ver2_temp + ver2_temp_bin(bit_len-j)*2^j;
            end
            inv_dec = dec2bin(ver2_temp - 1, bit_len);
            true_dec = logical([]);
            for j = 1:bit_len
                true_dec = [true_dec; xor(str2num(inv_dec(j)), 1)];
            end
            ver2_temp = 0;
            for j = 0:bit_len-1
                ver2_temp = ver2_temp + true_dec(bit_len-j)*2^j;
            end
            ver2_temp = -ver2_temp;
        else
            ver2_temp1 = 0; %former
            ver2_temp2 = 0; %latter
            for j = 0:31
                ver2_temp1 = ver2_temp1 + ver2_temp_bin(bit_len-j)*2^j;
            end
            for j = 0:31
                ver2_temp2 = ver2_temp2 + ver2_temp_bin(32-j)*2^j;
            end
            inv_dec1 = dec2bin(ver2_temp2, 32); %former
            inv_dec2 = dec2bin(ver2_temp1-1, 64); %latter
            true_dec = logical([]);
            for j = 1:32
                true_dec = [true_dec; xor(str2num(inv_dec1(j)), 1)];
            end
            for j = 33:64
                true_dec = [true_dec; xor(str2num(inv_dec2(j)), 1)];
            end
            ver2_temp = 0;
            for j = 0:bit_len-1
                ver2_temp = ver2_temp + true_dec(bit_len-j)*2^j;
            end
            ver2_temp = -ver2_temp;
        end
    else
        ver2_temp = 0;
        for j = 0:bit_len-1
            ver2_temp = ver2_temp + ver2_temp_bin(bit_len-j)*2^j;
        end
    end
    ver2_int = [ver2_int; ver2_temp];
end

for i = 1:length(ver2_bin)/bit_len/3
    vertex3(i, 1) = ver2_int(3*(i-1)+1);
    vertex3(i, 2) = ver2_int(3*(i-1)+2);
    vertex3(i, 3) = ver2_int(3*(i-1)+3);
end

%% recover the mesh 
for v = 1:num_vertemb
    if isempty(find(vex_wrong == Vertemb(v))) == 1
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
        
        refer_bin1 = int32(zeros(1, bit_len));
        refer_bin2 = int32(zeros(1, bit_len));
        refer_bin3 = int32(zeros(1, bit_len));
        for i = 1:refer_num
            refer_bin1 = refer_bin1 + int32(dec2binPN( vertex3(refer_vex(i),1), bit_len)');
            refer_bin2 = refer_bin2 + int32(dec2binPN( vertex3(refer_vex(i),2), bit_len)');
            refer_bin3 = refer_bin3 + int32(dec2binPN( vertex3(refer_vex(i),3), bit_len)');
        end
        refer_bin1 = int32(refer_bin1/refer_num);
        refer_bin2 = int32(refer_bin2/refer_num);
        refer_bin3 = int32(refer_bin3/refer_num);
        
        for i = 1:embbed_len
            vertex3(Vertemb(v),1) = bitset(vertex3(Vertemb(v),1), bit_len-i+1, refer_bin1(i));
            vertex3(Vertemb(v),2) = bitset(vertex3(Vertemb(v),2), bit_len-i+1, refer_bin2(i));
            vertex3(Vertemb(v),3) = bitset(vertex3(Vertemb(v),3), bit_len-i+1, refer_bin3(i));
        end
 
    end
end 
%Reset into vertexes
vertex3 = double(vertex3) / magnify;

end