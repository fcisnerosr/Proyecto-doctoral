%********PROGRAM FOR OBTAINING THE DYNAMIC RESPONSE OF
%********OF CRACKED BEAM STRUCTURES USING THE ZHENG'S
%********PROCEDURE. MADE BY ROLANDO SALGADO ESTRADA
%********PROFESSOR AT UNIVERSITY OF VERACRUZ
%********LAST MODIFICATION: 21st OF JUNE OF 2013
%********last version 25th November 2020


function ke=ZhengcircT8(Lp,xdc,A,Iz,Iy,J,E,i,depthc,G,betam)
      

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

% Damaged Area in the up thickness
    
ymt=pshi;
yct=abs(radioe-ymt);
xct=sqrt(radioe^2-yct^2);
thetat=2*atan(xct/yct);
Atrt=xct*yct;
Asct=thetat/2*radioe^2;
Ac1t=Asct-Atrt;
Act=A-Ac1t;   % net area


%final thickness
Actf=Ac1t;   % net area
Ac1tf=A-Ac1t;  % damage area
%***************************

%********Centroid of the cracked section

x_cgt=0;   % averall cross section 
ysct=2*radioe*sin(thetat/2)/(3*thetat/2);
ytrt=2/3*yct;

x_cdt=(ysct*Asct-ytrt*Atrt)/Ac1t;
x_ct=(x_cgt*A-x_cdt*Ac1t)/Act;
d1t=abs(x_cgt-x_ct); % change of centroid for axial force


%final thickness
    x_ctf=(ysct*Asct-ytrt*Atrt)/Actf;
    x_cdtf=(x_cgt*A-x_ctf*Act)/Ac1tf;
    d1tf=abs(x_cgt-x_ctf); % change of centroid for axial force
%*********************************

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
Iymtn=matlabFunction(Iymt);
Iymtn=Iymtn(tesp/diame);

%final thickness
Isctf=Iscct+Asct*(ysct-x_ct)^2;
Itrtf=Itrct+Atrt*(ytrt-x_ct)^2;
Icytf=Isctf-Itrtf;
%**************************

%Torsional constant with damage*****************

Rdamt=Ac1t/(2*pi*tesp)+tesp/2;
Jc1t=pi/2*(Rdamt^4-(Rdamt-tesp)^4);
Jct=J-Jc1t;

%final thickness
Rdamtf=Ac1tf/(2*pi*tesp)+tesp/2;
Jc1tf=pi/2*(Rdamtf^4-(Rdamtf-tesp)^4);
Jctf=J-Jc1tf;
%******************

%*********Second moment of inertia and direction (vertical y)

Izsct=(thetat-sin(thetat))*radioe^4/8;
Iztrt=(2*xct)^3*yct/48;
Idamagezt=Izsct-Iztrt;
Iczt=Iz-Idamagezt;


%final thickness
Icztf=Idamagezt;
%*****************************************


%***************************************

% after thickness
ym=pshi;
yce=abs(radioe-ym);
yci=yce;

xce=sqrt(radioe^2-yce^2);
xci=sqrt(radioi^2-yci^2);

thetae=2*atan(xce/yce);      %complete angle
thetai=2*atan(xci/yci);

Atre=xce*yce;
Atri=xci*yci;

Asce=thetae/2*radioe^2;
Asci=thetai/2*radioi^2;

Ace1=Asce-Atre;
Aci1=Asci-Atri;

Ac1=Ace1-Aci1;

%****************************
%if at>=radioe
Ac50=Ac1;
Ac150=A-Ac50;
%else
Ac=A-Ac1;   % net area
%end
%****************************

    
%********Centroid of the cracked section

x_cg=0;   % averall cross section (verificar)
ysce=2*radioe*sin(thetae/2)/(3*thetae/2);
ytre=2/3*yce;
ysci=2*radioi*sin(thetai/2)/(3*thetai/2);
ytri=2/3*yci;
%if at>=radioe
x_c50=abs((ysce*Asce-ytre*Atre-(ysci*Asci-ytri*Atri))/Ac50);
x_cd50=abs((x_cg*A-x_c50*Ac50)/Ac150);

