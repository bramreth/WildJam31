extends Control


func update_bars(max_health:int, health:int, max_armor:int, armor:int) -> void:
	$HealthBar.max_value = max_health
	$HealthBar.value = health
	$HealthBar/health.text = str(health)
	$ArmorBar.max_value = max_armor
	$ArmorBar.value = armor
	$ArmorBar/armor.text = str(armor)
	if armor <= 0: 
		$ArmorBar.visible = false
