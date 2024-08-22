close all;
clear all;
clc;
tic
Samples=1000;
Generations=2000;
Nvar=10;

Mo=zeros(10,10);
Ko=zeros(10,10);

Md=zeros(10,10);
Kd=zeros(10,10);

f1=fopen('results.txt','w');

m1 = [250; 375; 225; 254;400;350;225;235;190;260];
k1 = [1000;1110;1450;880;698;1545;1270;1450;980;1190];
D1 = [0.03;0.05;0.08;0.12;0.10;0.14;0.01;0.07;0.15;0.20];   % Vector que representa los factores de daño iniciales aplicados a la matriz de rigidez en el sistema dañado

% Bucles para crear la matriz de rigidez y de masa
for i=1:1:10
   Mo(i,i)=m1(i); 
   if i<10
      Ko(i,i)=k1(i)+k1(i+1); 
      if i==1
          Ko(i,i+1)=-k1(i+1); 
      else
          Ko(i,i+1)=-k1(i+1); 
          Ko(i,i-1)=-k1(i); 
      end
   else
      Ko(i,i)=k1(i);
      Ko(i,i-1)=-k1(i); 
   end
end    

Mo
Ko

% Eigendatos de estructura original (sin ningún daño)
[Vo,Do] = eig(Ko,Mo)


for i=1:1:10
   Md(i,i)=m1(i); 
   if i<10
      Kd(i,i)=k1(i)*(1-D1(i))+k1(i+1)*(1-D1(i+1)); 
      if i==1
          Kd(i,i+1)=-k1(i+1)*(1-D1(i+1)); 
      else
          Kd(i,i+1)=-k1(i+1)*(1-D1(i+1));
          Kd(i,i-1)=-k1(i)*(1-D1(i));
      end
   else
      Kd(i,i)=k1(i)*(1-D1(i));
      Kd(i,i-1)=-k1(i)*(1-D1(i)); 
   end
end    

% Eigendatos de estructura original (ya dañada)
    % Datos a encontrar
Md
Kd

[Vd,Dd]=eig(Kd,Md)

% Algoritmo Genetico
% la siguiente línea es para  indica que las configuraciones son específicamente para la función ga, que es la implementación del Algoritmo Genético en MATLAB.
% Las opciones y variables que configuras con gaoptimset y asignas a la estructura options no se utilizan directamente en otras partes del código; en su lugar, son utilizadas internamente por la función ga (el Algoritmo Genético) durante su ejecución.
options = gaoptimset(@ga);          % gaoptimset es para crear las configuraciones específicas para el AG
options.PopulationSize= Samples;
options.Generations=Generations;
options.StallGenLimit= 50;          % límite de generaciones en donde los individuos no cumplen con la función objetivo
options.Display='iter';                         % Muestra la información en cada iteración

% Este bloque de código configura funciones específicas que controlan el comportamiento de varios procesos dentro del Algoritmo Genético (GA) en MATLAB. Cada opción define una función que el GA utilizará para diferentes aspectos del proceso de evolución, como la creación de la población inicial, la selección de individuos, la mutación, y si se debe usar o no procesamiento paralelo.
% el @ le dice al campo de options que haga uso de la función después de @
options.CreationFcn=@gacreationlinearfeasible;  % esta línea del dice al AG cómo debe crear la primera generación de los individuos. @gacreationlinearfeasible hace que la primera generación de individuos cumplan con cualquier restricción lineal que defina en el problema. Esto asegura que el AG comience desde un inicio con soluciones válidas y así poder aumentar las probabilidades de que devuelva una respuesta correcta cuando el AG finalice
options.FitnessScalingFcn=@fitscalingprop;      % fitscalingprop: Esta técnica de escalamiento ajusta los valores de aptitud para que las diferencias entre ellos no sean tan extremas. Esto significa que incluso los individuos con una aptitud no tan alta todavía tienen una oportunidad razonable de ser seleccionados para la reproducción. Uno de los riesgos en los Algoritmos Genéticos (GA) es que si un individuo (o un pequeño grupo de individuos) tiene un valor de aptitud significativamente superior al de los demás en una población, el GA podría converger rápidamente hacia las características de esos individuos. Esto puede llevar a que el algoritmo se quede atrapado en un óptimo local en lugar de encontrar el óptimo global, que es la mejor solución posible en todo el espacio de búsqueda.
options.SelectionFcn=@selectionroulette;        % En este método, la probabilidad de que un individuo sea seleccionado es proporcional a su aptitud. Los individuos con mejores valores de aptitud tienen más probabilidades de ser seleccionados, pero también hay una oportunidad para aquellos con menor aptitud, lo que ayuda a mantener la diversidad genética en la población.
options.MutationFcn=@mutationadaptfeasible;     % Configura cómo se llevará a cabo la mutación. Función de Mutación Adaptativa Factible: mutationadaptfeasible es una función específica de MATLAB que realiza mutaciones de manera adaptativa. Aquí está lo que hace: Adaptativa: La mutación es adaptativa porque ajusta el grado de mutación dependiendo del progreso del GA. Si el algoritmo está haciendo buenos progresos, la mutación puede ser menos agresiva. Si no está haciendo mucho progreso, la mutación puede volverse más agresiva para explorar nuevas áreas del espacio de soluciones. Factibilidad: La mutación se realiza de tal manera que los individuos mutados aún cumplen con cualquier restricción del problema. Esto es crucial para asegurarse de que las soluciones mutadas sigan siendo válidas dentro del espacio de búsqueda permitido.
% Propósito de la Mutación: La mutación es una operación que introduce variación en los individuos de una población. Es esencial para mantener la diversidad genética, permitiendo que el algoritmo explore nuevas soluciones que no estaban presentes en la población original.
% Cómo Funciona: Durante la mutación, una pequeña parte del código genético (representado por el vector x en tu caso) de un individuo se altera al azar. Esta alteración puede ser un cambio pequeño en el valor de una variable o un ajuste más significativo, dependiendo de cómo esté definida la función de mutación.
options.UseParallel='always';

