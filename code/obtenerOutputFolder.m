function outputFolder = obtenerOutputFolder()
% obtenerOutputFolder  Devuelve la ruta absoluta de la carpeta "Resultados" 
% dentro de la carpeta "Proyecto-doctoral" ubicada en el árbol de trabajo.
% 
% Salida:
%   outputFolder  Ruta completa a la carpeta Resultados.

    % Obtiene ruta actual de trabajo
    currentPath = pwd;

    % Divide la ruta en sus componentes
    tokens = strsplit(currentPath, filesep);

    % Busca la carpeta raíz del proyecto
    idx = find(strcmp(tokens, 'Proyecto-doctoral'), 1, 'last');
    if isempty(idx)
        error('No se encontró la carpeta Proyecto-doctoral en la ruta actual.');
    end

    % Reconstruye la ruta hasta la carpeta Proyecto-doctoral y añade "Resultados"
    outputFolder = fullfile(tokens{1:idx}, 'Resultados');
end