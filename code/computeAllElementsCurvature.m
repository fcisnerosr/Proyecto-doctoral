function curvatureProfiles = computeAllElementsCurvature(connectivity, coordMatrix, modalMatrix, modeIndex)
% computeAllElementsCurvature Calcula los perfiles de curvatura para todos los elementos 
% de la subestructura.
%
% Esta función itera sobre cada elemento definido en la matriz de conectividad y 
% llama a computeElementCurvature para obtener el perfil de curvatura (por ejemplo, en
% 100 puntos de evaluación) para el modo especificado (modeIndex). 
%
% Entradas:
%   connectivity - Matriz de conectividad de tamaño (E x K), donde la primera columna
%                  es el ID del elemento y las columnas restantes son los nodos que
%                  conforman el elemento.
%   coordMatrix  - Matriz de coordenadas globales de cada nodo, en formato [nodeID, x, y, z].
%   modalMatrix  - Matriz de formas modales global, donde cada conjunto consecutivo de 3
%                  filas corresponde a un nodo y cada columna a un modo (por ejemplo,
%                  (nodos*3 x numModos)).
%   modeIndex    - Índice del modo a procesar (por ejemplo, 1, 2, ..., numModos).
%
% Salida:
%   curvatureProfiles - Un cell array de tamaño (E x 1), donde cada celda contiene el 
%                       perfil de curvatura (por ejemplo, un vector de 100 puntos) del 
%                       elemento correspondiente.
%
% Ejemplo de uso:
%   curvatureProfiles = computeAllElementsCurvature(connectivity, coordMatrix, modalMatrix, 1);

    % Número total de elementos en la subestructura
    numElements = size(connectivity, 1);

    % Inicializar el cell array para almacenar el perfil de curvatura de cada elemento
    curvatureProfiles = cell(numElements, 1);

    % Iterar sobre cada elemento de la subestructura
    for i = 1:numElements
        % Obtener el elemID del elemento actual (se asume que está en la primera columna)
        currentElemID = connectivity(i, 1);
        
        % Llamar a la función computeElementCurvature para obtener el perfil de curvatura
        curvatureProfile = computeElementCurvature(currentElemID, connectivity, coordMatrix, modalMatrix, modeIndex);
        
        % Almacenar el perfil en el cell array
        curvatureProfiles{i} = curvatureProfile;
    end
end
