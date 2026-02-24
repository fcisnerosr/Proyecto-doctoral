function [T, threshold] = generarT(no_elemento_a_danar, conectividad, DI1_COMAC)
% generarT Genera el vector T marcando los nodos con daño y define el umbral de comparación.
%
% Entradas:
%   - no_elemento_a_danar : Vector de elementos dañados
%   - conectividad        : Matriz de conectividad (columna 1: elemento, columnas 2-3: nodos)
%   - DI1_COMAC           : Vector para dimensionar T
%
% Salidas:
%   - T                   : Vector con 1 donde hay daño y 0 en el resto
%   - threshold           : Umbral definido para la detección de daño

    % Obtener nodos con daño (excluyendo nodos 1 al 4)
    respuesta = obtenerNodosConDanio(no_elemento_a_danar, conectividad);

    % Inicializar vector T
    T = zeros(length(DI1_COMAC), 1);

    % Marcar nodos dañados en T
    for nodo = respuesta
        idx = nodo - 4;  % Suponiendo que los nodos válidos comienzan en el nodo 5
        if idx >= 1 && idx <= length(T)
            T(idx) = 1;
        else
            warning('Nodo %d fuera de rango y no fue marcado en T.', nodo);
        end
    end

    % Definir umbral de comparación
    threshold = 0.05;  % Ajusta según el criterio del estudio
end
