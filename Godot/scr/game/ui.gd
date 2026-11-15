extends CanvasLayer
@onready var pole_help: Array = [
	preload("res://image/figures_market/peshk_pole.png"),
	preload("res://image/figures_market/kon_pole.png"),
	preload("res://image/figures_market/slon_pole.png"),
	preload("res://image/figures_market/lada_pole.png"),
	]

var up_lock: bool = false

@onready var peshk: Button = $ui_node/UP_PANEL/UP_PANEL/ramka/Margin/box/shops/shop/VBox/HBoxContainer2/HBoxContainer/peshk
@onready var kon: Button = $ui_node/UP_PANEL/UP_PANEL/ramka/Margin/box/shops/shop/VBox/HBoxContainer2/HBoxContainer/kon
@onready var slon: Button = $ui_node/UP_PANEL/UP_PANEL/ramka/Margin/box/shops/shop/VBox/HBoxContainer2/HBoxContainer/slon
@onready var lada: Button = $ui_node/UP_PANEL/UP_PANEL/ramka/Margin/box/shops/shop/VBox/HBoxContainer2/HBoxContainer/lada
@onready var peshk_fan: Button = $ui_node/UP_PANEL/UP_PANEL/ramka/Margin/box/shops/shop2/VBox/HBoxContainer2/HBoxContainer2/peshk_fan
@onready var kon_fan: Button = $ui_node/UP_PANEL/UP_PANEL/ramka/Margin/box/shops/shop2/VBox/HBoxContainer2/HBoxContainer2/kon_fan
@onready var slon_fan: Button = $ui_node/UP_PANEL/UP_PANEL/ramka/Margin/box/shops/shop2/VBox/HBoxContainer2/HBoxContainer2/slon_fan
@onready var lada_fan: Button = $ui_node/UP_PANEL/UP_PANEL/ramka/Margin/box/shops/shop2/VBox/HBoxContainer2/HBoxContainer2/lada_fan

@onready var karta: TextureRect = $ui_node/UP_PANEL/UP_PANEL/ramka/Margin/box/info/koloda/VBoxContainer/karta

@onready var popup_fig: PanelContainer = $ui_node/Popup_fig
@onready var popup_kart: PanelContainer = $ui_node/Popup_kart

@onready var ui_node: Control = $ui_node


func _ready() -> void:
	peshk.mouse_entered.connect(help_entered.bind("peshk"))
	kon.mouse_entered.connect(help_entered.bind("kon"))
	slon.mouse_entered.connect(help_entered.bind("slon"))
	lada.mouse_entered.connect(help_entered.bind("lada"))
	peshk_fan.mouse_entered.connect(help_entered.bind("peshk_fan"))
	kon_fan.mouse_entered.connect(help_entered.bind("kon_fan"))
	slon_fan.mouse_entered.connect(help_entered.bind("slon_fan"))
	lada_fan.mouse_entered.connect(help_entered.bind("lada_fan"))
	
	peshk.mouse_exited.connect(help_exited.bind("peshk"))
	kon.mouse_exited.connect(help_exited.bind("kon"))
	slon.mouse_exited.connect(help_exited.bind("slon"))
	lada.mouse_exited.connect(help_exited.bind("lada"))
	peshk_fan.mouse_exited.connect(help_exited.bind("peshk_fan"))
	kon_fan.mouse_exited.connect(help_exited.bind("kon_fan"))
	slon_fan.mouse_exited.connect(help_exited.bind("slon_fan"))
	lada_fan.mouse_exited.connect(help_exited.bind("lada_fan"))
	
	karta.mouse_entered.connect(help_k_entered)
	karta.mouse_exited.connect(help_k_exited)
	
	$ui_node/UP_PANEL.mouse_entered.connect(func():
		if up_lock:
			return
		var tween_1 = create_tween()
		var tween_2 = create_tween()
		tween_1.tween_property($ui_node/UP_PANEL/UP_PANEL, "modulate:a", 1.0, 0.3)
		tween_2.tween_property($ui_node/UP_PANEL/UP_PANEL, "position:y", 0.0, 0.3)
		)
	$ui_node/UP_PANEL.mouse_exited.connect(func():
		if up_lock:
			return
		var tween_1 = create_tween()
		var tween_2 = create_tween()
		tween_1.tween_property($ui_node/UP_PANEL/UP_PANEL, "modulate:a", 0.3, 0.3)
		tween_2.tween_property($ui_node/UP_PANEL/UP_PANEL, "position:y", -132.0, 0.3)
		)
	
	$ui_node/UP_PANEL/UP_PANEL/lock_b.toggled.connect(func(mode):
		up_lock = mode
		)

func _process(delta: float) -> void:
	pass

func help_entered(fig):
	match fig:
		"peshk" : 
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_name.text = "Пешка"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/HBoxContainer/info_2.text = "12\n1d6\n0\n2\n12"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_3.text = ""
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/pole_help_texture.texture = pole_help[0]
		"peshk_fan" : 
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_name.text = "Самурай"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/HBoxContainer/info_2.text = "12\n1d6\n0\n2\n24"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_3.text = "Может защитить от революции. Собирают +1 монету. Умирают вместе с королём."
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/pole_help_texture.texture = pole_help[0]
		"kon" : 
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_name.text = "Конь"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/HBoxContainer/info_2.text = "18\n1d6+1\n0\n3\n30"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_3.text = ""
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/pole_help_texture.texture = pole_help[1]
		"kon_fan" : 
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_name.text = "Шахид"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/HBoxContainer/info_2.text = "18\n1d6+1\n0\n2\n48"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_3.text = "Может взорвать вместе с собой фигуру в средней клетке."
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/pole_help_texture.texture = pole_help[1]
		"slon" : 
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_name.text = "Слон"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/HBoxContainer/info_2.text = "24\n1d6\n2\n2\n36"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_3.text = ""
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/pole_help_texture.texture = pole_help[2]
		"slon_fan" : 
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_name.text = "Священник"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/HBoxContainer/info_2.text = "24\n1d6\n2\n2\n60"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_3.text = "Может захватывать фигуры. Может воскресить любого короля за 30 монет."
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/pole_help_texture.texture = pole_help[2]
		"lada" : 
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_name.text = "Ладья"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/HBoxContainer/info_2.text = "30\n1d6+2\n0\n1\n90"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_3.text = ""
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/pole_help_texture.texture = pole_help[3]
		"lada_fan" : 
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_name.text = "ЭПИЧЕСКИ БОЛЬШАЯ ПУШКА!!! (ЭБП)"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/HBoxContainer/info_2.text = "30\n1d6+2\n0\n1\n90"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/info_3.text = "Если зарядить за 36 монет, может выстрелить в любую клетку снарядом <Ромашка>"
			$ui_node/Popup_fig/MarginContainer/HBoxContainer2/HBoxContainer/pole_help_texture.texture = pole_help[3]
		_ : pass
	
	popup_fig.size = Vector2(512, 256)
	popup_fig.global_position = ui_node.get_global_mouse_position() + Vector2(6, 6)
	popup_fig.visible = true

func help_exited(fig):
	popup_fig.visible = false


func help_k_entered():
	if karta.texture != null:
		$ui_node/Popup_kart/MarginContainer/Texture_kart.texture = karta.texture
		popup_kart.global_position = ui_node.get_global_mouse_position() + Vector2(6, 6)
		popup_kart.visible = true

func help_k_exited():
	popup_kart.visible = false

























#
