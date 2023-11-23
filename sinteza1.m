function slika_out = sinteza1(slika, mask, angle)

% funkcija prima 3 parametra: sliku visokih ucestanosti, masku i ugao rotacije

% slika se rotira za ugao koji je dat kao ulazni parametar
if(angle == 0)
    mask = mask;
    slika = slika;
elseif (angle == 90)
    mask = imrotate(mask, 90);
    slika = imrotate(slika, 90);
elseif(angle == 180)  
    mask = imrotate(mask, 180);
    slika = imrotate(slika, 180);
elseif(angle == 270) 
    mask = imrotate(mask, 270);
    slika = imrotate(slika, 270);
end

% L kernel 
kernel = [1 1 1 1 1 ; 1 1 1 1 1 ; 1 1 0 0 0 ; 0 0 0 0 0 ; 0 0 0 0 0];

[m,n] = size(mask);

for i = 3:m-2
    for j = 3:n-2
        if (mask(i,j) == 0)
            
            % blok za poredjenje predstavlja L okolinu ostecenog piksela
            cmp_block = slika(i-2:i+2,j-2:j+2,:);
            
            cmp_block1 = cmp_block(:,:,1).*kernel;
            cmp_block2 = cmp_block(:,:,2).*kernel;
            cmp_block3 = cmp_block(:,:,3).*kernel;

            min = inf; 
            
            for p = 3:m-2
                for q = 3:n-2
                    if (mask(p,q) ~= 0)
                        
                        tmp = mask(p-2:p+2,q-2:q+2);
                        tmp = tmp.*kernel;
                        
                        if(sum(sum(tmp)) == 12) % proverava da li su L regioni od interesa osteceni
                            
                            % blok za trazenje najslicnijeg L regiona
                            block = slika(p-2:p+2,q-2:q+2,:);
                            
                            block1 = block(:,:,1).*kernel;
                            block2 = block(:,:,2).*kernel;
                            block3 = block(:,:,3).*kernel;
                            
                            % suma kvadrata razlike za trazenje najslicnijeg bloka
                            suma1 = sum(sum((cmp_block1 - block1).^2));
                            suma2 = sum(sum((cmp_block2 - block2).^2));
                            suma3 = sum(sum((cmp_block3 - block3).^2));

                            suma = suma1 + suma2 + suma3;
                            
                            % definisanje koordinata najslicnijeg bloka
                            if(suma <= min)
                                min = suma;
                                k1 = p;
                                k2 = q;
                            end
                        end
                    end 
                end
            end
            
            % promena vrednosti ostecenog piksela
             mask(i,j) = 1;
             slika(i,j,:) = slika(k1,k2,:);
           
        end
    end
end

slika_out = slika;

end