%********PROGRAM FOR OBTAINING THE DYNAMIC RESPONSE OF
%********OF CRACKED BEAM STRUCTURES USING THE ZHENG'S
%********PROCEDURE. MADE BY ROLANDO SALGADO ESTRADA
%********PROFESSOR AT UNIVERSITY OF VERACRUZ
%********LAST MODIFICATION: 21st OF JUNE OF 2013
%********last version 25th November 2020


function ke=ZhengIRv2(Lp,xdc,A,Iz,Iy,J,E,depthc,G,bf,tf,tw,d)
      
Cv=zeros(6,6);

T=d-2*tf;     %heigth of the web

%*****crack properties******
%ce=i;    %Cracked elements
at=depthc; %depth of the crack
Lc=Lp-xdc; % distance from the j node

s=sym('s'); 
pshi=s*d; %symbolic value of a (pshi=x is the local variable)
phi_1=at/d;  % normalized cracked depth 

% not information is available for sections different than rectangular
 betam=1; %correction factor moment;
 betas=1; %correction factor shearing;
 betat=1; %correction factor torsion; 
 betan=1; %correction factor axial; 
 
%******shear factor******
shi=tw*(T-tf);  % consult sap2000 references for other cross sections

%******material properties****
mu=E/(2*G)-1;    %Poisson Modulus with elastic modulus relationship

%******geometric properties

% Damaged Area in the lower flange    
Ac1t=pshi*bf;    %cracked area
Act=A-Ac1t;   % net area


%********Centroid of the cracked section lower flange
x_cgt=d/2;   % averall cross section
x_cdt=pshi/2;
x_ct=(A*x_cgt-Ac1t*x_cdt)/Act;
d1t=abs(x_cgt-x_ct); % change of centroid for axial force

%**************************************************************
%upper flange crack depth
Ac1tf=(pshi-T-tf)*bf+bf*tf+T*tw;   %cracked area
Actf=A-Ac1tf;   % net area

x_cdtf=(bf*tf*tf/2+T*tw*(tf+T/2)+(pshi-tf-T)*bf*(T+tf+(pshi-T-tf)/2))...
       /Ac1tf;
   x_ctf=(A*x_cgt-Ac1tf*x_cdtf)/Actf;
    d1tf=abs(x_cgt-x_ctf); % change of centroid for axial force
%**************************************************************


%Inertia and properties with damage in the lower flange***************
Ifup=1/12*bf*tf^3+bf*tf*(d-1/2*tf-x_cgt)^2;
Iweb=1/12*tw*T^3+T*tw*(tf+T/2-x_cgt)^2;
Ifud=1/12*bf*(tf-pshi)^3+bf*(tf-pshi)*((tf+pshi)/2-x_cgt)^2;
Iyct=Ifup+Iweb+Ifud;
Iymt=Iy;


% cracked til upper flange
Iyctf=1/12*bf*(d-pshi)^3+bf*(d-pshi)*(x_cgt-(d+pshi)/2)^2;
Iymtf=Iy;
%**************************

%Torsional constant with damage in the lower flange*****************
Jct=1/3*bf*tf^3+1/3*T*tw^3+1/3*bf*(tf-pshi)^3;

%till upper flange
Jctf=1/3*bf*(d-pshi)^3;
%******************

%*********Second moment of inertia and direction (vertical z)
% in the lower flange
Iczt=1/12*tf*bf^3+1/12*tw^3*T+1/12*(tf-pshi)*bf^3;

%til upper flange
Icztf=1/12*bf^3*(d-pshi);
%*****************************************


% in the web*****************************
Ac1d=(pshi-tf)*tw+tf*bf;    %cracked area
Ac1=A-Ac1d;   % net area

    
%********Centroid of the cracked section with crack in the web
x_cg1=d/2;   % averall cross section
x_cd1=(bf*tf*tf/2+(pshi-tf)*tw*(pshi+tf)/2)/Ac1d;
x_c1=(A*x_cg1-Ac1d*x_cd1)/Ac1;
d1=abs(x_cg1-x_c1); % change of centroid for axial force


%Inertia and properties with damage with crack in the web***************
Ifup1=1/12*bf*tf^3+bf*tf*(d-1/2*tf-x_cgt)^2;
Iweb1=1/12*tw*(T-pshi+tf)^3+(T-pshi+tf)*tw*(pshi+(T-pshi+tf)/2-x_cgt)^2;
Iyc1=Ifup1+Iweb1;
Iymt1=Iy;

