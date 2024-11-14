function kg = simetria(kg)
    % Filtrar valores pequeños (menores que 1e-3)
    threshold = 1e-3;
    kg(abs(kg) < threshold) = 0; % Poner en cero valores menores al umbral en toda la matriz
    
    % Asegurar que cada capa de la matriz sea simétrica
    for i = 1:size(kg, 3)
        kg(:,:,i) = triu(kg(:,:,i)) + triu(kg(:,:,i), 1)'; % Hacer simétrico copiando la parte superior
        kg(:,:,i) = (kg(:,:,i) + kg(:,:,i)') / 2;          % Promediar para simetría perfecta
    end
end
