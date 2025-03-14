% %% Modos y frecuencias naturales
% function [modos_cond,frec_cond] = modos_frecuencias(KG_cond,M_cond)
% % function [modos_cond,frec_cond,modos_glob,frec_glob] = modos_frecuencias(KG_cond,M_cond)
%     %% Matriz condensada
%         % [modos_cond, wn2_cond] = eig(KG_cond,M_cond);
%         % frec_cond = sort(diag(((wn2_cond)^0.5)/(2*pi)));
% 
%     % [modos_cond, wn2_cond] = eigs(KG_cond,M_cond,3,'sm');
%     [modos_cond, wn2_cond] = eigs(KG_cond,M_cond,12,'sm');
%     frec_cond = (sort(diag(((wn2_cond)^0.5)/(2*pi)))).^-1;  % (segundos)
% 
%     % %% Matriz de rigidez completa
%     %     MG = matriz_de_masas_MPaz(D,t);             % Matriz de masa completa
%     %     [modos_glob, wn2_global] = eig(KG,MG);
%     %     frec_glob = diag(((wn2_global)^0.5)/(2*pi))
% 
%     % Normalizar los modos modales con respecto a la matriz de masa
%     modos_cond_norm = modos_cond;  % Pre-allocate the normalized mode shapes array
%     for i = 1:size(modos_cond, 2)
%         % Calcula la norma modal para el i-ésimo modo
%         modal_mass = modos_cond(:, i)' * M_cond * modos_cond(:, i);
%         modos_cond_norm(:, i) = modos_cond(:, i) / sqrt(modal_mass);
%     end
%     modos_cond = modos_cond_norm;
% end



function [modos_cond, frec_cond, Omega_cond] = modos_frecuencias(KG_cond, M_cond)
% modos_frecuencias 
%   Calcula los modos de vibración, periodos y frecuencias en rad/s 
%   a partir de KG_cond y M_cond usando la condensación estática.
%
% Salidas:
%   modos_cond -> Matriz de formas modales condensadas (nDOFs x 12)
%   frec_cond  -> Periodos en segundos (orden ascendente)
%   Omega_cond -> Frecuencias en rad/s (orden ascendente)

    % 1) Obtener valores propios y vectores propios
    [modos_cond, wn2_cond] = eigs(KG_cond, M_cond, 12, 'sm');
    % wn2_cond es diagonal con valores propios ~ (omega^2)
    
    % 2) Extraer las frecuencias en rad/s y ordenarlas
    omega_vals = sqrt(diag(wn2_cond));  % -> rad/s
    [omega_vals_sorted, idx_sort] = sort(omega_vals, 'ascend');
    
    % Reordenar las columnas de modos_cond según idx_sort
    modos_cond = modos_cond(:, idx_sort);
    
    % Guardar la variable Omega_cond (en rad/s)
    Omega_cond = omega_vals_sorted;  
    
    % 3) Calcular periodos en segundos (si lo deseas, similar a tu código)
    %    freq_Hz = Omega_cond / (2*pi);    % frecuencia en Hz
    %    T_cond  = 1 ./ freq_Hz;          % periodo en segundos
    %    frec_cond = sort(T_cond);        % lo ordenamos y lo devolvemos
    
    % O de forma directa, replicando tu idea original:
    %   sqrt(wn2_cond)/(2*pi) -> freq en Hz; luego ^-1 -> period
    %   Aquí lo hacemos paso a paso para mayor claridad:
    freq_Hz  = Omega_cond / (2*pi);  % en Hz
    T_cond   = 1 ./ freq_Hz;        % periodo en seg
    frec_cond = T_cond;             % lo ordenamos y lo devolvemos (ya está sorted)
    
    % 4) Normalizar los modos modales con respecto a la matriz de masa
    modos_cond_norm = modos_cond;
    for i = 1:size(modos_cond, 2)
        modal_mass = modos_cond(:, i)' * M_cond * modos_cond(:, i);
        modos_cond_norm(:, i) = modos_cond(:, i) / sqrt(modal_mass);
    end
    modos_cond = modos_cond_norm;

end