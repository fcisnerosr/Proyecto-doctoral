% programa for calculating the local stiffness matrix
% of linear elastic unidimensional elements with a dent
% donde by Rolando Salgado Estrada
% Full-time professor in the Faculty of Engineering of
% the Construction and the Habitat, Universidad Veracruzana
% 1st version 20th January 2021

function ke=localFEM(L,Acr,Izcr,Iycr,Jcr,A,Iz,Iy,J,xj,E,G)


% declare size of the local stiffness matrix
ke=zeros(12,12);

%symbolic variable
x=sym('x');

% Lagrange interpolation functions
Lag1=1-x^(1+1e-6)/L;
Lag2=x^(1+1e-6)/L;

% first derivative of the Lagrange interpolation functions
diffLag1=diff(Lag1,x,1);
diffLag2=diff(Lag2,x,1);

% integrant for the axial stiffness matrix
intk11Aa=E*A*diffLag1^2;
intk11Ab=E*Acr*diffLag1^2;
intk12Aa=E*A*diffLag1*diffLag2;
intk12Ab=E*Acr*diffLag1*diffLag2;
intk22Aa=E*A*diffLag2^2;
intk22Ab=E*Acr*diffLag2^2;

% integrant for the torsional stiffness matrix
intk44Aa=G*J*diffLag1^2;
intk44Ab=G*Jcr*diffLag1^2;
intk1010Aa=G*J*diffLag2^2;
intk1010Ab=G*Jcr*diffLag2^2;
intk104Aa=G*J*diffLag1*diffLag2;
intk104Ab=G*Jcr*diffLag1*diffLag2;

% Hermite interpolation functions
Hermite1=1-3*(x/L)^2+2*(x/L)^3;
Hermite2=-x*(1-x/L)^2;
Hermite3=3*(x/L)^2-2*(x/L)^3;
Hermite4=-x*((x/L)^2-x/L);
Hermitez2=x*(1-x/L)^2;
Hermitez4=x*((x/L)^2-x/L);


% second derivative of the Hermite interpolation functions
diffHermite1=diff(Hermite1,x,2);
diffHermite2=diff(Hermite2,x,2);
diffHermite3=diff(Hermite3,x,2);
diffHermite4=diff(Hermite4,x,2);
diffHermitez2=diff(Hermitez2,x,2);
diffHermitez4=diff(Hermitez4,x,2);

% integrant for the bending stiffness matrix
intk22Ba=E*Iz*diffHermite1^2;
intk22Bb=E*Izcr*diffHermite1^2;
intk33Ba=E*Iy*diffHermite1^2;
intk33Bb=E*Iycr*diffHermite1^2;
intk55Ba=E*Iy*diffHermite2^2;
intk55Bb=E*Iycr*diffHermite2^2;
intk66Ba=E*Iz*diffHermite2^2;
intk66Bb=E*Izcr*diffHermite2^2;
intk88Ba=E*Iz*diffHermite3^2;
intk88Bb=E*Izcr*diffHermite3^2;
intk99Ba=E*Iy*diffHermite3^2;
intk99Bb=E*Iycr*diffHermite3^2;
intk1111Ba=E*Iy*diffHermite4^2;
intk1111Bb=E*Iycr*diffHermite4^2;
intk1212Ba=E*Iz*diffHermite4^2;
intk1212Bb=E*Izcr*diffHermite4^2;

intk62Ba=E*Iz*diffHermitez2*diffHermite1;
intk62Bb=E*Izcr*diffHermitez2*diffHermite1;
intk82Ba=E*Iz*diffHermite3*diffHermite1;
intk82Bb=E*Izcr*diffHermite3*diffHermite1;
intk122Ba=E*Iz*diffHermitez4*diffHermite1;
intk122Bb=E*Izcr*diffHermitez4*diffHermite1;
intk53Ba=E*Iy*diffHermite2*diffHermite1;
intk53Bb=E*Iycr*diffHermite2*diffHermite1;
intk93Ba=E*Iy*diffHermite3*diffHermite1;
intk93Bb=E*Iycr*diffHermite3*diffHermite1;
intk113Ba=E*Iy*diffHermite4*diffHermite1;
intk113Bb=E*Iycr*diffHermite4*diffHermite1;
intk95Ba=E*Iy*diffHermite3*diffHermite2;
intk95Bb=E*Iycr*diffHermite3*diffHermite2;
intk115Ba=E*Iy*diffHermite4*diffHermite2;
intk115Bb=E*Iycr*diffHermite4*diffHermite2;
intk86Ba=E*Iz*diffHermite3*diffHermitez2;
intk86Bb=E*Izcr*diffHermite3*diffHermitez2;
intk126Ba=E*Iz*diffHermitez4*diffHermitez2;
intk126Bb=E*Izcr*diffHermitez4*diffHermitez2;
intk128Ba=E*Iz*diffHermitez4*diffHermite3;
intk128Bb=E*Izcr*diffHermitez4*diffHermite3;
intk119Ba=E*Iy*diffHermite4*diffHermite3;
intk119Bb=E*Iycr*diffHermite4*diffHermite3;

