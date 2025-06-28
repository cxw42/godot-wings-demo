extends HBoxContainer

@onready var label: Label = $Label
@onready var value_readout: Label = $ValueReadout
@onready var slider: HSlider = $Slider

@export_range(-1000,1000) var minimum
@export_range(-1000,1000) var maximum

@export var format_string: String = "%.f"

signal value_changed(value: float)

func _ready():
    label.text = name
    slider.min_value = minimum
    slider.max_value = maximum
    slider.step = (maximum-minimum)/100.0

func _on_slider_value_changed(value: float) -> void:
    value_changed.emit(value)
    value_readout.text = format_string % value
