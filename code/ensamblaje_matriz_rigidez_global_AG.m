function [KG_AG] = ensamblaje_matriz_rigidez_global_AG(num_element_sub,ke_AG_tensor,ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz, elem_con_dano_long_NE);
% KG del AG
   % Reensamblar la matriz global de rigidez con daño del AG
    KG   = zeros(IDmax,IDmax);
    KGtu = zeros(IDmax,NEn);
     for i = 1:NE
        KGf     = zeros(IDmax,IDmax);
        KGtuf   = zeros(IDmax,NEn);
        % Length of the elements
        L(i) = norm(nodes(elements(i,3),2:4) - nodes(elements(i,2),2:4));
        
        % Definir las variables como simbólicas
        CZ(i) = (nodes(elements(i,3),4) - nodes(elements(i,2),4)) / L(i);
        CY(i) = (nodes(elements(i,3),3) - nodes(elements(i,2),3)) / L(i);
        CX(i) = (nodes(elements(i,3),2) - nodes(elements(i,2),2)) / L(i);
        CXY(i) = sqrt(CX(i)^2 + CY(i)^2);
        
        locdam  = find(damele == i,1);
        locdent = find(eledent==i,1);
        if isempty(locdam) && isempty(locdent)   
            if i < num_element_sub
                ke(:,:,i) = ke_AG_tensor(:,:,i);
                % fprintf('numero de elemento %d, en sub-estructura\n',i);
                
            else
                ke(:,:,i) = localkeframe3D(A(i),Iy(i),Iz(i),J(i),E(i),G(i),L(i)); % matriz de rigidez
                % fprintf('numero de elemento %d, en super-estructura\n',i);
            end
        end
        vxzl(:,i) = vxz(i,2:end);       % VXZ para elementos ortogonales, no aplica para elementos diagonales
        [cosalpha,sinalpha] = ejelocal(CX(i),CY(i),CZ(i),CXY(i),vxzl(:,i));     % Calculo de angulos de cada elemento (esto solo es util para discriminar los elementos ortogonales de los elementos inclinados)
        [Gamma_gamma, Gamma_beta] = TransfM3Dframe(CX, CY, CZ , CXY, i, cosalpha, sinalpha);    % Matriz de transformaciones para cualquier dirección de elementos (vigas, columnas o elementos inclinados)
        
        % global stiffnes matrix of the elements 
        kg(:,:,i) = Gamma_gamma' * Gamma_beta' * ke(:,:,i) * Gamma_beta * Gamma_gamma;
        kg(:,:,i) = simetria(kg(:,:,i));    % Limpiado de elementos que no son completamente simetricos
        kg(:,:,i) = double(kg(:,:,i));
        % Comprobación de simetría
        % kg_numerica_exacta = double(kg(:,:,i));
        % kg_numerica = double(kg(:,:,i));
        % if issymmetric(kg_numerica)
        %    disp('La matriz es simétrica.');            
        % else
        %    disp('La matriz no es simétrica.')
        % end

        LV(:,i) = [ID(:,elements(i,2)); ID(:,elements(i,3))];
        indxLV = find(LV(:,i)>0);
        indxLVn = find(LV(:,i)<0);
        % assamblage general stiffness matrix
        KGf(LV(indxLV,i),LV(indxLV,i)) = kg(indxLV,indxLV,i); 
        KGtuf(LV(indxLV,i),LV(indxLVn,i) * (-1)-IDmax) = kg(indxLV,indxLVn,i);
        % stiffness matrix for reactions
        KG = KGf + KG;
        KGtu = KGtuf + KGtu;
        clear KGf;
        clear KGtuf;
    end

    KG_AG = KG;
end
