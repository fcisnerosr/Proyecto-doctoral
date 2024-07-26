function [MG] = matriz_de_masas_MPaz(D,t)
    % Matriz de masas completa
        ruta_archivo = 'E:\Archivos_Jaret\Mis_modificaciones\pruebas_excel\marco3Ddam0.xlsx';    
        % Lee los datos de la hoja de cálculo en MATLAB
        [M_long] = xlsread(ruta_archivo, 'nudos');
        longitud_nodo = (M_long(1,4)*0.5) + (M_long(2,2)*0.5) + (M_long(3,3)*0.5);
        [M_area] = xlsread(ruta_archivo, 'masses');
        Area = M_area(1,11);
        Dens = M_area(1,13);
        % Matriz traslacional 
            m  = Area * longitud_nodo * Dens;
        % Matriz rotacional
            d = D - (2*t);
            J = (1/32*pi*D^4)-(1/32*pi*d^4);
            R = 0.5*D;
            r = 0.5*d;
            IA = J/Area(1);
            % Inicializar matriz como una matriz de ceros de 24x24
            MG = zeros(24);
    
        % Definir los valores en la diagonal principal
        for i = 1:4
            % Primer ciclo: Colocar 1s
            MG((i-1)*6+1:(i-1)*6+3, (i-1)*6+1:(i-1)*6+3) = eye(3);
            
            % Segundo ciclo: Colocar X
            MG((i-1)*6+4:(i-1)*6+6, (i-1)*6+4:(i-1)*6+6) = eye(3) * IA; % Cambiar 5 por el valor que desees
            
            % Tercer ciclo: Colocar 0s
            MG((i-1)*6+7, (i-1)*6+7) = 0;
            MG((i-1)*6+8, (i-1)*6+8) = 0;
        end
        % Valores de masas rotacionales
            MG(5,5)     = IA;
            MG(6,6)     = IA;
            MG(11,11)   = IA;
            MG(12,12)   = IA;
            MG(17,17)   = IA;
            MG(18,18)   = IA;
            MG(23,23)   = IA;
            MG(24,24)   = IA;
            MG = MG(:, 1:end-2);
            MG = MG(1:end-2, :);
            MG = MG*m;
end
