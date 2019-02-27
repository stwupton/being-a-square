extends KinematicBody2D

const GRAVITY = 40

export(float) var jump_force = 600
export(float) var movement_speed = 200
export(float) var max_movement_speed = 500
export(float) var increased_movement_scale = 1.7
export(float) var increased_jump_force_scale = 1.6
export(float) var ground_friction = 40
export(float) var air_resistance = 5
export(int) var coyote_time = 2

var _movement = Vector2()
var _gravity_scale = 1
var _speed_platforms = []
var _jump_platforms = []
var _anti_gravity_waves = []
var _scaled_max_movement_speed = [max_movement_speed, max_movement_speed]
var _was_on_floor = false
var _coyote_count = 0

func _ready():
	set_process_input(true)
	set_physics_process(true)
	
func _physics_process(delta):
	if _anti_gravity_waves.empty():
		_handle_vertical_movement(delta)
		_handle_horizontal_movement(delta)
	else:
		_handle_anti_gravity_movement(delta)
		
	_movement = move_and_slide(_movement, Vector2(0, -1))
	
func _handle_vertical_movement(delta):
	# Check if player can coyote jump.
	var can_coyote_jump = false
	if _movement.y > 0 && _was_on_floor && _coyote_count <= coyote_time:
		can_coyote_jump = true
		_coyote_count += 1
	else:
		_was_on_floor = is_on_floor()
		_coyote_count = 0
		
	
	# Initiate jump.
	if Input.is_action_just_pressed('ui_up') && (is_on_floor() || can_coyote_jump):
		_movement.y -= jump_force if _jump_platforms.empty() else jump_force * increased_jump_force_scale
	
	# Change gravity scale.
	if Input.is_action_pressed('ui_up') && _movement.y < 0:
		_gravity_scale = .4
	else:
		_gravity_scale = 1

	# Apply downward thrust.
	if Input.is_action_pressed('ui_down'):
		_movement.y += jump_force
		
	# Apply gravity.
	if _anti_gravity_waves.empty():
		_movement.y += GRAVITY * _gravity_scale
	
func _handle_horizontal_movement(delta):
	if _movement.x != 0:
		# Apply are or ground resistance.
		var resistance_scalar = -1 if _movement.x > 0 else 1
		if is_on_floor():
			if abs(_movement.x) > ground_friction:
				_movement.x += ground_friction * resistance_scalar
			else:
				_movement.x = 0
		else:
			if abs(_movement.x) > air_resistance:
				_movement.x += air_resistance * resistance_scalar
			else:
				_movement.x = 0
				
		# Increase max movement speed if on a speed platform.
		var platform_direction = 0
		for platform in _speed_platforms:
			platform_direction += platform.direction
		if platform_direction > 0:
			_scaled_max_movement_speed[0] = (max_movement_speed * increased_movement_scale) - max_movement_speed
			_scaled_max_movement_speed[1] = max_movement_speed * increased_movement_scale
		elif platform_direction < 0:
			_scaled_max_movement_speed[0] = max_movement_speed * increased_movement_scale
			_scaled_max_movement_speed[1] = (max_movement_speed * increased_movement_scale) - max_movement_speed
		elif is_on_floor():
			_scaled_max_movement_speed = [max_movement_speed, max_movement_speed]
	
	if Input.is_action_pressed('ui_left'):
		_movement.x += -movement_speed
	if Input.is_action_pressed('ui_right'):
		_movement.x += movement_speed
		
	_movement.x = clamp(_movement.x, -_scaled_max_movement_speed[0], _scaled_max_movement_speed[1])
	
func _handle_anti_gravity_movement(delta):
	var ray_length = 32
	var space_state = get_world_2d().get_direct_space_state()
	var gp = global_position
	var ignore = [self]
	for wave in _anti_gravity_waves:
		ignore.append(wave)
		
	# Check all for sides for a wall.
	var hit = false
	var ray_positions = [
		Vector2(gp.x, gp.y - ray_length),
		Vector2(gp.x + ray_length, gp.y),
		Vector2(gp.x, gp.y + ray_length),
		Vector2(gp.x - ray_length, gp.y)
	]
	for i in range(ray_positions.size()):
		var result = space_state.intersect_ray(gp, ray_positions[i], ignore)
		if !result.empty():
			if result.collider is StaticBody2D:
				hit = true
			else:
				ignore.append(result.collider)
				--i

	var direction = Vector2()
	if hit:
		if Input.is_action_just_pressed('ui_up'):
			direction.y -= 1
		if Input.is_action_just_pressed('ui_right'):
			direction.x += 1
		if Input.is_action_just_pressed('ui_down'):
			direction.y += 1
		if Input.is_action_just_pressed('ui_left'):
			direction.x -= 1
		direction = direction.normalized()
		
	_movement += direction * jump_force

func apply_platform_speed_increase(platform):
	_speed_platforms.append(platform)
	
func remove_platform_speed_increase(platform):
	if _speed_platforms.has(platform):
		_speed_platforms.remove(_speed_platforms.find(platform))
		
func apply_jump_force_increase(platform):
	_jump_platforms.append(platform)
	
func remove_jump_force_increase(platform):
	if _jump_platforms.has(platform):
		_jump_platforms.remove(_jump_platforms.find(platform))
		
func apply_anti_gravity(platform):
	_anti_gravity_waves.append(platform)
	
func remove_anti_gravity(platform):
	if _anti_gravity_waves.has(platform):
		_anti_gravity_waves.remove(_anti_gravity_waves.find(platform))
		
func reset_movement():
	_movement = Vector2()

