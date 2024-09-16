function [KG_AG] = ensamblaje_matriz_rigidez_global_AG(num_element_sub,ke_AG,ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz, elem_con_dano_long_NE)
% KG del AG
    KG      = zeros(IDmax,IDmax);
    KGtu    = zeros(IDmax,NEn);
    ke      = zeros(12, 12, NE); % matriz local en ceros de todos los elementos tubulares (incluyendo superestructura)
    for j = 1:NE
        KGf     = zeros(IDmax,IDmax);
        KGtuf   = zeros(IDmax,NEn);
        % Length of the elements
        L(j) = sqrt((nodes(elements(j,2),2)-nodes(elements(j,3),2))^2 + ...
               (nodes(elements(j,2),3)-nodes(elements(j,3),3))^2 + ...
               (nodes(elements(j,2),4)-nodes(elements(j,3),4))^2);
        
        CZ(j) = (nodes(elements(j,3),4)-nodes(elements(j,2),4))/L(j);
        CY(j) = (nodes(elements(j,3),3)-nodes(elements(j,2),3))/L(j);
        CX(j) = (nodes(elements(j,3),2)-nodes(elements(j,2),2))/L(j);
        CXY(j)= sqrt(CX(j)^2 + CY(j)^2);
        locdam  = find(damele == j,1);
        locdent = find(eledent==j,1);
        if j > num_element_sub
            j
            ke(:,:,j) = localkeframe3D(A(j),Iy(j),Iz(j),J(j),E(j),G(j),L(j)); % matriz de rigidez 
            fprintf('numero de elemento %d, en super-estructura\n',j)
        else
            j
            ke(:,:,j) = ke_AG
            fprintf('numero de elemento %d, en sub-estructura\n',j)
        end
        vxzl(:,j) = vxz(j,2:end);
        [cosalpha,sinalpha] = ejelocal(CX(j),CY(j),CZ(j),CXY(j),vxzl(:,j));
        % Transformation matrix 3D
        LT(:,:,j) = TransfM3Dframe(CX(j),CY(j),CZ(j),CXY(j),cosalpha,sinalpha);
        % global stiffnes matrix of the elements
        kg(:,:,j) = LT(:,:,j)' * ke(:,:,j) * LT(:,:,j);
        LV(:,j) = [ID(:,elements(j,2)); ID(:,elements(j,3))];
        indxLV = find(LV(:,j)>0);
        indxLVn = find(LV(:,j)<0);
        % assamblage general stiffness matrix
        KGf(LV(indxLV,j),LV(indxLV,j)) = kg(indxLV,indxLV,j); 
        KGtuf(LV(indxLV,j),LV(indxLVn,j) * (-1)-IDmax) = kg(indxLV,indxLVn,j);
        KG = KGf + KG;
        % stiffness matrix for reactions
        KGtu = KGtuf + KGtu;
        clear KGf;
        clear KGtuf;
    end
    KG_AG = KG;
end