%Torsional constant with damage with crack in the web*****************
Jc1=1/3*bf*tf^3+1/3*tw^3*(T-pshi+tf);

%*********Second moment of inertia and direction in the web (vertical z)
Icz1=1/12*tf*bf^3+1/12*tw^3*(T-pshi+tf);

%*********************************************************
 K=zeros(12,12);   % initiate stiffness matrix

 %N=1:length(ce);
 
%******Stress Intensity Factors********
% in the lower flange
raizAt=sqrt(betan/(bf*A)*(A/Act-1));
raizMzt=sqrt(betam/(tf*Iz)*(Iz/Iczt-1));
raizMyt=sqrt(betam/(bf*Iy)*(Iymt/Iyct-1));
%raizMytn=sqrt(betam/(bf*Iy)*(Iy/Icyt-1));
raizVyt=sqrt(shi*2*(1+mu)*betas/(A*tf)*(A/Act-1));
raizVzt=sqrt(shi*2*(1+mu)*betas/(A*bf)*(A/Act-1));
raizTt=sqrt(betat/(bf*J)*(J/Jct-1));
%***************************************
% in the upper flange
raizAtf=sqrt(betan/(bf*A)*(A/Actf-1));
raizMztf=sqrt(betam/(tf*Iz)*(Iz/Icztf-1));
raizMytf=sqrt(betam/(bf*Iy)*(Iymtf/Iyctf-1)); 
%raizMytfn=sqrt(betam/(bf*Iy)*(Iymtn/Icytf-1)); 
raizVytf=sqrt(shi*2*(1+mu)*betas/(A*tf)*(A/Actf-1));
raizVztf=sqrt(shi*2*(1+mu)*betas/(A*bf)*(A/Actf-1));
raizTtf=sqrt(betat/(bf*J)*(J/Jctf-1));
%***************************************
% in the web
raizA1=sqrt(betan/(tw*A)*(A/Ac1-1));
raizMz1=sqrt(betam/(T*Iz)*(Iz/Icz1-1));
raizMy1=sqrt(betam/(tw*Iy)*(Iymt1/Iyc1-1));
%raizMy1n=sqrt(betam/(tw*Iy)*(Iymn/Icy1-1));
raizVy1=sqrt(shi*2*(1+mu)*betas/(A*T)*(A/Ac1-1));
raizVz1=sqrt(shi*2*(1+mu)*betas/(A*tw)*(A/Ac1-1));
raizT1=sqrt(betat/(tw*J)*(J/Jc1-1));
%*********************************************

% symbolic values of the forces
P1=sym('P1');
P2=sym('P2');
P3=sym('P3');
P4=sym('P4');
P5=sym('P5');
P6=sym('P6');


%*****************************************
% in the lower flange
KINpt=P1*raizAt+P1*d1t*raizMyt;
%KINptn=P1*raizAt+P1*d1t*raizMytn;
KIMSpyt=P2*Lc*raizMyt;
%KIMSpytn=P2*Lc*raizMytn;
KIMSpzt=P3*Lc*raizMzt;
KIMpyt=P5*raizMyt;
%KIMpytn=P5*raizMytn;
KIMpzt=P6*raizMzt;
KIISpyt=P2*raizVyt;
KIISpzt=P3*raizVzt;
KIIITpxt=P4*raizTt;

%*****************************************
% in the upper flange
KINptf=P1*raizAtf+P1*d1tf*raizMytf;
%KINptfn=P1*raizAtf+P1*d1tf*raizMytfn;
KIMSpytf=P2*Lc*raizMytf;
%KIMSpytfn=P2*Lc*raizMytfn;
KIMSpztf=P3*Lc*raizMztf;
KIMpytf=P5*raizMytf;
%KIMpytfn=P5*raizMytfn;
KIMpztf=P6*raizMztf;
KIISpytf=P2*raizVytf;
KIISpztf=P3*raizVztf;
KIIITpxtf=P4*raizTtf;
%*****************************************
% in the web
KINp1=P1*raizA1+P1*d1*raizMy1;
%KINp1n=P1*raizA+P1*d1*raizMy1n;
KIMSpy1=P2*Lc*raizMy1;
%KIMSpy1n=P2*Lc*raizMy1n;
KIMSpz1=P3*Lc*raizMz1;
KIMpy1=P5*raizMy1;
%KIMpy1n=P5*raizMy1n;
KIMpz1=P6*raizMz1;
KIISpy1=P2*raizVy1;
KIISpz1=P3*raizVz1;
KIIITpx1=P4*raizT1;
%******************************************


