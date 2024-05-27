%********PROGRAM FOR OBTAINING THE DYNAMIC RESPONSE OF
%********OF CRACKED BEAM STRUCTURES USING THE ZHENG'S
%********PROCEDURE. MADE BY ROLANDO SALGADO ESTRADA
%********PROFESSOR AT UNIVERSITY OF VERACRUZ
%********LAST MODIFICATION: 21st OF JUNE OF 2013
%********last version 25th November 2020


function ke=ZhengcircT(Lp,xdc,A,Iz,Iy,J,E,i,depthc,G)
      
%load SecCol;  
%load SecBeam;

Cv=zeros(6,6);


% radio from area
radioi=sqrt(2*Iy/A-A/(2*pi));
radioe=sqrt((A+pi*radioi^2)/pi);
diame=2*radioe;
diami=2*radioi;
b=diame;
h=diame;
tesp=radioe-radioi;    %thickness of the tubular circular section

%*****crack properties******
%ce=i;    %Cracked elements
at=depthc; %depth of the crack
Lc=Lp-xdc; % distance from the j node

s=sym('s'); 
pshi=s*diame; %symbolic value of a (pshi=x is the local variable)
phi_1=at/diame;  % normalized cracked depth 

%betam=3.3*x^4-15*x^3+21*x^2-12*x+3.8;
% not information is available for sections different than rectangular
 betam=1; %correction factor moment;
 betas=1; %correction factor shearing;
 betat=1; %correction factor torsion; 
 betan=1; %correction factor axial; 
 

%******shear factor******
shi=0.9-0.4*radioi/radioe;  % consult sap2000 references for other cross sections

%******material properties****
mu=E/(2*G)-1;    %Poisson Modulus with elastic modulus relationship

%******geometric properties
% Damaged Area
%if at<=tesp
ymt=pshi;
yct=radioe-ymt;
xct=sqrt(radioe^2-yct^2);
thetat=2*atan(xct/yct);
Atrt=xct*yct;
Asct=thetat/2*radioe^2;
Ac1t=Asct-Atrt;

%Ac1=b*pshi;    % crack width =b rectangular cross section 
Act=A-Ac1t;   % net area

%********Centroid of the cracked section

x_cgt=0;   % averall cross section (verificar)
ysct=2*radioe*sin(thetat/2)/(3*thetat/2);
ytrt=2/3*yct;
x_cdt=(ysct*Asct-ytrt*Atrt)/Ac1t;
x_ct=(x_cgt*A-x_cdt*Ac1t)/Act;
%x_c=(h+pshi)/2; % net area 
d1t=abs(x_cgt-x_ct); % change of centroid for axial force

%Inertia and properties with damage***************

Iscmt=(thetat+sin(thetat))*radioe^4/8;
Iscct=Iscmt-Asct*ysct^2;
Isct=Iscct+Asct*(ysct-x_cdt)^2;

Itrmt=2*xct*yct^3/4;
Itrct=2*xct*yct^3/36;
Itrt=Itrct+Atrt*(ytrt-x_cdt)^2;

Idamageyct=Isct-Itrt;
Idamageyt=Idamageyct+Ac1t*(x_cdt-x_ct)^2;
Iymt=Iy+A*((x_cgt-x_ct)^2);
Icyt=Iymt-Idamageyt;

%Torsional constant with damage*****************

Rdamt=sqrt(Ac1t/pi);
Jc1t=pi/2*Rdamt^4;
Jct=J-Jc1t;


%ratio=max(h-depthc,b)/min(h-depthc,b);
%k1=1/3*(1-0.63/ratio);

% if b>=h-depthc
% Jc=k1*(h-pshi)^3*b; 
% else
% Jc=k1*(h-pshi)*b^3;   
% end

%*********Second moment of inertia and direction (vertical y)

Izsct=(thetat+sin(thetat))*radioe^4/8;
Iztrt=(2*xct)^3*yct/48;
Idamagezt=Izsct-Iztrt;
Iczt=Iz-Idamagezt;

% Idamagez=(pshi*b^3)/12;
% Icz=Iz-Idamagez;
%else
    
