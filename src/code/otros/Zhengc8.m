%********PROGRAM FOR OBTAINING THE DYNAMIC RESPONSE OF
%********OF CRACKED BEAM STRUCTURES USING THE ZHENG'S
%********PROCEDURE. MADE BY ROLANDO SALGADO ESTRADA
%********PROFESSOR AT UNIVERSITY OF VERACRUZ
%********LAST MODIFICATION: 21st OF JUNE OF 2013
%********last version 25th November 2020


function ke=Zhengc9(Lp,xdc,A,Iz,Iy,J,E,i,depthc,G,h,b)
      
%load SecCol;  
%load SecBeam;

Cv=zeros(6,6);


%*****crack properties******
%ce=i;    %Cracked elements
at=depthc; %depth of the crack
Lc=Lp-xdc; % distance from the j node

s=sym('s'); 
pshi=s*h; %symbolic value of a (pshi=x is the local variable)
phi_1=at/h;  % normalized cracked depth 

betam=3.3*x^4-15*x^3+21*x^2-12*x+3.8;
% not information is available for sections different than rectangular
 %betam=2; %correction factor moment;
 betas=1; %correction factor shearing;
 betat=1; %correction factor torsion; 
 betan=1; %correction factor axial; 


%******shear factor******
shi=6/5;  % consult sap2000 references for other cross sections

%******material properties****
mu=E/(2*G)-1;    %Poisson Modulus with elastic modulus relationship

%******geometric properties
% Damaged Area

Ac1=b*pshi;    % crack width =b rectangular cross section 
Ac=A-Ac1;   % net area

%********Centroid of the cracked section

x_cg=h/2;   % averall cross section
x_cdam=h-pshi/2;    % damaged centroid
x_c=(h-pshi)/2; % net centroid
d1=abs(x_cg-x_c); % change of centroid for axial force

%Inertia and properties with damage***************

Idamagey=((b*pshi^3)/12)+(Ac1*((x_c-x_cdam)^2));
Iym=Iy+A*((x_cg-x_c)^2);
Icy=Iym-Idamagey;

%Torsional constant with damage*****************

ratio=max(h-depthc,b)/min(h-depthc,b);
k1=1/3*(1-0.63/ratio);

if b>=h-depthc
Jc=k1*(h-pshi)^3*b; 
else
Jc=k1*(h-pshi)*b^3;   
end

%*********Second moment of inertia and direction (vertical y)

Idamagez=(pshi*b^3)/12;
Icz=Iz-Idamagez;

%*********************************************************
 K=zeros(12,12);

 %N=1:length(ce);
 
%******Stress Intensity Factors********

raizA=sqrt(betan/(b*A)*(A/Ac-1));
raizMz=sqrt(betam/(h*Iz)*(Iz/Icz-1));
raizMy=sqrt(betam/(b*Iy)*(Iy/Icy-1));
raizVy=sqrt(shi*2*(1+mu)*betas/(A*h)*(A/Ac-1));
raizVz=sqrt(shi*2*(1+mu)*betas/(A*b)*(A/Ac-1));
raizT=sqrt(betat/(b*J)*(J/Jc-1));

P1=sym('P1');
P2=sym('P2');
P3=sym('P3');
P4=sym('P4');
P5=sym('P5');
P6=sym('P6');

KINp=P1*raizA+P1*d1*raizMy;
KIMSpy=P2*Lc*raizMy;
KIMSpz=P3*Lc*raizMz;
KIMpy=P5*raizMy;
KIMpz=P6*raizMz;
KIISpy=P2*raizVy;
KIISpz=P3*raizVz;
KIIITpx=P4*raizT;

ELE=1/E*((KINp+KIMSpz+KIMSpy+KIMpz+KIMpy)^2+(KIISpy+KIISpz)^2+...
    (1+mu)*KIIITpx^2);

G11=diff(ELE,P1,2);
G12=diff(diff(ELE,P1),P2);
G13=diff(diff(ELE,P1),P3);
G14=diff(diff(ELE,P1),P4);
G15=diff(diff(ELE,P1),P5);
G16=diff(diff(ELE,P1),P6);
G21=G12;
G22=diff(ELE,P2,2);
G23=diff(diff(ELE,P2),P3);
G24=diff(diff(ELE,P2),P4);
G25=diff(diff(ELE,P2),P5);
G26=diff(diff(ELE,P2),P6);
G31=G13;
G32=G23;
G33=diff(ELE,P3,2);
G34=diff(diff(ELE,P3),P4);
G35=diff(diff(ELE,P3),P5);
G36=diff(diff(ELE,P3),P6);
G41=G14;
G42=G24;
G43=G34;
G44=diff(ELE,P4,2);
G45=diff(diff(ELE,P4),P5);
G46=diff(diff(ELE,P4),P6);
G51=G15;
G52=G25;
G53=G35;
G54=G45;
G55=diff(ELE,P5,2);
G56=diff(diff(ELE,P5),P6);
G61=G16;
G62=G26;
G63=G36;
G64=G46;
G65=G56;
G66=diff(ELE,P6,2);

%*****************************************

