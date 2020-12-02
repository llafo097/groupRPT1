function SP_code(depth)

%Make functions for your calculations below and bring it all together in this main function
disp('SP_code checking in.')
new_var = SP_rope_volume(depth);

fprintf('depth: %d \nVolume: %d \n',depth,new_var);

end

function ropeVolume = SP_rope_volume(depth)
    
    %Packing efficiency of discs is found to be 0.9069 which applies to
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
function SP_rope_weight(depth)

end