ym=pshi;
yce=radioe-ym;
yci=yce;

xce=sqrt(radioe^2-yce^2);
xci=sqrt(radioi^2-yci^2);

thetae=2*atan(xce/yce);
thetai=2*atan(xci/yci);

Atre=xce*yce;
Atri=xci*yci;

Asce=thetae/2*radioe^2;
Asci=thetai/2*radioi^2;

Ace1=Asce-Atre;
Aci1=Asci-Atri;

Ac1=Ace1-Aci1;

Ac=A-Ac1;   % net area

    
%********Centroid of the cracked section

x_cg=0;   % averall cross section (verificar)
ysce=2*radioe*sin(thetae/2)/(3*thetae/2);
ytre=2/3*yce;
ysci=2*radioi*sin(thetai/2)/(3*thetai/2);
ytri=2/3*yci;
x_cd=(ysce*Asce-ytre*Atre-(ysci*Asci-ytri*Atri))/Ac1;
x_c=(x_cg*A-x_cd*Ac1)/Ac;
d1=abs(x_cg-x_c); % change of centroid for axial force    
    

%Inertia and properties with damage***************

Iscme=(thetae+sin(thetae))*radioe^4/8;
Iscce=Iscme-Asce*ysce^2;
Isce=Iscce+Asce*(ysce-x_cd)^2;

Itrce=2*xce*yce^3/36;
Itre=Itrce+Atre*(ytre-x_cd)^2;


Iscmi=(thetai+sin(thetai))*radioi^4/8;
Iscci=Iscmi-Asci*ysci^2;
Isci=Iscci+Asci*(ysci-x_cd)^2;

Itrci=2*xci*yci^3/36;
Itri=Itrci+Atri*(ytri-x_cd)^2;

Idamageyc=Isce-Itre-(Isci-Itri);
Idamagey=Idamageyc+Ac1*(x_cd-x_c)^2;
Iym=Iy+A*((x_cg-x_c)^2);
Icy=Iym-Idamagey;
    

%Torsional constant with damage*****************
s=phi_1;
%Ac1e=subs(Ac1);
%Ac1m=eval(Ac1e);
Rdame=(Ac1/pi+tesp^2)/(2*tesp);
Rdam=sqrt(Ac1/pi);
if real(eval(Rdame))<tesp
Jc1=pi/2*Rdam^4;
else
    Rdami=Rdame-tesp;
    Jc1=pi/2*(Rdame^4-Rdami^4);
end

Jc=J-Jc1;

%*********Second moment of inertia and direction (vertical y)

Izsce=(thetae+sin(thetae))*radioe^4/8;
Iztre=(2*xce)^3*yce/48;
Izsci=(thetai+sin(thetai))*radioi^4/8;
Iztri=(2*xci)^3*yci/48;

Idamagez=Izsce-Iztre-(Izsci-Iztri);
Icz=Iz-Idamagez;

%end

%*********************************************************
 K=zeros(12,12);

 %N=1:length(ce);
 
%******Stress Intensity Factors********

raizAt=sqrt(betan/(b*A)*(A/Act-1));
raizMzt=sqrt(betam/(h*Iz)*(Iz/Iczt-1));
raizMyt=sqrt(betam/(b*Iy)*(Iy/Icyt-1));
raizVyt=sqrt(shi*2*(1+mu)*betas/(A*h)*(A/Act-1));
raizVzt=sqrt(shi*2*(1+mu)*betas/(A*b)*(A/Act-1));
raizTt=sqrt(betat/(b*J)*(J/Jct-1));


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


KINpt=P1*raizAt+P1*d1t*raizMyt;
KIMSpyt=P2*Lc*raizMyt;
KIMSpzt=P3*Lc*raizMzt;
KIMpyt=P5*raizMyt;
KIMpzt=P6*raizMzt;
KIISpyt=P2*raizVyt;
KIISpzt=P3*raizVzt;
KIIITpxt=P4*raizTt;


