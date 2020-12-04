function [usableLength, totalDryWeight, buoyForce] = SP_code(depth, trapDiameter, trapWeight, numTraps)

    % Need to find these values:
        % Max spool outer wall diamater
        % Max spool length
        % Min bore Diameter 
        % check with team to see that usbaleLength function makes sense
    maxSpoolDiameter = 0.85;
    maxSpoolLength = maxSpoolDiameter;
    minBoreDiameter = 0.025;
    %Take a safety factor of 2.5 for spool calculations
    SF = 2.5;
    %There should always be 10cm of clearance between spool and eyebolts
    D1 = 0.1; %in m
    
    ropeVolume = SP_rope_volume(depth);
    ropeWeight = SP_rope_weight(depth);
    usableLength = SP_usable_Length(ropeVolume, minBoreDiameter);
    frictionForce = SP_friction_force(trapDiameter, numTraps, maxSpoolDiameter, maxSpoolLength);
    bushingLoad = SP_bushing_system_load(numTraps, trapWeight, frictionForce);
    shaftDiameter = SP_shaft_diameter(SF, D1, bushingLoad, usableLength);
    [boreDiameter, boreThickness] = SP_bore_diameter(SF, shaftDiameter, bushingLoad, usableLength);
    totalDryWeight = SP_totalDryWeight(ropeWeight, boreDiameter, boreThickness, usableLength);
    buoyForce = SP_buoy_force(usableLength, totalDryWeight);
    
    %Declaring log file to be modified
    log_file = 'C:\Users\luca_\OneDrive\Documents\Capstone\groupRPT1\Log\groupRPT1_LOG.TXT';
    
    %Write the log file (NOT USED BY SOLIDWORKS, BUT USEFUL TO DEBUG PROGRAM AND REPORT RESULTS IN A CLEAR FORMAT)
	%Please only create one log file for the complete project but try to keep the file easy to read by adding blank lines and sections...
    fid = fopen(log_file,'w+t');
	fprintf(fid,strcat('***Spool Sybsystem Design***\n'));
    fprintf(fid,strcat('Rope Volume =',32,num2str(ropeVolume),' (m^3).\n'));
    fprintf(fid,strcat('Rope Weight =',32,num2str(ropeVolume),' (Kg).\n'));
	fprintf(fid,strcat('Usable Length of Spool =',32,num2str(usableLength),' (m).\n'));
	fprintf(fid,strcat('Friction Force from Drag = ',32,num2str(frictionForce),' (N). \n \n'));
    fprintf(fid,strcat('Bushing Load = ',32,num2str(bushingLoad),' (N).\n'));
    fprintf(fid,strcat('Shaft Diameter = ',32,num2str(shaftDiameter),' (m).\n'));
    fprintf(fid,strcat('Bore Diameter = ',32,num2str(boreDiameter),' (m).\n'));
    fprintf(fid,strcat('Bore Thickness = ',32,num2str(boreThickness),' (m).\n'));
    fprintf(fid,strcat('Total Dry Weight = ',32,num2str(totalDryWeight),' (Kg).\n'));
    fprintf(fid,strcat('Buoy Force = ',32,num2str(buoyForce),' (N).\n'));
    fclose(fid);


    %fprintf('depth: %d \nVolume: %d \n',depth,new_var);

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

function usableLength = SP_usable_Length(ropeVolume, boreDiameter)
    
    %For optimizaiton it was found that a Do = Di/0.6 = usableLength
    %created well balanced spool with reasonably low redeployment times.
    Do = 0.0;
    Di = Do*0.6;
    usableLength = Do;
    
    while Di < (boreDiameter*2)
        %this is an inversed volume equation for the volume of rope on the
        %spool.
        usableLength = (4*ropeVolume/(pi*(1-0.6^2)))^(1/3); 
        Do = usableLength+ 0.01;
        Di = Do*0.6;    
    end
    Do = usableLength;
    Di = Do*0.6;   
    
end

