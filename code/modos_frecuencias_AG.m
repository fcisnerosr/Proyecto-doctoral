%% Modos y frecuencias naturales
function [modos_AG_cond,frec_AG] = modos_frecuencias_AG(KG_AG_cond,M_cond)
    [modos_AG_cond, wn2_cond] = eigs(KG_AG_cond,M_cond,5,'sm');
    frec_AG = (sort(diag(((wn2_cond)^0.5)/(2*pi)))).^-1;

     % Normalizar modos respecto a la masa
    for i = 1:size(modos_AG_cond, 2)
        norm_factor = sqrt(modos_AG_cond(:,i)' * M_cond * modos_AG_cond(:,i));
        modos_AG_cond(:,i) = modos_AG_cond(:,i) / norm_factor;
    end
end
