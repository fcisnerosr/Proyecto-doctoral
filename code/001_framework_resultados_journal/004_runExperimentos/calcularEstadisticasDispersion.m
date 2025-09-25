function [prom_dispersion, std_dispersion, mean_abs_dispersion, n_falsos_positivos] = calcularEstadisticasDispersion(P_scaled)
% calcularEstadisticasDispersion Calcula estadísticos de los valores dispersos en P_scaled.

    valid_vals = P_scaled(~isnan(P_scaled) & P_scaled < 50);  % Excluye NaNs y posibles verdaderos positivos

    prom_dispersion     = mean(valid_vals);
    std_dispersion      = std(valid_vals);
    mean_abs_dispersion = mean(abs(valid_vals));
    n_falsos_positivos  = sum(valid_vals > 50);

end
