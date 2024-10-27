% clc
% clear all
% close all
% % Script para calcular la matriz de rigidez global para un elemento inclinado
% 
% % Datos de ejemplo (propiedades del elemento)
% E = 210e9;  % Módulo de elasticidad en Pa
% A = 0.01;   % Área transversal en m^2
% L = 5;      % Longitud en metros
% Iz = 8.33e-6;  % Momento de inercia alrededor de Z en m^4
% Iy = 5e-6;  % Momento de inercia alrededor de Y en m^4
% G = 80e9;   % Módulo de corte en Pa
% J = 1e-4;   % Momento polar en m^4
% 
% % Cosenos directores (direcciones del elemento en el espacio global)
% % CX = 0.5;  CY = 0.8660;  CZ = 0;  % Ejemplo de un elemento inclinado a 45 grados
% CX = 0.5773502691896257;
% CY = CX;
% CZ = CX;
% 
% % Paso 1: Calcular la matriz de transformación
% T = transformation_matrix(CX, CY, CZ)
% 
% simetria_T = T * T'
% 
% % Paso 2: Calcular la matriz de rigidez local
% Ke_local = localkeframe3D(E, A, L, Iz, Iy, G, J);
% Ke_local = (Ke_local + Ke_local') / 2;  % Asegurar la simetría
% 
% % Paso 3: Transformar la matriz de rigidez al sistema global
% Ke_global = transform_to_global(Ke_local, T)
% 
% 
% % Redondear valores muy pequeños para mejorar la simetría visualmente
% Ke_global(abs(Ke_global) < 1e-10) = 0;
% 
% 
% % Mostrar el resultado
% disp('Matriz de Rigidez Global (Ke_global):');
% disp(Ke_global);
% if issymmetric(Ke_global)
%    disp('La matriz es simétrica.');            
% else
%    disp('La matriz no es simétrica.')
% end
% 
% 
% function T = transformation_matrix(CX, CY, CZ)
%     % Normalizar los cosenos directores para evitar acumulación de errores
%     norm_factor = sqrt(CX^2 + CY^2 + CZ^2);
%     CX = CX / norm_factor;
%     CY = CY / norm_factor;
%     CZ = CZ / norm_factor;
% 
%     % Calcular CXY y CXZ
%     CXY = sqrt(CX^2 + CY^2);
%     CXZ = sqrt(CX^2 + CZ^2);
% 
%     % Construir la matriz de rotación gamma
%     gamma = [
%         CX, CY, CZ;
%         -CX*CY/CXY, CXY, -CY*CZ/CXY;
%         -CZ/CXZ, 0, CX/CXZ
%     ];
% 
%     % Construir la matriz de transformación 12x12 utilizando gamma
%     T = blkdiag(gamma, gamma, gamma, gamma);  % Expansión a 12x12
% end
% 
% function ke = localkeframe3D(A,Iy,Iz,J,E,G,L)
% 
%     ke = zeros(12,12);
% 
%     ke(1,1)     = (E*A)/L; 
%     ke(2,2)     = (12*E*Iz)/L^3;
%     ke(3,3)     = (12*E*Iy)/L^3;
%     ke(4,4)     = (G*J)/L;
%     ke(5,5)     = (4*E*Iy)/L;
%     ke(6,6)     = (4*E*Iz)/L;
%     ke(7,7)     = (E*A)/L;
%     ke(8,8)     = (12*E*Iz)/L^3;
%     ke(9,9)     = (12*E*Iy)/L^3;
%     ke(10,10)   = (G*J)/L;
%     ke(11,11)   = (4*E*Iy)/L;
%     ke(12,12)   = (4*E*Iz)/L;
% 
%     ke(7,1)     = -ke(1,1);
%     ke(6,2)     = (6*E*Iz)/L^2;
%     ke(8,2)     = (-12*E*Iz)/L^3;
%     ke(12,2)    = (6*E*Iz)/L^2;
%     ke(5,3)     = -(6*E*Iy)/L^2;
%     ke(9,3)     = (-12*E*Iy)/L^3;
%     ke(11,3)    = (-6*E*Iy)/L^2;
%     ke(10,4)    = (-G*J)/L;
%     ke(9,5)     = (6*E*Iy)/L^2;
%     ke(11,5)    = 2*E*Iy/L;
%     ke(8,6)     = (-6*E*Iz)/L^2;
%     ke(12,6)    = (2*E*Iz)/L;
%     ke(12,8)    = (-6*E*Iz)/L^2;
%     ke(11,9)    = (6*E*Iy)/L^2;    
% 
%     keT = ke';
%     kediag = diag(diag(ke));
% 
%     ke = ke + keT - kediag;
% 
% end
% 
% 
% % Función para transformar la matriz de rigidez local al sistema global
% function Ke_global = transform_to_global(Ke_local, T)
%     % Transformación de la matriz de rigidez local al sistema global
%     Ke_global = T' * Ke_local * T;
% end

clc
clear all
close all

% Propiedades del elemento
E = 210e9;  % Módulo de elasticidad en Pa
A = 0.01;   % Área transversal en m^2
L = 5;      % Longitud en metros
Iz = 8.33e-6;  % Momento de inercia alrededor de Z en m^4
Iy = 5e-6;  % Momento de inercia alrededor de Y en m^4
G = 80e9;   % Módulo de corte en Pa
J = 1e-4;   % Momento polar en m^4

% Cosenos directores
CX = 1/(3^0.5)
CY = CX;
CZ = CX;

% Paso 1: Calcular la matriz de transformación
T = transformation_matrix(CX, CY, CZ);

% % Asegurar la ortogonalidad de T
% T(abs(T) < 1e-10) = 0;

% Comprobación de simetría
simetria_T = T * T'

% Paso 2: Calcular la matriz de rigidez local
Ke_local = localkeframe3D(E, A, L, Iz, Iy, G, J);
% Ke_local = (Ke_local + Ke_local') / 2;

% Paso 3: Transformar la matriz de rigidez al sistema global
Ke_global = transform_to_global(Ke_local, T);

% % Redondear valores pequeños en Ke_global
% Ke_global(abs(Ke_global) < 1e-10) = 0;

% Mostrar el resultado
disp('Matriz de Rigidez Global (Ke_global):');
disp(Ke_global);
if issymmetric(Ke_global)
   disp('La matriz es simétrica.');            
else
   disp('La matriz no es simétrica.')
end


function T = transformation_matrix(CX, CY, CZ)
    % Normalización de cosenos directores
    norm_factor = sqrt(CX^2 + CY^2 + CZ^2);
    CX = CX / norm_factor;
    CY = CY / norm_factor;
    CZ = CZ / norm_factor;

    % Calcular CXY y CXZ
    CXY = sqrt(CX^2 + CY^2);
    CXZ = sqrt(CX^2 + CZ^2);

    % Construir la matriz de rotación gamma
    gamma = [
        CX, CY, CZ;
        -CX*CY/CXY, CXY, -CY*CZ/CXY;
        -CZ/CXZ, 0, CX/CXZ
    ];

    % Expansión a 12x12
    T = blkdiag(gamma, gamma, gamma, gamma);
end

function ke = localkeframe3D(A,Iy,Iz,J,E,G,L)
    ke = zeros(12,12);
    
    ke(1,1)     = (E*A)/L; 
    ke(2,2)     = (12*E*Iz)/L^3;
    ke(3,3)     = (12*E*Iy)/L^3;
    ke(4,4)     = (G*J)/L;
    ke(5,5)     = (4*E*Iy)/L;
    ke(6,6)     = (4*E*Iz)/L;
    ke(7,7)     = (E*A)/L;
    ke(8,8)     = (12*E*Iz)/L^3;
    ke(9,9)     = (12*E*Iy)/L^3;
    ke(10,10)   = (G*J)/L;
    ke(11,11)   = (4*E*Iy)/L;
    ke(12,12)   = (4*E*Iz)/L;
    
    ke(7,1)     = -ke(1,1);
    ke(6,2)     = (6*E*Iz)/L^2;
    ke(8,2)     = (-12*E*Iz)/L^3;
    ke(12,2)    = (6*E*Iz)/L^2;
    ke(5,3)     = -(6*E*Iy)/L^2;
    ke(9,3)     = (-12*E*Iy)/L^3;
    ke(11,3)    = (-6*E*Iy)/L^2;
    ke(10,4)    = (-G*J)/L;
    ke(9,5)     = (6*E*Iy)/L^2;
    ke(11,5)    = 2*E*Iy/L;
    ke(8,6)     = (-6*E*Iz)/L^2;
    ke(12,6)    = (2*E*Iz)/L;
    ke(12,8)    = (-6*E*Iz)/L^2;
    ke(11,9)    = (6*E*Iy)/L^2;    
    
    % Asegurar la simetría de la matriz local
    keT = ke';
    kediag = diag(diag(ke));
    
    ke = ke + keT - kediag;
end

function Ke_global = transform_to_global(Ke_local, T)
    Ke_global = T' * Ke_local * T;
end


