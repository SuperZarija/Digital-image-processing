% Projekat iz predmeta "Digitalna obrada slike"
% Aleksandar Zarija EE49/2014
% Milica Milosevic  EE47/2015

%% Ucitavanje slike i njen prikaz

slika = im2double(imread('im1c.png'));
figure, imshow(slika)
title('Originalna slika')

% 1. Kreiranje maske ostecenja

hsv = rgb2hsv(slika);

h = hsv(:,:,1);
%figure, imshow(h)
title('H komponenta')

s = hsv(:,:,2);
%figure, imshow(s)
title('S komponenta')

v = hsv(:,:,3);
%figure, imshow(v)
title('V komponenta')

% masku pravimo na osnovu S komponente
mask = s >= 0.3;
%figure, imshow(mask)
title('Binarna maska pre obrade')

% modifikacija maske morfoloskim operacjama
se = strel('disk', 3, 8);

mask1 = imopen(mask, se); % otvaranjem eliminisemo sitne tackice izolovane od grafita
%figure, imshow(mask1)

mask2 = imclose(mask1, se); % zatvaranjem eliminisemo sitne pukotine na masci
%figure, imshow(mask2)
title('Binarna maska nakon obrade')

% Primena maske na originalnoj slici
mask_final = ~mask2;
%figure, imshow(mask_final)

slika1(:,:,1) = slika(:,:,1).*mask_final;
slika1(:,:,2) = slika(:,:,2).*mask_final;
slika1(:,:,3) = slika(:,:,3).*mask_final;
%figure, imshow(slika1)
title('Primenjena maska')

%% 2. Preraspodela energije u regionima ostecenih piksela

r = slika(:,:,1);
g = slika(:,:,2);
b = slika(:,:,3);

br_ostecenih = numel(find(~mask_final)); % broj ostecenih piksela

% srednja vrednost neostecenih piksela za R, G i B kanale
r_sr = sum(sum(slika1(:,:,1)))/(numel(r) - br_ostecenih);
g_sr = sum(sum(slika1(:,:,2)))/(numel(g) - br_ostecenih);
b_sr = sum(sum(slika1(:,:,3)))/(numel(b) - br_ostecenih);

% osteceni pikseli u R, G i B kanalima popunjavamo sa sr vr neostecenih piksela odgovarajuceg kanala
r(~mask_final) = r_sr; 
g(~mask_final) = g_sr;
b(~mask_final) = b_sr;

slika2 = cat(3,r,g,b);
%figure, imshow(slika2)
title('Slika sa popunjenim ostecenim regionom')

kernel = [0.073235 0.176765 0.073235; 0.176765 0 0.176765; 0.073235 0.176765 0.073235];

mask_tmp = mask_final;
temp = true;

slika3 = slika2;
while temp
   
    mask_tmp = imdilate(mask_tmp, strel('disk', 1, 8)); % smanjujemo konturu grafita
    mask_res = mask_tmp - mask_final;                   % odredjivanje granica regiona za filtriranje
    imshow(mask_res)

    % filtriramo sliku samo na mestima ostecenih piksela na svakom kanalu
    slika3(:,:,1) = roifilt2(kernel, slika3(:,:,1), mask_res);
    slika3(:,:,2) = roifilt2(kernel, slika3(:,:,2), mask_res);
    slika3(:,:,3) = roifilt2(kernel, slika3(:,:,3), mask_res);

    if(numel(find(~mask_tmp)) == 0) % uslov za prekidanje filtriranja
        temp = false;               % kada prodjemo kroz sve piksele konture grafita (maska_tmp)    
    end
end

figure, imshow(slika3)
title('Filtrirana popunjena slika')

%% 3. Izdvajanje niskih i visokih ucestanosti u slici

DCT_R = dct2(slika3(:,:,1));
%figure, imshow(log(abs(DCT_R)),[])
title('DCT R komponenta')

DCT_G = dct2(slika3(:,:,2));
%figure, imshow(log(abs(DCT_G)),[])
title('DCT G komponenta')

