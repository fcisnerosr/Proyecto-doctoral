function M = coerce_numeric_prop_geom(prop_geom)
% COERCE_NUMERIC_PROP_GEOM  Convierte cell (strings/números) a matriz double.
    if isnumeric(prop_geom), M = prop_geom; return; end
    M = zeros(size(prop_geom));
    for i = 1:size(prop_geom,1)
        for k = 1:size(prop_geom,2)
            v = prop_geom{i,k};
            if ischar(v) || (isstring(v) && isscalar(v))
                M(i,k) = str2double(string(v));
            elseif isnumeric(v) && isscalar(v)
                M(i,k) = v;
            else
                M(i,k) = NaN;
            end
        end
    end
end
