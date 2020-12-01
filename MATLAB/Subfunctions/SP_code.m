function SP_code()

%Make functions for your calculations below and bring it all together in this main function
disp('SP_code checking in.')

end

function SP_rope_volume(depth)
    
    %Packing efficiency of discs is found to be 0.9069 which applies to
    %   stacked rope.
    %To account for drift the rope length is double the depth of the
    %   system.
    %First half of rope length has 0.8cm diameter; second half has 1cm
    %diameter
    ropeDiam = 0.9
    packingEfficiency = 0.9069
    ropeLength = depth*2
    
end
function SP_rope_weight(depth)

end