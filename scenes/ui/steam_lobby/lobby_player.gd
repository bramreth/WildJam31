extends HBoxContainer
var uid = 0
var blank = preload("res://godot_tools/CommonAssets/buttons/qmark.png")
export var collapsed = false
var hidden = false
var state = 0
var in_game = false

signal invite(id)
signal join(id)

func _ready():
	$name.visible = not collapsed
	
func collapse():
#	$name/player.clip_text = true
	$name/status.clip_text = true
	$name/player.rect_size.x = 140
	$name.visible = false
	if uid != SteamLobby._my_steam_id:
		$VBoxContainer.visible = false
	
func expand():
	if hidden: return
#	$name/player.clip_text = false
	$name/status.clip_text = false
	$name/player.rect_size.x = 440
	$name.visible = true
	if uid != SteamLobby._my_steam_id:
		$VBoxContainer.visible = true
	
func set_player(friendID, hidden_in = false):
	uid = friendID
	if friendID == null:
		$PlayerProfile.texture = blank
		$name/player.text = "empty spot"
		visible = false
		return
	visible = true
#	print(Steam.getFriendRichPresence(uid))
	$name/player.set("custom_colors/font_color", Color.white)
	$name/player.text = Steam.getFriendPersonaName(friendID)
	Steam.connect("avatar_loaded", self, "loaded_avatar")
	if uid == SteamLobby._my_steam_id:
		$VBoxContainer.visible = false
		$name/status.visible = false
		$PlayerProfile.rect_min_size = Vector2(100,100)
		Steam.getPlayerAvatar(3, friendID)
	else:
		Steam.getPlayerAvatar(2, friendID)
	
	update_data()
	hidden = hidden_in
	collapse()
	
func set_ready():
	$name/player.set("custom_colors/font_color", Color.limegreen)

# Avatar is ready for display
func loaded_avatar(id: int, size: int, buffer: PoolByteArray) -> void:
	if uid != id: return
	Steam.disconnect("avatar_loaded", self, "loaded_avatar")
	print("Avatar for user: "+str(id)+", size: "+str(size))
	
	#Create the image and texture for loading
	var AVATAR: Image = Image.new()
	var AVATAR_TEXTURE: ImageTexture = ImageTexture.new()
	AVATAR.create(size, size, false, Image.FORMAT_RGBAF)
	
	# Lock and draw the image
	AVATAR.lock()
	for y in range(0, size):
		for x in range(0, size):
			var pixel: int = 4 * (x + y * size)
			var r: float = float(buffer[pixel]) / 255
			var g: float = float(buffer[pixel+1]) / 255
			var b: float = float(buffer[pixel+2]) / 255
			var a: float = float(buffer[pixel+3]) / 255
			AVATAR.set_pixel(x, y, Color(r, g, b, a))
	AVATAR.unlock()
	
	# Apply it to the texture
	AVATAR_TEXTURE.create_from_image(AVATAR)
	
	# Display it
	if size == 32:
		$PlayerProfile.set_texture(AVATAR_TEXTURE)
	elif size == 64:
		$PlayerProfile.set_texture(AVATAR_TEXTURE)
	else:
		print("Large Avatar - 128 x 128 pixels (Retrieved as "+str(size)+" pixels)")
		$PlayerProfile.set_texture(AVATAR_TEXTURE)



func _on_invite_pressed():
	emit_signal("invite", uid)


func _on_join_pressed():
	var play_dat = Steam.getFriendGamePlayed(uid)
	if play_dat.has("id") and play_dat.has("lobby"):
		if Steam.getAppID() == play_dat["id"]:
			emit_signal("join", play_dat["lobby"])


func _on_PlayerProfile_gui_input(event):
	if event is InputEventMouseButton and uid == SteamLobby._my_steam_id:
		if event.pressed:
			SteamLobby.leave_lobby()

func update_data():
	if uid == SteamLobby._my_steam_id or uid == null:
		return
	state = Steam.getFriendPersonaState(uid)
	var play_dat = Steam.getFriendGamePlayed(uid)
	if play_dat.has("id") and play_dat.has("lobby"):
		if Steam.getAppID() == play_dat["id"]:
			$VBoxContainer/join.visible = true
			in_game = true
			$name/status.text = "All Out Ammo"
			$name/status.set("custom_colors/font_color", Color.forestgreen)
		else:
			$name/status.text = "in another game"
			$name/status.set("custom_colors/font_color", Color.dodgerblue)
	else:
		if state > 0:
			$name/status.set("custom_colors/font_color", Color.dodgerblue)
			$name/status.text = "online"
		else:
			$name/status.set("custom_colors/font_color", Color.gray)
			$name/status.text = "offline"

func _on_Timer_timeout():
	update_data()
