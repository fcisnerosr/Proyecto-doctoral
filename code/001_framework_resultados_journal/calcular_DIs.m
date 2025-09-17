function [DI1_COMAC, DI2_Diff, DI3_Div, DI4_Diff_Flex, DI5_Div_Flex, DI6_Perc_Flex, DI7_Zscore_Flex, DI8_Prob_Flex] = calcular_DIs(modos_cond_u, modos_cond_d, Omega_cond_u, Omega_cond_d)
% calcular_DIs Calcula los índices de daño (DIs) entre dos modelos.
% Entradas:
%   modos_cond_u - Matriz de formas modales del modelo sin daño
%   modos_cond_d  - Matriz de formas modales del modelo con daño
%
% Salidas:
%   DI1_COMAC         - COMAC entre formas modales
%   DI2_Diff          - Diferencia absoluta entre modos
%   DI3_Div           - División modos_danado / modos_intacto
%   DI4_Diff_Flex     - Diferencia absoluta entre matrices de flexibilidad
%   DI5_Div_Flex      - División F_danada / F_intacta
%   DI6_Perc_Flex     - Porcentaje de diferencia relativa
%   DI7_Zscore_Flex   - Z-score por nodo
%   DI8_Prob_Flex     - Probabilidad asociada al z-score

    %% BLOQUE 1: Índices basados en formas modales

    % 1. COMAC — mide la correlación entre modos. Se transforma a un índice de daño.
    COMAC       = calcCOMAC(modos_cond_u, modos_cond_d);           % COMAC entre vectores modales
    COMAC_sqrt  = computeCOMACSqrt(COMAC);                          % Raíz cuadrada del COMAC para mayor suavidad
    DI1_COMAC   = 1 - COMAC_sqrt;                                   % Transformación a índice de daño
    DI1_COMAC   = normalizeTo01(DI1_COMAC);                         % Normalización entre 0 y 1

    % 2. Diferencia absoluta entre vectores modales (modo a modo)
    DI2_Diff        = abs(modos_cond_u - modos_cond_d);            % Diferencia punto a punto
    Diff_perNode    = unifyDiff(DI2_Diff);                          % Unificación por nodo
    DI2_Diff        = normalizeTo01(Diff_perNode);                  % Normalización

    % 3. División entre vectores modales — se mide desviación relativa
    ratio       = modos_cond_d ./ modos_cond_u;                    % Cociente modo dañado / intacto
    Div_perNode = unifyDiff(ratio);                                % Unificación por nodo (opcional)
    DI3_Div     = abs(ratio - 1);                                  % Desviación respecto a 1
    DI3_Div     = unifyDiff(DI3_Div);                              % Unificación por nodo
    DI3_Div     = normalizeTo01(DI3_Div);                          % Normalización

    %% BLOQUE 2: Índices basados en matrices de flexibilidad

    % 4. Diferencia directa entre matrices de flexibilidad (norma de la diagonal)
    F_u = modos_cond_u * diag(1./(Omega_cond_u.^2)) * modos_cond_u';  % Flexibilidad intacta
    F_d = modos_cond_d * diag(1./(Omega_cond_d.^2)) * modos_cond_d';  % Flexibilidad dañada

    DI4_Diff_Flex       = abs(F_d - F_u);                           % Diferencia absoluta matriz a matriz
    diff_diag           = diag(DI4_Diff_Flex);                      % Extrae términos de la diagonal
    DI4_Diff_Flex_node  = unifyDiffVector(diff_diag, 3);            % Agrupa cada 3 DOF por nodo
    DI4_Diff_Flex       = normalizeTo01(DI4_Diff_Flex_node);        % Normalización

    % 5. Cociente de flexibilidad por DOF → agrupado por nodo
    flex_diag_u     = diag(F_u);
    flex_diag_d     = diag(F_d);
    ratio_flex      = flex_diag_d ./ (flex_diag_u + eps);           % Cociente con corrección numérica
    DI_F_Div_raw    = abs(ratio_flex - 1);                           % Índice de daño relativo
    DI_F_Div_node   = unifyDiffVector(DI_F_Div_raw, 3);              % Agrupación por nodo
    DI_F_Div        = normalizeTo01(DI_F_Div_node);
    DI5_Div_Flex    = DI_F_Div;

    % 6. Porcentaje de variación entre flexibilidades
    Perc_flex_raw = 100 * abs(flex_diag_d - flex_diag_u) ./ max(flex_diag_u, eps);
    Perc_flex_node = unifyDiffVector(Perc_flex_raw, 3);
    Perc_flex_node_norm = normalizeTo01(Perc_flex_node);
    DI6_Perc_Flex = Perc_flex_node_norm;

    %% BLOQUE 3: Índices estadísticos (z-score y probabilidad)

    % 7. Z-score de las diferencias de flexibilidad por nodo
    diff_flex   = abs(F_d - F_u);                                   % Diferencia absoluta entre matrices
    diff_diag   = diag(diff_flex);                                  % Diagonal
    flex_unify  = unifyDiffVector(diff_diag, 3);                    % Agrupación por nodo
    mu_flex     = mean(flex_unify);                                 % Media
    sigma_flex  = std(flex_unify);                                  % Desviación estándar
    Z_flex      = (flex_unify - mu_flex) / sigma_flex;              % Z-score estandarizado
    DI7_Zscore_Flex = Z_flex;

    % 8. Probabilidad asociada al z-score (bilateral)
    absZ = abs(Z_flex);
    p_flex = 2 * (1 - myNormcdf(absZ));                             % Probabilidad bilateral
    p_flex_norm = normalizeTo01(Perc_flex_node);                    % Se reutiliza DI6 para normalización
    DI8_Prob_Flex = p_flex_norm;
end