%else
x_cd=abs((ysce*Asce-ytre*Atre-(ysci*Asci-ytri*Atri))/Ac1);
x_c=abs((x_cg*A-x_cd*Ac1)/Ac);
%end

d1=abs(x_cg-x_c); % change of centroid for axial force   
d150=abs(x_cg-x_c50); % change of centroid for axial force   


%Inertia and properties with damage***************

Iscme=(thetae+sin(thetae))*radioe^4/8;
Iscce=Iscme-Asce*ysce^2;
Itrce=2*xce*yce^3/36;

Iscmi=(thetai+sin(thetai))*radioi^4/8;
Iscci=Iscmi-Asci*ysci^2;
Itrci=2*xci*yci^3/36;

%if at>=radioe
Isce50=Iscce+Asce*(ysce-x_c50)^2;
Itre50=Itrce+Atre*(ytre-x_c50)^2;
Isci50=Iscci+Asci*(ysci-x_c50)^2;
Itri50=Itrci+Atri*(ytri-x_c50)^2; 
Iym50=Iy+A*((x_cg-x_c50)^2);
Iym50n=matlabFunction(Iym50);
Iym50n=Iym50n((radioe+radioi)/diame);
Icy50=Isce50-Itre50-(Isci50-Itri50);
%else    
Isce=Iscce+Asce*(ysce-x_cd)^2;
Itre=Itrce+Atre*(ytre-x_cd)^2;
Isci=Iscci+Asci*(ysci-x_cd)^2;
Itri=Itrci+Atri*(ytri-x_cd)^2;
Idamageyc=Isce-Itre-(Isci-Itri);
Idamagey=Idamageyc+Ac1*(x_cd+x_c)^2;
Iym=Iy+A*((x_cg-x_c)^2);
Icy=Iym-Idamagey;
Iymn=matlabFunction(Iym);
Iymn=Iymn(radioe/diame);
%end


%Torsional constant with damage*****************
s=phi_1;

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

Izsce=(thetae-sin(thetae))*radioe^4/8;
Iztre=(2*xce)^3*yce/48;
Izsci=(thetai-sin(thetai))*radioi^4/8;
Iztri=(2*xci)^3*yci/48;

Idamagez=Izsce-Iztre-(Izsci-Iztri);
%if at>=radioe
    Icz50=Idamagez;
%else
    Icz=Iz-Idamagez;
%end


%*********************************************************
 K=zeros(12,12);

 %N=1:length(ce);
 
%******Stress Intensity Factors********
% initial thickness
raizAt=sqrt(betan/(b*A)*(A/Act-1));
raizMzt=sqrt(betam/(h*Iz)*(Iz/Iczt-1));
raizMyt=sqrt(betam/(b*Iy)*(Iymt/Icyt-1));
raizMytn=sqrt(betam/(b*Iy)*(Iymtn/Icyt-1));
raizVyt=sqrt(shi*2*(1+mu)*betas/(A*h)*(A/Act-1));
raizVzt=sqrt(shi*2*(1+mu)*betas/(A*b)*(A/Act-1));
raizTt=sqrt(betat/(b*J)*(J/Jct-1));
%***************************************
% final thickness
raizAtf=sqrt(betan/(b*A)*(A/Actf-1));
raizMztf=sqrt(betam/(h*Iz)*(Iz/Icztf-1));
raizMytf=sqrt(betam/(b*Iy)*(Iymt/Icytf-1)); 
raizMytfn=sqrt(betam/(b*Iy)*(Iymtn/Icytf-1)); 
raizVytf=sqrt(shi*2*(1+mu)*betas/(A*h)*(A/Actf-1));
raizVztf=sqrt(shi*2*(1+mu)*betas/(A*b)*(A/Actf-1));
raizTtf=sqrt(betat/(b*J)*(J/Jctf-1));
%***************************************
% after initial thickness
raizA=sqrt(betan/(b*A)*(A/Ac-1));
raizMz=sqrt(betam/(h*Iz)*(Iz/Icz-1));
raizMy=sqrt(betam/(b*Iy)*(Iym/Icy-1));
raizMyn=sqrt(betam/(b*Iy)*(Iymn/Icy-1));
raizVy=sqrt(shi*2*(1+mu)*betas/(A*h)*(A/Ac-1));
raizVz=sqrt(shi*2*(1+mu)*betas/(A*b)*(A/Ac-1));
raizT=sqrt(betat/(b*J)*(J/Jc-1));
%*********************************************

