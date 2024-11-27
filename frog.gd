extends Mob

func _start():
	pass


func _on_kill_zone_body_entered(body: Node2D) -> void:
	body_entered_killzone(body)
