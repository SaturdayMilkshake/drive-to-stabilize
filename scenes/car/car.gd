extends CharacterBody2D

@onready var timer: Node = $Timer
@onready var car_sprite: Node = $CarSprite

@export_file("*.png") var car_sprite_path: String = ""

@export var driver_name: String = ""

@export var car_speed: Vector2 = Vector2(0, 100)
@export var car_acceleration: int = 1

@export var max_player_x_speed: int = 512

@export var max_car_speed: int = 200

@export var player_controlled: bool = false

@export var finish_distance: int = -35000

#Arduino Specific
var serial: GdSerial

func _ready() -> void:
	car_sprite.texture = load(car_sprite_path)
	
	if player_controlled:
		initialize_player_controlled_car()
	timer.start()

func _physics_process(delta: float) -> void:
	if player_controlled:
		process_player_controlled_car(delta)
		car_speed.y += car_acceleration
	car_speed.y = min(car_speed.y, max_car_speed)

	if self.global_position.x < 416:
		if !player_controlled:
			car_speed.x = randi_range(0, 80)
		car_speed.y = lerp(car_speed.y, 0.0, 0.02)
	elif self.global_position.x > 1504:
		if !player_controlled:
			car_speed.x = randi_range(0, -80)
		car_speed.y = lerp(car_speed.y, 0.0, 0.02)
		
	if is_on_wall() && player_controlled:
		car_speed.y = lerp(car_speed.y, 0.0, 0.1)
		
	velocity.x = car_speed.x
	velocity.y = -car_speed.y

	move_and_slide()
	
	if self.global_position.y <= finish_distance:
		SignalHandler.emit_signal("car_finished", driver_name)

func initialize_player_controlled_car() -> void:
	serial = GdSerial.new()
	serial.set_port("/dev/ttyACM0")
	serial.set_baud_rate(9600)
	
	var camera: Camera2D = Camera2D.new()
	add_child(camera)
	camera.make_current()
	camera.position = Vector2(0, -192)
	camera.zoom = Vector2(0.50, 0.50)
	
	car_speed = Vector2.ZERO

func process_player_controlled_car(delta: float) -> void:
	if Input.is_action_pressed("drive_left"):
		car_speed.x -= 20
		if car_speed.x < -max_player_x_speed:
			car_speed.x = -max_player_x_speed
	if Input.is_action_pressed("drive_right"):
		car_speed.x += 20
		if car_speed.x > max_player_x_speed:
			car_speed.x = max_player_x_speed
	else:
		if serial.open():
			var result: int = int(serial.readline())
			result -= 512
			car_speed.x = -result
			serial.close()
		car_speed.x = lerp(car_speed.x, 0.0, 0.005)

func randomize_speed_interval() -> void:
	if !player_controlled:
		car_speed.x = randi_range(-80, 80)
		car_speed.y = randi_range(25, 300)

func _on_timer_timeout() -> void:
	if !player_controlled:
		randomize_speed_interval()
	SignalHandler.emit_signal("update_position", driver_name, self.global_position.y)

func correct_car_angle() -> void:
	pass

func check_collision_boundaries() -> void:
	pass
