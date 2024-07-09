
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
% A = [1, 2; 2 4];
% B = [3, 1; 1 0];
% C = [3, 1; 6 4];
% 
% A_B = cat(3, A, B,C)
% 
% %%
% index = [1, 3, 9];
% 
% M(:,:,10) = zeros(2);
% %%
% % Llenar los valores de M en los índices especificados por index
% for i = 1:length(index)
%     M(:,:,index(i)) = A_B(:,:,i);
% end

% % Coordenadas de los 5 puntos
% close all
% x = [1, 2, 3, 4, 5];
% y = [1, 4, 9, 16, 25];
% 
% % Crear una figura
% figure;
% 
% % Graficar los 5 puntos
% plot(x, y, 'bo', 'MarkerSize', 5, 'MarkerFaceColor', 'b'); % 'bo' grafica puntos azules
% hold on;
% 
% % Dibujar la línea solo entre el segundo y el cuarto punto
% plot([x(2), x(4)], [y(2), y(4)], 'r-', 'LineWidth', 2); % 'g-' dibuja una línea roja
% 
% % Configurar la gráfica
% grid on;
% xlabel('Eje X');
% ylabel('Eje Y');
% title('Unión de Puntos Específicos');
% legend('Puntos', 'Línea entre primer y último punto', 'Línea entre segundo y cuarto punto');

%%
close all
% % Coordenadas de los 5 puntos en 3D
% x = [1, 2, 3, 4, 5];
% y = [1, 4, 9, 16, 25];
% z = [2, 8, 18, 32, 50];
% 
% % Crear una figura
% figure;
% 
% % Graficar los 5 puntos en 3D
% plot3(x, y, z, 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b'); % 'bo' grafica puntos azules
% hold on;
% 
% % Dibujar la línea solo entre el primer y el último punto
% plot3([x(1), x(end)], [y(1), y(end)], [z(1), z(end)], 'r-', 'LineWidth', 2); % 'r-' dibuja una línea roja
% 
% % Dibujar la línea solo entre el segundo y el cuarto punto
% plot3([x(2), x(4)], [y(2), y(4)], [z(2), z(4)], 'g-', 'LineWidth', 2); % 'g-' dibuja una línea verde
% 
% % Configurar la gráfica
% grid on;
% xlabel('Eje X');
% ylabel('Eje Y');
% zlabel('Eje Z');
% title('Unión de Puntos Específicos en 3D');
% legend('Puntos', 'Línea entre primer y último punto', 'Línea entre segundo y cuarto punto');
% 
% % Opcional: Cambiar la vista de la gráfica para mejor visualización
% view(3); % Vista en 3D

% % Coordenadas de los 5 puntos
% X = [1, 2, 3, 4, 5];
% Y = [1, 4, 9, 16, 25];
% Z = [1, 8, 27, 64, 125];
% 
% % Crear una figura
% figure;
% 
% % Graficar los 5 puntos en 3D
% plot3(X, Y, Z, 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b'); % 'bo' grafica puntos azules
% hold on;
% 
% % Dibujar la línea solo entre el segundo y el cuarto punto
% plot3([X(2), X(4)], [Y(2), Y(4)], [Z(2), Z(4)], 'b-', 'LineWidth', 3); % 'b-' dibuja una línea azul
% 
% % Agregar etiquetas de texto para los índices de los puntos
% for i = 1:length(X)
%     text(X(i), Y(i), Z(i), num2str(i), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');
% end
% 
% % Configurar la gráfica
% grid on;
% xlabel('Eje X');
% ylabel('Eje Y');
% zlabel('Eje Z');
% title('Unión de Segundo y Cuarto Punto con Índices');
% legend('Puntos', 'Línea entre segundo y cuarto punto');
% 
% % Opcional: Cambiar la vista de la gráfica para mejor visualización
% view(3);  % Vista en 3D

for i = 1:76
    fprintf("text(X(%d), Y(%d), Z(%d), num2str(%d), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');\n", i, i, i, i);
end
