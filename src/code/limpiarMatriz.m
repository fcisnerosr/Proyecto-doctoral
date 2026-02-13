function matriz_limpia = limpiarMatriz(matriz_original)
    % Esta función limpia la matriz original según el criterio especificado
    % de poner a cero todos los elementos con exponentes de e-08 o más pequeños.

    % Obtenemos el tamaño de la matriz original
    [filas, columnas] = size(matriz_original);
    
    % Inicializamos la matriz limpia
    matriz_limpia = matriz_original;
    
    % Recorremos cada elemento de la matriz
    for i = 1:filas
        for j = 1:columnas
            elemento = matriz_original(i, j);
            if isnumeric(elemento)
                % Verificar si el elemento es menor que 1e-08 en valor absoluto
                if abs(elemento) < 1e-03
                    matriz_limpia(i, j) = 0;
                end
            end
        end
    end
end
