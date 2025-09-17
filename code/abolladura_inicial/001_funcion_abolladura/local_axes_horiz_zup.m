function R = local_axes_horiz_zup(pa, pb)
    %LOCAL_AXES_HORIZ_ZUP  Base local con z' vertical, x' a lo largo del elemento.
    % pa, pb: [1x3] o [3x1] puntos de los nodos a (fijo) y b (libre) en GLOBAL.
    pa = pa(:); pb = pb(:);
    ez = [0;0;1];                 % z' vertical global
    ex = pb - pa;                 % dirección global del elemento
    % Proyecta ex en el plano horizontal (si hay pequeño desnivel numérico)
    ex = ex - (ex.'*ez)*ez;       
    L  = norm(ex);  assert(L>0,'Elemento casi vertical o nodos coinciden.');
    ex = ex / L;                  % x' unitario
    ey = cross(ez, ex);           % y' = z' x x' (sistema derecho)
    R  = [ex ey ez];              % columnas = ejes locales en coords globales
end
