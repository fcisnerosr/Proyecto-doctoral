function [M] = matriz_de_masas_diagonal(D,t)
    ruta_archivo = 'E:\Archivos_Jaret\Mis_modificaciones\pruebas_excel\marco3Ddam0.xlsx';
    
    % Lee los datos de la hoja de cálculo en MATLAB
    [M_long] = xlsread(ruta_archivo, 'nudos');
    longitud_nodo = (M_long(1,4)*0.5) + (M_long(2,2)*0.5) + (M_long(3,3)*0.5);
    [M_area] = xlsread(ruta_archivo, 'masses');
    Area = M_area(1,11);
    Dens = M_area(1,13);
    m  = Area * longitud_nodo * Dens;
%     mr = m*((D*0.5)^2)
%     mr = (m)*(((4000/2)^2+(3000/2)^2)/12)
    mr = m;
%     radio = D/2
%     mrx =  2*pi*t*Dens*radio^3*longitud_nodo
%     mry =   1/4*pi*radio^2*longitud_nodo^4
%     mrz = mry
    
    
%     M = diag([m, m, m, mrx, mry, mrz]);
    M = diag([m, m, m, mr, mr, mr]);
    
    % Crear un arreglo multidimensional de 4 páginas
    arreglo = repmat(M, [1, 1, 1, 4]);
    
    % Tamaño de las submatrices expandidas
    n = size(M, 1) * 2;
    
    % Inicializar la matriz expandida
    expanded_matrix = zeros(n);
    
    for i = 1:4
        % Crear una matriz de ceros de tamaño n x n
        submatrix = zeros(n);
        
        % Rellenar la diagonal principal con m y mr
        for j = 1:n
            if j <= n/2
                submatrix(j, j) = m;
            else
%                 submatrix(j, j) = mrx;
                submatrix(j, j) = mr;
            end
        end
        
        % Colocar los valores de la submatriz original en la parte superior izquierda
        start_row = (i - 1) * size(M, 1) + 1;
        end_row = i * size(M, 1);
        submatrix(1:size(M, 1), 1:size(M, 2)) = arreglo(:, :, 1, i);
        
        % Almacenar la submatriz en la matriz expandida
        expanded_matrix(start_row:end_row, start_row:end_row) = submatrix(1:size(M, 1), 1:size(M, 2));
    end
    
    M = expanded_matrix;

end
