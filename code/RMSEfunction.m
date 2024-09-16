function [Objetivo] = RMSEfunction(x, num_element_sub, M_cond, frec_cond_d,...
    L, ID, NE, elements, nodes, IDmax, NEn, damele, eledent, A, Iy, Iz, J, E, G, ...
    vxz, elem_con_dano_long_NE,...
    modos_cond_d)
    % Inicializa la variable objetivo
    Objetivo  = 0;
    
    % Pesos para las funciones objetivo
    w1 = 0.6;  % Peso al RMSE
    w2 = 0.4;  % Peso al MACN
    
    % Recorta las propiedades a la subestructura
    L_sub  = L(1:num_element_sub);   
    A_sub  = A(1:num_element_sub);   
    Iy_sub = Iy(1:num_element_sub);  
    Iz_sub = Iz(1:num_element_sub);
    E_sub  = E(1:num_element_sub);
    G_sub  = G(1:num_element_sub);
    J_sub  = J(1:num_element_sub);
    
    ke_AG_tensor = zeros(12,12,num_element_sub);
    % Recorre cada uno de los num_element_sub elementos para aplicar el daño
    for i = 1:num_element_sub
        % Matriz de rigidez local
        ke_AG = zeros(12,12);
        
        % Aplica daño por corrosión
        A_damaged  = A_sub(i)  * (1 - x(3*i - 2));  
        Iy_damaged = Iy_sub(i) * (1 - x(3*i - 1));  
        Iz_damaged = Iz_sub(i) * (1 - x(3*i)); 
        
        % Modifica los términos afectados en la matriz de rigidez local
        % Elementos de la diagonal principal
        ke_AG(1, 1)  =  E_sub(i) * A_damaged / L_sub(i);
        ke_AG(2, 2)  =  12 * E_sub(i) * Iy_damaged / L_sub(i)^3;
        ke_AG(3, 3)  =  12 * E_sub(i) * Iz_damaged / L_sub(i)^3;
        ke_AG(4, 4)  =  (G_sub(i) * J_sub(i)) / L_sub(i);
        ke_AG(5, 5)  =  4 * E_sub(i) * Iy_damaged / L_sub(i);
        ke_AG(6, 6)  =  4 * E_sub(i) * Iz_damaged / L_sub(i);
        ke_AG(7, 7)  =  E_sub(i) * A_damaged / L_sub(i);
        ke_AG(8, 8)  =  12 * E_sub(i) * Iy_damaged / L_sub(i)^3;
        ke_AG(9, 9)  =  12 * E_sub(i) * Iz_damaged / L_sub(i)^3;
        ke_AG(10, 10) = (G_sub(i) * J_sub(i)) / L_sub(i);
        ke_AG(11, 11) = 4 * E_sub(i) * Iy_damaged / L_sub(i);
        ke_AG(12, 12) = 4 * E_sub(i) * Iz_damaged / L_sub(i);
        
        % Resto de los elementos de la matriz de rigidez local
        ke_AG(7, 1)  = -ke_AG(1, 1);
        ke_AG(6, 2)  = (6 * E_sub(i) * Iz_damaged) / L_sub(i)^2;
        ke_AG(8, 2)  = (-12 * E_sub(i) * Iz_damaged) / L_sub(i)^3;
        ke_AG(12, 2) = (6 * E_sub(i) * Iz_damaged) / L_sub(i)^2;
        ke_AG(5, 3)  = -(6 * E_sub(i) * Iy_damaged) / L_sub(i)^2;
        ke_AG(9, 3)  = (-12 * E_sub(i) * Iy_damaged) / L_sub(i)^3;
        ke_AG(11, 3) = (-6 * E_sub(i) * Iy_damaged) / L_sub(i)^2;
        ke_AG(10, 4) = (-G_sub(i) * J_sub(i)) / L_sub(i);
        ke_AG(9, 5)  = (6 * E_sub(i) * Iy_damaged) / L_sub(i)^2;
        ke_AG(11, 5) = 2 * E_sub(i) * Iy_damaged / L_sub(i);
        ke_AG(8, 6)  = (-6 * E_sub(i) * Iz_damaged) / L_sub(i)^2;
        ke_AG(12, 6) = (2 * E_sub(i) * Iz_damaged) / L_sub(i);
        ke_AG(12, 8) = (-6 * E_sub(i) * Iz_damaged) / L_sub(i)^2;
        ke_AG(11, 9) = (6 * E_sub(i) * Iy_damaged) / L_sub(i)^2;
        
        % Las siguientes lineas acompleta el resto de la matriz de rigidez a fin de que quede simetrica
        keT = ke_AG';
        kediag = diag(diag(ke_AG));
        ke_AG = ke_AG + keT - kediag;
        ke_AG_tensor(:,:,i) = ke_AG;
   end
    
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
        
        CZ(j) = (nodes(elements(j,3),4)-nodes(elements(j,2),4))/L(j);
        CY(j) = (nodes(elements(j,3),3)-nodes(elements(j,2),3))/L(j);
        CX(j) = (nodes(elements(j,3),2)-nodes(elements(j,2),2))/L(j);
        CXY(j)= sqrt(CX(j)^2 + CY(j)^2);
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
        % stiffness matrix for reactions
        KG = KGf + KG;
        KGtu = KGtuf + KGtu;
        clear KGf;
        clear KGtuf;
    end

    KG_AG = KG;

    % Condensación estática de matrices globales
    KG_AG_cond              = condensacion_estatica_AG(KG_AG);
    [modos_AG_cond,frec_AG] = modos_frecuencias_AG(KG_AG_cond,M_cond);
    % Extraer la parte real de los modos y frecuencias
    modos_AG_cond = real(modos_AG_cond);
    frec_AG = real(frec_AG);
    % RMSE y MACN (MAC Normalizado)
    SumRMSEVal = 0;
    for i = 1:length(frec_AG)
        SumRMSEVal = SumRMSEVal + (frec_AG(i) - frec_cond_d(i))^2;
    end
    RMSE = sqrt(SumRMSEVal / length(frec_AG));

    % Calcular el MACN para formas modales
    macn_value = 0;
    for i = 1:size(modos_cond_d, 2)
        num = (modos_cond_d(:,i)' * modos_AG_cond(:,i))^2;
        den = (modos_cond_d(:,i)' * modos_cond_d(:,i)) * (modos_AG_cond(:,i)' * modos_AG_cond(:,i));
        MAC_value = num / den;
        macn_value = macn_value + sqrt((1 - MAC_value) / MAC_value);
    end
    macn_value = macn_value / size(modos_cond_d, 2);  % Promedio de MACN

    % Combinar en una función objetivo ponderada
    Objetivo = w1 * RMSE + w2 * (1 - macn_value);
end


