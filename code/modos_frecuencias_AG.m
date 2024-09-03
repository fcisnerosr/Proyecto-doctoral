%% Modos y frecuencias naturales
function [modos_AG_cond,frec_AG] = modos_frecuencias_AG(KG_AG_cond,M_cond)
    [modos_AG_cond, wn2_cond] = eigs(KG_AG_cond,M_cond,3,'sm');
    frec_AG = sort(diag(((wn2_cond)^0.5)/(2*pi)));
end
