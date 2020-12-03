function SP_code(depth, trapDiameter, trapWeight, numTraps)

    % Need to find these values:
        % Max spool outer wall diamater
        % Max spool length
        % check with team to see that usbaleLength function makes sense
        
    %Take a safety factor of 2.5 for spool calculations
    SF = 2.5;
    %There should always be 10cm of clearance between spool and eyebolts
    D1 = 0.1; %in m
        
%Make functions for your calculations below and bring it all together in this main function
disp('SP_code checking in.')
new_var = SP_rope_volume(depth);

fprintf('depth: %d \nVolume: %d \n',depth,new_var);

end

function [ropeVolume] = SP_rope_volume(depth)
    
    %Packing efficiency of discsa is found to be 0.9069 which applies to
    %   stacked rope.
    %To account for drift the rope length is double the depth of the
    %   system.
    %First half of rope length has 0.8cm diameter; second half has 1cm
    %diameter
    ropeDiameter = 0.009;
    packingEfficiency = 0.9069;
    ropeLength = depth*2;
    ropeVolume = (pi*((ropeDiameter/2)^2))*depth/packingEfficiency; %in m^3
end

function [ropeWeight] = SP_rope_weight(depth)

    %Rope weight source: https://www.engineeringtoolbox.com/polypropylene-rope-strength-d_1516.html
    %When doing load calculations this weight is ignored, as it's lighter
    %than water and thus positively buoyant.
    ropeWeightPerMeter = 0.035; %(in Kg, assuming 0.009m Diameter line (1/2 is 0.008m, 1/2 is 0.01m))
    ropeWeight = ropeWeightPerMeter*depth*2;

end

function usableLength = SP_usable_Length(ropeVolume)
    
    %For optimizaiton it was found that a minimum value of Di = Do/2
    Do = 0.63
    Di = 0.3
    usableLength = ropeVolume/(pi*(Do^2-Di^2))
end

function frictionForce = SP_friction_force(trapDiamter, maxSpoolDiameter, maxSpoolLength)
    
    %taking the largest possible version of the spool for this calculation
    %as the spool size varies based on these results. The difference should
    %be negligible across the entire range of spool sizes
    
    %Coefficient of friction of spool (equated to a cykinder)
    Cs = 0.64;
    %Coefficient of friction of traps (equated to a disc)
    Ct = 1.12;
    %Speed of line hauler is 120ft/sec in majority of cases seen on the
    %market. Source: https://www.go2marine.com/Discovery-Bay-Power-Hauler-Alaskan-Model-HD923
    V = 120*12*2.54/(60*100); %Converted to m/s
    %Density of seawater at 500m. This is lower than this system is
    %designed to go. Source: https://www.britannica.com/science/seawater/Density-of-seawater-and-pressure
    p = 1030.49; %Kg/m^3
    %Cross-sectional areas of the spool and traps (cumulative) respectively
    As = maxSpoolDiameter*maxSpoolLength;
    At = numTraps*pi*(trapDiamter/2)^2;

    %Calculating friction force of entire spool system as it gets dragged
    %up.
    %Equation #62 in Analysis Report
    frictionForce = (Cs*As + Ct*At)*p*V^2/2; % in N
end

function bushingLoad = SP_bushing_system_load(numTraps, trapWeight, frictionForce)

    %Gravity force in m^2/s
    g = 9.81;
    %Total weight after buoyancy of all traps. Spool and rope are
    %positively buoyant. Traps are assumed to be made of T316 Stainless
    %steel mesh as a sort of worst case scenario. Also lobsters are
    %neutrally buoyant.
    Wt = numTraps*trapWeight; % in Kg
    
    %Weight on one bushing in spool system. Doubled to account for initial
    %shock and possible obstructions to cage such as rocks or sand. 
    %Equation #272 in Analysis Report
    bushingLoad = 2*(Wt*g+frictionForce)/2; %in N
    
end

function shaftDiameter = SP_shaft_diameter(SF, bushingLoad, usableLength)

    %Take moment at highest point: in the middle of the shaft.
    %Equation #275 in Analysis Report
    maxMoment = 2*bushingLoad(2*D1+usableLength)/2; %in N*m
    
    %Set minimum shaft outer and inner diameter
    Do = 0.01;
    Di = Do*0.2;
    n = 0;
    
    %Using 316 stainless steel, so yield strength = 290Mpa
    Sy = 290000000 %in pa
    
    %Optimize shaft for SF >= 2.5
    while n < SF 
        
        %Stress at middle of shaft.
        %Equation #276 in Analysis Report
        shaftStress = 32*maxMoment/(pi(Do^3-Di^3));%in pa
        n = Sy/shaftStress; 
        Do = Do + 0.002;
        Di = Do*0.2;
    end
end

function boreDiameter = SP_bore_diameter(shaftDiameter, bushingLoad, usableLength)
    
    %Take moment at highest point: in the middle of the bore.
    maxMoment = 2*bushingLoad*usableLength/2; %in N*m
    
    %Set minimum bore outer and inner diameter to shaft outer diameter plus
    %a factor of 1.25 to account for bushing. This was a standard
    %inner/outer diamter ratio of several bushings found on McMaster Carr.
    Do = shaftDiameter*1.25;
    Di = Do*0.4;
    n = 0;
    
    %Using HDPE, so yield strength = 23Mpa
    Sy = 23000000 %in pa
    
    %Optimize bore for SF >= 2.5
    while n < SF 
        
        %Stress at middle of bore.
        %Equation #284 in Analysis Report
        boreStress = 32*maxMoment/(pi(Do^3-Di^3));%in pa
        n = Sy/boreStress; 
        Do = Do + 0.002;
        Di = Do*0.4;
        
    end
    boreThickness = (Do-Di)/2; 
end
