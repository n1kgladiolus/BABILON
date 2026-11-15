extends HBoxContainer
class_name PlayerRow

## Плашка одного игрока: подпись с ID + ползунок громкости.


signal volume_changed(value: float)

@onready var id_label: Label = $IDLabel
@onready var volume_slider: HSlider = $VolumeSlider

var peer_id: int = -1


func _ready() -> void:
	volume_slider.min_value = 0.0
	volume_slider.max_value = 5.0
	volume_slider.step = 0.01
	volume_slider.value = 2.0
	volume_slider.value_changed.connect(_on_slider_changed)


func setup(id: int) -> void:
	peer_id = id
	id_label.text = "Игрок %d" % id


func _on_slider_changed(value: float) -> void:
	volume_changed.emit(value)
