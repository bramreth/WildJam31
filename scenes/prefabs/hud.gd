extends Control


func update_health(health, armor) -> void:
	$HealthDisplay/HealthBar.value = health
	$HealthDisplay/HealthBar/health.text = String(health)
	$HealthDisplay/ArmorBar.value = armor
	$HealthDisplay/ArmorBar/armor.text = String(armor)
