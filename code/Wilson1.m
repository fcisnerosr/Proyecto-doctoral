
function [u,v,ac,u00,v00,ac00]=Wilson1(dt,TDuration,Ma,x,fi,forcet,omega,u00,v00)

%High Order recursive algorithm for
%solution of Modal Equation
%Program made by Rolando Salgado 
%Ph D Student of the University of Minho
%Campus Azurém, Guimarães, Portugal.


%0.	NORMALIZED VECTORS

CI=x'*Ma*x;
C=diag(CI).^(-0.5);
xn=x*diag(C);

% I.	LOAD

forcet=xn'*forcet';

% modal initial conditions
u0=x'*u00';
v0=x'*v00';


%I.	INITIAL CALCULATIONS

nmodes=length(omega);

for i=1:nmodes
   
   wd=omega(i)*(1-fi^2)^0.5;
   wp=omega(i)*fi;
   fip=fi/(1-fi^2)^0.5;
   a0=2*fi*omega(i);
   a1=wd^2-wp^2;
   a2=2*wp*wd;
   
   %I.1	Load
   R=forcet(i,:);
   [Rmodes,Rtime]=size(R);
   R0=zeros(Rmodes,3);
   R=[R,R0];
   
   Sdt=exp(-fi*omega(i)*dt)*sin(wd*dt);
   Cdt=exp(-fi*omega(i)*dt)*cos(wd*dt);
   Spdt=-wp*Sdt+wd*Cdt;
   Cpdt=-wp*Cdt-wd*Sdt;
   S2pdt=-a1*Sdt-a2*Cdt;
   C2pdt=-a1*Cdt+a2*Sdt;
   
   Bdt=[Sdt Cdt 1 dt dt^2 dt^3; Spdt Cpdt 0 1 2*dt 3*dt^2; S2pdt C2pdt 0 0 2 6*dt];
   
   IC=[wd -wp 0 1 0 0; 0 1 1 0 0 0; 0 0 omega(i)^2 a0 2 0; 0 0 0 omega(i)^2 2*a0 6; 0 0 0 0 2*omega(i)^2 6*a0; 0 0 0 0 0 6*omega(i)^2];
   
   C=IC^-1;
   
   A=Bdt*C;
   
   %Initial conditions
   
   %n1=floor(Ti/dt)+1;
   n1=0+1;
   %n2=floor((Tf-Ti)/dt)+n1-1;
   n2=floor(TDuration/dt)+n1-1;
   
   %if Ti==0
    %  y=zeros(3,1);
    y(1,1)=u0(i);
    y(2,1)=v0(i);
      y(3,1)=R(1)-2*fi*omega(i)*v0(i)-omega(i)^2*u0(i);
      %   yp=zeros(nmodes,1);
% else
%    y(1,1)=u00(i);
%    y(2,1)=v00(i);
%    y(3,1)=ac00(i);
%    end
   
   %III. RECURSIVE SOLUTION
   
   
   for t=n1:n2
      
      Rp(t)=(R(t+1)-R(t))/dt;
      Rp(t+1)=(R(t+2)-R(t+1))/dt;
      Rp(t+2)=(R(t+3)-R(t+2))/dt;
      %R2p(t)=6/dt^2*(R(t)-R(t+1))+2/dt*(Rp(t+1)+2*Rp(t));
      R2p(t)=0;
      %R2p(t+1)=6/dt^2*(R(t+1)-R(t+2))+2/dt*(Rp(t+2)+2*Rp(t+1));
      R2p(t+1)=0;
      %R3p(t)=(R2p(t+1)-R2p(t))/dt;
      R3p(t)=0;
      Rt=[y(2,t-n1+1); y(1,t-n1+1); R(t); Rp(t); R2p(t); R3p(t)];
      
      y(:,t+1-n1+1)=A*Rt;
      
   end
   
   yu(i,:)=y(1,:);
   yup(i,:)=y(2,:);
   yu2p(i,:)=y(3,:);
   
end

%IV. NEXT INITIAL CONDITIONS

u00=yu(:,t+2-n1);
v00=yup(:,t+2-n1);
ac00=yu2p(:,t+2-n1);


%V. FINAL DYNAMIC RESPONSE
   
   u=xn*yu;   
   v=xn*yup;
   ac=xn*yu2p;
   
   
      
      
      
      
      
   
   
   