function frictionForce = SP_friction_force(trapDiamter, numTraps, maxSpoolDiameter, maxSpoolLength)
    
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

function [Do] = SP_shaft_diameter(SF, D1, bushingLoad, usableLength)

    %Take moment at highest point: in the middle of the shaft.
    %Equation #275 in Analysis Report
    maxMoment = 2*bushingLoad*(2*(D1+usableLength))/2; %in N*m
    
    %Set minimum shaft outer and inner diameter
    Do = 0.01;
    Di = Do*0.2;
    n = 0;
    
    %Using 316 stainless steel, so yield strength = 290Mpa
    Sy = 290000000; %in pa
    
    %Optimize shaft for SF >= 2.5
    while n < SF 
        
        %Stress at middle of shaft.
        %Equation #276 in Analysis Report
        shaftStress = 32*maxMoment/(pi*(Do^3-Di^3));%in pa
        n = Sy/shaftStress; 
        Do = Do + 0.002;
        Di = Do*0.2;
    end
end

function [Do, boreThickness] = SP_bore_diameter(SF, shaftDiameter, bushingLoad, usableLength)
    
    %Take moment at highest point: in the middle of the bore.
    maxMoment = 2*bushingLoad*usableLength/2; %in N*m
    
    %Set minimum bore outer and inner diameter to shaft outer diameter plus
    %a factor of 1.25 to account for bushing. This was a standard
    %inner/outer diamter ratio of several bushings found on McMaster Carr.
    Do = shaftDiameter*1.25;
    Di = Do*0.4;
    n = 0;
    
    %Using HDPE, so yield strength = 23Mpa
    Sy = 23000000; %in pa
    
    %Optimize bore for SF >= 2.5
    while n < SF 
        
        %Stress at middle of bore.
        %Equation #284 in Analysis Report
        boreStress = 32*maxMoment/(pi*(Do^3-Di^3));%in pa
        n = Sy/boreStress; 
        Do = Do + 0.002;
        Di = Do*0.4;
        
    end
    boreThickness = (Do-Di)/2; 
end

function totalDryWeight = SP_totalDryWeight(ropeWeight, boreDiameter, boreThickness, usableLength)

    %Spool is made of HDPE which has a density of 970 Kg/m^3
    %Source: https://www.plasticseurope.org/en/about-plastics/what-are-plastics/large-family/polyolefins#:~:text=The%20density%20of%20HDPE%20can,and%20tensile%20strength%20than%20LDPE.
    densityHDPE = 970;
    outerWallThickness = 0.05;
    
    %The four terms in this equation are respectively the volumes of: the
    %inner bore, outer barrel, support fin, and outer walls of the spool
    spoolVolume = pi*((boreDiameter/2)^2-((boreDiameter - boreThickness/2)/2)^2)*usableLength + pi*((usableLength*0.6/2)^2-((usableLength*0.6 - boreThickness/2)/2)^2)*usableLength + pi*(((usableLength*0.6-boreThickness/2)/2)^2-(boreDiameter/2)^2)*boreThickness + 2*pi*(usableLength/2)^2;
    
    totalDryWeight = densityHDPE*spoolVolume+ropeWeight;
end

function buoyForce = SP_buoy_force(D, W)
    %The buoys should be able to turn the spool a full revolution every
    %2.5s on release. This number will speed up as rope is released. Alpha
    %is measuered in rad/s
    alpha = 2*pi*1/2.5;
    
    %8.3N is the highest friction force seen acting on the buoys
    Ff = 8.3; % in N
    %Gravity and water density
    g = 9.81;
    p = 1030.49; %Kg/m^3 
    %buoyDiameter = 2*((3*D^4*alpha+D/2*Ff)/(8*32*D/2*p*g))^(1/3)
   %Round 2:
    
    buoyDiameter = 2*((3*alpha*W*D/2)/(16*pi*p*g))^(1/3)
    buoyForce = 8/3*pi*(buoyDiameter/2)^3*p*g;
   
    
end
