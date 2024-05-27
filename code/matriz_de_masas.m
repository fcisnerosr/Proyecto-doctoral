function [M_cond] = matriz_de_masas()
    % Lectura de datos del .XLSX para cálculo de la masa nodal
        ruta_archivo = 'E:\Archivos_Jaret\Mis_modificaciones\pruebas_excel\marco3Ddam0.xlsx';
        [M_long] = xlsread(ruta_archivo, 'nudos');
        longitud_nodo = (M_long(1,4)*0.5) + (M_long(2,2)*0.5) + (M_long(3,3)*0.5);
        [M_area] = xlsread(ruta_archivo, 'masses');
        Area = M_area(1,11);
        Dens = M_area(1,13);
        m  = Area * longitud_nodo * Dens;

    % Masa rotacional inercial
            % Opción 1 - Despreciarla
                mr = 0.000001;     

%             % Opción 2 - Mario Paz
%                 A = 45851;
%                 d = D - (2*t);
%                 J = (1/32*pi*D^4)-(1/32*pi*d^4);
%                 R = 0.5*D;
%                 r = 0.5*d;
%                 IA = J/A(1);
%                 mr = m*IA;    
% 
%             % Opción 3 - Matriz torsional nodal a lo largo del elemento tubular (cálculo con el dr. IFG)
%                 r = D/2;
%                 mr = 2*pi*t*Dens*r^3*longitud_nodo
%                 
%             % Opción 4 - Chopra
%                 Long_x = M_long(2,2);
%                 Long_y = M_long(3,3);
%                 mr = m*((Long_x/2)^2+(Long_y/2)^2)/12;    
    
    % Ensamble de matriz de masas diagonal
        [Nudos] = xlsread(ruta_archivo, 'nudos');
        L = (length(Nudos) * 0.5);  % Se multiplica por 0.5 porque son los nudos efectivos, se excluyen a los nudos empotrados
        M = zeros(L*3);     % Se multiplica por 3 porque cada GDL no condensado se le consideran 3 grados efectivos. los traslacionales y la rotación al rededor de Z global
        for i = 1:L*3
            if mod(i, 3) == 1
                M(i, i) = m;        % Masa traslacional
            elseif mod(i, 3) == 2
                M(i, i) = m;        % Masa traslacional
            else
                M(i, i) = mr;       % Masa rotacional
            end
        end
        M = M_cond;
end