%****quadrature integration using Gauss-Lobato Method

 if G11==0; c(1,1)=0; else c(1,1)=b*h*integral(matlabFunction(G11),1e-11,phi_1); end
 if G12==0; c(1,2)=0; else c(1,2)=b*h*integral(matlabFunction(G12),1e-11,phi_1); end
 if G13==0; c(1,3)=0; else c(1,3)=b*h*integral(matlabFunction(G13),1e-11,phi_1); end
 if G14==0; c(1,4)=0; else c(1,4)=b*h*integral(matlabFunction(G14),1e-11,phi_1); end
 if G15==0; c(1,5)=0; else c(1,5)=b*h*integral(matlabFunction(G15),1e-11,phi_1); end
 if G16==0; c(1,6)=0; else c(1,6)=b*h*integral(matlabFunction(G16),1e-11,phi_1); end
 if G22==0; c(2,2)=0; else c(2,2)=b*h*integral(matlabFunction(G22),1e-11,phi_1); end
 if G23==0; c(2,3)=0; else c(2,3)=b*h*integral(matlabFunction(G23),1e-11,phi_1); end
 if G24==0; c(2,4)=0; else c(2,4)=b*h*integral(matlabFunction(G24),1e-11,phi_1); end
 if G25==0; c(2,5)=0; else c(2,5)=b*h*integral(matlabFunction(G25),1e-11,phi_1); end
 if G26==0; c(2,6)=0; else c(2,6)=b*h*integral(matlabFunction(G26),1e-11,phi_1); end   
 if G33==0; c(3,3)=0; else c(3,3)=b*h*integral(matlabFunction(G33),1e-11,phi_1); end
 if G34==0; c(3,4)=0; else c(3,4)=b*h*integral(matlabFunction(G34),1e-11,phi_1); end
 if G35==0; c(3,5)=0; else c(3,5)=b*h*integral(matlabFunction(G35),1e-11,phi_1); end
 if G36==0; c(3,6)=0; else c(3,6)=b*h*integral(matlabFunction(G36),1e-11,phi_1); end
 if G44==0; c(4,4)=0; else c(4,4)=b*h*integral(matlabFunction(G44),1e-11,phi_1); end
 if G45==0; c(4,5)=0; else c(4,5)=b*h*integral(matlabFunction(G45),1e-11,phi_1); end
 if G46==0; c(4,6)=0; else c(4,6)=b*h*integral(matlabFunction(G46),1e-11,phi_1); end
 if G55==0; c(5,5)=0; else c(5,5)=b*h*integral(matlabFunction(G55),1e-11,phi_1); end
 if G56==0; c(5,6)=0; else c(5,6)=b*h*integral(matlabFunction(G56),1e-11,phi_1); end
 if G66==0; c(6,6)=0; else c(6,6)=b*h*integral(matlabFunction(G66),1e-11,phi_1); end

c(2,1)=c(1,2);
c(3,1)=c(1,3);
c(3,2)=c(2,3);
c(4,1)=c(1,4);
c(4,2)=c(2,4);
c(4,3)=c(3,4);
c(5,1)=c(1,5);
c(5,2)=c(2,5);
c(5,3)=c(3,5);
c(5,4)=c(4,5);
c(6,1)=c(1,6);
c(6,2)=c(1,6);
c(6,3)=c(2,6);
c(6,4)=c(4,6);
c(6,5)=c(5,6);

 
         Cdamage=[
              c(1,1)               -c(1,2)                 -c(1,3)             -c(1,4)                 -c(1,5)          -c(1,6);
             -c(2,1)                c(2,2)                 -c(2,3)             -c(2,4)                 -c(2,5)           c(2,6);    
             -c(3,1)               -c(3,2)                  c(3,3)             -c(3,4)                 -c(3,5)          -c(3,6);
             -c(4,1)               -c(4,2)                 -c(4,3)              c(4,4)                 -c(4,5)          -c(4,6);   
             -c(5,1)               -c(5,2)                 -c(5,3)             -c(5,4)                  c(5,5)          -c(5,6); 
             -c(6,1)                c(6,2)                 -c(6,3)             -c(6,4)                 -c(6,5)           c(6,6); 
         ];
  
  
   Cv=Cv+Cdamage;
   clear c;


%****************+++++++++++++++++++++++++++++Undamaged flexibility matrix***************************************************
 

Ccomp=[
   Lp/(E*A)       0                                 0                  0                0                0
   0         Lp^3/(3*E*Iz)                          0                  0                0             Lp^2/(2*E*Iz)    
   0              0                           Lp^3/(3*E*Iy)            0            -Lp^2/(2*E*Iy)       0
   0              0                                 0                Lp/(G*J)           0                0   
   0              0                          -Lp^2/(2*E*Iy)            0             Lp/(E*Iy)           0 
   0          Lp^2/(2*E*Iz)                         0                  0                0             Lp/(E*Iz) 
];

Ctotal=Ccomp+Cv;

T=[
   -1               0               0               0               0               0
    0              -1               0               0               0               0 
    0               0              -1               0               0               0
    0               0               0              -1               0               0
    0               0               Lp              0              -1               0
    0              -Lp              0               0               0              -1
    1               0               0               0               0               0
    0               1               0               0               0               0
    0               0               1               0               0               0
    0               0               0               1               0               0
    0               0               0               0               1               0
    0               0               0               0               0               1
    ];

ke=T*Ctotal^(-1)*T';
    
end

