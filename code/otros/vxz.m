clc
clear all

% Paso 1: Leer los datos de conectividad desde Excel
[~, ~, raw] = xlsread('E:\Archivos_Jaret\Mis_modificaciones\pruebas_excel\marco3Ddam0.xlsx', 'conectividad');
% [~, ~, raw] = xlsread('E:\Archivos_Jaret\Mis_modificaciones\pruebas_excel\marco3Ddam0_prueba_borrar.xlsx', 'conectividad')

% Extraer los datos de nodos iniciales y finales de los elementos
nudoi = cell2mat(raw(2: end, 2)) % Nodos iniciales
nudoj = cell2mat(raw(2: end, 3)) % Nodos finales


% Paso 2: Calcular los vectores de dirección para cada elemento tubular
VXZ = zeros(length(nudoi), 3) % Inicializar matriz para los cosenos directores vxz


% MARCO EN 3D
coordenadas = [
                0	    0	    5000;
                4000	0	    5000;
                4000	3000	5000;
                0	    3000	5000;
                0	    0	    0;
                4000	0	    0;
                4000	3000	0;
                0	    3000	0

]


% Definir los vectores de dirección para cada elemento alineados con los ejes globales
for i = 1:length(nudoi)
    % Coordenadas del nodo inicial y final del elemento
    nodo_inicial = coordenadas(nudoi(i), :)
    nodo_final   = coordenadas(nudoj(i), :)

    % Calcular la dirección del elemento tubular
    direccion = nodo_final - nodo_inicial;
    direccion = direccion / norm(direccion); % Normalizar el vector dirección

    % Alinear los vectores de dirección con los ejes globales
    % Aquí, asumimos que los ejes X, Y, Z están orientados como se describe en tus coordenadas
    if direccion(1) == 1 % Eje X
        VXZ(i, :) = [1, 0, 0];
    elseif direccion(2) == 1 % Eje Y
        VXZ(i, :) = [0, 1, 0];
    elseif direccion(3) == 1 % Eje Z
        VXZ(i, :) = [0, 0, 1];
    elseif direccion(3) == -1 % Eje -Z
        VXZ(i, :) = [0, 0, -1];
    elseif direccion(2) == -1 % Eje -Y
        VXZ(i, :) = [0, -1, 0];
    end
end

disp('Los vectores de dirección VXZ alineados con los ejes globales son:');
disp(VXZ);

% % Escribir los cosenos directores en un archivo de Excel
% xlswrite('E:\Archivos_Jaret\Mis_modificaciones\pruebas_excel\VXZ.xlsx', VXZ, 'VXZ'); % Escribir en la pestaña "vxz"

