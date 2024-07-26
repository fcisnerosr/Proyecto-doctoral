% Program for calculating the mass matrix of a
% one dimensional element model
% Done by Rolando Salgado Estrada
% 1st version
% 12th March 2021

function masses= masseldyn(nodes,elements,L,A,gammae,vpos,time)

[l,m]=size(nodes);
[le,me]=size(elements);
[lv,mv]=size(vpos);


for i=1:l
    nr=find(elements(:,[2 3])==nodes(i,1));
    nk=find(nr-le>0);
    if isempty(nk)
        nr=nr;
    else
        nr(nk)=nr(nk)-le;
    end
    
    
    ve=A(nr).*L(nr)';
    masse=sum(gammae(nr).*ve)/2;
 
masses(i,[2 3 4])=masse(i);  % traslational masses
masses(i,[5 6 7])=1*10^-8;   % rotational masses
end
masses(:,1)=1:l;
end



   