DCT_B = dct2(slika3(:,:,3));
%figure, imshow(log(abs(DCT_B)),[])
title('DCT B komponenta')

DCT_slika = cat(3,DCT_R,DCT_G,DCT_B);
figure, imshow(log(abs(DCT_slika)),[])
title('DCT slika')

% kreiranje maske za bolje izdvojanje niskih ucestanosti
DCT_mask_low = zeros(size(DCT_R));
i = 1;
for j = 40:-1:1
    DCT_mask_low(1:j,i) = 1;
    i = i+1;
end

figure, imshow(DCT_mask_low)
title('DCT maska niskih ucestanosti')

% primena maske na svaki od RGB kanala
dct_low(:,:,1) = DCT_R.*DCT_mask_low;
dct_low(:,:,2) = DCT_G.*DCT_mask_low;
dct_low(:,:,3) = DCT_B.*DCT_mask_low;

figure, imshow(log(abs(dct_low)),[])
title('DCT slika nakon primene maske')

% kreiranje slike niskih ucestanosti (IDCT)
slika_low(:,:,1) = idct2(dct_low(:,:,1));
slika_low(:,:,2) = idct2(dct_low(:,:,2));
slika_low(:,:,3) = idct2(dct_low(:,:,3));

figure, imshow(slika_low)
title('Slika niskih ucestanosti')
imwrite(slika_low,'niske_ucestanosti.jpg')

% kreiranje slike visokih ucestanosti 
slika_high(:,:,1) = slika3(:,:,1) - slika_low(:,:,1);
slika_high(:,:,2) = slika3(:,:,2) - slika_low(:,:,2);
slika_high(:,:,3) = slika3(:,:,3) - slika_low(:,:,3);

figure, imshow(slika_high)
title('Slika visokih ucestanosti')
imwrite(slika_high, 'visoke_ucestanosti.jpg')

(slika_high(:,:,1) - min(min(slika_high(:,:,1))))/(max(max(slika_high(:,:,1))) - min(min(slika_high(:,:,1))));

%% 4. Sinteza strukture nad slikom visokih ucestanosti

% smanjivanje dimenzija slike radi lakse obrade
slika_h = imresize(slika_high, 1/4);
mask_f = imresize(mask_final, 1/4);

% sinteza ostecenih piksela
S1 = sinteza1(slika_h, mask_f,0);
figure, imshow(S1+slika_l)

S2 = sinteza1(S1, mask_f,90);
S2r = imrotate(S2,270);
figure, imshow(S2r)

S3 = sinteza1(S2r, mask_f,180);
S3r = imrotate(S3,180);
figure, imshow(S3r)

S4 = sinteza1(S3r, mask_f,270);
S4r = imrotate(S4,90);
figure, imshow(S4r)

% usrednjavanje pretodno dobijenih slika
R_final = 1/4*(S1(:,:,1) + S2r(:,:,1) + S3r(:,:,1) + S4r(:,:,1));
G_final = 1/4*(S1(:,:,2) + S2r(:,:,2) + S3r(:,:,2) + S4r(:,:,2));
B_final = 1/4*(S1(:,:,3) + S2r(:,:,3) + S3r(:,:,3) + S4r(:,:,3));

% spajanje usrednjenih kanala u finalnu sliku visokih ucestanosti
slika_sint = cat(3,R_final, G_final, B_final);
figure, imshow(slika_sint)

%% 5. Finalna slika dobijena kombinovanjem slike niskih ucestanosti i slike
%     generisane u prethodnom koraku

% smanjivanje dimenzija slike niskih ucestanosti
slika_l = imresize(slika_low,1/4);

% sabiranje slika niskih i visokih ucestanosti
S_res = slika_sint + slika_l;
figure, imshow(S_res)

% vracanje dimenzija finalne slike u originalne dimenzije
S_final = imresize(S_res, 4);
figure, imshow(S_final)
imwrite(S_final, 'finalna slika.jpg')
