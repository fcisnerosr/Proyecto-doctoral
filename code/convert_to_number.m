% Función auxiliar para convertir cualquier entrada en número correctamente
function num = convert_to_number(x)
    if ischar(x)  % Si es string
        num = str2double(x);
    elseif iscell(x) && numel(x) == 1  % Si es un cell anidado con un número dentro
        num = convert_to_number(x{1});  
    else
        num = x;  % Si ya es un número, lo deja igual
    end
end
