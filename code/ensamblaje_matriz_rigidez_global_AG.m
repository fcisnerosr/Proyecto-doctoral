function [KG_AG] = ensamblaje_matriz_rigidez_global_AG(num_element_sub,ke_AG_tensor,ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, vxz, elem_con_dano_long_NE);
% KG del AG
   % Reensamblar la matriz global de rigidez con daño del AG
    KG   = zeros(IDmax,IDmax);
    KGtu = zeros(IDmax,NEn);
     for j = 1:NE
        KGf     = zeros(IDmax,IDmax);
        KGtuf   = zeros(IDmax,NEn);
        % Length of the elements
        L(j) = sqrt((nodes(elements(j,2),2)-nodes(elements(j,3),2))^2 + ...
               (nodes(elements(j,2),3)-nodes(elements(j,3),3))^2 + ...
               (nodes(elements(j,2),4)-nodes(elements(j,3),4))^2);
        
        % Definir las variables como simbólicas
        CZ_sym = sym((nodes(elements(j,3),4) - nodes(elements(j,2),4)) / L(j));
        CY_sym = sym((nodes(elements(j,3),3) - nodes(elements(j,2),3)) / L(j));
        CX_sym = sym((nodes(elements(j,3),2) - nodes(elements(j,2),2)) / L(j));
        
        % Calcular CXY manteniendo la exactitud simbólica
        CXY_sym = sqrt(CX_sym^2 + CY_sym^2);
        
        % Almacenar resultados en formato simbólico para conservar precisión
        CZ(j)  = CZ_sym;
        CY(j)  = CY_sym;
        CX(j)  = CX_sym;
        CXY(j) = CXY_sym;
        
        locdam  = find(damele == j,1);
        locdent = find(eledent==j,1);
        if isempty(locdam) && isempty(locdent)   
            if j < num_element_sub
                ke(:,:,j) = ke_AG_tensor(:,:,j);
                % fprintf('numero de elemento %d, en sub-estructura\n',j);
                
            else
                ke(:,:,j) = localkeframe3D(A(j),Iy(j),Iz(j),J(j),E(j),G(j),L(j)); % matriz de rigidez
                % fprintf('numero de elemento %d, en super-estructura\n',j);
            end
        end

        % vxzl(:,j) = vxz(j,2:end);
        % [cosalpha,sinalpha] = ejelocal(CX(j),CY(j),CZ(j),CXY(j),vxzl(:,j));
        % Transformation matrix 3D
        [T_gamma, T_beta] = TransfM3Dframe_AG(j, elements, nodes, L, CX, CY, CZ, CXY);
        % global stiffnes matrix of the elements
        
        % global stiffnes matrix of the elements 
        Gamma = T_gamma * T_beta;
        % Gamma = T_gamma * T_beta;
        kg(:,:,j) = Gamma' * ke(:,:,j) * Gamma;
        kg(:,:,j) = double(kg(:,:,j));
        % kg_numerica = double(kg(:,:,j));
        % if issymmetric(kg_numerica)
        %    disp('La matriz es simétrica.');            
        % else
        %    disp('La matriz no es simétrica.')
        % end

        LV(:,j) = [ID(:,elements(j,2)); ID(:,elements(j,3))];
        indxLV = find(LV(:,j)>0);
        indxLVn = find(LV(:,j)<0);
        % assamblage general stiffness matrix
        KGf(LV(indxLV,j),LV(indxLV,j)) = kg(indxLV,indxLV,j); 
        KGtuf(LV(indxLV,j),LV(indxLVn,j) * (-1)-IDmax) = kg(indxLV,indxLVn,j);
        % stiffness matrix for reactions
        KG = KGf + KG;
        KGtu = KGtuf + KGtu;
        clear KGf;
        clear KGtuf;
    end

    KG_AG = KG;
end
