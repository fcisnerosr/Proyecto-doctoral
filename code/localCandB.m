% programa for calculating the local stiffness matrix
% of linear elastic unidimensional elements with a dent
% donde by Rolando Salgado Estrada
% Full-time professor in the Faculty of Engineering of
% the Construction and the Habitat, Universidad Veracruzana
% 1st version 20th January 2021

function ke=localCandB(L,Acr,Izcr,Iycr,Jcr,A,Iz,Iy,J,xj,E,G,h)

% Christides and Barr method
alphacr=2.256;   %according to results determined by Salgado 2009.

% declare size of the local stiffness matrix
ke=zeros(12,12);

%symbolic variable
x=sym('x');

% Cr factor
CIzcr=Iz/Izcr-1;
CIycr=Iy/Iycr-1;
CAcr=A/Acr-1;
CJcr=J/Jcr-1;

Izcrf=Izcr/(1+CIzcr*exp(-2*alphacr*abs(x-xj)/h));
Iycrf=Iycr/(1+CIycr*exp(-2*alphacr*abs(x-xj)/h));
Jcrf=Jcr/(1+CJcr*exp(-2*alphacr*abs(x-xj)/h));
Acrf=Izcr/(1+CAcr*exp(-2*alphacr*abs(x-xj)/h));

% Lagrange interpolation functions
Lag1=1-x^(1+1e-6)/L;
Lag2=x^(1+1e-6)/L;

% first derivative of the Lagrange interpolation functions
diffLag1=diff(Lag1,x,1);
diffLag2=diff(Lag2,x,1);

% integrant for the axial stiffness matrix
intk11Ab=E*Acrf*diffLag1^2;
intk12Ab=E*Acrf*diffLag1*diffLag2;
intk22Ab=E*Acrf*diffLag2^2;

% integrant for the torsional stiffness matrix
intk44Ab=G*Jcrf*diffLag1^2;
intk1010Ab=G*Jcrf*diffLag2^2;
intk104Ab=G*Jcrf*diffLag1*diffLag2;

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
intk22Bb=E*Izcrf*diffHermite1^2;
intk33Bb=E*Iycrf*diffHermite1^2;
intk55Bb=E*Iycrf*diffHermite2^2;
intk66Bb=E*Izcrf*diffHermite2^2;
intk88Bb=E*Izcrf*diffHermite3^2;
intk99Bb=E*Iycrf*diffHermite3^2;
intk1111Bb=E*Iycrf*diffHermite4^2;
intk1212Bb=E*Izcrf*diffHermite4^2;

intk62Bb=E*Izcrf*diffHermitez2*diffHermite1;
intk82Bb=E*Izcrf*diffHermite3*diffHermite1;
intk122Bb=E*Izcrf*diffHermitez4*diffHermite1;
intk53Bb=E*Iycrf*diffHermite2*diffHermite1;
intk93Bb=E*Iycrf*diffHermite3*diffHermite1;
intk113Bb=E*Iycrf*diffHermite4*diffHermite1;
intk95Bb=E*Iycrf*diffHermite3*diffHermite2;
intk115Bb=E*Iycrf*diffHermite4*diffHermite2;
intk86Bb=E*Izcrf*diffHermite3*diffHermitez2;
intk126Bb=E*Izcrf*diffHermitez4*diffHermitez2;
intk128Bb=E*Izcrf*diffHermitez4*diffHermite3;
intk119Bb=E*Iycrf*diffHermite4*diffHermite3;

% stiffness matrix components
ke(1,1)=integral(matlabFunction(intk11Ab),1e-10,L);
ke(2,2)=integral(matlabFunction(intk22Bb),1e-10,L);  
ke(3,3)=integral(matlabFunction(intk33Bb),1e-10,L);  
ke(4,4)=integral(matlabFunction(intk44Ab),1e-10,L);
ke(5,5)=integral(matlabFunction(intk55Bb),1e-10,L);
ke(6,6)=integral(matlabFunction(intk66Bb),1e-10,L);
ke(7,7)=integral(matlabFunction(intk22Ab),1e-10,L);   
ke(8,8)=integral(matlabFunction(intk88Bb),1e-10,L);
ke(9,9)=integral(matlabFunction(intk99Bb),1e-10,L); 
ke(10,10)=integral(matlabFunction(intk1010Ab),1e-10,L);   
ke(11,11)=integral(matlabFunction(intk1111Bb),1e-10,L);   
ke(12,12)=integral(matlabFunction(intk1212Bb),1e-10,L);   
ke(7,1)=integral(matlabFunction(intk12Ab),1e-10,L);      
ke(6,2)=integral(matlabFunction(intk62Bb),1e-10,L);      
ke(8,2)=integral(matlabFunction(intk82Bb),1e-10,L);   
ke(12,2)=integral(matlabFunction(intk122Bb),1e-10,L);      
ke(5,3)=integral(matlabFunction(intk53Bb),1e-10,L);
ke(9,3)=integral(matlabFunction(intk93Bb),1e-10,L);
ke(11,3)=integral(matlabFunction(intk113Bb),1e-10,L);
ke(10,4)=integral(matlabFunction(intk104Ab),1e-10,L);
ke(9,5)=integral(matlabFunction(intk95Bb),1e-10,L);
ke(11,5)=integral(matlabFunction(intk115Bb),1e-10,L);
ke(8,6)=integral(matlabFunction(intk86Bb),1e-10,L);
ke(12,6)=integral(matlabFunction(intk126Bb),1e-10,L);
ke(12,8)=integral(matlabFunction(intk128Bb),1e-10,L);
ke(11,9)=integral(matlabFunction(intk119Bb),1e-10,L);      
      
keT=ke';
kediag=diag(diag(ke));

ke=ke+keT-kediag;
