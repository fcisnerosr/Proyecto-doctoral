function [SumRMSE] = RMSEfunction(x,KG_cond,M_cond,modos_cond,frec_cond)

M = zeros(12,12);
K = zeros(12,12);

% for i=1:1:12
%    M(i,i) = m1(i); 
%    if i<12
%       K(i,i) = k1(i)*(1-x(i))+k1(i+1)*(1-x(i+1)); 
%       if i == 1
%           K(i,i+1) = -k1(i+1)*(1-x(i+1)); 
%       else
%           K(i,i+1) = -k1(i+1)*(1-x(i+1));
%           K(i,i-1) = -k1(i)*(1-x(i));
%       end
%    else
%       K(i,i) = k1(i)*(1-x(i));
%       K(i,i-1) = -k1(i)*(1-x(i)); 
%    end
% end    

[Vr,Dr] = eig(K,M);

SumRMSEVec = 0;
SumRMSEVal = 0;

for i = 1:1:12
    SumRMSEVal = SumRMSEVal+(1/Dd(i,i)-1/Dr(i,i))^2;
    for j=1:1:12
       SumRMSEVec = SumRMSEVec+(1/Vd(i,j)-1/Vr(i,j))^2;
    end
end    

%SumRMSE=(SumRMSEVec/100)^0.5+(SumRMSEVal/12)^0.5;
SumRMSE = 1e8*(SumRMSEVal/12)^0.5;
end