% stiffness matrix components
ke(1,1)=integral(matlabFunction(intk11Aa),1e-10,x1dent)+...
       integral(matlabFunction(intk11Ab),x1dent,x2dent)+...
       integral(matlabFunction(intk11Aa),x2dent,L);
                 
ke(2,2)=integral(matlabFunction(intk22Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk22Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk22Ba),x2dent,L);  
   
ke(3,3)=integral(matlabFunction(intk33Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk33Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk33Ba),x2dent,L);  
   
ke(4,4)=integral(matlabFunction(intk44Aa),1e-10,x1dent)+...
       integral(matlabFunction(intk44Ab),x1dent,x2dent)+...
       integral(matlabFunction(intk44Aa),x2dent,L);
   
ke(5,5)=integral(matlabFunction(intk55Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk55Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk55Ba),x2dent,L);
   
ke(6,6)=integral(matlabFunction(intk66Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk66Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk66Ba),x2dent,L);

ke(7,7)=integral(matlabFunction(intk22Aa),1e-10,x1dent)+...
       integral(matlabFunction(intk22Ab),x1dent,x2dent)+...
       integral(matlabFunction(intk22Aa),x2dent,L);   
   
ke(8,8)=integral(matlabFunction(intk88Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk88Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk88Ba),x2dent,L);
   
ke(9,9)=integral(matlabFunction(intk99Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk99Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk99Ba),x2dent,L); 
   
ke(10,10)=integral(matlabFunction(intk1010Aa),1e-10,x1dent)+...
       integral(matlabFunction(intk1010Ab),x1dent,x2dent)+...
       integral(matlabFunction(intk1010Aa),x2dent,L);   
   
ke(11,11)=integral(matlabFunction(intk1111Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk1111Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk1111Ba),x2dent,L);   
   
ke(12,12)=integral(matlabFunction(intk1212Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk1212Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk1212Ba),x2dent,L);   

ke(7,1)=integral(matlabFunction(intk12Aa),1e-10,x1dent)+...
       integral(matlabFunction(intk12Ab),x1dent,x2dent)+...
       integral(matlabFunction(intk12Aa),x2dent,L);      


ke(6,2)=integral(matlabFunction(intk62Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk62Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk62Ba),x2dent,L);      
   
ke(8,2)=integral(matlabFunction(intk82Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk82Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk82Ba),x2dent,L);   
   
ke(12,2)=integral(matlabFunction(intk122Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk122Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk122Ba),x2dent,L);      
   
ke(5,3)=integral(matlabFunction(intk53Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk53Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk53Ba),x2dent,L);
   
ke(9,3)=integral(matlabFunction(intk93Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk93Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk93Ba),x2dent,L);
   
ke(11,3)=integral(matlabFunction(intk113Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk113Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk113Ba),x2dent,L);
   
ke(10,4)=integral(matlabFunction(intk104Aa),1e-10,x1dent)+...
       integral(matlabFunction(intk104Ab),x1dent,x2dent)+...
       integral(matlabFunction(intk104Aa),x2dent,L);
   
ke(9,5)=integral(matlabFunction(intk95Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk95Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk95Ba),x2dent,L);
   
ke(11,5)=integral(matlabFunction(intk115Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk115Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk115Ba),x2dent,L);
   
ke(8,6)=integral(matlabFunction(intk86Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk86Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk86Ba),x2dent,L);
   
ke(12,6)=integral(matlabFunction(intk126Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk126Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk126Ba),x2dent,L);
   
ke(12,8)=integral(matlabFunction(intk128Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk128Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk128Ba),x2dent,L);
   
ke(11,9)=integral(matlabFunction(intk119Ba),1e-10,x1dent)+...
       integral(matlabFunction(intk119Bb),x1dent,x2dent)+...
       integral(matlabFunction(intk119Ba),x2dent,L);      
      

keT=ke';
kediag=diag(diag(ke));

ke=ke+keT-kediag;
