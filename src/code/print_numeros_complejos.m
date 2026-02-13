function numeros_complejos_o_no(matriz,nombre_variable)
    if ~isreal(matriz)
        fprintf('El tensor %s contiene términos complejos.\n',nombre_variable);
    else
        fprintf('El tensor %s no contiene términos complejos.\n',nombre_variable);
    end
end
