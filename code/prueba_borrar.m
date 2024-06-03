
clc; clear all

% % Crear el dato de entrada
% SECC_registr_inctacto = table([1; 3; 2; 4], {'SECC01'; 'SECC01'; 'SECC03'; 'SECC04'}, 'VariableNames', {'UniqueName', 'SectionProperty'})
% 
% 
% 
% % Vector V
% V = [3 4 2 1]'
% 
% % Verificar la pertenencia de cada valor de UniqueName en V
% pertenece = ismember(SECC_registr_inctacto.UniqueName, V);
% 
% % Ordenar la tabla SECC_registr_inctacto según la pertenencia
% SECC_registr_inctacto_ordenado = SECC_registr_inctacto(pertenece, :)


% % Crear el dato de entrada
% SECC_registr_inctacto = table([1; 3; 2; 4], {'SECC01'; 'SECC03'; 'SECC02'; 'SECC04'}, 'VariableNames', {'UniqueName', 'SectionProperty'})
% 
% % Vector V
% V = [3 1 2 4]'
% 
% % Comparar los valores de UniqueName con V y obtener los índices resultantes
% [~, idx] = ismember(SECC_registr_inctacto.UniqueName, V);
% 
% % Reordenar la columna SectionProperty utilizando los índices
% SECC_registr_inctacto_sorted = SECC_registr_inctacto(idx, :)



% % Cell array original
% cell_array = {
%     [73]
%     [78]
%     [83]
%     [88]
%     [74]
%     [75]
%     [76]
% };
% 
% % Convertir a valores numéricos
% numeric_array = cell2mat(cell_array)

% NE = 10;
% no_elemento_a_danar = [1, 6];
% elem_rep = zeros(length(no_elemento_a_danar),NE);
% 
% for i = 1:length(no_elemento_a_danar)
%     for j = 1:NE
%         elem_rep(i,j) = no_elemento_a_danar(i);
%     end
% end
% 
% elem_rep_fila = zeros(length(1),NE);
% j = [];
% for i = 1:height(elem_rep)
%     j(i) = i;
% end
% 
% % for i = 1:length(j)
% 
%     vector1 = elem_rep(1,no_elemento_a_danar(1):no_elemento_a_danar(2)-1)
%     vector2 = elem_rep(2,no_elemento_a_danar(2):end)
%     vector_concatenado = horzcat(vector1, vector2)
%     vector3 = elem_rep(2,no_elemento_a_danar(2):end)
% end
% 


% j = 1
% for j = 1:height(elem_rep)
% for i = 1:length(elem_rep_fila) 
% 
% 
%     if elem_rep(i,j) == no_elemento_a_danar(j)
%             elem_rep_fila(i) = elem_rep(i,j)
%             % j = j+1;
%         end
%     end
% end



% for i = 1:length(no_elemento_a_danar)
%     for j = 1:NE
%         if j == elem_rep(i)
%             elem_rep_fila(j) = elem_rep(i)
%         else
%             elem_rep_fila(j) = elem_rep(i)
%         end
%     end
% end


% NE = 176;
% no_elemento_a_danar = [1, 50];  % Puedes modificar estos valores según sea necesario
% 
% % Inicializar el vector de resultado
% resultado = zeros(1, NE);
% 
% % Asignar el primer valor de no_elemento_a_danar desde el inicio hasta el segundo valor de no_elemento_a_danar - 1
% resultado(1:no_elemento_a_danar(2)-1) = no_elemento_a_danar(1);
% 
% % Asignar el segundo valor de no_elemento_a_danar desde el segundo valor de no_elemento_a_danar hasta el final
% resultado(no_elemento_a_danar(2):NE) = no_elemento_a_danar(2);
% 
% % Mostrar el vector resultado
% disp(resultado);




% NE = 100;
% no_elemento_a_danar = [1, 6, 7,90];  % Puedes modificar estos valores según sea necesario
% 
% % Inicializar vector_concatenado como un vector vacío
% vector_concatenado = [];
% 
% % Construir el vector_concatenado
% for i = 1:length(no_elemento_a_danar)
%     if i < length(no_elemento_a_danar)
%         vector_concatenado = [vector_concatenado, ones(1, no_elemento_a_danar(i + 1) - no_elemento_a_danar(i)) * no_elemento_a_danar(i)];
%     else
%         vector_concatenado = [vector_concatenado, ones(1, NE - no_elemento_a_danar(i) + 1) * no_elemento_a_danar(i)];
%     end
% end
% 
% % Mostrar el resultado
% disp(vector_concatenado);

%%
A = [1, 2; 2 4];
B = [3, 1; 1 0];
C = [3, 1; 6 4];

A_B = cat(3, A, B,C)

%%
index = [1, 3, 9];

M(:,:,10) = zeros(2);
%%
% Llenar los valores de M en los índices especificados por index
for i = 1:length(index)
    M(:,:,index(i)) = A_B(:,:,i);
end