function [ver2_temp] = BinaryConversion_2_10(ver2_temp_bin,bit_len)
% 函数说明：将二进制数组转换成十进制整数
% 输出：bin2_10（二进制数组）
% 输入：value（十进制整数）
    if(ver2_temp_bin(1)==1)
        if(bit_len<64)
            ver2_temp = 0;
            for j = 0:bit_len-2
                ver2_temp = ver2_temp + ver2_temp_bin(bit_len-j)*2^j;
            end
            inv_dec = dec2bin(ver2_temp-1, bit_len);
            true_dec = logical([]);
            for j = 1:bit_len
                true_dec = [true_dec; xor(str2num(inv_dec(j)), 1)];
            end
            ver2_temp = 0;
            for j = 0:bit_len-2
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