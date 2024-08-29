
function ke_AG = localkeframe3D_AG(A,Iy,Iz,J,E,G,L)
    ke_AG(4,4)     = (G*J)/L;
    ke_AG(10,10)   = (G*J)/L;
    ke_AG(10,4)    = (-G*J)/L;
    ke_AG(4,10)    = (-G*J)/L;
   
    
    keT = ke_AG';
    kediag = diag(diag(ke_AG));
    
    ke_AG = ke_AG + keT - kediag;

end


