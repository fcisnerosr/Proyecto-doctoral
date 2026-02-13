function COMAC = calcCOMAC(Phi_sano, Phi_danado)
% calcCOMAC  Calcula el Coordinate Modal Assurance Criterion (COMAC)
%            entre dos conjuntos de modos de vibración.
%
% Sintaxis:
%    COMAC = calcCOMAC(Phi_sano, Phi_danado)
%
% Entradas:
%    Phi_sano   : Matriz de formas modales del estado sano
%                 (dimensiones: n_coords x n_modos)
%    Phi_danado : Matriz de formas modales del estado dañado
%                 (dimensiones: n_coords x n_modos)
%
% Salida:
%    COMAC : Vector de longitud n_coords, donde cada elemento COMAC(j)
%            indica la correlación modal local en la coordenada j.

    % Verificar que ambas matrices tengan el mismo tamaño
    [n_coords_sano, n_modos_sano] = size(Phi_sano);
    [n_coords_danado, n_modos_danado] = size(Phi_danado);

    if n_coords_sano ~= n_coords_danado || n_modos_sano ~= n_modos_danado
        error('Las dimensiones de Phi_sano y Phi_danado no coinciden.');
    end

    % Inicializar el vector COMAC
    COMAC = zeros(n_coords_sano, 1);

    % Calcular COMAC para cada coordenada j
    for j = 1:n_coords_sano
        numerador = 0;
        sumSano   = 0;
        sumDanado = 0;

        % Sumar sobre todos los modos
        for i = 1:n_modos_sano
            numerador = numerador + (Phi_sano(j,i) * Phi_danado(j,i))^2;
            sumSano   = sumSano   + (Phi_sano(j,i))^2;
            sumDanado = sumDanado + (Phi_danado(j,i))^2;
        end

        % Evitar división por cero
        if sumSano == 0 || sumDanado == 0
            COMAC(j) = 0;  % Asignar 0 si alguna suma es 0 (o puedes manejarlo distinto)
        else
            COMAC(j) = numerador / (sumSano * sumDanado);
        end
    end

end
