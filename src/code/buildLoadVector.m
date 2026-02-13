function LoadVector = buildLoadVector()
    % Definimos las cargas y momentos que se aplican a cada nodo
    Fx = 50000;   % N
    Fy = -60000;  % N
    Fz = 30000;   % N
    % Mx = -10000;  % N·mm
    % My = -20000;  % N·mm
    % Mz = 15000;   % N·mm

    % Número de grados de libertad por nodo
    dof = 3;
    % Número de nodos
    nNodes = 20;

    % Vector de 6x1 con la carga del "patrón" para un solo nodo
    % loadPatternNode = [Fx; Fy; Fz; Mx; My; Mz];
    loadPatternNode = [Fx; Fy; Fz];

    % Replicamos el patrón para los 20 nodos en un vector columna de (nNodes*dof)x1
    LoadVector = repmat(loadPatternNode, nNodes, 1);
end
