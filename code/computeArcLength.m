function arcLength = computeArcLength(coordinates)
% computeArcLength Calcula el vector de longitudes de arco acumuladas a partir de
% una matriz de coordenadas nodales.
%
% Sintaxis:
%   arcLength = computeArcLength(coordinates)
%
% Entradas:
%   coordinates - Matriz de tamaño (N x 3) con las coordenadas de cada nodo [x y z],
%                 ordenadas según el recorrido del elemento.
%
% Salida:
%   arcLength   - Vector columna (N x 1) donde cada entrada es la longitud de arco
%                 acumulada desde el primer nodo hasta ese nodo.
%
% Ejemplo:
%   coords = [0, 0, 0;
%             41667, 0, 0;
%             41667, 41667, 0;
%             0, 41667, 0];
%   arcLength = computeArcLength(coords);
%   % arcLength dará como resultado: [0; 41667; 83334; 125001]

    % Calcular las diferencias entre nodos consecutivos (cada fila: [dx, dy, dz])
    deltas = diff(coordinates);          % Resultado: (N-1) x 3

    % Calcular la distancia Euclidiana para cada par consecutivo de nodos
    distances = sqrt(sum(deltas.^2, 2));   % Vector de distancia, tamaño (N-1) x 1

    % Calcular la longitud de arco acumulada
    arcLength = [0; cumsum(distances)];
end
