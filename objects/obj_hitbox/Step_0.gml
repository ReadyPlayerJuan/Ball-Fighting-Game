/// @desc Move to controller

x = hitbox_controller.x;
y = hitbox_controller.y;

if(spawn_time <= 0) {
	image_xscale = x_size / 64;
	image_yscale = y_size / 64;
} else {
	spawn_time -= delta;
	image_xscale = 0;
	image_yscale = 0;
}

#region Tick entity collision timers
for(var i = ds_list_size(objects_collided_with)-1; i >= 0; i--) {
	var new_time = ds_list_find_value(same_collision_timers, i) - delta;
	
	//Check if timer is finished
	if(new_time <= 0) {
		//Delete item off collision blacklist
		ds_list_delete(same_collision_timers, i);
		ds_list_delete(objects_collided_with, i);
	} else {
		//Replace with lower timer
		ds_list_set(same_collision_timers, i, new_time);
	}
}
#endregion

if(lifetime != -999) {
	lifetime -= delta;
	if(lifetime <= 0) {
		instance_destroy(self);
	}
}