% Matriz_M_completa_y_condensada.m
function [M_cond] = Matriz_M_completa_y_condensada(masas_en_cada_nodo)
    % Suponiendo que masas_en_cada_nodo es una matriz donde la segunda columna contiene las masas
    % y deseas comenzar desde el nodo 5
    masas = masas_en_cada_nodo(5:end, 2);  % Selecciona desde el nodo 5 de la segunda columna
    
    % Repetir cada masa tres veces en un vector
    masas_rep = repelem(masas, 3);  % Repite cada elemento de 'masas' tres veces
    
    % Crear la matriz de masas condensada
    M_cond = diag(masas_rep);
% % function [M_condensada,M, masas_en_cada_nodo] = Matriz_M_completa_y_condensada(coordenadas, masas_en_cada_nodo)
% %% SECCION: Matriz de masas completa
%     %% BLOQUE: longitudes de matriz de masa completa (n y m)
%     n = length(coordenadas) - 4;        % se quitan los primeros cuatro nodos de la base
%     m = masas_en_cada_nodo(5:end,:);    % se selecciona a partir de la masa 5 porque las masas de la base (del nodo 1 al 4) no se toman en cuenta en el analisis de condensacion estatica
% 
%     %% BLOQUE: Numero de GDL de la matriz de masas completa (longitudVector)
%     % Matriz de masas 
%     M = zeros(n*6,n*6);                 % matriz de ceros de matriz de masa completa
%     v = zeros(1,n*6);                   % vector de long. n (GDL). En el siguiente bloque sera asignado con numeros consecutivos de 1 al 6 hasta llenar todo el vector v
%     j = 0;
%     % SUBLOQUE: vector de long = NGL global con numeros consecutivos del 1 al 6 hasta terminar el vector v (v)    
%         % vectores que sirven para posicionar cada masa nodal en la matriz de masa completa
%     for i = 1:length(v)
%         j = j + 1;
%         v(i) = j;
%         if j >= 6
%             j = 0;
%         end
%     end
%     y = zeros(1,n*6);
%     j = 0;
%     for i = 1:length(y)
%         j = j + 1;
%         y(i) = j;                   % y es un vector de long = NGDL con numeros consecutivos del 1 al 3 hasta llenarlo
%         if j >= 3
%             j = 0;
%         end
%     end
%     longitudVector = n * 6;
% 
%     %% BLOQUE: Matriz de masas globales (M)
%     % SUBLOQUE: 
%     % Crear un vector vacío
%     y = zeros(1, longitudVector);
%     % Contador para la posición actual en el vector
%     posicionActual = 1;
%     % Bucle para recorrer los números del 1 al n
%     for numero = 1:n
%     % Repetir el número 3 veces
%         for repeticiones = 1:3
%             % Asignar el número al vector
%             y(posicionActual) = numero;
%             % Incrementar la posición actual
%             posicionActual = posicionActual + 1;
%         end
%         % Repetir el 9 3 veces
%         for repeticiones9 = 1:3
%             % Asignar el 9 al vector
%             y(posicionActual) = 9;                  % y es un vector de NGL globales de la masa traslacional que van del 1 al NGDL repetidos 3 veces y el rotacional que se le asigna el no. 9 repetido 3 veces
%             % Incrementar la posición actual
%             posicionActual = posicionActual + 1;
%         end
%     end
%     % SUBLOQUE: Ciclo de asignacion de cada masa nodal a la matriz global de masas con ceros
%     for i = 1:n*6
%         if v(i) == 4 | v(i) == 5 | v(i) == 6
%             M(i,i) = 8*10^-20;
%             % M(i,i) = m(y(i),2);
%         else
%             M(i,i) = m(y(i),2);
%         end
%     end
%     M
%     %% SECCION: Matriz de masas condensada
%     %% BLOQUE: Matriz de masas condensada de long = NGDL - 4 * 3 (M_condensada)
%         % se contruye mediante la funcion blkdiag()
%     % Inicializar la nueva matriz
%     M_condensada = [];
%     % Iterar sobre cada bloque n*n de la matriz
%     for i = 1:size(M, 1)/6
%         % Obtener el índice de inicio y fin del bloque actual
%         indice_inicio = (i-1)*6 + 1;
%         indice_fin = i*6;
%         % Obtener el bloque actual
%         bloque_actual = M(indice_inicio:indice_fin, indice_inicio:indice_fin);
%         % Eliminar las filas y columnas correspondientes a los elementos 3, 4 y 5
%         bloque_actual(3:5,:) = [];
%         bloque_actual(:,3:5) = [];
%         % Agregar el bloque modificado a la nueva matriz
%         M_condensada = blkdiag(M_condensada, bloque_actual);
%     end
end
