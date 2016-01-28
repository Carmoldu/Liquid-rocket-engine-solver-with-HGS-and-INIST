%Given a pressure for the liquid fuels (must be below the critical
%temperatures of both the oxidiser and the reductor, the performance of the
%rocket engine is given. It is necessary to include INIST and HGS
%libraries, which can be found at https://github.com/ManelSoria/INIST and https://github.com/OpenLlop/HGS


ended=false;
option=-1;
load('IND')

correct=false;
fprintf('Critical pressure for O2: %f \nCritical pressure for N2: %f \n',INIST(IND.O2,'pcrit'),INIST(IND.H2,'pcrit'))

while correct==false;
        
    input=inputdlg('Enter a value for the chamber pressure lower than the critical pressures of both liquids (in bars)');
    Pchamber=str2num(input{:});
    
    if Pchamber<INIST(IND.H2,'pcrit') && Pchamber<INIST(IND.O2,'pcrit')
        correct=true;
    else
        waitfor(msgbox('The values entered are over the critical pressure of one of both liquds'))
    end
end
correct=false

while correct==false;
        
    input=inputdlg({'Enter the H2 input mols: ','Enter the O2 input mols: '});
    molsH2=str2num(input{1});
    molsO2=str2num(input{2});
    
    if molsH2>0 && molsO2>0
        correct=true;
    else
        waitfor(msgbox('The values entered must be over 0!!'))
    end
end

Pamb=1;
exhaustArea=1;


[Thrust,Vexhaust,Mp,Tchamber] = computeEngine(molsH2, molsO2, Pchamber, Pamb, exhaustArea)