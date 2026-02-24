function outputFolder = obtenerOutputFolder()
% obtenerOutputFolder  Devuelve la ruta absoluta de la carpeta "Resultados" 
% dentro de la carpeta raíz del proyecto.
% 
% Salida:
%   outputFolder  Ruta completa a la carpeta Resultados.

    % Obtiene ruta del script (más confiable que pwd)
    scriptPath = fileparts(mfilename('fullpath'));
    
    % Sube desde 000_framework hasta la raíz del proyecto
    % Estructura: proyecto/code/001_framework_resultados_journal/000_framework
    rootPath = fullfile(scriptPath, '..', '..', '..');
    rootPath = char(java.io.File(rootPath).getCanonicalPath());
    
    % Construye la ruta a Resultados
    outputFolder = fullfile(rootPath, 'Resultados');
end