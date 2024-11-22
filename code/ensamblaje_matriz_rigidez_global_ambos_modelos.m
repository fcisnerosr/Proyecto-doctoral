function [KG_damaged, KG_undamaged,L, kg] = ensamblaje_matriz_rigidez_global_ambos_modelos(ID, NE, ke_d_total,elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G,  vxz, elem_con_dano_long_NE)
    % KG con daño
    KG_damaged = [];  % Inicializa con un valor vacío o cero
    KG_undamaged = [];  % Inicializa con un valor vacío o cero
    % Armado de la matriz de rigidez global
    %matrices_de_rigidez_ambos_modelos KG con daño
    KG=zeros(IDmax,IDmax);
    KGtu=zeros(IDmax,NEn);
    cont = 1;   % contador para iterar sobre ke_d_total
    for i = 1:NE
    % for i = 1:1
        KGf     = zeros(IDmax,IDmax);
        KGtuf   = zeros(IDmax,NEn);
        L(i) = norm(nodes(elements(i,3),2:4) - nodes(elements(i,2),2:4));
        
        
        CZ(i)  = (nodes(elements(i,3),4) - nodes(elements(i,2),4)) / L(i);
        CY(i)  = (nodes(elements(i,3),3) - nodes(elements(i,2),3)) / L(i);
        CX(i)  = (nodes(elements(i,3),2) - nodes(elements(i,2),2)) / L(i);
        CXY(i) = sqrt(CX(i)^2 + CY(i)^2);


        locdam  = find(damele == i,1);
        locdent = find(eledent==i,1);
        if isempty(locdam) && isempty(locdent)
            % local stiffness matrix of the elements
            if i == elem_con_dano_long_NE(i)
               % Asignacion de dano local a la matrices locales con danos asignadas previamente
                ke(:,:,i) = ke_d_total(:,:,cont);
                cont = cont + 1;
            else
                ke(:,:,i) = localkeframe3D(A(i),Iy(i),Iz(i),J(i),E(i),G(i),L(i));
            end            
        end

        % Matriz de transformaciones
        vxzl(:,i) = vxz(i,2:end);       % VXZ para elementos ortogonales, no aplica para elementos diagonales
        [cosalpha,sinalpha] = ejelocal(CX(i),CY(i),CZ(i),CXY(i),vxzl(:,i));     % Calculo de angulos de cada elemento (esto solo es util para discriminar los elementos ortogonales de los elementos inclinados)
        [Gamma_gamma, Gamma_beta] = TransfM3Dframe(CX, CY, CZ , CXY, i, cosalpha, sinalpha);    % Matriz de transformaciones para cualquier dirección de elementos (vigas, columnas o elementos inclinados)
        
        % matriz global de cada elemento
        kg(:,:,i) = Gamma_gamma' * Gamma_beta' * ke(:,:,i) * Gamma_beta * Gamma_gamma;
        kg(:,:,i) = simetria(kg(:,:,i));    % Limpiado de elementos que no son completamente simetricos

        LV(:,i) = [ID(:,elements(i,2)); ID(:,elements(i,3))];
        indxLV = find(LV(:,i)>0);
        indxLVn = find(LV(:,i)<0);
        % assamblage general stiffness matrix
        KGf(LV(indxLV,i),LV(indxLV,i)) = kg(indxLV,indxLV,i); 
        KGtuf(LV(indxLV,i),LV(indxLVn,i) * (-1)-IDmax) = kg(indxLV,indxLVn,i);
        KG = KGf + KG;
        % stiffness matrix for reactions
        KGtu = KGtuf + KGtu;
        clear KGf;
        clear KGtuf;
    end
    KG_damaged = KG;
    
    clear KG

    % % KG intacta
    % KG=zeros(IDmax,IDmax);
    % KGtu=zeros(IDmax,NEn);
    % for i = 1:NE
    %    KGf     = zeros(IDmax,IDmax);
    %    KGtuf   = zeros(IDmax,NEn);
    %    % Length of the elements
    %    L(i) = sqrt((nodes(elements(i,2),2)-nodes(elements(i,3),2))^2 + ...
    %            (nodes(elements(i,2),3)-nodes(elements(i,3),3))^2 + ...
    %            (nodes(elements(i,2),4)-nodes(elements(i,3),4))^2);
    % 
    %    CZ(i) = (nodes(elements(i,3),4)-nodes(elements(i,2),4))/L(i);
    %    CY(i) = (nodes(elements(i,3),3)-nodes(elements(i,2),3))/L(i);
    %    CX(i) = (nodes(elements(i,3),2)-nodes(elements(i,2),2))/L(i);
    %    CXY(i)= sqrt(CX(i)^2 + CY(i)^2);
    %    locdam  = find(damele == i,1);
    %    locdent = find(eledent==i,1);
    %    if isempty(locdam) && isempty(locdent)
    %         % local stiffness matrix of the elements
    %        ke(:,:,i) = localkeframe3D(A(i),Iy(i),Iz(i),J(i),E(i),G(i),L(i));
    %    elseif isempty(locdent)
    %        xdc = xdcr(locdam) * L(i);
    %        if strcmp(tipo(i),'circular')
    %           depthr1 = depthr(locdam) * radio(i);
    %            ke(:,:,i) = ZhengcircT(L(i),xdc,A(i),Iz(i),Iy(i),J(i),E(i),locdam,depthr1,G(i));
    %        elseif  strcmp(tipo(i),'rectangular')
    %            depthr1 = depthr(locdam) * h(i);
    %            ke(:,:,i) = Zhengrectub(L(i),xdc,A(i),Iz(i),Iy(i),J(i),E(i),locdam,depthr1,G(i),h(i),b(i),trec(i));  
    %        end             
    %     elseif isempty(locdam)
    %       ident = eledent(locdent);
    %        x1dent = x1dentr * L(ident);
    %         x2dent = x2dentr * L(ident);
    %       ke(:,:,i) = FEMdent(L(ident),Adent(locdent),Izdent(locdent),...
    %                    Iydent(locdent),Jdent(locdent),A(ident),Iz(ident),Iy(ident),...
    %                    J(ident),x1dent,x2dent,E(ident),G(ident));                
    %    end
    %    vxzl(:,i) = vxz(i,2:end);
    %    [cosalpha,sinalpha] = ejelocal(CX(i),CY(i),CZ(i),CXY(i),vxzl(:,i));
    %     %alpha = pi/4;
    %     % Transformation matrix 3D
    %     LT(:,:,i) = TransfM3Dframe(CX(i),CY(i),CZ(i),CXY(i),cosalpha,sinalpha);
    %     % global stiffnes matrix of the elements  
    %    kg(:,:,i) = LT(:,:,i)' * ke(:,:,i) * LT(:,:,i);
    %     LV(:,i) = [ID(:,elements(i,2)); ID(:,elements(i,3))];
    %     indxLV = find(LV(:,i)>0);
    %     indxLVn = find(LV(:,i)<0);
    %     % assamblage general stiffness matrix
    %    KGf(LV(indxLV,i),LV(indxLV,i)) = kg(indxLV,indxLV,i); 
    %    KGtuf(LV(indxLV,i),LV(indxLVn,i) * (-1)-IDmax) = kg(indxLV,indxLVn,i);
    %    KG = KGf + KG;
    %    % stiffness matrix for reactions
    %    KGtu = KGtuf + KGtu;
    %    clear KGf;
    %    clear KGtuf;
    % end
    % KG_undamaged = KG;
end




