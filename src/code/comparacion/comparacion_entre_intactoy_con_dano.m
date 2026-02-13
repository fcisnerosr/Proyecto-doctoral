%% función "Ensamblaje de matrices globales" con dano e intacto
    [KG_damaged, ke]    = ensamblaje_matriz_rigidez_global_con_dano(NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, E, G, vxz, ID, KG, KGtu, ke_d_total, elem_con_dano_long_NE);
    [KG_undamage]       = ensamblaje_matriz_rigidez_global_intacta (NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, E, G, vxz, ID, KG, KGtu);

%% Comparación entre intacta y con daño
    KG_damaged_cond  = condensacion_estatica(KG_damaged);
    KG_undamage_cond = condensacion_estatica(KG_undamage);

%% Modos y frecuencias de estructura condensados y globales
    [modos_undamage_cond, frec_undamage_cond] = modos_frecuencias(KG_undamage_cond, M_cond);
    [modos_damage_cond,   fre_damagec_cond]   = modos_frecuencias(KG_damaged_cond,  M_cond);

%% Graficas sin daño
    graf_formas_modales(modos_undamage_cond, nodes)
%% Graficas con daño
    graf_formas_modales(modos_damage_cond,   nodes)
