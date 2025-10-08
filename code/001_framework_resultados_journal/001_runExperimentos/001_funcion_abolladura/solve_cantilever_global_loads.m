
function [q_b_local, q_b_global, r_a_local, r_a_global] = ...
    solve_cantilever_global_loads(ke_d, pa, pb, Fb_global)
    %SOLVE_CANTILEVER_GLOBAL_LOADS  Nodo a fijo (6 GDL), cargas GLOBAL en nodo b.
    % ke_d     : 12x12 (local) del elemento (orden [u v w rx ry rz] por nodo).
    % pa,pb    : coordenadas globales [x y z] de los nodos a (fijo) y b (libre).
    % Fb_global: 6x1 fuerzas/momentos en GLOBAL aplicadas en nodo b:
    %            [Fx; Fy; Fz; Mx; My; Mz].
    %
    % Devuelve:
    %   q_b_local (6x1)  : despl./rots en b en LOCAL
    %   q_b_global (6x1) : despl./rots en b en GLOBAL
    %   r_a_local (6x1)  : reacciones en a en LOCAL
    %   r_a_global (6x1) : reacciones en a en GLOBAL
    
    arguments
        ke_d (12,12) double
        pa (1,3) double
        pb (1,3) double
        Fb_global (6,1) double
    end
    % --- validaciones
    assert(norm(ke_d-ke_d.','fro') <= 1e-10*norm(ke_d,'fro')+1e-14, 'ke_d no simétrica.');
    % --- transformación global->local
    R  = local_axes_horiz_zup(pa, pb);
    T6 = blkdiag(R.', R.');                 % 6x6 (global -> local)
    Fb_local = T6 * Fb_global;
    
    % --- particiones (a=fijo, b=libre)
    Kff = ke_d(7:12,7:12);                  % nodo b
    Kcf = ke_d(1:6,  7:12);                 % reacciones en a
    
    % --- solución
    q_b_local = Kff \ Fb_local;             % desplazamientos/rotaciones en b (LOCAL)
    r_a_local = Kcf * q_b_local;            % reacciones en a (LOCAL)
    
    % --- pasar a GLOBAL
    T6_inv = blkdiag(R, R);                 % 6x6 (local -> global)
    q_b_global = T6_inv * q_b_local;
    r_a_global = T6_inv * r_a_local;
end