% after half diameter
raizA50=sqrt(betan/(b*A)*(A/Ac50-1));
raizMz50=sqrt(betam/(h*Iz)*(Iz/Icz50-1));
raizMy50=sqrt(betam/(b*Iy)*(Iym50/Icy50-1));
raizMy50n=sqrt(betam/(b*Iy)*(Iym50n/Icy50-1));
raizVy50=sqrt(shi*2*(1+mu)*betas/(A*h)*(A/Ac50-1));
raizVz50=sqrt(shi*2*(1+mu)*betas/(A*b)*(A/Ac50-1));
raizT50=sqrt(betat/(b*J)*(J/Jc-1));
%*********************************************



P1=sym('P1');
P2=sym('P2');
P3=sym('P3');
P4=sym('P4');
P5=sym('P5');
P6=sym('P6');


%*****************************************
KINpt=P1*raizAt+P1*d1t*raizMyt;
KINptn=P1*raizAt+P1*d1t*raizMytn;
KIMSpyt=P2*Lc*raizMyt;
KIMSpytn=P2*Lc*raizMytn;
KIMSpzt=P3*Lc*raizMzt;
KIMpyt=P5*raizMyt;
KIMpytn=P5*raizMytn;
KIMpzt=P6*raizMzt;
KIISpyt=P2*raizVyt;
KIISpzt=P3*raizVzt;
KIIITpxt=P4*raizTt;


%*****************************************
KINptf=P1*raizAtf+P1*d1tf*raizMytf;
KINptfn=P1*raizAtf+P1*d1tf*raizMytfn;
KIMSpytf=P2*Lc*raizMytf;
KIMSpytfn=P2*Lc*raizMytfn;
KIMSpztf=P3*Lc*raizMztf;
KIMpytf=P5*raizMytf;
KIMpytfn=P5*raizMytfn;
KIMpztf=P6*raizMztf;
KIISpytf=P2*raizVytf;
KIISpztf=P3*raizVztf;
KIIITpxtf=P4*raizTtf;
%*****************************************

KINp=P1*raizA+P1*d1*raizMy;
KINpn=P1*raizA+P1*d1*raizMyn;
KIMSpy=P2*Lc*raizMy;
KIMSpyn=P2*Lc*raizMyn;
KIMSpz=P3*Lc*raizMz;
KIMpy=P5*raizMy;
KIMpyn=P5*raizMyn;
KIMpz=P6*raizMz;
KIISpy=P2*raizVy;
KIISpz=P3*raizVz;
KIIITpx=P4*raizT;
%******************************************

KINp50=P1*raizA50+P1*d150*raizMy50;
KINp50n=P1*raizA50+P1*d150*raizMy50n;
KIMSpy50=P2*Lc*raizMy50;
KIMSpy50n=P2*Lc*raizMy50n;
KIMSpz50=P3*Lc*raizMz50;
KIMpy50=P5*raizMy50;
KIMpy50n=P5*raizMy50n;
KIMpz50=P6*raizMz50;
KIISpy50=P2*raizVy50;
KIISpz50=P3*raizVz50;
KIIITpx50=P4*raizT50;
%******************************************


%************************************************************************
ELEt=1/E*((KINpt+KIMSpzt+KIMSpyt+KIMpzt+KIMpyt)^2+(KIISpyt+KIISpzt)^2+...
    (1+mu)*KIIITpxt^2);


ELEtn=1/E*((KINptn+KIMSpzt+KIMSpytn+KIMpzt+KIMpytn)^2+(KIISpyt+KIISpzt)^2+...
    (1+mu)*KIIITpxt^2);