%************************************************************************
% in the lower flange
ELEt=1/E*((KINpt+KIMSpzt+KIMSpyt+KIMpzt+KIMpyt)^2+(KIISpyt+KIISpzt)^2+...
    (1+mu)*KIIITpxt^2);


% in the upper flange
ELEtf=1/E*((KINptf+KIMSpztf+KIMSpytf+KIMpztf+KIMpytf)^2+(KIISpytf+KIISpztf)^2+...
    (1+mu)*KIIITpxtf^2);

% in the web
ELE1=1/E*((KINp1+KIMSpz1+KIMSpy1+KIMpz1+KIMpy1)^2+(KIISpy1+KIISpz1)^2+...
    (1+mu)*KIIITpx1^2);


%****************************************************************

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



G11t1=diff(ELE1,P1,2);
G12t1=diff(diff(ELE1,P1),P2);
G13t1=diff(diff(ELE1,P1),P3);
G14t1=diff(diff(ELE1,P1),P4);
G15t1=diff(diff(ELE1,P1),P5);
G16t1=diff(diff(ELE1,P1),P6);
G21t1=G12t1;
G22t1=diff(ELE1,P2,2);
G23t1=diff(diff(ELE1,P2),P3);
G24t1=diff(diff(ELE1,P2),P4);
G25t1=diff(diff(ELE1,P2),P5);
G26t1=diff(diff(ELE1,P2),P6);
G31t1=G13t1;
G32t1=G23t1;
G33t1=diff(ELE1,P3,2);
G34t1=diff(diff(ELE1,P3),P4);
G35t1=diff(diff(ELE1,P3),P5);
G36t1=diff(diff(ELE1,P3),P6);
G41t1=G14t1;
G42t1=G24t1;
G43t1=G34t1;
G44t1=diff(ELE1,P4,2);
G45t1=diff(diff(ELE1,P4),P5);
G46t1=diff(diff(ELE1,P4),P6);
G51t1=G15t1;
G52t1=G25t1;
G53t1=G35t1;
G54t1=G45t1;
G55t1=diff(ELE1,P5,2);
G56t1=diff(diff(ELE1,P5),P6);
G61t1=G16t1;
G62t1=G26t1;
G63t1=G36t1;
G64t1=G46t1;
G65t1=G56t1;
G66t1=diff(diff(ELE1,P6),P6);



%**********************************
G11tf=diff(ELEtf,P1,2);
G12tf=diff(diff(ELEtf,P1),P2);
G13tf=diff(diff(ELEtf,P1),P3);
G14tf=diff(diff(ELEtf,P1),P4);
G15tf=diff(diff(ELEtf,P1),P5);
G16tf=diff(diff(ELEtf,P1),P6);
G21tf=G12tf;
G22tf=diff(ELEtf,P2,2);
G23tf=diff(diff(ELEtf,P2),P3);
G24tf=diff(diff(ELEtf,P2),P4);
G25tf=diff(diff(ELEtf,P2),P5);
G26tf=diff(diff(ELEtf,P2),P6);
G31tf=G13tf;
G32tf=G23tf;
G33tf=diff(ELEtf,P3,2);
G34tf=diff(diff(ELEtf,P3),P4);
G35tf=diff(diff(ELEtf,P3),P5);
G36tf=diff(diff(ELEtf,P3),P6);
G41tf=G14tf;
G42tf=G24tf;
G43tf=G34tf;
G44tf=diff(ELEtf,P4,2);
G45tf=diff(diff(ELEtf,P4),P5);
G46tf=diff(diff(ELEtf,P4),P6);
G51tf=G15tf;
G52tf=G25tf;
G53tf=G35tf;
G54tf=G45tf;
G55tf=diff(ELEtf,P5,2);
G56tf=diff(diff(ELEtf,P5),P6);
G61tf=G16tf;
G62tf=G26tf;
G63tf=G36tf;
G64tf=G46tf;
G65tf=G56tf;
G66tf=diff(ELEtf,P6,2);

%*****************************************


