function f = objective_function(alpha, DI, T, threshold)
% objective_function con umbral para evitar falsos positivos.
%
% Entradas:
%   alpha     : vector de 5 pesos (por ejemplo, [alpha1, ..., alpha5])
%   DI        : estructura con los 5 índices de daño ya calculados, con campos:
%               DI.DI2_COMAC, DI.DI2_Diff, DI.DI2_Div, DI.DI4_Diff_Flex, DI.DI5_Div_Flex
%               (cada uno es un escalar, previamente condensado)
%   T         : valor objetivo al que se desea que la combinación ponderada se acerque.
%   threshold : umbral (scalar) para "filtrar" falsos positivos.
%
% Salida:
%   f         : valor de la función objetivo a minimizar

    % Aplicar umbral: si el DI es menor que el umbral, se le asigna 0.
    DI1_COMAC_adj     = max(DI.DI1_COMAC - threshold, 0);
    DI2_Diff_adj      = max(DI.DI2_Diff - threshold, 0);
    DI3_Div_adj       = max(DI.DI3_Div - threshold, 0);
    % DI4_Diff_Flex_adj = max(DI.DI4_Diff_Flex - threshold, 0);
    % DI5_Div_Flex_adj  = max(DI.DI5_Div_Flex - threshold, 0);
    
    % Combinar los DI ajustados usando los pesos alpha
    P = alpha(1)*DI1_COMAC_adj + alpha(2)*DI2_Diff_adj + alpha(3)*DI3_Div_adj;
        % + alpha(4)*DI4_Diff_Flex_adj + ...
        % alpha(5)*DI5_Div_Flex_adj;
    
    % Función objetivo: minimizar la diferencia entre la combinación P y T.
    % f = abs(P - T);
    f = sum((P - T).^2);
end
