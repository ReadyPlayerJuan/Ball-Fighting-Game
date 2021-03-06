/// @desc Teleport an orb
/// @arg controller
/// @arg target x
/// @arg target y

with(argument0) {
	if(num_orbs_orbiting > 0) {
		for(var i = ds_list_size(orbs) - 1; i >= 0; i--) {
			var orb = ds_list_find_value(orbs, i);
			if(orb.orb_movement_state == OrbMovementState.ORBITING) {
				with(orb) {
					orb_movement_state = OrbMovementState.TELEPORTING;
					
					orb.x_vel = 0;
					orb.y_vel = 0;
					
					//orbiting_angle = ((orbiting_angle + pi) mod (2*pi)) - pi;
					//var angle = arctan2(mouse_y - y, mouse_x - x);
					//orbiting_angle = (orbiting_angle + angle) / 2;
					
					movement_data[0] = 0; //teleport timer
					movement_data[1] = 0.35; //teleport timer max
					movement_data[2] = 0; //teleported
					movement_data[3] = argument1; //target x
					movement_data[4] = argument2; //target y
				}
				num_orbs_orbiting--;
				break;
			}
		}
	}
}