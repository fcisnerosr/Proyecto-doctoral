% Structural analysis program of structures in 2D
% Done by Rolando Salgado Estrada
% Assistant Professor at Faculty of Engineering of Construction and
% Habitat of Universidad Veracruzana Campus Veracruz
% 1st version 21st October 2020


function SAPMIA

% reading data files
[file,path] = uigetfile(('*.xlsx'), 'Choose a File');
pathfile = strcat(path,file);

nodes = xlsread(pathfile,'nudos');
elements = xlsread(pathfile,'conectividad');
propgeom = xlsread(pathfile,'prop geom');
fixnodes= xlsread(pathfile,'fix nodes');
nodeforces=xlsread(pathfile,'node forces');

fixn=fixnodes(:,2:end)';


indx0=find(fixn==0);
indx1=find(fixn==1);

k=0;
[m,n]=size(fixn);
ID=zeros(m,n);

for i=1:length(indx0)
    
    ID(indx0(i))=k+1;
    k=k+1;
    
end


for i=1:length(indx1)
    
    ID(indx1(i))=(k+1)*(-1);
    k=k+1;
    
end


NE=length(elements(:,1));
A=propgeom(:,2);
I=propgeom(:,3);
E=propgeom(:,4);


% Length of the elements

IDmax=max(max(ID));

KG=zeros(IDmax,IDmax);

for i=1:NE
    KGf=zeros(IDmax,IDmax);
 L(elements(i,1))=sqrt((nodes(elements(i,2),2)-nodes(elements(i,3),2))^2+...
     (nodes(elements(i,2),3)-nodes(elements(i,3),3))^2);
 
 theta(elements(i,1))=atan((nodes(elements(i,3),3)-nodes(elements(i,2),3))/...
     (nodes(elements(i,3),2)-nodes(elements(i,2),2)));
 
 % local stiffness matrix of the elements
 
 ke(:,:,elements(i,1))=localke(A(i),I(i),E(i),L(i));
 
 % Transformation matrix 2D
 
  LT(:,:,elements(i,1))=TransfM(theta(i));
 
   
 kg(:,:,elements(i,1))=LT(:,:,elements(i,1))'*ke(:,:,elements(i,1))*LT(:,:,elements(i,1));
 
 LV(:,elements(i,1))=[ID(:,elements(i,2)); ID(:,elements(i,3))];
 
 indxLV=find(LV(:,elements(i,1))>0);
 
 KGf(LV(indxLV,elements(i,1)),LV(indxLV,elements(i,1)))=kg(indxLV,indxLV,elements(i,1)); 
 KG=KGf+KG;
 clear KGf;
end

Pnodes=zeros(IDmax,1);

for j=1:length(nodeforces(:,1))
LVnodes(:,j)=[ID(:,nodeforces(j,1))];


Pnodes(LVnodes(:,j))=nodeforces(j,2:end);
end


DeltaG=(KG^(-1))*Pnodes;


% Fuerzas internas en los elementos

Deltag=zeros(IDmax,NE);
for i=1:NE
    
    
    indxLV=find(LV(:,elements(i,1))>0);
    Deltag(indxLV,i)=DeltaG(LV(indxLV,elements(i,1)));
    Fi(:,i)=ke(:,:,elements(i,1))*LT(:,:,elements(i,1))*Deltag(:,i);
end


dotLocations = find(file == '.')
if isempty(dotLocations)
	% No dots at all found so just take entire name.
	outfile = file;
else
	% Take up to , but not including, the first dot.
	outfile = file(1:dotLocations(1)-1)
end

outfile=strcat(outfile,'results');

results='DeltaG Fi KG ke Pnodes LT ID L theta;'

%saving main results to output file
eval(['save ' outfile '  ' results ]);

















