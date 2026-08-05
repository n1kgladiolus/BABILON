class_name AccData
extends Resource


@export var USERNAME: String = "name"
@export var PASSWORD: String = "pass"
@export var TRAST: bool = false
@export var avatar: ImageTexture = null
@export var SCOPE: int = 0
@export var PART: int = 0
@export var WINS: int = 0
@export var BUCKS: int = 0
@export var LOG_IN: String = ""
@export var CLAN: String = ""
@export var CLANTEG: String = ""

func to_dict() -> Dictionary:
	return {
		"USERNAME": USERNAME,
		"TRAST": TRAST,
		"SCOPE": SCOPE,
		"PART": PART,
		"WINS": WINS,
		"BUCKS": BUCKS,
		"CLAN": CLAN,
		"CLANTEG" : CLANTEG,
	}


static func from_dict(d: Dictionary) -> AccData:
	var obj = AccData.new()
	obj.USERNAME = d.get("USERNAME", "")
	obj.TRAST = d.get("TRAST", false)
	obj.SCOPE = d.get("SCOPE", 0)
	obj.PART = d.get("PART", 0)
	obj.WINS = d.get("WINS", 0)
	obj.BUCKS = d.get("BUCKS", 0)
	obj.CLAN = d.get("CLAN", 0)
	obj.CLANTEG = d.get("CLANTEG", 0)
	return obj


func avatar_to_base64() -> String:
	if avatar == null:
		return ""
	var img = avatar.get_image()
	var png_buffer = img.save_png_to_buffer()
	return Marshalls.raw_to_base64(png_buffer)


static func avatar_from_base64(b64: String) -> ImageTexture:
	if b64 == "":
		return null
	var png_data = Marshalls.base64_to_raw(b64)
	var img = Image.new()
	var err = img.load_png_from_buffer(png_data)
	if err == OK:
		return ImageTexture.create_from_image(img)
	return null
