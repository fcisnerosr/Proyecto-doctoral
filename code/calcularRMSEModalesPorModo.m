function RMSEs = calcularRMSEModalesPorModo(modos_cond_u, modos_cond_d)
    % Umbral para considerar valores como significativos
    umbral = 1e-8;
    numModos = size(modos_cond_u, 2);
    RMSEs = zeros(1, numModos);

    % Normalización de las formas modales (unidad de norma)
    for i = 1:numModos
        if norm(modos_cond_u(:, i)) > umbral
            modos_cond_u(:, i) = modos_cond_u(:, i) / norm(modos_cond_u(:, i));
        else
            modos_cond_u(:, i) = zeros(size(modos_cond_u(:, i)));
        end
        
        if norm(modos_cond_d(:, i)) > umbral
            modos_cond_d(:, i) = modos_cond_d(:, i) / norm(modos_cond_d(:, i));
        else
            modos_cond_d(:, i) = zeros(size(modos_cond_d(:, i)));
        end
    end
    
    % Aplicación del umbral para eliminar ruido numérico
    modos_cond_u(abs(modos_cond_u) < umbral) = 0;
    modos_cond_d(abs(modos_cond_d) < umbral) = 0;

    % Cálculo del RMSE para cada modo
    for i = 1:numModos
        diferencias = modos_cond_u(:, i) - modos_cond_d(:, i);
        RMSEs(i) = sqrt(mean(diferencias.^2));  % Promedio de cuadrados de las diferencias
    end

    return
end
