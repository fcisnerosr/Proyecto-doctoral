% Structural analysis program of structures in 2D
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 21st October 2020


function SAPMIAele

% reading data files
[file,path] = uigetfile(('*.xlsx'), 'Choose a File');
pathfile = strcat(path,file);

% reading input data
nodes = xlsread(pathfile,'nudos');
elements = xlsread(pathfile,'conectividad');
propgeom = xlsread(pathfile,'prop geom');
fixnodes= xlsread(pathfile,'fix nodes');
nodeforces=xlsread(pathfile,'node forces');
uniformload=xlsread(pathfile,'uniform load');
pload=xlsread(pathfile,'puntual load');

% eliminating node numbers
fixn=fixnodes(:,2:end)';


indx0=find(fixn==0);
indx1=find(fixn==1);

k=0;
[m,n]=size(fixn);
ID=zeros(m,n);

%sorting element numbers
[B,IN]=sort(elements(:,1));


% creating ID matrix
for i=1:length(indx0)
    
    ID(indx0(i))=k+1;
    k=k+1;
    
end


for i=1:length(indx1)
    
    ID(indx1(i))=(k+1)*(-1);
    k=k+1;
    
end

% geometrical properties
NE=length(elements(:,1));
A=propgeom(:,2);
I=propgeom(:,3);
E=propgeom(:,4);

IDmax=max(max(ID));

NEn=length(find(ID<0));

KG=zeros(IDmax,IDmax);
KGtu=zeros(IDmax,NEn);

for i=1:NE
    KGf=zeros(IDmax,IDmax);
    KGtuf=zeros(IDmax,NEn);
    % Length of the elements
 L(i)=sqrt((nodes(elements(i,2),2)-nodes(elements(i,3),2))^2+...
     (nodes(elements(i,2),3)-nodes(elements(i,3),3))^2);
 % angle of the element to the x global axis
 theta(i)=atan((nodes(elements(i,3),3)-nodes(elements(i,2),3))/...
     (nodes(elements(i,3),2)-nodes(elements(i,2),2)));
 
 % local stiffness matrix of the elements
 ke(:,:,i)=localke(A(i),I(i),E(i),L(i));
 
 % Transformation matrix 2D
  LT(:,:,i)=TransfM(theta(i));
 
  
 % global stiffnes matrix of the elements  
 kg(:,:,i)=LT(:,:,i)'*ke(:,:,i)*LT(:,:,i);
 
 LV(:,i)=[ID(:,elements(i,2)); ID(:,elements(i,3))];
 
 indxLV=find(LV(:,i)>0);
 indxLVn=find(LV(:,i)<0);
 
 % assamblage general stiffness matrix
 KGf(LV(indxLV,i),LV(indxLV,i))=kg(indxLV,indxLV,i); 
 KGtuf(LV(indxLV,i),LV(indxLVn,i)*(-1)-IDmax)=kg(indxLV,indxLVn,i);
 KG=KGf+KG;
 % stiffness matrix for reactions
 KGtu=KGtuf+KGtu;
 clear KGf;
 clear KGtuf;
end

Pnodes=zeros(IDmax,1);

% assamblage of node forces
for j=1:length(nodeforces(:,1))
LVnodes(:,j)=[ID(:,nodeforces(j,1))];


Pnodes(LVnodes(:,j))=nodeforces(j,2:end);
end


% perfectly clamped forces
FEMG=zeros(1,IDmax);

% for i=1:length(uniformload(:,1))
%     
% 
% FEMew(:,i)=[uniformload(i,2)*L(uniformload(i,1))/2,uniformload(i,3)*L(uniformload(i,1))/2,0,...
%     uniformload(i,2)*L(uniformload(i,1))/2,uniformload(i,3)*L(uniformload(i,1))/2,0];
% 
% FEMgw(:,i)=LT(:,:,uniformload(i,1))'*FEMew;
% 
% LVF=LV(:,IN(uniformload(i,1)));
% indxLVF=find(LVF>0);
% FEMGf(LVF(indxLVF))=FEMgw(indxLVF,i); 
%  FEMG=FEMGf+FEMG;
%  clear FEMGf;
% 
% end



% global displacements
DeltaG=(KG^(-1))*Pnodes;


% reactions
React=KGtu'*DeltaG;

% Element internal forces
Deltag=zeros(6,NE);
for i=1:NE
    
    
    indxLV=find(LV(:,i)>0);
    Deltag(indxLV,i)=DeltaG(LV(indxLV,i));
    Fi(:,i)=ke(:,:,elements(i,1))*LT(:,:,i)*Deltag(:,i);
end

%eliminating file extension
dotLocations = find(file == '.');
if isempty(dotLocations)
	% No dots at all found so just take entire name.
	outfile = file;
else
	% Take up to , but not including, the first dot.
	outfile = file(1:dotLocations(1)-1);
end

% creating output file
outfile=strcat(outfile,'results');

% variables to be saved
results='DeltaG Fi React KG ke Pnodes LT ID L theta;';

%saving main results to output file
eval(['save ' outfile '  ' results ]);

















