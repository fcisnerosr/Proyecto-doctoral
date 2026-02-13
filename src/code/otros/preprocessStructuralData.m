function [IDmax, NEn, nodes, elements, damele, eledent, ID, NE, A, Iy, Iz, J, E, G, vxz, KG, KGtu] = preprocessStructuralData(pathfile);
    nodes       = xlsread(pathfile,'nudos');
    elements    = xlsread(pathfile,'conectividad');
    [propgeom,txtpg] = xlsread(pathfile,'prop geom');
    fixnodes    = xlsread(pathfile,'fix nodes');

    vxz         = xlsread(pathfile,'vxz');

    % eliminating node numbers
    fixn = fixnodes(:,2:end)';

    % total number of nodes
    nnodes = length(nodes(:,1));

    % adding non fix nodes
        % GDL a nudos libres
    for l = 1 : length(fixnodes(:,1))
        indxfix         = find(fixnodes(l,1) == nodes(:,1));
        indxfixo        = find(indxfix == fixnodes(:,1));
        fixt(indxfix,:) = fixn(:,indxfixo)';
    end

    fixn = fixt';
    % indexes of non fix and fix nodes
    indx0 = find(fixn == 0);
    indx1 = find(fixn == 1);
    k     = 0;
    [m,n] = size(fixn);
    ID    = zeros(m,n);

    %sorting element numbers
        % Ordena los no. de elementos
    [B,IN] = sort(elements(:,1));


    % creating ID matrix
        % Ciclos para definir los grados de libertad de cada elemento. 
        % Todos los grados de libertad de cada nodo que no están restringidos, 
        % los numera en orden consecutivo 1,2,3,…,n. 
        % Mientras los que sí lo están restringidos les da números negativos
    for i = 1:length(indx0)
        ID(indx0(i)) = k+1;
        k = k+1;   
    end    

    for i = 1:length(indx1)    
        ID(indx1(i)) = (k+1)*(-1);
        k = k+1;    
    end

    % geometrical properties
    NE = length(elements(:,1));
    A  = propgeom(:,2);
    Iy = propgeom(:,3);
    Iz = propgeom(:,4);
    J = propgeom(:,5);
    E = propgeom(:,6);
    G = propgeom(:,7);
        eledent = [];
        damele  = [];

    % ID es un índice que almacena y clasifica los valores máximos de GDL de cada elemento. 
    % Recordar que los ID negativos son los que están restringidos. 
    % NEn cuenta todos los nodos restringidos.
    IDmax  = max(max(ID));
    NEn    = length(find(ID<0));
    
    %% Proceso de ensamblaje de KG (Matriz de rigidez global)        
        % Son inicialmente matrices de ceros, 
        % cuyas dimensiones son los GDL máximos, 
        % calculados en el paso anterior
    KG     = zeros(IDmax,IDmax);
    KGtu   = zeros(IDmax,NEn);  % KGtu = Matriz de rigidez global con reacciones

end
