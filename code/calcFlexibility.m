function F = calcFlexibility(phi, T)
    % phi   : Matriz de formas modales de tamaño (N x M), donde
    %         - N es el número de nodos o grados de libertad,
    %         - M es el número de modos considerados.
    %
    % T     : Vector de períodos de vibración en segundos, de tamaño (1 x M) o (M x 1)
    %         donde T(i) es el período del modo i.
    %
    % F     : Matriz de flexibilidad (N x N).
    
    % Verificamos dimensiones
    [N, M] = size(phi);
    if length(T) ~= M
        error('La longitud de "T" debe coincidir con el número de columnas de "phi".');
    end

    % Convertimos los períodos T a frecuencias angulares en rad/s:
    omega_rad = 2*pi ./ T;  % omega en rad/s

    % OPCIÓN A: Implementación directa (suma modo a modo)
    % F = sum(1/omega_i^2 * phi_i * phi_i^T) para i = 1..M
    F = zeros(N, N);
    for i = 1:M
        F = F + (1 / omega_rad(i)^2) * (phi(:, i) * phi(:, i)');
    end

    % OPCIÓN B: Implementación matricial (comentada)
    % Omega2Inv = diag(1 ./ (omega_rad.^2));
    % F = phi * Omega2Inv * phi';
end
