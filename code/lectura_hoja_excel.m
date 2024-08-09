function [NE, IDmax, NEn, elements, nodes, damele, eledent, A, Iy, Iz, J, E, G, vxz, ID, KG, KGtu] = lectura_hoja_excel(pathfile)
    % reading input data
    nodes            = xlsread(pathfile,'nudos');
    elements         = xlsread(pathfile,'conectividad');
    [propgeom,txtpg] = xlsread(pathfile,'prop geom');
    fixnodes         = xlsread(pathfile,'fix nodes');
    nodeforces       = xlsread(pathfile,'node forces');
    uniformload      = xlsread(pathfile,'uniform load');
    pload            = xlsread(pathfile,'puntual load');
    vxz              = xlsread(pathfile,'vxz');
    masses           = xlsread(pathfile,'masses');
    modespar         = xlsread(pathfile,'modes');
    dynload=xlsread(pathfile,'dynload');
    damage=xlsread(pathfile,'damage');
    propdent=xlsread(pathfile,'prop dent');

    % eliminating node numbers
    fixn=fixnodes(:,2:end)';
    
    % total number of nodes
    nnodes=length(nodes(:,1));
    
    
    fixt=zeros(nnodes,6);
    % adding non fix nodes
    for l=1:length(fixnodes(:,1))
    indxfix=find(fixnodes(l,1)==nodes(:,1));
    indxfixo=find(indxfix==fixnodes(:,1));
    fixt(indxfix,:)=fixn(:,indxfixo)';
    end
    
    fixn=fixt';
    % indexes of non fix and fix nodes
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
    Iy=propgeom(:,3);
    Iz=propgeom(:,4);
    J=propgeom(:,5);
    E=propgeom(:,6);
    G=propgeom(:,7);
    tipo=txtpg;
    radio=zeros(size(propgeom(:,10)));
    b=zeros(size(propgeom(:,10)));
    h=zeros(size(propgeom(:,10)));
    trec=zeros(size(propgeom(:,10)));
    for i=1:length(propgeom(:,10))
        if strcmp(tipo(i),'circular')
            radio(i)=propgeom(i,9);
        elseif strcmp(tipo(i),'rectangular')
            b(i)=propgeom(i,9);
            h(i)=propgeom(i,10);
            trec(i)=propgeom(i,11);
        end
    end
    % dent properties
    if isempty(propdent)==1
        eledent=[];
        Adent=[];
        Iydent=[];
        Izdent=[];
        Jdent=[];
        x1dentr=[];
        x2dentr=[];
    else
        eledent=propdent(:,1);
        Adent=propdent(:,2);
        Iydent=propdent(:,3);
        Izdent=propdent(:,4);
        Jdent=propdent(:,5);
        x1dentr=propdent(:,6);
        x2dentr=propdent(:,7);
    end
    
    % damage properties
    if isempty(damage)==1
        damele=[];
        xdcr=[];
        depthr=[];
    else
        damele=damage(:,1);
        xdcr=damage(:,2);
        depthr=damage(:,3);
    end
    IDmax=max(max(ID));
    IDmin=abs(min(min(ID)));
    indxdp=find(ID>0);
    indxdn=find(ID<0);
    
    NEn=length(find(ID<0));
    
    KG=zeros(IDmax,IDmax);
    KGtu=zeros(IDmax,NEn);

end
