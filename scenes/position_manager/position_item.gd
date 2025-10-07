class_name PositionItem
extends Control

@export var player_item: bool = false

@export var icon_texture: Texture = null
@export var item_name: String = ""
@export var inital_score: int = 0

@export var lap_step_length: float = 2500.0
@export var pit_step_length: float = 600.0

@export var pit_entry_point: int = 1
@export var pit_stoppage_point: int = 1
@export var pit_exit_point: int = 1

@export var max_pit_stops: int = 2

@export var driver_performace_weight: int = 1

@onready var icon: Node = $Icon
@onready var position_name: Node = $PositionName
@onready var data_displayer: Node = $DataDisplayer
@onready var finish_rect: Node = $FinishRect
@onready var fastest_lap_rect: Node = $FastestLapRect
@onready var lap_time_offset: Node = $LapTimeOffset
@onready var background: Node = $Background

@onready var tire_label: Node = $TireLabel

@onready var pit_timer: Node = $PitTimer

@onready var animation_player: Node = $AnimationPlayer

var success_probability: int = 100

var current_score: int = 0
var current_lap: int = 1
var max_laps: int = 1

var pit_score: int = 0

var tire_type: String = "Soft"
var tire_options: Array = ["Soft", "Medium", "Hard"]
var tire_age: int = 0

var lap_time: float = 0.0
var total_lap_time: float = 0.0
var final_lap_time: float = 0.0
var pit_time: float = 0.0
var pit_stoppage_time: float = 0.0

var processing_active: bool = false
var unsortable: bool = false
var final_lap_time_set: bool = false
var current_fastest_lap: bool = false

var pitting_next_lap: bool = false
var in_pit: bool = false
var pitted: bool = false

var pit_stops: int = 0

enum DriverState {
	NORMAL,
	IN_PIT,
	PITTING,
	FINISHED
}

var driver_state: int = DriverState.NORMAL

func _ready() -> void:
	SignalHandler.connect("update_position", Callable(self, "update_position"))
	SignalHandler.connect("car_finished", Callable(self, "car_finished"))
	current_lap = 1
	icon.texture = icon_texture
	position_name.text = item_name
	current_score = inital_score
	if player_item:
		background.color = Color.MEDIUM_VIOLET_RED

func _physics_process(delta: float) -> void:
	total_lap_time += delta
	
func reset_values() -> void:
	current_score = 0

func get_lap_time() -> float:
	return lap_time

func update_trailing_seconds(seconds: float) -> void:
	if !in_pit:
		lap_time_offset.text = "+%1.3f" % seconds
	else:
		lap_time_offset.text = "IN PIT"

func set_leader_text(text: String) -> void:
	lap_time_offset.text = text

func set_fastest_lap_anim(driver_name: String) -> void:
	if driver_name == item_name:
		current_fastest_lap = true
		animation_player.play("ShowFastestLap")
	else:
		if current_fastest_lap:
			current_fastest_lap = false
			animation_player.play("HideFastestLap")

func update_position(driver_name: String, current_position: int) -> void:
	if driver_name == item_name:
		current_score = current_position
		update_trailing_seconds(abs(current_score / 1000.0))

func car_finished(driver_name: String) -> void:
	if driver_name == item_name && !unsortable:
		unsortable = true
		final_lap_time = total_lap_time
		animation_player.play("ShowFinish")
