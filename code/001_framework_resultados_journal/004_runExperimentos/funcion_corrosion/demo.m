% Supón 1 elemento corroído 20% en t:
prop_geom_mat_dummy = zeros(5, 20); % al menos columnas 11 y 12
prop_geom_mat_dummy(3,11) = 300;    % D (mm)
prop_geom_mat_dummy(3,12) = 25;     % t (mm)

no_elemento_a_danar = 3;
L_d = 4000;
caso_dano = {'corrosion'};
dano_porcentaje = 20;
E = 1.9995e5; G = E/(2*(1+0.28));

[Ke] = ke_corrosion_uniform_from_prop(no_elemento_a_danar, L_d, dano_porcentaje, prop_geom_mat_dummy, E, G, 11, 12);
fprintf('Simetría: %.2e\n', norm(Ke-Ke.','fro')/norm(Ke,'fro'));  % ~ 0

% SPD/cond
[~,p]=chol(Ke);  assert(p==0,'Ke no SPD');
fprintf('condest(Ke) ~ %.2e\n', condest(Ke));