KINp=P1*raizA+P1*d1*raizMy;
KIMSpy=P2*Lc*raizMy;
KIMSpz=P3*Lc*raizMz;
KIMpy=P5*raizMy;
KIMpz=P6*raizMz;
KIISpy=P2*raizVy;
KIISpz=P3*raizVz;
KIIITpx=P4*raizT;

ELEt=1/E*((KINpt+KIMSpzt+KIMSpyt+KIMpzt+KIMpyt)^2+(KIISpyt+KIISpzt)^2+...
    (1+mu)*KIIITpxt^2);

ELE=1/E*((KINp+KIMSpz+KIMSpy+KIMpz+KIMpy)^2+(KIISpy+KIISpz)^2+...
    (1+mu)*KIIITpx^2);


G11t=diff(ELEt,P1,2);
G12t=diff(diff(ELEt,P1),P2);
G13t=diff(diff(ELEt,P1),P3);
G14t=diff(diff(ELEt,P1),P4);
G15t=diff(diff(ELEt,P1),P5);
G16t=diff(diff(ELEt,P1),P6);
G21t=G12t;
G22t=diff(ELEt,P2,2);
G23t=diff(diff(ELEt,P2),P3);
G24t=diff(diff(ELEt,P2),P4);
G25t=diff(diff(ELEt,P2),P5);
G26t=diff(diff(ELEt,P2),P6);
G31t=G13t;
G32t=G23t;
G33t=diff(ELEt,P3,2);
G34t=diff(diff(ELEt,P3),P4);
G35t=diff(diff(ELEt,P3),P5);
G36t=diff(diff(ELEt,P3),P6);
G41t=G14t;
G42t=G24t;
G43t=G34t;
G44t=diff(ELEt,P4,2);
G45t=diff(diff(ELEt,P4),P5);
G46t=diff(diff(ELEt,P4),P6);
G51t=G15t;
G52t=G25t;
G53t=G35t;
G54t=G45t;
G55t=diff(ELEt,P5,2);
G56t=diff(diff(ELEt,P5),P6);
G61t=G16t;
G62t=G26t;
G63t=G36t;
G64t=G46t;
G65t=G56t;
G66t=diff(ELEt,P6,2);


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

 if G11==0; c(1,1)=0; elseif phi_1<=tesp/diame; c(1,1)=b*h*integral(matlabFunction(G11t),1e-10,tesp/diame); else c(1,1)=b*h*integral(matlabFunction(G11t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G11),tesp/diame,phi_1); end
 if G12==0; c(1,2)=0; elseif phi_1<=tesp/diame; c(1,2)=b*h*integral(matlabFunction(G12t),1e-10,tesp/diame); else c(1,2)=b*h*integral(matlabFunction(G12t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G12),tesp/diame,phi_1); end
 if G13==0; c(1,3)=0; elseif phi_1<=tesp/diame; c(1,3)=b*h*integral(matlabFunction(G13t),1e-10,tesp/diame); else c(1,3)=b*h*integral(matlabFunction(G13t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G13),tesp/diame,phi_1); end
 if G14==0; c(1,4)=0; elseif phi_1<=tesp/diame; c(1,4)=b*h*integral(matlabFunction(G14t),1e-10,tesp/diame); else c(1,4)=b*h*integral(matlabFunction(G14t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G14),tesp/diame,phi_1); end
 if G15==0; c(1,5)=0; elseif phi_1<=tesp/diame; c(1,5)=b*h*integral(matlabFunction(G15t),1e-10,tesp/diame); else c(1,5)=b*h*integral(matlabFunction(G15t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G15),tesp/diame,phi_1); end
 if G16==0; c(1,6)=0; elseif phi_1<=tesp/diame; c(1,6)=b*h*integral(matlabFunction(G16t),1e-10,tesp/diame); else c(1,6)=b*h*integral(matlabFunction(G16t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G16),tesp/diame,phi_1); end
 if G22==0; c(2,2)=0; elseif phi_1<=tesp/diame; c(2,2)=b*h*integral(matlabFunction(G22t),1e-10,tesp/diame); else c(2,2)=b*h*integral(matlabFunction(G22t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G22),tesp/diame,phi_1); end
 if G23==0; c(2,3)=0; elseif phi_1<=tesp/diame; c(2,3)=b*h*integral(matlabFunction(G23t),1e-10,tesp/diame); else c(2,3)=b*h*integral(matlabFunction(G23t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G23),tesp/diame,phi_1); end
 if G24==0; c(2,4)=0; elseif phi_1<=tesp/diame; c(2,4)=b*h*integral(matlabFunction(G24t),1e-10,tesp/diame); else c(2,4)=b*h*integral(matlabFunction(G24t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G24),tesp/diame,phi_1); end
 if G25==0; c(2,5)=0; elseif phi_1<=tesp/diame; c(2,5)=b*h*integral(matlabFunction(G25t),1e-10,tesp/diame); else c(2,5)=b*h*integral(matlabFunction(G25t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G25),tesp/diame,phi_1); end
 if G26==0; c(2,6)=0; elseif phi_1<=tesp/diame; c(2,6)=b*h*integral(matlabFunction(G26t),1e-10,tesp/diame); else c(2,6)=b*h*integral(matlabFunction(G26t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G26),tesp/diame,phi_1); end
 if G33==0; c(3,3)=0; elseif phi_1<=tesp/diame; c(3,3)=b*h*integral(matlabFunction(G33t),1e-10,tesp/diame); else c(3,3)=b*h*integral(matlabFunction(G33t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G33),tesp/diame,phi_1); end
 if G34==0; c(3,4)=0; elseif phi_1<=tesp/diame; c(3,4)=b*h*integral(matlabFunction(G34t),1e-10,tesp/diame); else c(3,4)=b*h*integral(matlabFunction(G34t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G34),tesp/diame,phi_1); end
 if G35==0; c(3,5)=0; elseif phi_1<=tesp/diame; c(3,5)=b*h*integral(matlabFunction(G35t),1e-10,tesp/diame); else c(3,5)=b*h*integral(matlabFunction(G35t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G35),tesp/diame,phi_1); end
 if G36==0; c(3,6)=0; elseif phi_1<=tesp/diame; c(3,6)=b*h*integral(matlabFunction(G36t),1e-10,tesp/diame); else c(3,6)=b*h*integral(matlabFunction(G36t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G36),tesp/diame,phi_1); end
 if G44==0; c(4,4)=0; elseif phi_1<=tesp/diame; c(4,4)=b*h*integral(matlabFunction(G44t),1e-10,tesp/diame); else c(4,4)=b*h*integral(matlabFunction(G44t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G44),tesp/diame,phi_1); end
 if G45==0; c(4,5)=0; elseif phi_1<=tesp/diame; c(4,5)=b*h*integral(matlabFunction(G45t),1e-10,tesp/diame); else c(4,5)=b*h*integral(matlabFunction(G45t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G45),tesp/diame,phi_1); end
 if G46==0; c(4,6)=0; elseif phi_1<=tesp/diame; c(4,6)=b*h*integral(matlabFunction(G46t),1e-10,tesp/diame); else c(4,6)=b*h*integral(matlabFunction(G46t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G46),tesp/diame,phi_1); end
 if G55==0; c(5,5)=0; elseif phi_1<=tesp/diame; c(5,5)=b*h*integral(matlabFunction(G55t),1e-10,tesp/diame); else c(5,5)=b*h*integral(matlabFunction(G55t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G55),tesp/diame,phi_1); end
 if G56==0; c(5,6)=0; elseif phi_1<=tesp/diame; c(5,6)=b*h*integral(matlabFunction(G56t),1e-10,tesp/diame); else c(5,6)=b*h*integral(matlabFunction(G56t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G56),tesp/diame,phi_1); end
 if G66==0; c(6,6)=0; elseif phi_1<=tesp/diame; c(6,6)=b*h*integral(matlabFunction(G66t),1e-10,tesp/diame); else c(6,6)=b*h*integral(matlabFunction(G66t),1e-10,tesp/diame)+b*h*integral(matlabFunction(G66),tesp/diame,phi_1); end

 
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