LB=zeros(10,1);
UB=zeros(10,1);

LowerLim=0.0;       % Variable que define que cualquier dano minimo permitido en cualqueir elemento es 0%
UpperLim=0.30;      % Variable que define que cualquier dano maximo permitido en cualqueir elemento es del 30%. Este valores es importante en los tipos de danos que estemos trabajando porque para la abolladura será el 50% mientras que para la corrosión es del 100%

for i=1:1:10    % va hasta 10 por los 10 grados de libertad del sistema
    % Configurar los límites inferiores y superiores para todas las variables de daño en el AG. Esto significa que cada variable de daño puede variar entre 0% (ningún daño) y 30% (máximo daño)
    LB(i)=LowerLim; 
    UB(i)=UpperLim;
    % los valores de daño dentro de los rangos definidos por LB y UB se combinarán y variarán en cada generación del AG. El objetivo es encontrar la combinación de daños que minimice la función objetivo (RMSE)
end    
CWFile='CWFOutput1.txt';    % Nombre del archivo donde irán registrándose los resultados del AG
diary (CWFile);             % Abre el archivo de salida para que todas las salidas en la consola de MATLAB se registren en este archivo
parpool('Processes', 6)     %  configura MATLAB para ejecutar la optimización del Algoritmo Genético utilizando 6 núcleos de CPU en paralelo, lo que puede acelerar significativamente el proceso al permitir la evaluación simultánea de múltiples individuos en cada generación
% En mi CPU se pueden 6 como máximo, para saber cuántos puede cada usaurio ejecutar en el command window lo siguiente:
% numCores = feature('numcores');
% disp(['Número de núcleos: ', num2str(numCores)]);
% La siguiente linea se a cabo el proceso del ga
[x,fval,exitflag,output,population,scores] =ga(@(x)RMSEfunction(x,k1,m1,Vd,Dd),Nvar,[],[],[],[],LB,UB,[],options);
    % Función Objetivo: RMSEfunction(x,k1,m1,Vd,Dd) es la función objetivo que el AG intenta minimizar.
    % Variables de Optimización: Nvar define el número de variables que se optimizan.
    % Límites: LB y UB+ son los límites inferiores y superiores para las variables de optimización, definidos previamente.
    % Opciones: options incluye todas las configuraciones del AG como el tamaño de la población, número de generaciones, funciones de selección, etc.
delete(gcp('nocreate'));
diary off;                  %  Cierra el archivo de salida, deteniendo el registro de las salidas en la consola.

x
fval
exitflag
output
population
scores

M1=zeros(10,10);
K1=zeros(10,10);

for i=1:1:10
   M1(i,i)=m1(i); 
   if i<10
      K1(i,i)=k1(i)*(1-x(i))+k1(i+1)*(1-x(i+1)); 
      if i==1
          K1(i,i+1)=-k1(i+1)*(1-x(i+1)); 
      else
          K1(i,i+1)=-k1(i+1)*(1-x(i+1));
          K1(i,i-1)=-k1(i)*(1-x(i));
      end
   else
      K1(i,i)=k1(i)*(1-x(i));
      K1(i,i-1)=-k1(i)*(1-x(i)); 
   end
end    
M1
K1
[Vr,Dr]=eig(K1,M1)

for i=1:1:10
   fprintf(f1,' %14.8f  %14.8f\n',D1(i),x(i));
end    

fprintf(f1,'\n\n');

for i=1:1:10
   fprintf(f1,' %14.8f  %14.8f  %14.8f\n',Do(i,i),Dd(i,i),Dr(i,i));
end    

fprintf(f1,'\n\n');


for i=1:1:10
  for j=1:1:10  
   fprintf(f1,' %14.8f  %14.8f  %14.8f\n',Vo(j,i),Vd(j,i),Vr(j,i));
  end
  fprintf(f1,'\n\n');
end    


fclose all;

toc