%************************************************************************
ELEtf=1/E*((KINptf+KIMSpztf+KIMSpytf+KIMpztf+KIMpytf)^2+(KIISpytf+KIISpztf)^2+...
    (1+mu)*KIIITpxtf^2);

ELEtfn=1/E*((KINptfn+KIMSpztf+KIMSpytfn+KIMpztf+KIMpytfn)^2+(KIISpytf+KIISpztf)^2+...
    (1+mu)*KIIITpxtf^2);


%************************************************************************

ELE=1/E*((KINp+KIMSpz+KIMSpy+KIMpz+KIMpy)^2+(KIISpy+KIISpz)^2+...
    (1+mu)*KIIITpx^2);

ELEn=1/E*((KINpn+KIMSpz+KIMSpyn+KIMpz+KIMpyn)^2+(KIISpy+KIISpz)^2+...
    (1+mu)*KIIITpx^2);


%****************************************************************

ELE50=1/E*((KINp50+KIMSpz50+KIMSpy50+KIMpz50+KIMpy50)^2+(KIISpy50+KIISpz50)^2+...
    (1+mu)*KIIITpx50^2);

ELE50n=1/E*((KINp50n+KIMSpz50+KIMSpy50n+KIMpz50+KIMpy50n)^2+(KIISpy50+KIISpz50)^2+...
    (1+mu)*KIIITpx50^2);

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



G11tn=diff(ELEtn,P1,2);
G12tn=diff(diff(ELEtn,P1),P2);
G13tn=diff(diff(ELEtn,P1),P3);
G14tn=diff(diff(ELEtn,P1),P4);
G15tn=diff(diff(ELEtn,P1),P5);
G16tn=diff(diff(ELEtn,P1),P6);
G21tn=G12tn;
G22tn=diff(ELEtn,P2,2);
G23tn=diff(diff(ELEtn,P2),P3);
G24tn=diff(diff(ELEtn,P2),P4);
G25tn=diff(diff(ELEtn,P2),P5);
G26tn=diff(diff(ELEtn,P2),P6);
G31tn=G13tn;
G32tn=G23tn;
G35tn=diff(diff(ELEtn,P3),P5);
G41tn=G14tn;
G42tn=G24tn;
G45tn=diff(diff(ELEtn,P4),P5);
G51tn=G15tn;
G52tn=G25tn;
G53tn=G35tn;
G54tn=G45tn;
G55tn=diff(ELEtn,P5,2);
G56tn=diff(diff(ELEtn,P5),P6);
G61tn=G16tn;
G62tn=G26tn;
G65tn=G56tn;



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


G11tfn=diff(ELEtfn,P1,2);
G12tfn=diff(diff(ELEtfn,P1),P2);
G13tfn=diff(diff(ELEtfn,P1),P3);
G14tfn=diff(diff(ELEtfn,P1),P4);
G15tfn=diff(diff(ELEtfn,P1),P5);
G16tfn=diff(diff(ELEtfn,P1),P6);
G21tfn=G12tfn;
G22tfn=diff(ELEtfn,P2,2);
G23tfn=diff(diff(ELEtfn,P2),P3);
G24tfn=diff(diff(ELEtfn,P2),P4);
G25tfn=diff(diff(ELEtfn,P2),P5);
G26tfn=diff(diff(ELEtfn,P2),P6);
G31tfn=G13tfn;
G32tfn=G23tfn;
G35tfn=diff(diff(ELEtfn,P3),P5);
G41tfn=G14tfn;
G42tfn=G24tfn;
G45tfn=diff(diff(ELEtfn,P4),P5);
G51tfn=G15tfn;
G52tfn=G25tfn;
G53tfn=G35tfn;
G54tfn=G45tfn;
G55tfn=diff(ELEtfn,P5,2);
G56tfn=diff(diff(ELEtfn,P5),P6);
G61tfn=G16tfn;
G62tfn=G26tfn;
G65tfn=G56tfn;

%************************************

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


