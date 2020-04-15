function direction = Get_direction(name)
    if contains(name,'UL_DR')
        direction = 'UL_DR';
    elseif contains(name,'UR_DL')
        direction = 'UR_DL';
    elseif contains(name,'UD')
        direction = 'UD';
    elseif contains(name,'RL')
        direction = 'RL';
    end
end