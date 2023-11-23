function slika_out = sinteza(slika, mask_final, kernel)

u = (size(kernel, 1)-1)/2;
v = (size(kernel, 2)-1)/2;
mask_pad = padarray(mask_final, [u v], 'symmetric');
slika_pad = padarray(slika, [u v], 'symmetric');
mask_tmp = mask_final;
temp = true;

slika_out = slika;
        
while temp

    mask_tmp = imdilate(mask_tmp, strel('disk', 1, 8)); % smanjujemo konturu grafita
    mask_res = mask_tmp - mask_final;                   % odredjivanje granica regiona za filtriranje
    %imshow(mask_res)

    min = 1;                                           % postavljamo vrednost minimuma
    for j = 1+u : size(mask_pad,1)-2
        for i = 1+v : size(mask_pad,2)-2
		
            if(mask_res(j-u, i-v) == 1) 
                region = mask_pad(j-2:j+2, i-2:i+2);
                mask_adapt = region.*kernel;            % maska koja ima 0 na mestima ostecenih piksela
        
                for p = 3:size(mask_pad,1)-2
                    for q = 3:size(mask_pad,2)-2
                        if(mask_pad(p,q) == 1)
                            %if(p ~= j && q ~= i) %da li je ovaj uslov suvisan, jer svakako ne posmatramo piksele koji su deo grafita?
                                region2 = mask_pad(p-u:p+u, q-v:q+v);
                                if(region2 == ~mask_adapt)
                                    s = slika_pad(p-u:p+u, q-v:q+v);
                                    poredi = sum((sum((s.*mask_adapt - s.*region).^2)));
                                    if(min < poredi)
                                        min = slika(p,q);
                                    end
                                end
                            %end
                        end
                    end
                end
            end
            
            slika_out(j-u, i-v) = min;
            
        end
    end

    if(numel(find(~mask_tmp)) == 0) % uslov za prekidanje filtriranja
        temp = false;               % kada prodjemo kroz sve piksele konture grafita (maska_tmp)    
    end
end
end