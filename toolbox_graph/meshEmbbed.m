function [vertex2, message_bin] = meshEmbbed(m, vertex1, face, vex_wrong, embbed_len)
%Embed messages into vertexes of the encrypted mesh

%% Convert Vertexes into Bitstream
magnify = 10^m;
[vertex1, bit_len] = meshPrepro(m, vertex1);
vertex2 = vertex1;

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
Vertemb = sort(Vertemb);

%% Embed messages into selected vertexes

%Generate the embedded message
[~, num_vertemb] = size(Vertemb); 
[~, num_wrong] = size(vex_wrong);
k_emb = 54321;
message_bin = logical(pseudoGenerate(3*embbed_len*(num_vertemb-num_wrong), k_emb));

embbed_num = 0;
for i = 1:num_vertemb  %Ö±½ÓÂúÇ¶
        if isempty(find(vex_wrong == Vertemb(i))) == 1
            for j = 1:3            
                for k = 1:embbed_len
                    if message_bin(embbed_num+1) == 1
                        vertex2(Vertemb(i),j) = bitset(vertex2(Vertemb(i),j),bit_len-k+1,1);
                        embbed_num = embbed_num + 1;
                    else
                        vertex2(Vertemb(i),j) = bitset(vertex2(Vertemb(i),j),bit_len-k+1,0);
                        embbed_num = embbed_num + 1;
                    end
                end
            end
        end
end
%Reset into vertexes
vertex2 = double(vertex2) / magnify;

end
