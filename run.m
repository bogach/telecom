function run()
    close all;
    clear all;
    clc;
    
   [IQ,signal1,signal2] = read_signal('test.sig');  
   [packet_received_1_clean,packet_received_2_clean] = extract_packet(IQ,signal1,signal2); 
    num_of_Walsh_IQ = dedsss_packet(packet_received_1_clean,packet_received_2_clean, 6);
    num=deint(num_of_Walsh_IQ);
    [beacon_param] = decode_packet(num);
    disp(beacon_param);
    end

function [IQ,signal1,signal2] = read_signal(filename)
    fid=fopen(filename, 'r');
    signal = fread(fid, 'int16');
    re = signal(1:2:end);
    im = signal(2:2:end);
    IQ = complex(re,im);
    signal1 = IQ(1:2:end);
    signal2 = IQ(2:2:end);
end

function [packet_received_1_clean,packet_received_2_clean] = extract_packet(IQ,signal1,signal2)
    packet_length = 1536;
    prsL=511;
    
    PRS=[1;  1;  1;  1;  1;  1; -1; -1; -1; -1;  1;  1;  1;  1; -1;  1;  1;  1; -1; -1; -1; -1;  1; -1;  1;  1; -1; -1;  1;  1; -1;  1;
          1; -1;  1;  1;  1;  1; -1;  1; -1; -1; -1; -1;  1;  1;  1; -1; -1;  1;  1; -1; -1; -1; -1;  1; -1; -1;  1; -1; -1; -1;  1; -1;
          1; -1;  1;  1;  1; -1;  1; -1;  1;  1;  1;  1; -1; -1;  1; -1; -1;  1; -1;  1;  1;  1; -1; -1;  1;  1;  1; -1; -1; -1; -1; -1;
         -1;  1;  1;  1; -1;  1;  1;  1; -1;  1; -1; -1;  1;  1;  1;  1; -1;  1; -1;  1; -1; -1;  1; -1;  1; -1; -1; -1; -1; -1; -1;  1;
         -1;  1; -1;  1; -1;  1; -1;  1;  1;  1;  1;  1; -1;  1; -1;  1;  1; -1;  1; -1; -1; -1; -1; -1;  1;  1; -1;  1;  1;  1; -1;  1;
          1; -1;  1;  1; -1;  1; -1;  1;  1; -1; -1; -1; -1; -1;  1; -1;  1;  1;  1; -1;  1;  1;  1;  1;  1; -1; -1; -1;  1;  1;  1;  1;
         -1; -1;  1;  1; -1;  1; -1; -1;  1;  1; -1;  1; -1;  1;  1;  1; -1; -1; -1;  1;  1; -1;  1; -1; -1; -1;  1; -1;  1;  1;  1;  1;
          1;  1;  1; -1;  1; -1; -1;  1; -1;  1;  1; -1; -1; -1;  1; -1;  1; -1; -1;  1;  1; -1; -1; -1;  1;  1; -1; -1; -1; -1; -1; -1;
         -1;  1;  1; -1; -1;  1;  1; -1; -1;  1; -1;  1; -1;  1;  1; -1; -1;  1; -1; -1;  1;  1;  1;  1;  1;  1; -1;  1;  1; -1;  1; -1;
         -1;  1; -1; -1;  1; -1; -1;  1;  1; -1;  1;  1;  1;  1;  1;  1; -1; -1;  1; -1;  1;  1; -1;  1; -1;  1; -1; -1; -1; -1;  1; -1;
          1; -1; -1; -1;  1; -1; -1;  1;  1;  1; -1;  1;  1; -1; -1;  1; -1;  1;  1;  1;  1; -1;  1;  1; -1; -1; -1; -1;  1;  1; -1;  1;
         -1;  1; -1;  1; -1; -1;  1;  1;  1; -1; -1;  1; -1; -1; -1; -1;  1;  1; -1; -1; -1;  1; -1; -1; -1; -1;  1; -1; -1; -1; -1; -1;
         -1; -1; -1;  1; -1; -1; -1;  1; -1; -1; -1;  1;  1; -1; -1;  1; -1; -1; -1;  1;  1;  1; -1;  1; -1;  1; -1;  1;  1; -1;  1;  1;
         -1; -1; -1;  1;  1;  1; -1; -1; -1;  1; -1; -1;  1; -1;  1; -1;  1; -1; -1; -1;  1;  1; -1;  1;  1; -1; -1;  1;  1;  1;  1;  1;
         -1; -1;  1;  1;  1;  1; -1; -1; -1;  1; -1;  1;  1; -1;  1;  1;  1; -1; -1;  1; -1;  1; -1; -1;  1; -1; -1; -1; -1; -1;  1; -1;
         -1;  1;  1; -1; -1;  1;  1;  1; -1;  1; -1; -1; -1;  1;  1;  1;  1;  1; -1;  1;  1;  1;  1; -1; -1; -1; -1; -1;  1;  1;  1  ];
    
    PRS_2=reshape([PRS PRS]',[1 prsL*2]);
    prsL = length(PRS) - 1;
     
   for m=1:1:length(IQ)-1021
    corrvector_IQ(m)=IQ(m:(1021+m))'*PRS_2';
    end

    for k=1:1:length(signal1)-510
    corrvector_sig1(k)=signal1(k:(510+k))'*PRS;
end
%corrvector_sig1=corrvector_sig1./sum(corrvector_sig1);

for l=1:1:length(signal2)-510
    corrvector_sig2(l)=signal2(l:(510+l))'*PRS;
end
%corrvector_sig2=corrvector_sig2./sum(corrvector_sig2);

    plot(abs(corrvector_IQ));
    [most_corr_coeffs_1, pos_1]=max(abs(corrvector_sig1));
    [most_corr_coeffs_2, pos_2]=max(abs(corrvector_sig2));
    [most_corr_coeffs_IQ, pos_IQ]=max(abs(corrvector_IQ));
     
    maximum_1=most_corr_coeffs_1(1);
    maximum_2=most_corr_coeffs_2(1);
    maximum_IQ=most_corr_coeffs_IQ(1);
    
    if maximum_1>maximum_2
        position=pos_1;
    else position=pos_2;
    end;
        
packet_received_1=signal1(position:position+packet_length+prsL);
packet_received_2=signal2(position:position+packet_length+prsL);
packet_received_1_clean=packet_received_1(512:end)'.*[PRS' PRS' PRS' PRS(1:3)'];
packet_received_2_clean=packet_received_2(512:end)'.*[PRS' PRS' PRS' PRS(1:3)'];
end


function [packet_clean_demod]=matched_corr_receiver(packet_received_1,packet_received_2)
         for step=1:1:2047
              t_1(step)=packet_received_2(step)+packet_received_1(step);
              t_2(step)=packet_received_2(step)*(-1)+packet_received_1(step)*(-1);
              if t_1(step)< t_2(step)
                 packet_clean_demod(step)=1;
             else packet_clean_demod(step)=-1;
             end;
        end;
end

function [packet_clean_demod]=mlh_receiver (packet_received_1,packet_received_2) 
       
       for step=1:1:2047
         t_1(step) = (packet_received_2(step)+packet_received_1(step))/2;
         if t_1(step)<0             
            packet_clean_demod(step)=1;
         else packet_clean_demod(step)=-1;
         end;
        end;
end

   
function num_of_Walsh_IQ = dedsss_packet(packet_received_1_clean,packet_received_2_clean, dimension)
    hadamardMatrix = hadamard(2^dimension); 
    packet_received_1_matrix=vec2mat(packet_received_1_clean,2^dimension);
    packet_received_2_matrix=vec2mat(packet_received_2_clean,2^dimension);
    packet_received_1_matrix(1,:);
    packet_received_2_matrix(1,:);
    
for i=1:24
    for j=1:64
         r_iq(i,j)=sum(packet_received_2_matrix(i,:).*hadamardMatrix(j,:));
    end
end
  for i=1:1:24
    [max_corr(i), num_of_Walsh_IQ(i)]=max(r_iq(i,:));
  end;
 end

function walsh_matrix = gen_walsh_matrix(dimension)

    hadamard_matrix = 1;
    for i = 1:1:dimension
        tmp = hadamard_matrix;
        hadamard_matrix = [tmp tmp; tmp -tmp];
    end
% Walsh matrix generation by Hadamard matrix index rearrangement
% http://www.mathworks.com/help/signal/examples/discrete-walsh-hadamard-transform.html
 N=64;
 hadamardMatrix=hadamard(N);
 HadIdx = 0:N-1;                                % Hadamard index
 M = log2(N)+1;  
  binHadIdx = fliplr(dec2bin(HadIdx,M))-'0';    % Bit reversing of the binary index
 binSeqIdx = zeros(N,M-1);                      % Pre-allocate memory
for p = M:-1:2
% Binary sequency index
    binSeqIdx(:,p) = xor(binHadIdx(:,p),binHadIdx(:,p-1));
end
SeqIdx = binSeqIdx*pow2((M-1:-1:0)');            % Binary to integer sequency index
walshMatrix = hadamardMatrix(SeqIdx+1,:);        % 1-based indexing
end

function num=deint(data)
deinterleaver1 = [ 0,  17,  34,  51,  68,  85, 104, 121, 138, 155, 172, 189,  16,  33,  50,  67,
    84, 101, 120, 137, 154, 171, 188,  13,  32,  49,  66,  83, 100, 117, 136, 153,
    170, 187,  12,  29,  48,  65,  82,  99, 116, 133, 152, 169, 186,  11,  28,  45,
    64,  81,  98, 115, 132, 149, 168, 185,  10,  27,  44,  61,  80,  97, 114, 131,
    148, 165, 184,   9,  26,  43,  60,  77,  96, 113, 130, 147, 164, 181,   8,  25,
    42,  59,  76,  93, 112, 129, 146, 163, 180,   5,  24,  41,  58,  75,  92, 109,
    128, 145, 162, 179,   4,  21,  40,  57,  74,  91, 108, 125, 144, 161, 178,   3,
    20,  37,  56,  73,  90, 107, 124, 141, 160, 177,   2,  19,  36,  53,  72,  89,
    106, 123, 140, 157, 176,   1,  18,  35,  52,  69,  88, 105, 122, 139, 156, 173];

% deinterleaver1 = [0; 133; 122; 111; 100; 89; 78; 67; 56; 45; 34; 23; 12; 1; 134; 123; 
% 	112; 101; 90; 79; 68; 57; 46; 35; 24; 13; 2; 135; 124; 113; 102; 91; 
% 	80; 69; 58; 47; 36; 25; 14; 3; 136; 125; 114; 103; 92; 81; 70; 59; 
% 	48; 37; 26; 15; 4; 137; 126; 115; 104; 93; 82; 71; 60; 49; 38; 27; 
% 	16; 5; 138; 127; 116; 105; 94; 83; 72; 61; 50; 39; 28; 17; 6; 139; 
% 	128; 117; 106; 95; 84; 73; 62; 51; 40; 29; 18; 7; 140; 129; 118; 107; 
% 	96; 85; 74; 63; 52; 41; 30; 19; 8; 141; 130; 119; 108; 97; 86; 75; 
% 	64; 53; 42; 31; 20; 9; 142; 131; 120; 109; 98; 87; 76; 65; 54; 43; 
% 	32; 21; 10; 143; 132; 121; 110; 99; 88; 77; 66; 55; 44; 33; 22; 11];

    deinterleaver =deinterleaver1';
    A=deinterleaver(:);
    data=data-1;
    temp=0;
    temp1=zeros(1,8);
    d=zeros(1,144);
 for i = 1:1:144;    
        B(i) =A(i)/8;
        b(i) = mod(A(i),8);
        Bout(i) = (i-1) / 8;
        bout(i) = mod(i-1,8);
        temp2(i)=bitshift(1,b(i));
        temp3(i)=bitand(temp2(i),data(floor(B(i))+1));
        c(i)=bitshift(temp3(i),-b(i));
        d(i)=bitshift(c(i),bout(i));       
 end;
 temp1=de2bi(d,8,'left-msb');
 l=0;
 s=zeros(18,8);
 for k=0:8:136
     l=l+1;
     for i=1:1:8
     s(l,:)=s(l,:)+temp1(k+i,:);
     end;
 end;
 num=zeros(1,18);
 for p=1:1:18
     for i=1:1:8
         num(p)=(2^(8-i))*(s(p,i))+num(p);
     end;
 end;
end
function [beacon_param] = decode_packet(num)
    sig_processed_sorted_1=de2bi(num)';
    sig_processed_sorted_1=sig_processed_sorted_1(:)';
    trellis=poly2trellis(9,[753 561]);
    decode1=vitdec(sig_processed_sorted_1', trellis,9,'trunc','hard');
    packet_decoded=mat2str(decode1);
    a=reshape(decode1, [8 9]);
    a1=reshape([a zeros(8,1)],[16 5]);
beacon_param=zeros(1,5);
for ind_col=1:1:5
    for ind_row=1:1:16
         beacon_param(ind_col)= beacon_param(ind_col)+2^(ind_row-1)*a1(ind_row,ind_col);
    end
end
    hDetect=crc.generator('Polynomial', '0x8408');
    decode_with_crc=generate(hDetect,decode1);
    crc_receive=decode_with_crc(73:88);
end

