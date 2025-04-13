function curvatureProfile = computeElementCurvature(elemID, connectivity, coordMatrix, modalMatrix, modeIndex)
% computeElementCurvature Calcula el perfil de curvatura para un elemento tubular.
%
% Esta función se encarga de:
%   1. Extraer los nodos que conforman el elemento (según la matriz de conectividad),
%      excluyendo los nodos empotrados (IDs ≤ 4).
%   2. Con las coordenadas globales de esos nodos, se calcula el vector de longitudes
%      de arco acumuladas (posición a lo largo del elemento).
%   3. Extraer de la matriz modal, para cada nodo, los valores de la forma modal en el
%      modo indicado por modeIndex (unificando los 3 DOF de cada nodo en un único valor).
%   4. Con el vector de longitudes de arco y los valores modales se construye un spline
%      que representa la forma modal continua; se deriva dos veces para obtener la curvatura.
%   5. Se evalúa el spline derivado en 100 puntos para generar el perfil de curvatura.
%
% Entradas:
%   elemID       - ID del elemento a procesar (según la conectividad).
%   connectivity - Matriz de conectividad con formato [elementID, nodoInicio, nodoFin, ...].
%   coordMatrix  - Matriz de coordenadas de cada nodo, formato [nodeID, x, y, z].
%   modalMatrix  - Matriz de formas modales global, donde cada conjunto consecutivo de 3 filas
%                  corresponde a un nodo y cada columna a un modo (por ejemplo, 60x12 para 20 nodos y 12 modos).
%   modeIndex    - Índice del modo que se desea procesar (entre 1 y el número total de modos).
%
% Salida:
%   curvatureProfile - Vector columna de 100 puntos con los valores de la curvatura
%                      (segunda derivada de la forma modal) a lo largo del elemento.
%
% Ejemplo de uso:
%   curvatureProfile = computeElementCurvature(5, connectivity, coordMatrix, modalMatrix, 1);

    % --- Paso 1: Extraer los nodos del elemento según la conectividad ---
    % Se busca la fila de la conectividad cuyo primer valor (ID del elemento) sea elemID
    rowIndex = find(connectivity(:,1) == elemID);
    if isempty(rowIndex)
        error('Elemento con ID %d no encontrado en la matriz de conectividad.', elemID);
    end
    
    % Extraer la fila correspondiente; se asume que las columnas 2:end son los nodos
    connRow = connectivity(rowIndex, :);
    elementNodes = connRow(2:end);
    % Excluir nodos empotrados (IDs ≤ 4)
    elementNodes = elementNodes(elementNodes > 4);
    if isempty(elementNodes)
        error('Para el elemento %d, no quedan nodos válidos luego de excluir empotrados.', elemID);
    end
    
    % --- Paso 2: Extraer las coordenadas de los nodos del elemento y calcular el vector de longitudes de arco ---
    numNodes = numel(elementNodes);
    coordsElem = zeros(numNodes, 3);
    for i = 1:numNodes
        nodeID = elementNodes(i);
        rowCoord = find(coordMatrix(:,1) == nodeID);
        if isempty(rowCoord)
            error('No se encontraron coordenadas para el nodo %d.', nodeID);
        end
        coordsElem(i, :) = coordMatrix(rowCoord, 2:4);  % Extrae [x, y, z]
    end
    % Calcular el vector de longitud de arco para este elemento a partir de sus nodos
    arcLength = computeArcLength(coordsElem);
    
    % --- Paso 3: Extraer los valores modales para cada nodo del elemento para el modo indicado ---
    % Se procesa cada nodo del elemento; se unifican los 3 DOF (por ejemplo, usando la norma) para obtener un único valor por nodo.
    phi = zeros(numNodes, 1);
    for i = 1:numNodes
        nodeID = elementNodes(i);
        % Extrae las 3 filas correspondientes a este nodo de la matriz modal
        phi_nodeMatrix = extractNodeModal(modalMatrix, nodeID);
        % Seleccionar el valor del modo 'modeIndex' (un valor representativo del nodo); se usa la norma de las 3 DOF del modo
        phi(i) = norm(phi_nodeMatrix(:, modeIndex));
    end
    
    % --- Paso 4: Construir la función spline y calcular la curvatura ---
    pp = spline(arcLength, phi);         % Construye la función spline que interpola los valores de la forma modal a lo largo del elemento
    pp2 = fnder(pp, 2);                  % Calcula la segunda derivada del spline (curvatura)
    s_dense = linspace(min(arcLength), max(arcLength), 100);  % Genera 100 puntos equidistantes en el intervalo
    curvatureProfile = fnval(pp2, s_dense);  % Evalúa la curvatura en esos puntos, obteniendo el perfil de curvatura

end
