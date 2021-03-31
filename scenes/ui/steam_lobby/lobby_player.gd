extends HBoxContainer
var uid = 0
var blank = preload("res://godot_tools/CommonAssets/buttons/qmark.png")

func set_player(friendID):
	if friendID == null:
		$PlayerProfile.texture = blank
		$player.text = "empty spot"
		return
	$player.set("custom_colors/font_color", Color.white)
	uid = friendID
	$player.text = Steam.getFriendPersonaName(friendID)
	Steam.connect("avatar_loaded", self, "loaded_avatar")
	Steam.getPlayerAvatar(2, friendID)
	
func set_ready():
	$player.set("custom_colors/font_color", Color.limegreen)

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

