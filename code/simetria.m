function kg = simetria(kg, i)
    % Filtrar valores pequeños (menores que 1e-8)
    threshold = 1e-3;
    kg(:,:,i) = kg(:,:,i) .* (abs(kg(:,:,i)) >= threshold);

    % Asegurar que la matriz sea simétrica copiando la parte superior a la inferior
    kg(:,:,i) = triu(kg(:,:,i)) + triu(kg(:,:,i), 1)';

    % Para asegurarnos de que la matriz es perfectamente simétrica, hacemos el promedio de las partes superior e inferior
    kg(:,:,i) = (kg(:,:,i) + kg(:,:,i)') / 2;
end
