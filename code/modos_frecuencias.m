%% Modos y frecuencias naturales
function [modos_cond,frec_cond] = modos_frecuencias(KG_cond,M_cond)
% function [modos_cond,frec_cond,modos_glob,frec_glob] = modos_frecuencias(KG_cond,M_cond)
    %% Matriz condensada
        % [modos_cond, wn2_cond] = eig(KG_cond,M_cond);
        % frec_cond = sort(diag(((wn2_cond)^0.5)/(2*pi)));

    [modos_cond, wn2_cond] = eigs(KG_cond,M_cond,3,'sm');
    frec_cond = (sort(diag(((wn2_cond)^0.5)/(2*pi)))).^-1;  % (segundos)

    % %% Matriz de rigidez completa
    %     MG = matriz_de_masas_MPaz(D,t);             % Matriz de masa completa
    %     [modos_glob, wn2_global] = eig(KG,MG);
    %     frec_glob = diag(((wn2_global)^0.5)/(2*pi))

    % Normalizar los modos modales con respecto a la matriz de masa
    modos_cond_norm = modos_cond;  % Pre-allocate the normalized mode shapes array
    for i = 1:size(modos_cond, 2)
        % Calcula la norma modal para el i-ésimo modo
        modal_mass = modos_cond(:, i)' * M_cond * modos_cond(:, i);
        modos_cond_norm(:, i) = modos_cond(:, i) / sqrt(modal_mass);
    end
    modos_cond = modos_cond_norm;
end
