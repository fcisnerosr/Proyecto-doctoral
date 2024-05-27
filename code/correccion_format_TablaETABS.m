function correccion_format_TablaETABS(archivo_excel)
    %% Corregir de formato los números en la tabla importada de ETABS:
    % En todo este bloque de código, se realizó el cambio de formato de los números
    % debido a que ETABS importa sus tablas en formato de texto en algunas columnas.
        % NOTA: No se pudo realizar funciones para cada pestaña debido a que el comando "readtable" de MATLAB
              % fue siempre bastante inconsiste al exportar las tablas de ETABS.

    hoja_excel = 'Assembled Joint Masses';
        % archivo_excel: Ruta del archivo Excel
        % hoja_excel: Nombre de la hoja en el archivo Excel
        % letra_columna: Letra de la columna a convertir (por ejemplo, 'B', 'C', etc.)
        % n: Número de columna a convertir a formato número
        n = 2;
        letra_columna = 'B';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array        
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico1 = str2double(array_columna);           % Convierte los elementos de la columna a números        
        % Calcula el rango de celdas para escribir
        rango_celdas1 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico1) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila        
        n = 3;
        letra_columna = 'C';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array        
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico2 = str2double(array_columna); % Convierte los elementos de la columna a números
        rango_celdas2    = [letra_columna  '4:' letra_columna num2str(length(vector_numerico2) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila
        xlswrite(archivo_excel, vector_numerico1, hoja_excel, rango_celdas1);
        xlswrite(archivo_excel, vector_numerico2, hoja_excel, rango_celdas2);
         

    hoja_excel = 'Beam Bays';
        n = 2;
        letra_columna = 'B';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        indice_fila_a_eliminar = 1;                             % La tabla produce una fila de ceros, provoca errores 
        data(indice_fila_a_eliminar, :) = [];                   % Eliminación de fila de ceros leida por comando "readtable"
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico1 = str2double(array_columna); % Convierte los elementos de la columna a números
        % Calcula el rango de celdas para escribir
        rango_celdas1 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico1) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila
        n = 3;
        letra_columna = 'C';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        indice_fila_a_eliminar = 1;                             % La tabla produce una fila de ceros, provoca errores 
        data(indice_fila_a_eliminar, :) = [];                   % Eliminación de fila de ceros leida por comando "readtable"
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico2 = str2double(array_columna); % Convierte los elementos de la columna a números
        rango_celdas2    = [letra_columna  '4:' letra_columna num2str(length(vector_numerico2) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila
        xlswrite(archivo_excel, vector_numerico1, hoja_excel, rango_celdas1);
        xlswrite(archivo_excel, vector_numerico2, hoja_excel, rango_celdas2);
         
        
    hoja_excel = 'Beam Object Connectivity';
         n = 1;
        letra_columna = 'A';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array        
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico1 = str2double(array_columna); % Convierte los elementos de la columna a números        
        % Calcula el rango de celdas para escribir
        rango_celdas1 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico1) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila      
        n = 4;
        letra_columna = 'D';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        columna = data(:, n) ;                                  % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array        
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico2 = str2double(array_columna); % Convierte los elementos de la columna a números        
        % Calcula el rango de celdas para escribir
        rango_celdas2 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico2) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila        
        n = 5;
        letra_columna = 'E';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        columna = data(:, n) ;                                  % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array        
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico3 = str2double(array_columna); % Convierte los elementos de la columna a números        
        % Calcula el rango de celdas para escribir
        rango_celdas3 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico1) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila
        xlswrite(archivo_excel, vector_numerico1, hoja_excel, rango_celdas1);
        xlswrite(archivo_excel, vector_numerico2, hoja_excel, rango_celdas2);
        xlswrite(archivo_excel, vector_numerico3, hoja_excel, rango_celdas3);
         

    hoja_excel = 'Brace Bays';
        n = 2;
        letra_columna = 'B';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        indice_fila_a_eliminar = 1;                             % La tabla produce una fila de ceros, provoca errores 
        data(indice_fila_a_eliminar, :) = [];                   % Eliminación de fila de ceros leida por comando "readtable"
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array        
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico1 = str2double(array_columna); % Convierte los elementos de la columna a números        
        % Calcula el rango de celdas para escribir
        rango_celdas1 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico1) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila        
        n = 3;
        letra_columna = 'C';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        indice_fila_a_eliminar = 1;                             % La tabla produce una fila de ceros, provoca errores 
        data(indice_fila_a_eliminar, :) = [];                   % Eliminación de fila de ceros leida por comando "readtable"
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array        
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico2 = str2double(array_columna); % Convierte los elementos de la columna a números        
        % Calcula el rango de celdas para escribir
        rango_celdas2 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico2) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila        
        rango_celdas3 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico1) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila
        xlswrite(archivo_excel, vector_numerico1, hoja_excel, rango_celdas1);
        xlswrite(archivo_excel, vector_numerico2, hoja_excel, rango_celdas2);
         

    hoja_excel = 'Brace Object Connectivity';
        n = 1;
        letra_columna = 'A';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array        
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico1 = str2double(array_columna); % Convierte los elementos de la columna a números        
        % Calcula el rango de celdas para escribir
        rango_celdas1 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico1) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila        
        xlswrite(archivo_excel, vector_numerico1, hoja_excel, rango_celdas1);
        n = 4;
        letra_columna = 'D';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        columna = data(:, n) ;                                  % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array        
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico2 = str2double(array_columna); % Convierte los elementos de la columna a números        
        % Calcula el rango de celdas para escribir
        rango_celdas2 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico2) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila
        xlswrite(archivo_excel, vector_numerico2, hoja_excel, rango_celdas2);
        n = 5;
        letra_columna = 'E';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico3 = str2double(array_columna); % Convierte los elementos de la columna a números        
        % Calcula el rango de celdas para escribir
        rango_celdas3 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico1) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila
        xlswrite(archivo_excel, vector_numerico3, hoja_excel, rango_celdas3);
         

     hoja_excel =  'Frame Assigns - Sect Prop';
        n = 3;
        letra_columna = 'C';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        indice_fila_a_eliminar = 1;                             % La tabla produce una fila de ceros, provoca errores 
        data(indice_fila_a_eliminar, :) = [];                   % Eliminación de fila de ceros leida por comando "readtable"
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico1 = str2double(array_columna); % Convierte los elementos de la columna a números
        % Calcula el rango de celdas para escribir
        rango_celdas1 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico1) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila
        xlswrite(archivo_excel, vector_numerico1, hoja_excel, rango_celdas1);
         

     hoja_excel =  'Group Assignments';
        n = 3;
        letra_columna = 'C';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        indice_fila_a_eliminar = 1;                             % La tabla produce una fila de ceros, provoca errores 
        data(indice_fila_a_eliminar, :) = [];                   % Eliminación de fila de ceros leida por comando "readtable"
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico1 = str2double(array_columna); % Convierte los elementos de la columna a números
        % Calcula el rango de celdas para escribir
        rango_celdas1 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico1) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila
        xlswrite(archivo_excel, vector_numerico1, hoja_excel, rango_celdas1);
         

    hoja_excel =  'Joint Assigns - Restraints';
        n = 2;
        letra_columna = 'B';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        indice_fila_a_eliminar = 1;                             % La tabla produce una fila de ceros, provoca errores 
        data(indice_fila_a_eliminar, :) = [];                   % Eliminación de fila de ceros leida por comando "readtable"
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico1 = str2double(array_columna); % Convierte los elementos de la columna a números
        % Calcula el rango de celdas para escribir
        rango_celdas1 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico1) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila
        n = 3;
        letra_columna = 'C';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        indice_fila_a_eliminar = 1;                             % La tabla produce una fila de ceros, provoca errores 
        data(indice_fila_a_eliminar, :) = [];                   % Eliminación de fila de ceros leida por comando "readtable"
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico2 = str2double(array_columna); % Convierte los elementos de la columna a números
        % Calcula el rango de celdas para escribir
        rango_celdas2 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico2) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila
        xlswrite(archivo_excel, vector_numerico1, hoja_excel, rango_celdas1);
        xlswrite(archivo_excel, vector_numerico2, hoja_excel, rango_celdas2);
         
        
    hoja_excel = 'Point Bays';
        n = 1;
        letra_columna = 'A';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico1 = str2double(array_columna); % Convierte los elementos de la columna a números
        % Calcula el rango de celdas para escribir
        rango_celdas1 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico1) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila
        xlswrite(archivo_excel, vector_numerico1, hoja_excel, rango_celdas1);
    
    hoja_excel = 'Point Object Connectivity';
        n = 1;
        letra_columna = 'A';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico1 = str2double(array_columna); % Convierte los elementos de la columna a números
        % Calcula el rango de celdas para escribir
        rango_celdas1 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico1) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila        
        n = 4;
        letra_columna = 'D';
        data = readtable(archivo_excel, 'Sheet', hoja_excel);   % Se usa el comando readtable porque incluye texto en lugar de números
        columna = data(:, n);                                   % Selecciona la columna especificada por el número n
        array_columna = table2array(columna);                   % Convierte la columna a un array
        % Convierte el array en un vector numérico si los datos son números
        vector_numerico2 = str2double(array_columna); % Convierte los elementos de la columna a números
        % Calcula el rango de celdas para escribir
        rango_celdas2 = [letra_columna  '4:' letra_columna num2str(length(vector_numerico2) + 3)]; % el número 4 es porque todas columnas en todas las pestañas empiezan a partir de la 4ta fila        
        xlswrite(archivo_excel, vector_numerico1, hoja_excel, rango_celdas1);
        xlswrite(archivo_excel, vector_numerico2, hoja_excel, rango_celdas2);
end
