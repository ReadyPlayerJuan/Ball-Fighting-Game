/// @desc ?

switch(orb_movement_state) {
	#region Free Movement
	case OrbMovementState.FREE:
	{
		has_friction = true;
		move_through_walls = false;
		hitbox.damage = 0;
		
		var distance_to_controller = sqrt(sqr(orb_controller.x - x) + sqr(orb_controller.y - y));
		if(distance_to_controller < orb_controller.orb_rotation_distance * 1.3) {
			orb_movement_state = OrbMovementState.ORBITING;
			orb_controller.num_orbs_orbiting++;
		}
		
		event_inherited();
	}
	break;
	#endregion
	#region Launching
	case OrbMovementState.LAUNCHING:
	{
		/*  0: curve timer
			1: curve timer max
			2: acceleration timer
			3: acceleration timer max
			4: max speed
			5: target x
			6: target y
			7: start angle		*/
		
		has_friction = false;
		move_through_walls = false;
		//hitbox.damage = 0.25;
		
		//Check mode
		if(movement_data[0] != -1) {
			//Curve progression
			movement_data[0] = min(movement_data[1], movement_data[0] + delta);
			var prog_curve = 1 - power(movement_data[0] / movement_data[1], 2);
			
			//Velocity progression / acceleration
			movement_data[2] = min(movement_data[3], movement_data[2] + delta);
			var prog_vel = power(movement_data[2] / movement_data[3], 1);
			
			//Angle to target position
			var angle = arctan2(movement_data[6] - y, movement_data[5] - x);
			
			//Set velocity
			x_vel = (prog_vel * movement_data[4] * cos(angle)) + (prog_curve * -100 * cos(orbiting_angle));
			y_vel = (prog_vel * movement_data[4] * sin(angle)) + (prog_curve * -100 * sin(orbiting_angle));
			
			//Check if near the target position
			var distance = sqrt(sqr(movement_data[5] - x) + sqr(movement_data[6] - y));
			if(distance < prog_vel * movement_data[4] * (3 / 60)) {
				//Switch mode, no longer change angle
				movement_data[0] = -1;
				movement_data[1] = angle;
			}
		} else {
			//Move in same angle forever
			
			//Still accelerate
			movement_data[2] = min(movement_data[3], movement_data[2] + delta);
			var prog_vel = power(movement_data[2] / movement_data[3], 1);
			
			//Set velocity
			x_vel = prog_vel * movement_data[4] * cos(movement_data[1]);
			y_vel = prog_vel * movement_data[4] * sin(movement_data[1]);
		}
		
		//Movement and collision code
		event_inherited();
		
		if(collide_terrain_horizontal != 0 || collide_terrain_vertical != 0) {
			orb_movement_state = OrbMovementState.FREE;
		}
	}
	break;
	#endregion
	#region Returning
	case OrbMovementState.RETURNING:
	{
		has_friction = false;
		move_through_walls = true;
		hitbox.damage = 0;
		//show_debug_message("returning");
		//Calculate direction and movement variables
		var angle = arctan2(orb_controller.y - y, orb_controller.x - x) + 0;
		var acceleration = 15000;
		var max_vel = 1500;
		
		//Accelerate
		x_vel += acceleration * cos(angle) * delta;
		y_vel += acceleration * sin(angle) * delta;
		
		//Cap speed
		var vel = sqrt(sqr(x_vel) + sqr(y_vel));
		x_vel *= min(1, max_vel / vel);
		y_vel *= min(1, max_vel / vel);
		
		//Check if near controller
		var distance = sqrt(sqr(orb_controller.x - x) + sqr(orb_controller.y - y));
		if(distance < min(max_vel, vel) * (2 / 60)) {
			//Return to orbit
			orb_movement_state = OrbMovementState.ORBITING;
			//orb_index = orb_controller.num_orbs_orbiting;
			
			orb_controller.num_orbs++;
			orb_controller.num_orbs_orbiting++;
			
			
			ds_list_delete(orb_controller.orbs, ds_list_find_index(orb_controller.orbs, self));
			ds_list_insert(orb_controller.orbs, irandom_range(0, ds_list_size(orb_controller.orbs)-1), self);
		}
		
		//Run movement and collision code
		event_inherited();
	}
	break;
	#endregion
	#region Teleporting
	case OrbMovementState.TELEPORTING:
	{
		/*  0: teleport timer
			1: teleport timer max
			2: teleported
			3: target x
			4: target y	    */
		
		is_visible = false;
		movement_data[0] += delta;
		
		if(movement_data[0] >= movement_data[1]) {
			orb_movement_state = OrbMovementState.FREE;
			is_visible = true;
			
			x = movement_data[3];
			y = movement_data[4];
			
			with(instance_create_layer(x, y, "Instances", obj_circ_hitbox)) {
				hitbox_controller = other;
				hitbox_type = HitboxType.CIRC_TEMP;
				lifetime = 0.1;
				x_size = 64 * 2;
				y_size = 64 * 2;
				damage = 0.25;
				knockback = 300;
			}
		} else if(movement_data[0] >= movement_data[1] / 2 && movement_data[2] == 0) {
			
			//movement_data[2] = 1;
		}
		
		event_inherited();
	}
	break;
	#endregion
}