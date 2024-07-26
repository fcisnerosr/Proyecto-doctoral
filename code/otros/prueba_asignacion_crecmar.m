clc
close all
clear all


% %% Espesores
% % Definimos las variables
% h = 16;
% tirante = 14;
% profundidad_nodos   = [2, 5, 9, 11, 14];
% % profundidad_nodos   = [2, 6, 9];
% esp_nodos = zeros(size(profundidad_nodos));
% 
% % Calculamos el esp para cada nodo
% for i = 1:length(profundidad_nodos)
%   if profundidad_nodos(i) <= 3
%     esp_nodos(i) = 3;
%   elseif profundidad_nodos(i) > 3 && profundidad_nodos(i) <= 6
%     esp_nodos(i) = 2;
%   elseif profundidad_nodos(i) > 6 && profundidad_nodos(i) <= 9
%     esp_nodos(i) = 1;
%   else
%     esp_nodos(i) = 0;
%   end
% end
% 
% % Mostramos los resultados
% disp('Nodo | Profundidad (m) | Esp');
% disp('----|----|----');
% col1 = 2:(length(profundidad_nodos)+1)';
% col1 = col1';
% col2 = profundidad_nodos';
% col3 =  esp_nodos';
% tabla = horzcat(col1, col2, col3)
% 
% %% Longitudes nodales
% V_long              = zeros(length(profundidad_nodos),1);
% prof_inicial_crec   = h - tirante;
% for i = 1:(length(col1))
%     if tabla(i,3) == 0
%         break
%     end
%     if i == 1
%         V_long(i) = prof_inicial_crec + abs((tabla(i+1,2)-tabla(i,2))*0.5);
%     else
%         V_long(i) = abs((tabla(i+1,2)-tabla(i,2))*0.5);
%     end
% end
% 
% disp('          Nodo |      Prof (m) |     esp |     long nodal');
% horzcat(tabla, V_long)

% % Valores de entrada
% nudos_unicos_crecmar = [1, 7, 3];
% 
% % Matriz
% long_y_nodos = [
%     150, 3;
%     20, 7;
%     20, 7;
%     20, 7;
%     200, 1;
% ];
% 
% % Vector para almacenar los valores no repetidos
% vector_resultante = zeros(1, numel(nudos_unicos_crecmar));
% 
% % Iterar sobre las filas de la matriz
% for i = 1:size(long_y_nodos, 1)
%     % Obtener el valor en la segunda columna de la fila actual
%     valor_actual = long_y_nodos(i, 2);
% 
%     % Verificar si el valor ya ha sido agregado al vector resultante
%     if ~ismember(valor_actual, vector_resultante)
%         % Obtener el índice correspondiente al valor en 'valores'
%         indice_valores = find(nudos_unicos_crecmar == valor_actual);
% 
%         % Asignar el valor de la primera columna de la fila actual al vector resultante
%         vector_resultante(indice_valores) = long_y_nodos(i, 1);
%     end
% end
% 
% disp('Vector resultante:');
% disp(vector_resultante);


% V =[...
% 10  1   3;
% 5   3   4;
% 10  2   2;
% 80  1   4;...
% ]
% 
% maximo = max(V(:, 2:3), [], 'all');
% col1 = zeros(maximo,1);
% for i = 1:maximo
%     col1(i) = i;
% end
% 
% 
% valor = V(:, 1) / 2;
% % Vector para almacenar el resultado final
% resultado = zeros(maximo, 1);
% % Repartir cada elemento de "valor" en cada i elemento de V_masa
% for i = 1:size(V, 1)
%     resultado(V(i, 2)) = resultado(V(i, 2)) + valor(i);
%     resultado(V(i, 3)) = resultado(V(i, 3)) + valor(i);
% end  
% resultado


% nodos_y_esp_concatenado_actualizado = [...
%            1         1000           75            4;...
%            3         1000           75            2;...
%            4         1000           75            2;...
%            2         1000           75            4
%            ]


% diam_list =  [...
% 		1	3	700;...
% 		3	1	700;...
% 		2	4	700;...
% 		2	4	700;...
% 		2	1	600;...
% 		4	6	700;...
% 		6	7	600;...
%                     ]



% diam_cat = [...
%      0     0     0    0;...
%      0     0     0    0;...
%      0     0     0    0;...
%      0     0     0    0
%       0     0     0    0;
%      ]

