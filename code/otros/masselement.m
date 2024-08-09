% Program for calculating the mass matrix of a
% one dimensional element model
% Done by Rolando Salgado Estrada
% 1st version
% 12th March 2021

function masses = masselement(nodes,elements,L,A,tipo,water,radio,b,h,gammae)
	% gammae = masa volumétrica del acero
    gammaw = 1.00*10^(-9); % Densidad del agua
    
    [l,m]   = size(nodes);      % l no es uno, es ele minúscula
    [le,me] = size(elements);    
    
    for i = 1:l     % l no es uno, es ele minúscula
        nr = find(elements(:,[2 3]) == nodes(i,1)); % Número de elementos que concurren en un nudo
        nk = find(nr-le>0);
        if isempty(nk)
            nr = nr;
        else
            nr(nk) = nr(nk)-le;
        end       
        
        ve      = A(nr).*L(nr)'             % Volumen (vector)
        masse   = sum(gammae(nr)'.*ve)/2    % (escalar) y /2 porque se reparte la masa de cada elemento a cada nodo en que concurren por medio de elementos tributarias
        clear Amaciza;
        
        for j = 1:length(nr)
            if strcmp(tipo(j),'circular')
                Amaciza(j) = pi*radio(nr(j))^2; % Área de un elemento tubular
            else
                Amaciza(j) = b(nr(j))*h(nr(j)); % Área de un elemento rectangular
            end
            if strcmp(water(nr(j)),'water')
                Amaciza(j) = Amaciza(j);
            else
                Amaciza(j) = 0;
            end 
        end
        
        massw       = gammaw*sum(Amaciza.*L(nr))/2  % (escalar)
        % Se reparte la masa entre los diferentes nudos por eso se divide entre 2 (Lados tributarios)
        massesc(i)  = masse+massw;

        masses(i,[2 3 4]) = massesc(i); % traslational masses
        masses(i,[5 6 7]) = 1*10^-8;    % rotational masses
    end
    masses(:,1) = 1:l % l no es uno, es ele minúscula
end



   


