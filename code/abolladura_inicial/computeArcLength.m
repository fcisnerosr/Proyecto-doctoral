function arcLength = computeArcLength(connectivity, elemID, coordMatrix)
% computeArcLength  Calcula el vector de longitudes de arco para un elemento
%                   definido en la matriz de conectividad, excluyendo los
%                   nodos empotrados (1 a 4).
%
% Sintaxis:
%   arcLength = computeArcLength(connectivity, elemID, coordMatrix)
%
% Entradas:
%   connectivity - matriz de tamaño (E x K) donde:
%                  - La primera columna es el ID del elemento (por ejemplo, 1,2,3,...).
%                  - Las columnas restantes listan los nodos que forman ese elemento.
%                    En caso de elementos simples (2 nodos), serán 3 columnas totales:
%                       [elementID, nodoInicio, nodoFin].
%                    Para elementos con más nodos (subdivididos), habrá más columnas.
%
%   elemID       - ID (o índice) del elemento cuyo vector de longitud se desea calcular.
%   coordMatrix  - matriz de tamaño (N x 4) con la forma:
%                    [ nodeID, x, y, z ]
%                  donde N es el número total de nodos.
%
% Salida:
%   arcLength    - vector columna con la longitud de arco acumulada para
%                  cada nodo válido (excluyendo nodos 1..4) que defina el elemento.
%                  Empieza en 0 y aumenta hasta la longitud total del elemento.
%
% Ejemplo de uso:
%   % Supongamos que connectivity = [ 1 1 5; 2 5 9; 3 2 6; ... ];
%   % y coordMatrix = [1 0 0 0; 2 41667 0 0; 3 41667 41667 0; ... ];
%   arcLen = computeArcLength(connectivity, 1, coordMatrix);

    % 1. Buscar la fila de 'connectivity' que corresponda a elemID
    %    (Hay dos variantes: o la primera columna es strictly 'elemID' o
    %     elemID es el índice de la fila. Ajusta según tu caso.)
    
    % Variante A: si la primera columna EXACTAMENTE es el ID del elemento:
    rowIndex = find(connectivity(:,1) == elemID);
    if isempty(rowIndex)
        error('Elemento con ID %d no se encuentra en la matriz de conectividad.', elemID);
    end
    
    % Extraer la fila correspondiente
    connRow = connectivity(rowIndex, :);
    
    % connRow = [ elemID, nodo1, nodo2, (nodo3, nodo4,... si hubiera) ]
    % Nos interesan los nodos a partir de la segunda columna:
    elementNodes = connRow(2:end);
    
    % 2. Excluir los nodos empotrados (IDs 1..4) si aparecen
    %    Filtramos los nodos que sean > 4
    validNodes = elementNodes(elementNodes > 4);
    if isempty(validNodes)
        % Si todos los nodos eran empotrados, no hay nada que calcular
        arcLength = 0;
        warning('Todos los nodos del elemento %d estaban empotrados (1..4).', elemID);
        return;
    end
    
    % 3. Construir una lista de coordenadas (x,y,z) para estos nodos (en orden).
    %    Ojo: si hay más de 2 nodos, asegúrate de ordenarlos adecuadamente
    %    según la secuencia real. En un reticulado simple (2 nodos por elem),
    %    la "ordenación" es trivial. Si no, tendrías que definir la secuencia.
    
    coordsElement = zeros(numel(validNodes), 3);
    
    for i = 1:numel(validNodes)
        nodeID = validNodes(i);
        % Encontrar la fila en coordMatrix con ID = nodeID
        rowCoord = find(coordMatrix(:,1) == nodeID);
        if isempty(rowCoord)
            error('No se encuentra la fila de coordenadas para nodeID = %d.', nodeID);
        end
        coordsElement(i,:) = coordMatrix(rowCoord, 2:4);  % tomar [x,y,z]
    end
    
    % Si tu elemento "básico" es solo 2 nodos, coordsElement tendrá 2 filas,
    % lo cual facilita el cálculo. Para más de 2 nodos, están en coordsElement
    % y dependerá de su orden si requieres un reordenamiento adicional.

    % 4. Calcular las diferencias entre nodos consecutivos
    deltas = diff(coordsElement, 1, 1);  % (M-1) x 3, donde M = size(coordsElement,1)

    % 5. Distancia Euclidiana por cada tramo
    distances = sqrt(sum(deltas.^2, 2));

    % 6. Longitud de arco acumulada
    arcLength = [0; cumsum(distances)];

end
