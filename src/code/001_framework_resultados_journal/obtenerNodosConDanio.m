function respuesta = obtenerNodosConDanio(no_elemento_a_danar, conectividad)
% obtenerNodosConDanio Devuelve los nodos afectados por daño, excluyendo los nodos 1 al 4.
%
% Entradas:
%   - no_elemento_a_danar: vector con los números de los elementos dañados
%   - conectividad: matriz de conectividad (columna 1: elemento, columnas 2-3: nodos conectados)
%
% Salida:
%   - respuesta: vector con nodos únicos dañados, excluyendo los nodos 1 al 4

    % 1. Extraer nodos asociados a los elementos dañados
    nodos_danados = conectividad(no_elemento_a_danar, 2:3);

    % 2. Convertir a vector y unir todos los nodos
    todos_nodos = nodos_danados(:);

    % 3. Eliminar nodos 1 al 4 y duplicados
    nodos_excluidos = [1:4];
    respuesta = unique(setdiff(todos_nodos, nodos_excluidos))';
end
