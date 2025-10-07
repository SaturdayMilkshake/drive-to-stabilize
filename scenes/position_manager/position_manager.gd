extends Control

var set_delta: float = 0.0033

func _ready() -> void:
	$Timer.start(1)

func update_positions() -> void:
	var position_items: Array = $PositionContainer.get_children()
	
	position_items.sort_custom(sort_positions)

	var index: int = 0
	position_items[0].set_leader_text("Interval")
	for position_item: Node in position_items:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(position_item, "global_position", Vector2(64, 16 + 48 * (index + 1)), 0.5)
		if index < position_items.size() - 1:
			var compared_item: Node = position_items[index + 1]
			if !compared_item.unsortable:
				if position_item.unsortable:
					compared_item.update_trailing_seconds(compared_item.total_lap_time - position_item.final_lap_time)
				else:
					compared_item.update_trailing_seconds((abs(position_item.current_score - compared_item.current_score)) * set_delta + randf_range(0.0, 0.01))
			else:
				compared_item.update_trailing_seconds((compared_item.final_lap_time - position_item.final_lap_time))
		index += 1
	
func sort_positions(original, compared) -> bool:
	#TODO: account for overtaking disallowed
	if original is PositionItem && compared is PositionItem:
		if original.unsortable:
			if compared.unsortable:
				return original.final_lap_time < compared.final_lap_time
			else:
				return true
		elif compared.unsortable:
			return false
		else:
			if original.current_score < compared.current_score:
				return true
			else:
				return false
	else:
		return false

func _on_timer_timeout() -> void:
	update_positions()
