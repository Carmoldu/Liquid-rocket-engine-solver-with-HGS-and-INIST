function [Thrust,Vexhaust,Mp,Tchamber] = computeEngine(molsH2, molsO2, Pchamber, Pamb, exhaustArea)
%This function computes the Thrust for a given chamber pressure of an adapted engine working with H2 and O2 given the composition in
%mols of the entering liquids

IND=load('IND');

species={'H2','O2','H2O','H','O','OH'};
MMO2=0.032; %kg/mol
MMH2=0.002; %kg/mol
inletMols=[molsH2 molsO2 0 0 0 0];  %mols/s

Pexhaust=Pamb;  %bar

%Computation of the mass flow
Mp=molsH2*MMH2+molsO2*MMO2; %Kg/s


%compute the temperature at the chamber given that the Hin must be equal to
%Hout

%First, it is necessary to compute the Hin with INIST and convert it to HGS
%enthalpy reference

% INIST diference between saturated liquqid at our pressure with a reference point:
Tref=300;
deltaHInistO2=(INIST(IND.IND.O2,'h_pt',Pchamber,Tref)-INIST(IND.IND.O2,'hl_p',Pchamber))*INIST(IND.IND.O2,'MM');
deltaHInistN2=(INIST(IND.IND.H2,'h_pt',Pchamber,Tref)-INIST(IND.IND.H2,'hl_p',Pchamber))*INIST(IND.IND.H2,'MM');

% entalpia del O2 liquid saturat a la pressio p, en l'escala de HGS sera
% igual a l'entalpia en les condicions de referncia menys el valor
% anterior:
hHGSinO2liq=hgssingle('O2','h',Tref)-deltaHInistO2;
hHGSinN2liq=hgssingle('H2','h',Tref)-deltaHInistN2;

Hin=inletMols(2)*hHGSinO2liq+inletMols(1)*hHGSinN2liq


%Now, we force Hin to be equal to Hout
function DeltaH=DeltaH(Tprod)
        comp=hgseq(species,inletMols,Tprod,Pchamber);
        [~,~,~,~,~,~,Hout,~,~]=hgsprop(species,comp,Tprod,Pchamber);
        DeltaH=Hout-Hin;
end

% Solving the problem
solver='fzero';
options=[];
Tstar=2500;
Tchamber = hgssolve(@DeltaH,Tstar,solver,options)

outputMolsChamber=hgseq(species,inletMols,Tchamber,Pchamber);

%____________________________________________________________________________________________________________________________
%Now that we have the combustion properties, we can use isenthropic
%shifting flow to solve the exhaust nozzle

[Texhaust,MolsExhaust,Vexhaust,MachExhaust]=hgsisentropic( species,outputMolsChamber,Tchamber,Pchamber,Pexhaust,'shifting');


Thrust=Mp*Vexhaust+(Pexhaust*1e5-Pamb*1e5)*exhaustArea;


end

