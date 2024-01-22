clear; clc; close all;
addpath(genpath(pwd));

fprintf('Conduct RDH-ED based on MSB in 3D meshes:\n');
% vextex0: 原始顶点信息
% vextex1: 加密顶点信息
% vextex2: 加密后嵌入秘密数据顶点信息
% vextex3: 提取恢复后顶定信息 

fid = fopen('results.txt','w');
files = dir('origin');
[num, ~]= size(files);
for i=1:num
if strfind(files(i).name,'.ply')
    name = files(i).name;
else
    continue;
end

name = name;
source_dir = ['origin/',name];
display(name)
fprintf(fid, '%s\n',name);
fprintf(fid, 'm        embbed_len       capacity       hd                snr\n');
display('m     embbed_len      capacity      hd                    snr');
for m = 6:9;
%% Read a 3D mesh file
[~, file_name, suffix] = fileparts(source_dir);
if(strcmp(suffix,'.obj')==0) %off
    %[vertex, face] = read_mesh(source_dir);
    [vertex, face] = read_mesh(source_dir);
  %  vertex = vertex'; face = face';
else %obj
    Obj = readObj(source_dir);
    vertex = Obj.v; face = Obj.f.v;
end

vertex0 = vertex;

%% Preprocessing
magnify = 10^m;
[vertex, bit_len] = meshPrepro(m, vertex);

for embbed_len = 1:bit_len/4*3;

%% caculate wrong
vex_wrong = meshWrong(vertex, face, bit_len, embbed_len);

%% Encryption
%Compute mesh length
[meshlen, ver_bin] = meshLength(vertex, bit_len);
%Generate a psudorandom stream
k_enc = 12345;
sec_bin = logical(pseudoGenerate(meshlen, k_enc));
%Encrypt
enc_bin = xor(ver_bin, sec_bin);
%Generate encrypted mesh
vertex1 = meshGenerate(enc_bin, magnify, face, bit_len);
out_file = fullfile('encryption', ['encrypt_',file_name, '.off']);
%write_off(out_file, vertex1, face);
%write_ply(out_file, vertex1, face);

%% Message embedding
[vertex2, message_bin] = meshEmbbed(m, vertex1, face, vex_wrong, embbed_len);
out_file = fullfile('embedded',['embbed_',file_name, '.off']);
%write_off(out_file, vertex2, face);

%% Message extraction & mesh recovery
[ext_m, vertex3] = meshRecovery(m ,vertex2, face, vex_wrong, embbed_len);
out_file = fullfile('recovery',['recovery_',file_name, '.off']);
%write_off(out_file, vertex3, face);

%% Experimental result
%Compute HausdorffDist
hd = HausdorffDist(vertex0,vertex3,1,0);
%Compute SNR
snr = meshSNR(vertex0,vertex3);
%Compute capacity
[vex_num, ~] = size(vertex);
capacity = length(ext_m)/vex_num;
%Compute error percent

% if isempty(int32(message_bin))
%     err_percent = 0;
%     break;
% end
% 
% err_dist = int32(message_bin)-ext_m;
% err_length = length(find(err_dist(:)~=0));
% err_percent = err_length/length(ext_m);

fprintf(fid,'%d       %d     %f      %e          %f\n', m, embbed_len, capacity, hd, snr);
fprintf(fid,'\n');
display([num2str(m),'        ' ,num2str(embbed_len),'          ',num2str(capacity),'       ', num2str(hd),'                ',num2str(snr)]);
end
end
end
