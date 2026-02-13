% === demo_abolladura_driver.m ===
clc; clear; close all
[ke_d, PF, P] = ab_build_element_ke(30, 300, 25, 4000, 1.9995e5, 0.28, 1000, 5, 3e-3);
% Chequeo rápido:
fprintf('Ke simétrica?  ||K-K^T||/||K|| = %.2e\n', norm(ke_d-ke_d.','fro')/norm(ke_d,'fro'));
%%
% Caso voladizo básico (si ya tienes tu solver):
pa=[0 0 0]; pb=[P.L 0 0]; Fb_g=[0;0;1000;0;0;0];
[qb_l, qb_g, ra_l, ra_g] = solve_cantilever_global_loads(ke_d, pa, pb, Fb_g);
disp(qb_g)
