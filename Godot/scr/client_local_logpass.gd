class_name client_local_logpass
extends Resource


@export var USERNAME: String = ""
@export var PASSWORD: String = ""
@export var controls_data: Dictionary = {}

@export var SETTINGS := {
	"S_Master" : 0,
	"S_Background" : -14,
	"S_Action" : -8,
	"S_Voice" : 0,
	"S_Veter" : -5,
	"PTT_BUTTON_NAME" : "ALT",
	"VOX_MODE" : "ON",
	"MICROFONE" : "ON",
	"DED_MODE" : "OFF",
	"COLOR_DED" : {
		"mBear" : Color(0.767, 0.361, 0.0, 1.0),
		"mBull" : Color(0.0, 0.0, 0.996, 1.0),
		"mDragon" : Color(0.0, 0.49, 0.0, 1.0),
		"mEagle" : Color(1.0, 0.961, 0.0, 1.0),
		"mElephant" : Color(0.529, 0.118, 0.863, 1.0),
		"mLion" : Color(0.929, 0.106, 0.141, 1.0),
	},
	
}


# ControlsResource.gd

# --- СОХРАНЕНИЕ ---
# Этот метод заполняет наш словарь controls_data данными из InputMap
func capture_from_input_map() -> void:
	controls_data.clear() # Очищаем словарь перед сохранением
	
	# Получаем список всех действий
	var actions = InputMap.get_actions()
	for action in actions:
		# Получаем массив событий (клавиш, кнопок) для этого действия
		var events = InputMap.action_get_events(action)
		# Копируем события в наш словарь
		# Важно: мы создаем копию событий, а не ссылку на оригинал
		controls_data[action] = events.duplicate(true)

# --- ЗАГРУЗКА ---
# Этот метод применяет настройки из нашего словаря к InputMap
func apply_to_input_map() -> void:
	for action in controls_data:
		# Очищаем существующие события для этого действия в InputMap
		InputMap.action_erase_events(action)
		
		# Добавляем новые события из нашего словаря
		var events = controls_data[action]
		for event in events:
			# Добавляем событие в InputMap
			InputMap.action_add_event(action, event)
