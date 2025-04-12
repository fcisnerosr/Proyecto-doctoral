function arcLength = computeArcLength(coordinates)
% computeArcLength Calcula el vector de longitudes de arco acumuladas a partir de
% una matriz de coordenadas nodales, excluyendo los primeros 4 nodos (empotrados).
%
% Sintaxis:
%   arcLength = computeArcLength(coordinates)
%
% Entradas:
%   coordinates - Matriz de tamaño (N x 3) con las coordenadas de cada nodo [x y z],
%                 ordenadas según el recorrido del elemento. Se asume que los primeros 
%                 4 nodos corresponden a nodos empotrados y se excluyen.
%
% Salida:
%   arcLength   - Vector columna (M x 1) donde M = N - 4, donde cada entrada es la longitud
%                 de arco acumulada desde el primer nodo no empotrado hasta ese nodo.
%
% Ejemplo:
%   coords = [... % matriz de coordenadas con 24 nodos];
%   arcLength = computeArcLength(coords);
%   % arcLength se calculará usando sólo los nodos 5 a 24.
%

    % Verificar que existan al menos 5 nodos
    if size(coordinates,1) < 5
        error('Se requieren al menos 5 nodos, pues los primeros 4 se excluirán.');
    end

    % Excluir los primeros 4 nodos (empotrados)
    filteredCoordinates = coordinates(5:end, :);  

    % Calcular las diferencias entre nodos consecutivos de la malla filtrada
    deltas = diff(filteredCoordinates);  % Dimensión: (M-1) x 3, donde M = N - 4

    % Calcular la distancia Euclidiana entre cada par consecutivo
    distances = sqrt(sum(deltas.^2, 2));   % Vector columna de tamaño (M-1) x 1

    % Calcular la longitud de arco acumulada: comienza en 0 y suma cada segmento
    arcLength = [0; cumsum(distances)];
end
