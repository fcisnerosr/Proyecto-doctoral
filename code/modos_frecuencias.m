%% Modos y frecuencias naturales
function [modos_cond,frec_cond] = modos_frecuencias(KG_cond,M_cond)
% function [modos_cond,frec_cond,modos_glob,frec_glob] = modos_frecuencias(KG_cond,M_cond)
    %% Matriz condensada
        % [modos_cond, wn2_cond] = eig(KG_cond,M_cond);
        % frec_cond = sort(diag(((wn2_cond)^0.5)/(2*pi)));

    [modos_cond, wn2_cond] = eigs(KG_cond,M_cond,3,'sm');
    frec_cond = (sort(diag(((wn2_cond)^0.5)/(2*pi)))).^-1;

    % %% Matriz de rigidez completa
    %     MG = matriz_de_masas_MPaz(D,t);             % Matriz de masa completa
    %     [modos_glob, wn2_global] = eig(KG,MG);
    %     frec_glob = diag(((wn2_global)^0.5)/(2*pi))
end