%****quadrature integration 

 if (G11t1==0||G11t==0||G11tf==0) ; c(1,1)=0; 
 elseif phi_1<=tf/d; c(1,1)=bf*tf*integral(matlabFunction(G11t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(1,1)=bf*tf*integral(matlabFunction(G11t),1e-6,tf/d)+tw*T*integral(matlabFunction(G11t1),tf/d,phi_1); 
 else  c(1,1)=bf*tf*integral(matlabFunction(G11t),1e-6,tf/d)+tw*T*integral(matlabFunction(G11t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G11tf),(tf+T)/d,phi_1);
 end
 
 if (G12t1==0||G12t==0||G12tf==0); c(1,2)=0; 
 elseif phi_1<=tf/d; c(1,2)=bf*tf*integral(matlabFunction(G12t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(1,2)=bf*tf*integral(matlabFunction(G12t),1e-6,tf/d)+tw*T*integral(matlabFunction(G12t1),tf/d,phi_1); 
 else  c(1,2)=bf*tf*integral(matlabFunction(G12t),1e-6,tf/d)+tw*T*integral(matlabFunction(G12t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G12tf),(tf+T)/d,phi_1);
 end
     
 
 if (G13t1==0||G13t==0||G13tf==0); c(1,3)=0; 
 elseif phi_1<=tf/d; c(1,3)=bf*tf*integral(matlabFunction(G13t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(1,3)=bf*tf*integral(matlabFunction(G13t),1e-6,tf/d)+tw*T*integral(matlabFunction(G13t1),tf/d,phi_1); 
 else  c(1,3)=bf*tf*integral(matlabFunction(G13t),1e-6,tf/d)+tw*T*integral(matlabFunction(G13t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G13tf),(tf+T)/d,phi_1);
 end
 
 if (G14t1==0||G14t==0||G14tf==0); c(1,4)=0; 
 elseif phi_1<=tf/d; c(1,4)=bf*tf*integral(matlabFunction(G14t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(1,4)=bf*tf*integral(matlabFunction(G14t),1e-6,tf/d)+tw*T*integral(matlabFunction(G14t1),tf/d,phi_1); 
 else  c(1,4)=bf*tf*integral(matlabFunction(G14t),1e-6,tf/d)+tw*T*integral(matlabFunction(G14t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G14tf),(tf+T)/d,phi_1);
 end
 
 if (G15t1==0||G15t==0||G15tf==0); c(1,5)=0; 
 elseif phi_1<=tf/d; c(1,5)=bf*tf*integral(matlabFunction(G15t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(1,5)=bf*tf*integral(matlabFunction(G15t),1e-6,tf/d)+tw*T*integral(matlabFunction(G15t1),tf/d,phi_1); 
 else  c(1,5)=bf*tf*integral(matlabFunction(G15t),1e-6,tf/d)+tw*T*integral(matlabFunction(G15t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G15tf),(tf+T)/d,phi_1);
 end
 
 if (G16t1==0||G16t==0||G16tf==0); c(1,6)=0; 
 elseif phi_1<=tf/d; c(1,6)=bf*tf*integral(matlabFunction(G16t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(1,6)=bf*tf*integral(matlabFunction(G16t),1e-6,tf/d)+tw*T*integral(matlabFunction(G16t1),tf/d,phi_1); 
 else  c(1,6)=bf*tf*integral(matlabFunction(G16t),1e-6,tf/d)+tw*T*integral(matlabFunction(G16t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G16tf),(tf+T)/d,phi_1);
 end
 
 if (G22t1==0||G22t==0||G22tf==0); c(2,2)=0; 
 elseif phi_1<=tf/d; c(2,2)=bf*tf*integral(matlabFunction(G22t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(2,2)=bf*tf*integral(matlabFunction(G22t),1e-6,tf/d)+tw*T*integral(matlabFunction(G22t1),tf/d,phi_1); 
 else  c(2,2)=bf*tf*integral(matlabFunction(G22t),1e-6,tf/d)+tw*T*integral(matlabFunction(G22t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G22tf),(tf+T)/d,phi_1);
 end
 
 if (G23t1==0||G23t==0||G23tf==0); c(2,3)=0; 
 elseif phi_1<=tf/d; c(2,3)=bf*tf*integral(matlabFunction(G23t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(2,3)=bf*tf*integral(matlabFunction(G23t),1e-6,tf/d)+tw*T*integral(matlabFunction(G23t1),tf/d,phi_1); 
 else  c(2,3)=bf*tf*integral(matlabFunction(G23t),1e-6,tf/d)+tw*T*integral(matlabFunction(G23t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G23tf),(tf+T)/d,phi_1);
 end

 if (G24t1==0||G24t==0||G24tf==0); c(2,4)=0; 
 elseif phi_1<=tf/d; c(2,4)=bf*tf*integral(matlabFunction(G24t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(2,4)=bf*tf*integral(matlabFunction(G24t),1e-6,tf/d)+tw*T*integral(matlabFunction(G24t1),tf/d,phi_1); 
 else  c(2,4)=bf*tf*integral(matlabFunction(G24t),1e-6,tf/d)+tw*T*integral(matlabFunction(G24t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G24tf),(tf+T)/d,phi_1);
 end
 
 if (G25t1==0||G25t==0||G25tf==0); c(2,5)=0; 
 elseif phi_1<=tf/d; c(2,5)=bf*tf*integral(matlabFunction(G25t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(2,5)=bf*tf*integral(matlabFunction(G25t),1e-6,tf/d)+tw*T*integral(matlabFunction(G25t1),tf/d,phi_1); 
 else  c(2,5)=bf*tf*integral(matlabFunction(G25t),1e-6,tf/d)+tw*T*integral(matlabFunction(G25t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G25tf),(tf+T)/d,phi_1);
 end

 if (G26t1==0||G26t==0||G26tf==0); c(2,6)=0; 
 elseif phi_1<=tf/d; c(2,6)=bf*tf*integral(matlabFunction(G26t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(2,6)=bf*tf*integral(matlabFunction(G26t),1e-6,tf/d)+tw*T*integral(matlabFunction(G26t1),tf/d,phi_1); 
 else  c(2,6)=bf*tf*integral(matlabFunction(G26t),1e-6,tf/d)+tw*T*integral(matlabFunction(G26t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G26tf),(tf+T)/d,phi_1);
 end
 
 if (G33t1==0||G33t==0||G33tf==0); c(3,3)=0; 
 elseif phi_1<=tf/d; c(3,3)=bf*tf*integral(matlabFunction(G33t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(3,3)=bf*tf*integral(matlabFunction(G33t),1e-6,tf/d)+tw*T*integral(matlabFunction(G33t1),tf/d,phi_1); 
 else  c(3,3)=bf*tf*integral(matlabFunction(G33t),1e-6,tf/d)+tw*T*integral(matlabFunction(G33t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G33tf),(tf+T)/d,phi_1);
 end

 if (G34t1==0||G34t==0||G34tf==0); c(3,4)=0; 
 elseif phi_1<=tf/d; c(3,4)=bf*tf*integral(matlabFunction(G34t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(3,4)=bf*tf*integral(matlabFunction(G34t),1e-6,tf/d)+tw*T*integral(matlabFunction(G34t1),tf/d,phi_1); 
 else  c(3,4)=bf*tf*integral(matlabFunction(G34t),1e-6,tf/d)+tw*T*integral(matlabFunction(G34t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G34tf),(tf+T)/d,phi_1);
 end
 
 if (G35t1==0||G35t==0||G35tf==0); c(3,5)=0; 
 elseif phi_1<=tf/d; c(3,5)=bf*tf*integral(matlabFunction(G35t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(3,5)=bf*tf*integral(matlabFunction(G35t),1e-6,tf/d)+tw*T*integral(matlabFunction(G35t1),tf/d,phi_1); 
 else  c(3,5)=bf*tf*integral(matlabFunction(G35t),1e-6,tf/d)+tw*T*integral(matlabFunction(G35t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G35tf),(tf+T)/d,phi_1);
 end

 if (G36t1==0||G36t==0||G36tf==0); c(3,6)=0; 
 elseif phi_1<=tf/d; c(3,6)=bf*tf*integral(matlabFunction(G36t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(3,6)=bf*tf*integral(matlabFunction(G36t),1e-6,tf/d)+tw*T*integral(matlabFunction(G36t1),tf/d,phi_1); 
 else  c(3,6)=bf*tf*integral(matlabFunction(G36t),1e-6,tf/d)+tw*T*integral(matlabFunction(G36t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G36tf),(tf+T)/d,phi_1);
 end

 if (G44t1==0||G44t==0||G44tf==0); c(4,4)=0; 
 elseif phi_1<=tf/d; c(4,4)=bf*tf*integral(matlabFunction(G44t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(4,4)=bf*tf*integral(matlabFunction(G44t),1e-6,tf/d)+tw*T*integral(matlabFunction(G44t1),tf/d,phi_1); 
 else  c(4,4)=bf*tf*integral(matlabFunction(G44t),1e-6,tf/d)+tw*T*integral(matlabFunction(G44t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G44tf),(tf+T)/d,phi_1);
 end

 if (G45t1==0||G45t==0||G45tf==0); c(4,5)=0; 
 elseif phi_1<=tf/d; c(4,5)=bf*tf*integral(matlabFunction(G45t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(4,5)=bf*tf*integral(matlabFunction(G45t),1e-6,tf/d)+tw*T*integral(matlabFunction(G45t1),tf/d,phi_1); 
 else  c(4,5)=bf*tf*integral(matlabFunction(G45t),1e-6,tf/d)+tw*T*integral(matlabFunction(G45t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G45tf),(tf+T)/d,phi_1);
 end
 
 if (G46t1==0||G46t==0||G46tf==0); c(4,6)=0; 
 elseif phi_1<=tf/d; c(4,6)=bf*tf*integral(matlabFunction(G46t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(4,6)=bf*tf*integral(matlabFunction(G46t),1e-6,tf/d)+tw*T*integral(matlabFunction(G46t1),tf/d,phi_1); 
 else  c(4,6)=bf*tf*integral(matlabFunction(G46t),1e-6,tf/d)+tw*T*integral(matlabFunction(G46t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G46tf),(tf+T)/d,phi_1);
 end
 
 if (G55t1==0||G55t==0||G55tf==0); c(5,5)=0; 
 elseif phi_1<=tf/d; c(5,5)=bf*tf*integral(matlabFunction(G55t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(5,5)=bf*tf*integral(matlabFunction(G55t),1e-6,tf/d)+tw*T*integral(matlabFunction(G55t1),tf/d,phi_1); 
 else  c(5,5)=bf*tf*integral(matlabFunction(G55t),1e-6,tf/d)+tw*T*integral(matlabFunction(G55t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G55tf),(tf+T)/d,phi_1);
 end
 
 if (G56t1==0||G56t==0||G56tf==0); c(5,6)=0; 
 elseif phi_1<=tf/d; c(5,6)=bf*tf*integral(matlabFunction(G56t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(5,6)=bf*tf*integral(matlabFunction(G56t),1e-6,tf/d)+tw*T*integral(matlabFunction(G56t1),tf/d,phi_1); 
 else  c(5,6)=bf*tf*integral(matlabFunction(G56t),1e-6,tf/d)+tw*T*integral(matlabFunction(G56t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G56tf),(tf+T)/d,phi_1);
 end

 if (G66t1==0||G66t==0||G66tf==0); c(6,6)=0; 
 elseif phi_1<=tf/d; c(6,6)=bf*tf*integral(matlabFunction(G66t),1e-6,phi_1); 
 elseif phi_1<=(T+tf)/d; c(6,6)=bf*tf*integral(matlabFunction(G66t),1e-6,tf/d)+tw*T*integral(matlabFunction(G66t1),tf/d,phi_1); 
 else  c(6,6)=bf*tf*integral(matlabFunction(G66t),1e-6,tf/d)+tw*T*integral(matlabFunction(G66t1),tf/d,(tf+T)/d)+bf*tf*integral(matlabFunction(G66tf),(tf+T)/d,phi_1);
 end

 %*********************************************************
 
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
c(6,2)=c(2,6);
c(6,3)=c(3,6);
c(6,4)=c(4,6);
c(6,5)=c(5,6);

 
         Cdamage=[
              c(1,1)               -c(1,2)                 -c(1,3)             -c(1,4)                 -c(1,5)          -c(1,6);
             -c(2,1)                c(2,2)                  c(2,3)             -c(2,4)                  c(2,5)           c(2,6);    
             -c(3,1)                c(3,2)                  c(3,3)             -c(3,4)                  c(3,5)           c(3,6);
             -c(4,1)               -c(4,2)                 -c(4,3)              c(4,4)                 -c(4,5)          -c(4,6);   
             -c(5,1)                c(5,2)                  c(5,3)             -c(5,4)                  c(5,5)           c(5,6); 
             -c(6,1)                c(6,2)                  c(6,3)             -c(6,4)                  c(6,5)           c(6,6); 
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