G11n=diff(ELEn,P1,2);
G12n=diff(diff(ELEn,P1),P2);
G13n=diff(diff(ELEn,P1),P3);
G14n=diff(diff(ELEn,P1),P4);
G15n=diff(diff(ELEn,P1),P5);
G16n=diff(diff(ELEn,P1),P6);
G21n=G12n;
G22n=diff(ELEn,P2,2);
G23n=diff(diff(ELEn,P2),P3);
G24n=diff(diff(ELEn,P2),P4);
G25n=diff(diff(ELEn,P2),P5);
G26n=diff(diff(ELEn,P2),P6);
G31n=G13n;
G32n=G23n;
G35n=diff(diff(ELEn,P3),P5);
G41n=G14n;
G42n=G24n;
G45n=diff(diff(ELEn,P4),P5);
G51n=G15n;
G52n=G25n;
G53n=G35n;
G54n=G45n;
G55n=diff(ELEn,P5,2);
G56n=diff(diff(ELEn,P5),P6);
G61n=G16n;
G62n=G26n;
G65n=G56n;





%*****************************************

G11c5=diff(ELE50,P1,2);
G12c5=diff(diff(ELE50,P1),P2);
G13c5=diff(diff(ELE50,P1),P3);
G14c5=diff(diff(ELE50,P1),P4);
G15c5=diff(diff(ELE50,P1),P5);
G16c5=diff(diff(ELE50,P1),P6);
G21c5=G12c5;
G22c5=diff(ELE50,P2,2);
G23c5=diff(diff(ELE50,P2),P3);
G24c5=diff(diff(ELE50,P2),P4);
G25c5=diff(diff(ELE50,P2),P5);
G26c5=diff(diff(ELE50,P2),P6);
G31c5=G13c5;
G32c5=G23c5;
G33c5=diff(ELE50,P3,2);
G34c5=diff(diff(ELE50,P3),P4);
G35c5=diff(diff(ELE50,P3),P5);
G36c5=diff(diff(ELE50,P3),P6);
G41c5=G14c5;
G42c5=G24c5;
G43c5=G34c5;
G44c5=diff(ELE50,P4,2);
G45c5=diff(diff(ELE50,P4),P5);
G46c5=diff(diff(ELE50,P4),P6);
G51c5=G15c5;
G52c5=G25c5;
G53c5=G35c5;
G54c5=G45c5;
G55c5=diff(ELE50,P5,2);
G56c5=diff(diff(ELE50,P5),P6);
G61c5=G16c5;
G62c5=G26c5;
G63c5=G36c5;
G64c5=G46c5;
G65c5=G56c5;
G66c5=diff(ELE50,P6,2);


G11c5n=diff(ELE50n,P1,2);
G12c5n=diff(diff(ELE50n,P1),P2);
G13c5n=diff(diff(ELE50n,P1),P3);
G14c5n=diff(diff(ELE50n,P1),P4);
G15c5n=diff(diff(ELE50n,P1),P5);
G16c5n=diff(diff(ELE50n,P1),P6);
G21c5n=G12c5n;
G22c5n=diff(ELE50n,P2,2);
G23c5n=diff(diff(ELE50n,P2),P3);
G24c5n=diff(diff(ELE50n,P2),P4);
G25c5n=diff(diff(ELE50n,P2),P5);
G26c5n=diff(diff(ELE50n,P2),P6);
G31c5n=G13c5n;
G32c5n=G23c5n;
G35c5n=diff(diff(ELE50n,P3),P5);
G41c5n=G14c5n;
G42c5n=G24c5n;
G45c5n=diff(diff(ELE50n,P4),P5);
G51c5n=G15c5n;
G52c5n=G25c5n;
G53c5n=G35c5n;
G54c5n=G45c5n;
G55c5n=diff(ELE50n,P5,2);
G56c5n=diff(diff(ELE50n,P5),P6);
G61c5n=G16c5n;
G62c5n=G26c5n;
G65c5n=G56c5n;










%*****************************************


