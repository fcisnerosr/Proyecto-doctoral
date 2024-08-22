function [SumRMSE]=RMSEfunction(x,k1,m1,Vd,Dd)
  M=zeros(10,10);
  K=zeros(10,10);
  
  for i=1:1:10
     M(i,i)=m1(i); 
     if i<10
        K(i,i)=k1(i)*(1-x(i))+k1(i+1)*(1-x(i+1)); 
        if i==1
            K(i,i+1)=-k1(i+1)*(1-x(i+1)); 
        else
            K(i,i+1)=-k1(i+1)*(1-x(i+1));
            K(i,i-1)=-k1(i)*(1-x(i));
        end
     else
        K(i,i)=k1(i)*(1-x(i));
        K(i,i-1)=-k1(i)*(1-x(i)); 
     end
  end    
  
  [Vr,Dr]=eig(K,M);
  
  SumRMSEVec=0;
  SumRMSEVal=0;
  
  for i=1:1:10
      SumRMSEVal=SumRMSEVal+(1/Dd(i,i)-1/Dr(i,i))^2;
      for j=1:1:10
         % SumRMSEVec=SumRMSEVec+(1/Vd(i,j)-1/Vr(i,j))^2;
         SumRMSEVec=SumRMSEVec+(Vd(i,j)-Vr(i,j))^2;
      end
  end    
  
  %SumRMSE=(SumRMSEVec/100)^0.5+(SumRMSEVal/10)^0.5;
  SumRMSE=1e8*(SumRMSEVal/10)^0.5;
end
