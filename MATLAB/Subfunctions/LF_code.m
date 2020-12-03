%This is the design function that will optimize the size of shaft 2 in the
%belt drive subsystem

function LF_code(LS, M_SR, DS)

%constant variables 
T1=31.24; %Units N*m. rope tension at continuous operation 
F_rad=1503.89; %Units N. radial force from the belt drive
LS=0.4016 ;%Units m. length of spool
T_C=2.64 ; %Units in N*m. continuous torque from motor catalogue
%Max shaft stress calculated using the conecentration factors from graphs.
KTT=2.3; %Concentration factor for tension loading
KTB=2; %Concentration factor for bending loading
KT_T=1.7; %Concentration factor for torsion loading
    %Source: Fundamentals of Machine Component Design” Robert C. Juvinall and Kurt M, Marshek, Wiley; 5th edition.
%Shaft 2 is made from 2205 Stainless Steel 
YS_SS2205=448.159; %Units MPa.  
    %Source: McMaster-Carr catalogue

%variables calculated from spool design code
M_SR=WS/9.81; %Units kg. mass of spool plus rope
F_RC= ;%Units N. rope tension force when rope is caught 
DS= ;%Units m. diameter of spool including the entire rope wrapped around itself 

%force calculations for failure scenario of boat rolling
T_R =((M_SR*(0.33+LS/2)^2)*(-0.5))/2;  %torque due to momentum change. 0.33m distance from floor to bottom of spool in the z-direction
FR=(2*T_R)/(0.33+LS/2);   %force due to momentum change

%Scenario 1, where the boat is rolling and the momentum change creates a force on the line spooler system
%--------------------------------------------------------------------------------------

%calculation of resistance forces from bearings 3 and 4
R_B4X=(F_rad*0.0225+(T1+FR)*(LS/2+0.085)+WS*sind(30)*(LS/2+0.085))/0.037; %moment about bearing 3. The z-axis is assumed to be colinear with the shaft length
R_B3X=F_rad-R_B4X; %x-direction forces summed. The x-axis is assumed to be perpendicular with shaft length

%Calculate the total tension, moment and torque acting on shaft 2 during
%rocking of boat 
M_TOT=(T1+FR+WS*sind(30))*(LS/2+0.048);%0.048 is distance from bearing 4 and centre of gravity of the spool where the rope, weight and momentum force is acting
P_TOT=WS*cosd(30); %only force acting along the shaft is the weight of the spool+rope 
T_TOT=3*T_C; %Continuous torque of motor from catalogue times the 3:1 pulley increase in size. This gives the output torque

%The concentration factor for shaft steps requires a ratio between the two diameters and 
%the fillet radius to the smaller shaft diameter 
BD_S2_D2=BD_S2_D1/1.4; %The step in the shaft will maintain a 1.4 ratio for the shaft diameters
BD_SE_r=0.04*BD_S2_D1; %the ration 


%Maximum stresses for tension, bending and torsion are found by calculating
%the nominal stresses and multiplying them by their respective
%concentration factor
MS_TE=((4*P_TOT)/(pi*BD_S2_D2^2))*2.3; %Maximum stress due to tension 
MS_BE=((32*M_TOT)/(pi*(BD_S2_D2)^3))*2; %Maximum stress due to bending
MS_TO=((16*T_TOT)/(pi*BD_S2_D2^3))*1.7; %Maximum stress due to torsion

%-----------------------------------------------------------------------------
 

%Scenario #2, where the rope is caught and the tension on the rope, due to momentum change, acts on the line spooler system
%------------------------------------------------------------------------------

%Maximum Stresses are found by multiplying the nominal stress and multiplying it by the concentration factor.  
T_S2=((M_SR*(DS^2)/4)*(-0.145))/2+62.157;
M_S2=F_RC*(LS/2); 
P_S2=WS; 

%-------------------------------------------------------------------------------

%Optimization loop, change diameter until safety factor 'n' > 2.5
    while n<2.5
        BD_S2_D1 = BD_S2_D1 + 0.001;
        BD_S2_D2=BD_S2_D1/1.4;
        STRESS_S1=sqrt((MS_TE+MS_BE)^2+3*(MS_TO)^2);    %Scenario 1 prime sress
        STRESS_S2=sqrt((T_S2+M_S2)^2+3(T_S2)^2);         %Scenario 2 prime stress
        
        %choose the larger stress between STRESS_S1 and STRESS_S2
       
        n = YS_SS2205/STRESS_S1;
    end
    
    new_BD_S2_D1 = BD_S2_D1;
end