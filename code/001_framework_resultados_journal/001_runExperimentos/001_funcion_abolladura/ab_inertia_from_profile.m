function [Iy_d, Iz_d, cY, cZ] = ab_inertia_from_profile(P, G)
% AB_INERTIA_FROM_PROFILE  Integra tiras delgadas sobre el contorno y suma la parte achatada.
% Usa método general por segmentos (evita códigos por cuadrante).

Y = G.Y(:); Z = G.Z(:); t = P.t;
% Cierre robusto
if Y(1)~=Y(end) || Z(1)~=Z(end)
    Y(end+1)=Y(1); Z(end+1)=Z(1);
end

dY = diff(Y);  dZ = diff(Z);
Lseg = hypot(dY, dZ);
Ny = (Y(1:end-1)+Y(2:end))/2;
Nz = (Z(1:end-1)+Z(2:end))/2;

% Centroide delgada (ponderado por longitud)
Ltot = sum(Lseg);
cY = sum(Ny.*Lseg)/Ltot;
cZ = sum(Nz.*Lseg)/Ltot;

% Ángulo con el eje y (para rotación de inercias locales)
phi = acos( max(min(abs(dY)./Lseg,1),0) );   % en [0,pi/2]
% Inercias locales de tira (rectángulo L x t)
Iy_loc = (1/12) * Lseg .* (t.^3);
Iz_loc = (1/12) * (Lseg.^3) .* t;

% Rotación a ejes {y,z}: Iy' = (Iy+Iz)/2 ± ((Iy-Iz)/2) cos(2phi)
c2 = cos(2*phi);
Iy_rot = 0.5*(Iy_loc + Iz_loc) + 0.5*(Iy_loc - Iz_loc).*c2;
Iz_rot = 0.5*(Iy_loc + Iz_loc) - 0.5*(Iy_loc - Iz_loc).*c2;

% Teorema ejes paralelos
Ay = t.*Lseg;  % área equivalente de cada tira
dy = (Nz - cZ);   % distancia en Z para Iy
dz = (Ny - cY);   % distancia en Y para Iz

Iy_d = sum(Iy_rot + Ay .* (dy.^2));
Iz_d = sum(Iz_rot + Ay .* (dz.^2));

% Parte achatada (tira recta de longitud G.L_ach en z=zi)
Lach = G.L_ach;  if Lach>0
    Iy_flat = (1/12)*Lach*(t^3);
    Iz_flat = (1/12)*(Lach^3)*t;
    Aflat   = Lach*t;
    dZflat  = (G.zi - cZ);  % distancia al eje y (afecta Iy)
    Iy_d = Iy_d + Iy_flat + Aflat*(dZflat^2);
    Iz_d = Iz_d + Iz_flat;  % distancia en y=0
end
end