% %% mi código
% ind_diam_cat = zeros(length(diam)*2,1)';
% ind = [1 2 3 4]
% longitud_ind_diam_cat = length(ind_diam_cat);
% longitud_ind = length(ind);
% indice_inicial = 1;
% for i = 1:longitud_ind_diam_cat
%     indice_actual = mod(i - 1, longitud_ind) + 1;
%     ind_diam_cat(i) = ind(indice_actual);
% end
% 
% i1 = [1     2     3     4     1     2     3     4     1     2     3     4];
% i2 = [1     2     3     4     5     6     1     2     3     4     5     6 ];
% %               1     2     3     4     5     6     7 
% 
% 
% % for i = 1:length(diam)
% for i = 1
%     % for j = 1:length(diam)
%     for j = 1:3
%         if diam(i2(j),1) == diam_cat(i1(j),1)
%             diam_cat(i1(j),i+1) = diam(i2(j),3)
%         end
%     end
%     if diam(i2(i),1) == diam_cat(i1(i),1)
%         diam_cat(i1(j),i+1) = diam(i2(j),3)
%     end
% end

% 
% diam_cat = zeros(4);
% 
% % Itera sobre diam_list y actualiza diam_cat
% for i = 1:size(diam_list, 1)
%     diam_cat(diam_list(i, 1), diam_list(i, 2)) = diam_list(i, 3);
%     diam_cat(diam_list(i, 2), diam_list(i, 1)) = diam_list(i, 3);
% end
% 
% disp('diam_cat =');
% disp(diam_cat);

% suma = zeros(length(diam_cat),1)
% 
% for i = 1:length(diam_cat)
%     suma(i) = sum(diam_cat(:,i))
% end
% diam_prom = sum(suma)/length(suma)

% % Inicializar diam_cat_actualizado como una copia de diam_cat
% diam_cat_actualizado = diam_cat;
% 
% % Iterar sobre las filas de diam
% for i = 1:size(diam, 1)
%     % Obtener el valor de la primera columna de diam
%     valor_primera_columna_diam = diam(i, 1);
% 
%     % Buscar el índice en la primera columna de diam_cat
%     indice = find(diam_cat(:, 1) == valor_primera_columna_diam);
% 
%     % Asignar los valores de la segunda y tercera columna de diam a las columnas correspondientes de diam_cat_actualizado
%     diam_cat_actualizado(indice, 2:end) = diam(i, 3:end);
% end
% diam_cat_actualizado

        % nodo         % prof         % esp     % no. elem   % diam
nod_datos = [...
            4            40              75           4          650
            1            50               0           4          650
            2            10              50           4          650
            3            10              25           4          650
			5            00               0           4          650]
           
            
        % elem      % nod   % nod      % long_element
Tabla_completa = [...
           1            1       4       50000 
           2            2       3       50000 
           3            3       4       50000 
           4            4       1       50000
           5            1       5       50000
           6            1       3       50000]

% % Inicializar el vector columna
% Cb_vector = zeros(size(Tabla_completa, 1), 1);
% 
% % Recorrer las dos primeras columnas de Tabla_completa
% for i = 1:size(Tabla_completa, 1)
%     % Obtener los índices de los nodos de la tabla
%     nodo1_index = Tabla_completa(i, 2);
%     nodo2_index = Tabla_completa(i, 3);
% 
%     % Verificar que los índices estén dentro de los límites de nod_datos
%     if nodo1_index <= size(nod_datos, 1) && nodo2_index <= size(nod_datos, 1)
%         % Verificar si la tercera columna de nod_datos es cero
%         if nod_datos(nodo1_index, 3) == 0 && nod_datos(nodo2_index, 3) == 0
%             % En caso de que tenga un espesor de crec mar igual a cero su Cb = 1.6
%             Cb_vector(i) = 0;
%         else
%             % Si no es cero, asignar 1.6 al elemento correspondiente en Cb_vector
%             Cb_vector(i) = 1.2;
%         end
%     else
%         % Si los índices están fuera de los límites, asignar cero al elemento correspondiente en Cb_vector
%         Cb_vector(i) = 0;
%     end
% end
% Nodos de la tabla completa
nodos1 = Tabla_completa(:, 2);
nodos2 = Tabla_completa(:, 3);

% Crear el vector Cb
Cb = zeros(size(nodos1));  % Inicializar con ceros

% Iterar sobre los nodos
for i = 1:length(nodos1)
    nodo1 = nodos1(i);  % Nodo 1 actual
    nodo2 = nodos2(i);  % Nodo 2 actual
    
    % Buscar los nodos en nod_datos y verificar la tercera columna
    nodo1_index = find(nod_datos(:, 1) == nodo1);
    nodo2_index = find(nod_datos(:, 1) == nodo2);
    
    % Verificar si la tercera columna es cero
    if nod_datos(nodo1_index, 3) == 0 && nod_datos(nodo2_index, 3) == 0
        Cb(i) = 0;  % Si ambos son cero, asignar cero a Cb
    else
        Cb(i) = 1.2;  % Si no, asignar 1.2 a Cb
    end
end
Cb
