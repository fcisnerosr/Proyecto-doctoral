
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


% Crear el dato de entrada
SECC_registr_inctacto = table([1; 3; 2; 4], {'SECC01'; 'SECC03'; 'SECC02'; 'SECC04'}, 'VariableNames', {'UniqueName', 'SectionProperty'})

% Vector V
V = [3 1 2 4]'

% Comparar los valores de UniqueName con V y obtener los índices resultantes
[~, idx] = ismember(SECC_registr_inctacto.UniqueName, V);

% Reordenar la columna SectionProperty utilizando los índices
SECC_registr_inctacto_sorted = SECC_registr_inctacto(idx, :)



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
