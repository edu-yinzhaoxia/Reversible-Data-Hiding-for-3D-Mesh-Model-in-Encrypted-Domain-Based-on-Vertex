%% 
clear; clc;close all;
addpath(genpath(pwd));
% vextex0: Original vertex information 
% vextex1: Encrypted vertex information 
% vextex2: Vertex information embedded in secret data after encryption  
% vextex3: Vertex information after extraction and restoration 
%%
fid = fopen('results.txt','w'); % Save output
dataset = dir('origin'); 
files = dataset;
[num, ~]= size(files);
C = 0;
Capacity = [];
for m= 3:9
for i = 1 : num
    a = strfind(files(i).name,'.off');
    if isempty(strfind(files(i).name,'.off')) && isempty(strfind(files(i).name,'.ply'))
        continue;
    else
        name = files(i).name;
    end
    
    source_dir = ['origin/',name];
    display(name)
    fprintf(fid, '%s\n',name);
    display('m           capacity             hd                   snr');
    fprintf(fid, 'm             capacity              hd               snr\n');
%     m = 5;% Vertex information storage accuracy m
    %% Read a 3D mesh file
    [~, file_name, suffix] = fileparts(source_dir);
    if strcmp(suffix,'.off') %off
        [vertex, face] = read_mesh(source_dir);
        vertex = vertex';
        face = face';
    elseif strcmp(suffix,'.ply')
        [vertex, face] = read_mesh(source_dir);
    elseif strcmp(suffix,'.obj')
        Obj = readObj(source_dir);
        vertex = Obj.v; face = Obj.f.v;
    end

    vertex0 = vertex;% 记录初始顶点值
    %% Preprocessing
    magnify = 10^m;
    % 归一化
    [vertex, bit_len] = meshPrepro(m, vertex0);
    vertex = (vertex + (magnify))/2;
%     figure(1),
%     plot_mesh(vertex,face);
    %% Prediction error detection
    [label_map,vertemb] = markEmbbed(vertex, face, bit_len);
    [label_bin,num_label] = labelBinary(label_map);% 将labelmap转化为6位的二进制并获取总长度
    %% 
    [meshlen, mesh_bin] = meshLength(vertex, bit_len);
    k_enc = 12345;
    sec_bin = logical(pseudoGenerate(meshlen, k_enc));
    %Encrypt
    enc_bin = xor(mesh_bin, sec_bin);
%     % vertex1 = meshEncrypt(enc_bin',bit_len,magnify);
    % 1为小数表示 2为整数 3为嵌入信息的 4为解密的
    vertex1 = meshGenerate(enc_bin, magnify, face, bit_len);
    [Room_1,Room_2,vertex2] = arrangeVertex(vertex1,m,label_map,vertemb,bit_len);% 将可嵌入空间和
    [vertex3,message] = dataEmbed(vertex2,Room_2,label_bin,label_map,bit_len,vertemb,magnify);
    [vertex4] = vertRecovery(vertex3,face,Room_2,bit_len,magnify,sec_bin);
%     vertex4 = (vertex4*2-1); 
    %% 可视化
%     figure(1),
%     plot_mesh(vertex0,face);
%     figure(2),

%     plot_mesh(vertex2,face);
%     figure(3),
%     plot_mesh(vertex3,face);
%     figure(4),
%     plot_mesh(vertex4,face);
    %% 存储本地
    out_file = fullfile('encryption',['encryption_',file_name, '.off']);
    write_off(out_file, vertex2, face);
    out_file = fullfile('embedded',['embedded_',file_name, '.off']);
    write_off(out_file, vertex3, face);
    out_file = fullfile('recovery',['recovery_',file_name, '.off']);
    write_off(out_file, vertex4, face);
    %% Experimental result
    %Compute HausdorffDist
    hd = HausdorffDist(vertex0,vertex4,1,0);
    %Compute SNR
    snr = meshSNR(vertex0,vertex4);
    %Compute capacity
    [vex_num, ~] = size(vertex);
    capacity = length(message)/vex_num;
    C = C + capacity;
    fprintf(fid,'%d          %f         %e          %f\n', m,capacity, hd, snr);
    display([num2str(m),'           ',num2str(capacity),'              ', num2str(hd),'            ',num2str(snr)]);
    Capacity = [Capacity, capacity];
end
end
avecapacity = C / (num-3);