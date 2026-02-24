function pathfile = obtenerRutaMarco3Ddam0()
    % Función para obtener la ruta completa del archivo marco3Ddam0.xlsx
    %
    % Salida:
    %   pathfile: Ruta completa del archivo

    % Obtener ruta del script actual
    scriptPath = fileparts(mfilename('fullpath'));
    
    % Subir hasta la raíz del proyecto (2 niveles arriba desde code/001_framework_resultados_journal/)
    rootPath = fullfile(scriptPath, '..', '..');
    rootPath = char(java.io.File(rootPath).getCanonicalPath());
    
    % Intentar varios paths posibles (priorizando el que existe)
    posibles_rutas = {
        fullfile(rootPath, 'pruebas_excel', 'marco3Ddam0.xlsx');
        fullfile(rootPath, 'data', 'excels_de_ing_Jaret', 'marco3Ddam0.xlsx');
        fullfile(rootPath, 'data', 'marco3Ddam0.xlsx');
    };
    
    for i = 1:length(posibles_rutas)
        if exist(posibles_rutas{i}, 'file')
            pathfile = posibles_rutas{i};
            fprintf('✓ Archivo encontrado: %s\n', pathfile);
            return;
        end
    end
    
    % Si no se encuentra ninguno, mostrar error informativo
    error(['No se encontró marco3Ddam0.xlsx en ninguna ubicación esperada:\n' ...
           '  %s\n  %s\n  %s\n' ...
           'Por favor, verifica que el archivo existe en pruebas_excel/'], ...
           posibles_rutas{1}, posibles_rutas{2}, posibles_rutas{3});
end
