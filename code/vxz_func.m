function [vxz] = vxz_func
    % clc
    % clear all
    % M_entre_que_nodos = [
    %     1   1   9;
    %     2   1   5;
    %     3   5   10;
    %     4   2   5;
    %     5   5   9;
    %     6   2   10;
    %     7   2   6;
    %     8   6   11;
    %     9   3   6;
    %     10  6   10;
    %     11  3   11;
    %     12  3   7;
    %     13  7   12;
    %     14  4   7;
    %     15  7   11;
    %     16  4   12;
    %     17  4   8;
    %     18  8   9;
    %     19  1   8;
    %     20  8   12;
    %     21  9   10;
    %     22  10  11;
    %     23  12  11;
    %     24  9   12;
    %     25  9   17;
    %     26  9   13;
    %     27  13  18;
    %     28  10  13;
    %     29  13  17;
    %     30  10  18;
    %     31  10  14;
    %     32  14  19;
    %     33  11  14;
    %     34  14  18;
    %     35  11  19;
    %     36  11  15;
    %     37  15  20;
    %     38  12  15;
    %     39  15  19;
    %     40  12  20;
    %     41  12  16;
    %     42  16  17;
    %     43  9   16;
    %     44  16  20;
    %     45  17  18;
    %     46  18  19;
    %     47  20  19;
    %     48  17  20;
    %     49  17  25;
    %     50  17  21;
    %     51  21  26;
    %     52  18  21;
    %     53  21  25;
    %     54  18  26;
    %     55  18  22;
    %     56  22  27;
    %     57  19  22;
    %     58  22  26;
    %     59  19  27;
    %     60  19  23;
    %     61  23  28;
    %     62  20  23;
    %     63  23  27;
    %     64  20  28;
    %     65  20  24;
    %     66  24  25;
    %     67  17  24;
    %     68  24  28;
    %     69  25  26;
    %     70  26  27;
    %     71  28  27;
    %     72  25  28;
    %     73  25  33;
    %     74  25  29;
    %     75  29  34;
    %     76  26  29;
    %     77  29  33;
    %     78  26  34;
    %     79  26  30;
    %     80  30  35;
    %     81  27  30;
    %     82  30  34;
    %     83  27  35;
    %     84  27  31;
    %     85  31  36;
    %     86  28  31;
    %     87  31  35;
    %     88  28  36;
    %     89  28  32;
    %     90  32  33;
    %     91  25  32;
    %     92  32  36;
    %     93  33  34;
    %     94  34  35;
    %     95  36  35;
    %     96  33  36;
    %     97  33  41;
    %     98  33  37;
    %     99  37  42;
    %     100 34  37;
    %     101 37  41;
    %     102 34  42;
    %     103 34  38;
    %     104 38  43;
    %     105 35  38;
    %     106 38  42;
    %     107 35  43;
    %     108 35  39;
    %     109 39  44;
    %     110 36  39;
    %     111 39  43;
    %     112 36  44;
    %     113 36  40;
    %     114 40  41;
    %     115 33  40;
    %     116 40  44;
    %     120 41  44];
    %
    % M_ubicacion_nodos = [
    %     1   0           0           0;
    %     2   41666.67    0           0;
    %     3   41666.67    41666.66    0;
    %     4   0           41666.66    0;
    %     5   20833.33    1329.79     10638.3;
    %     6   40336.88    20833.33    10638.3;
    %     7   20833.33    40336.87    10638.3;
    %     8   1329.79     20833.33    10638.3;
    %     9   2500        2500        20000;
    %     10  39166.67    2500        20000;
    %     11  39166.67    39166.66    20000;
    %     12  2500        39166.66    20000;
    %     13  20833.33    3841.46     30731.71;
    %     14  37825.2     20833.33    30731.71;
    %     15  20833.33    37825.2     30731.71;
    %     16  3841.46     20833.33    30731.71;
    %     17  5000        5000        40000;
    %     18  36666.67    5000        40000;
    %     19  36666.67    36666.66    40000;
    %     20  5000        36666.66    40000;
    %     21  20833.33    6357.14     50857.14;
    %     22  35309.52    20833.33    50857.14;
    %     23  20833.33    35309.52    50857.14;
    %     24  6357.14     20833.33    50857.14;
    %     25  7500        7500        60000;
    %     26  34166.66    7500        60000;
    %     27  34166.66    34166.66    60000;
    %     28  7500        34166.66    60000;
    %     29  20833.33    8879.31     71034.48;
    %     30  32787.36    20833.33    71034.48;
    %     31  20833.33    32787.35    71034.48;
    %     32  8879.31     20833.33    71034.48;
    %     33  10000       10000       80000;
    %     34  31666.67    10000       80000;
    %     35  31666.67    31666.66    80000;
    %     36  10000       31666.66    80000;
    %     37  20833.34    11413.04    91304.35;
    %     38  30253.63    20833.33    91304.35;
    %     39  20833.34    30253.62    91304.35;
    %     40  11413.04    20833.33    91304.35;
    %     41  12500       12500       100000;
    %     42  29166.67    12500       100000;
    %     43  29166.67    29166.66    100000;
    %     44  12500       29166.66    100000
    % ];
    %
    % % Number of elements
    % numElements = size(M_entre_que_nodos, 1);
    %
    % % Initialize matrices for local axes
    % vecxX = zeros(numElements, 3);
    % vecxY = zeros(numElements, 3);
    % vecxZ = zeros(numElements, 3);
    %
    % % Loop through each element to calculate local axes
    % for i = 1:numElements
    %     % Extract node indices from M_entre_que_nodos
    %     nodeStartIndex = M_entre_que_nodos(i, 2);
    %     nodeEndIndex = M_entre_que_nodos(i, 3);
    %
    %     % Retrieve coordinates for start and end nodes from M_ubicacion_nodos
    %     coord1 = M_ubicacion_nodos(nodeStartIndex, 2:4);
    %     coord2 = M_ubicacion_nodos(nodeEndIndex, 2:4);
    %
    %     % Calculate the directional vector from start to end
    %     vector_direccion = coord2 - coord1;
    %
    %     % Normalize the directional vector to get the local x-axis vector
    %     vecxX(i, :) = vector_direccion / norm(vector_direccion);
    %
    %     % Define a global vertical vector (z-axis)
    %     vector_vertical = [0, 0, 1];
    %
    %     % Calculate the local y-axis vector as the cross product of x and z
    %     vecxY(i, :) = -1 * cross(vecxX(i, :), vector_vertical);
    %     vecxY(i, :) = vecxY(i, :) / norm(vecxY(i, :));  % Normalize
    %
    %     % Calculate the local z-axis vector as the cross product of x and y to ensure orthogonality
    %     vecxZ(i, :) = cross(vecxX(i, :), vecxY(i, :));
    %     vecxZ(i, :) = vecxZ(i, :) / norm(vecxZ(i, :));  % Normalize
    %
    %
    %     % filename = 'vecxZ_matrix.xlsx'; % Define the file name
    %     % writematrix(vecxZ, filename, 'Sheet', 1); % Write to Excel
    % end
    % % Concatenate the element numbers at the beginning of the vecxZ matrix
    % elementNumbers = M_entre_que_nodos(:, 1);
    % vecxZ = horzcat(elementNumbers, vecxZ);  % Concatenate the column at the start
    %
    % vxz = vecxZ
% end
     % Coordenadas de los puntos

    % coord2 = [12500, 29166.66, 109000];
    % coord1 = [29166.67, 29166.66, 109000];
    % 
    % % Cálculo del vector direccional
    % vector_direccion = coord2 - coord1;
    % 
    % % Normalización del vector direccional para obtener el vector unitario x
    % vecxX = vector_direccion / norm(vector_direccion);
    % 
    % % Definir un vector vertical global (eje z)
    % vector_vertical = [0, 0, 1];
    % 
    % % Calcular el vector perpendicular al vector direccional y al vector vertical
    % % para obtener el eje y
    % vecxY = cross(vecxX, vector_vertical);
    % vecxY = vecxY / norm(vecxY)  % Normalizar
    % 
    % % Calcular el nuevo vector z a partir del vector x y y para asegurar la ortogonalidad
    % vecxZ = cross(vecxX, vecxY);
    % vecxZ = vecxZ / norm(vecxZ)  % Normalizar
    filename = 'E:/Archivos_Jaret/Proyecto-doctoral/pruebas_excel/marco3Ddam0.xlsx';
    sheetName = 'vxz';
    vxz = readmatrix(filename, 'Sheet', sheetName)
end