%****quadrature integration 

 if (G11==0||G11t==0||G11tf==0) ; c(1,1)=0; 
 elseif phi_1<=tesp/diame; c(1,1)=b*h*integral(matlabFunction(G11tn),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(1,1)=b*h*integral(matlabFunction(G11tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G11n),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(1,1)=b*h*integral(matlabFunction(G11tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G11n),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G11c5n),radioe/diame,phi_1); 
 else  c(1,1)=b*h*integral(matlabFunction(G11tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G11n),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G11c5n),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G11tfn),(radioe+radioi)/diame,phi_1); 
 end
 
 if (G12==0||G12t==0||G12tf==0); c(1,2)=0; 
 elseif phi_1<=tesp/diame; c(1,2)=b*h*integral(matlabFunction(G12tn),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(1,2)=b*h*integral(matlabFunction(G12tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G12n),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(1,2)=b*h*integral(matlabFunction(G12tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G12n),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G12c5n),radioe/diame,phi_1); 
 else  c(1,2)=b*h*integral(matlabFunction(G12tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G12n),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G12c5n),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G12tfn),(radioe+radioi)/diame,phi_1); 
 end
 
 if (G13==0||G13t==0||G13tf==0); c(1,3)=0; 
 elseif phi_1<=tesp/diame; c(1,3)=b*h*integral(matlabFunction(G13tn),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(1,3)=b*h*integral(matlabFunction(G13tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G13n),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(1,3)=b*h*integral(matlabFunction(G13tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G13n),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G13c5n),radioe/diame,phi_1); 
 else  c(1,3)=b*h*integral(matlabFunction(G13tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G13n),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G13c5n),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G13tfn),(radioe+radioi)/diame,phi_1); 
 end
 
 if (G14==0||G14t==0||G14tf==0); c(1,4)=0; 
 elseif phi_1<=tesp/diame; c(1,4)=b*h*integral(matlabFunction(G14tn),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(1,4)=b*h*integral(matlabFunction(G14tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G14n),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(1,4)=b*h*integral(matlabFunction(G14tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G14n),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G14c5n),radioe/diame,phi_1); 
 else  c(1,4)=b*h*integral(matlabFunction(G14tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G14n),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G14c5n),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G14tfn),(radioe+radioi)/diame,phi_1); 
 end
 
 if (G15==0||G15t==0||G15tf==0); c(1,5)=0; 
 elseif phi_1<=tesp/diame; c(1,5)=b*h*integral(matlabFunction(G15tn),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(1,5)=b*h*integral(matlabFunction(G15tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G15n),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(1,5)=b*h*integral(matlabFunction(G15tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G15n),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G15c5n),radioe/diame,phi_1); 
 else  c(1,5)=b*h*integral(matlabFunction(G15tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G15n),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G15c5n),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G15tfn),(radioe+radioi)/diame,phi_1); 
 end
 
 if (G16==0||G16t==0||G16tf==0); c(1,6)=0; 
 elseif phi_1<=tesp/diame; c(1,6)=b*h*integral(matlabFunction(G16tn),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(1,6)=b*h*integral(matlabFunction(G16tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G16n),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(1,6)=b*h*integral(matlabFunction(G16tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G16n),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G16c5n),radioe/diame,phi_1); 
 else  c(1,6)=b*h*integral(matlabFunction(G16tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G16n),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G16c5n),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G16tfn),(radioe+radioi)/diame,phi_1); 
 end
 
 if (G22==0||G22t==0||G22tf==0); c(2,2)=0; 
 elseif phi_1<=tesp/diame; c(2,2)=b*h*integral(matlabFunction(G22tn),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(2,2)=b*h*integral(matlabFunction(G22tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G22n),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(2,2)=b*h*integral(matlabFunction(G22tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G22n),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G22c5n),radioe/diame,phi_1); 
 else  c(2,2)=b*h*integral(matlabFunction(G22tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G22n),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G22c5n),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G22tfn),(radioe+radioi)/diame,phi_1); 
 end
 
 if (G23==0||G23t==0||G23tf==0); c(2,3)=0; 
 elseif phi_1<=tesp/diame; c(2,3)=b*h*integral(matlabFunction(G23tn),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(2,3)=b*h*integral(matlabFunction(G23tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G23n),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(2,3)=b*h*integral(matlabFunction(G23tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G23n),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G23c5n),radioe/diame,phi_1); 
 else  c(2,3)=b*h*integral(matlabFunction(G23tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G23n),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G23c5n),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G23tfn),(radioe+radioi)/diame,phi_1); 
 end

 if (G24==0||G24t==0||G24tf==0); c(2,4)=0; 
 elseif phi_1<=tesp/diame; c(2,4)=b*h*integral(matlabFunction(G24tn),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(2,4)=b*h*integral(matlabFunction(G24tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G24n),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(2,4)=b*h*integral(matlabFunction(G24tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G24n),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G24c5n),radioe/diame,phi_1); 
 else  c(2,4)=b*h*integral(matlabFunction(G24tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G24n),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G24c5n),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G24tfn),(radioe+radioi)/diame,phi_1); 
 end
 
 if (G25==0||G25t==0||G25tf==0); c(2,5)=0; 
 elseif phi_1<=tesp/diame; c(2,5)=b*h*integral(matlabFunction(G25tn),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(2,5)=b*h*integral(matlabFunction(G25tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G25n),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(2,5)=b*h*integral(matlabFunction(G25tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G25n),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G25c5n),radioe/diame,phi_1); 
 else  c(2,5)=b*h*integral(matlabFunction(G25tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G25n),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G25c5n),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G25tfn),(radioe+radioi)/diame,phi_1); 
 end

 if (G26==0||G26t==0||G26tf==0); c(2,6)=0; 
 elseif phi_1<=tesp/diame; c(2,6)=b*h*integral(matlabFunction(G26tn),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(2,6)=b*h*integral(matlabFunction(G26tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G26n),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(2,6)=b*h*integral(matlabFunction(G26tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G26n),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G26c5n),radioe/diame,phi_1); 
 else  c(2,6)=b*h*integral(matlabFunction(G26tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G26n),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G26c5n),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G26tfn),(radioe+radioi)/diame,phi_1); 
 end
 
 if (G33==0||G33t==0||G33tf==0); c(3,3)=0; 
 elseif phi_1<=tesp/diame; c(3,3)=b*h*integral(matlabFunction(G33t),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(3,3)=b*h*integral(matlabFunction(G33t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G33),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(3,3)=b*h*integral(matlabFunction(G33t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G33),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G33c5),radioe/diame,phi_1); 
 else  c(3,3)=b*h*integral(matlabFunction(G33t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G33),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G33c5),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G33tf),(radioe+radioi)/diame,phi_1); 
 end

 if (G34==0||G34t==0||G34tf==0); c(3,4)=0; 
 elseif phi_1<=tesp/diame; c(3,4)=b*h*integral(matlabFunction(G34t),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(3,4)=b*h*integral(matlabFunction(G34t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G34),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(3,4)=b*h*integral(matlabFunction(G34t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G34),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G34c5),radioe/diame,phi_1); 
 else  c(3,4)=b*h*integral(matlabFunction(G34t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G34),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G34c5),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G34tf),(radioe+radioi)/diame,phi_1); 
 end
 
 if (G35==0||G35t==0||G35tf==0); c(3,5)=0; 
 elseif phi_1<=tesp/diame; c(3,5)=b*h*integral(matlabFunction(G35tn),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(3,5)=b*h*integral(matlabFunction(G35tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G35n),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(3,5)=b*h*integral(matlabFunction(G35tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G35n),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G35c5n),radioe/diame,phi_1); 
 else  c(3,5)=b*h*integral(matlabFunction(G35tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G35n),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G35c5n),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G35tfn),(radioe+radioi)/diame,phi_1); 
 end

 if (G36==0||G36t==0||G36tf==0); c(3,6)=0; 
 elseif phi_1<=tesp/diame; c(3,6)=b*h*integral(matlabFunction(G36t),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(3,6)=b*h*integral(matlabFunction(G36t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G36),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(3,6)=b*h*integral(matlabFunction(G36t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G36),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G36c5),radioe/diame,phi_1); 
 else  c(3,6)=b*h*integral(matlabFunction(G36t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G36),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G36c5),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G36tf),(radioe+radioi)/diame,phi_1); 
 end

 if (G44==0||G44t==0||G44tf==0); c(4,4)=0; 
 elseif phi_1<=tesp/diame; c(4,4)=b*h*integral(matlabFunction(G44t),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(4,4)=b*h*integral(matlabFunction(G44t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G44),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(4,4)=b*h*integral(matlabFunction(G44t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G44),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G44c5),radioe/diame,phi_1); 
 else  c(4,4)=b*h*integral(matlabFunction(G44t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G44),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G44c5),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G44tf),(radioe+radioi)/diame,phi_1); 
 end

 if (G45==0||G45t==0||G45tf==0); c(4,5)=0; 
 elseif phi_1<=tesp/diame; c(4,5)=b*h*integral(matlabFunction(G45tn),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(4,5)=b*h*integral(matlabFunction(G45tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G45n),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(4,5)=b*h*integral(matlabFunction(G45tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G45n),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G45c5n),radioe/diame,phi_1); 
 else  c(4,5)=b*h*integral(matlabFunction(G45tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G45n),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G45c5n),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G45tfn),(radioe+radioi)/diame,phi_1); 
 end
 
 if (G46==0||G46t==0||G46tf==0); c(4,6)=0; 
 elseif phi_1<=tesp/diame; c(4,6)=b*h*integral(matlabFunction(G46t),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(4,6)=b*h*integral(matlabFunction(G46t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G46),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(4,6)=b*h*integral(matlabFunction(G46t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G46),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G46c5),radioe/diame,phi_1); 
 else  c(4,6)=b*h*integral(matlabFunction(G46t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G46),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G46c5),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G46tf),(radioe+radioi)/diame,phi_1); 
 end
 
 if (G55==0||G55t==0||G55tf==0); c(5,5)=0; 
 elseif phi_1<=tesp/diame; c(5,5)=b*h*integral(matlabFunction(G55tn),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(5,5)=b*h*integral(matlabFunction(G55tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G55n),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(5,5)=b*h*integral(matlabFunction(G55tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G55n),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G55c5n),radioe/diame,phi_1); 
 else  c(5,5)=b*h*integral(matlabFunction(G55tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G55n),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G55c5n),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G55tfn),(radioe+radioi)/diame,phi_1); 
 end
 
 if (G56==0||G56t==0||G56tf==0); c(5,6)=0; 
 elseif phi_1<=tesp/diame; c(5,6)=b*h*integral(matlabFunction(G56tn),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(5,6)=b*h*integral(matlabFunction(G56tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G56n),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(5,6)=b*h*integral(matlabFunction(G56tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G56n),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G56c5n),radioe/diame,phi_1); 
 else  c(5,6)=b*h*integral(matlabFunction(G56tn),1e-6,tesp/diame)+b*h*integral(matlabFunction(G56n),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G56c5n),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G56tfn),(radioe+radioi)/diame,phi_1); 
 end

 if (G66==0||G66t==0||G66tf==0); c(6,6)=0; 
 elseif phi_1<=tesp/diame; c(6,6)=b*h*integral(matlabFunction(G66t),1e-6,phi_1); 
 elseif phi_1<=(radioe)/diame; c(6,6)=b*h*integral(matlabFunction(G66t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G66),tesp/diame,phi_1); 
 elseif phi_1<=(radioe+radioi)/diame; c(6,6)=b*h*integral(matlabFunction(G66t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G66),tesp/diame,radioe/diame)+b*h*integral(matlabFunction(G66c5),radioe/diame,phi_1); 
 else  c(6,6)=b*h*integral(matlabFunction(G66t),1e-6,tesp/diame)+b*h*integral(matlabFunction(G66),tesp/diame,(radioe)/diame)+b*h*integral(matlabFunction(G66c5),radioe/diame,(radioe+radioi)/diame)+b*h*integral(matlabFunction(G66tf),(radioe+radioi)/diame,phi_1); 
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

