%% 
clear; clc;close all;
addpath(genpath(pwd));
% vextex0: Original vertex information 
% vextex1: Encrypted vertex information 
% vextex2: Vertex information embedded in secret data after encryption  
% vextex3: Vertex information after extraction and restoration 

fid = fopen('results.txt','w'); % Save output
dataset = dir('origin'); 
testmodel = dir('testmodel'); 
files = dataset;
[num, ~]= size(files);
C = 0;
Capacity = [];
Ma = [];
Mi = [];
for i = 1 : num
    if strfind(files(i).name,'.off')% if strfind(files(i).name,'.ply') %Read a file in .ply format
        name = files(i).name;
    else
        continue;
    end
    source_dir = ['origin/',name];
    m = 5;% Vertex information storage accuracy m
    %% Read a 3D mesh file
    
    [~, file_name, suffix] = fileparts(source_dir);
    if(strcmp(suffix,'.obj')==0) %off
        [vertex, face] = read_mesh(source_dir);
        vertex = vertex'; face = face';
    else %obj
        Obj = readObj(source_dir);
        vertex = Obj.v; face = Obj.f.v;
    end
    vertex0 = vertex;
    Ma = [Ma max(vertex0(:))];
    Mi = [Mi min(vertex0(:))];
end