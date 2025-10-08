function G = ab_build_dented_profile(P, zi)
% AB_BUILD_DENTED_PROFILE  Contorno (y,z) de sección abollada conservando perímetro.
% Devuelve G.Y, G.Z (Nseg+1), delta y cuerda, z_dent.

N = P.Nseg;
R = P.R; t = P.t; lim = P.lim;
alpha = linspace(0, 2*pi, N+1);
Y0 = R*cos(alpha);  Z0 = R*sin(alpha);

% Inicial: parte no achatada con “barriga” sinusoidal controlada por delta
z_dent = zi + R;                % como en tu script
delta  = 0.0;                   % se actualizará para ajustar el perímetro
Sig    = sign(cos(alpha));      % signo por cuadrante (similar a tu lógica)

% Local: define plantilla
Yd = Y0 + delta.*sin((pi/2)/z_dent*(Z0+R)).*Sig;
Zd = Z0;
% Reemplaza arco superior por tramo plano z=zi
mask_flat = Z0 > zi;
Zd(mask_flat) = zi;

% Longitud objetivo = perímetro intacto
Pintact = 2*pi*R;

% Función para calcular longitud total del contorno abollado
    function Ltot = lenYZ(y,z)
        dy = diff(y); dz = diff(z);
        Ltot = sum( hypot(dy,dz) );
    end

% Ajuste de delta por búsqueda lineal simple (como tu while con lim)
Ltarget = Pintact;
Lcur = lenYZ(Yd,Zd);
step = lim; dir = sign(Lcur - Ltarget);
best = [abs(Lcur-Ltarget), delta];

for it=1:20000
    delta = delta - dir*step;
    Yd = Y0 + delta.*sin((pi/2)/z_dent*(Z0+R)).*Sig;
    Zd = Z0;  Zd(mask_flat) = zi;
    Lcur = lenYZ(Yd,Zd);
    err = Lcur - Ltarget;
    if abs(err) < best(1), best=[abs(err), delta]; end
    if sign(err)~=dir, step = step*0.5; dir = sign(err); end
    if abs(err) < lim, break; end
end
delta = best(2);
Yd = Y0 + delta.*sin((pi/2)/z_dent*(Z0+R)).*Sig;
Zd = Z0;  Zd(mask_flat) = zi;

% Cuerda y longitud achatada
cuerda = 2*sqrt(R^2 - (R - (R-zi))^2);   % ~2*sqrt(R^2 - zi^2) equivalente
% más robusto: intersecciones con z=zi
iz = find(diff(mask_flat)~=0);
if numel(iz)>=2
    y1 = Yd(iz(1)+1); y2 = Yd(iz(2)+1);
    cuerda = abs(y2 - y1);
end
L_ach = cuerda + 2*delta;

G.Y = Yd(:); G.Z = Zd(:);
G.delta = delta; G.cuerda = cuerda; G.L_ach = L_ach; G.zi = zi;
end
