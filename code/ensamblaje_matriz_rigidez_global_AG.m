function [KG_AG] = ensamblaje_matriz_rigidez_global_AG(num_element_sub,ke_AG,ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz, elem_con_dano_long_NE)
% KG del AG
    KG   = zeros(IDmax,IDmax);
    KGtu = zeros(IDmax,NEn);

    for i = 1:NE
       KGf     = zeros(IDmax,IDmax);
       KGtuf   = zeros(IDmax,NEn);
       % Length of the elements
       L(i) = sqrt((nodes(elements(i,2),2)-nodes(elements(i,3),2))^2 + ...
               (nodes(elements(i,2),3)-nodes(elements(i,3),3))^2 + ...
               (nodes(elements(i,2),4)-nodes(elements(i,3),4))^2);
    
       CZ(i) = (nodes(elements(i,3),4)-nodes(elements(i,2),4))/L(i);
       CY(i) = (nodes(elements(i,3),3)-nodes(elements(i,2),3))/L(i);
       CX(i) = (nodes(elements(i,3),2)-nodes(elements(i,2),2))/L(i);
       CXY(i)= sqrt(CX(i)^2 + CY(i)^2);
       locdam  = find(damele == i,1);
       locdent = find(eledent==i,1);
        if isempty(locdam) && isempty(locdent) && (i > num_element_sub)
            % local stiffness matrix of the elements
           ke_AG(:,:,i) = localkeframe3D(A(i),Iy(i),Iz(i),J(i),E(i),G(i),L(i));
            
       end
       vxzl(:,i) = vxz(i,2:end);
       [cosalpha,sinalpha] = ejelocal(CX(i),CY(i),CZ(i),CXY(i),vxzl(:,i));
        %alpha = pi/4;
        % Transformation matrix 3D
        LT(:,:,i) = TransfM3Dframe(CX(i),CY(i),CZ(i),CXY(i),cosalpha,sinalpha);
        disp(size(LT));
        disp(size(ke_AG));
        % global stiffnes matrix of the elements
       kg(:,:,i) = LT(:,:,i)' * ke_AG(:,:,i) * LT(:,:,i);
        disp(size(kg));
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
    KG_undamaged = KG;
end
