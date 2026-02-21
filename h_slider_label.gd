extends HBoxContainer

@onready var label: Label = $Label
@onready var value_readout: Label = $ValueReadout
@onready var slider: HSlider = $Slider

@export_range(-1000, 1000) var minimum
@export_range(-1000, 1000) var maximum

@export var value: float:
    set(p_new):
        value = p_new
        notify_property_list_changed()
        if not slider:
            return
        slider.value = p_new

@export var enabled: bool = true:
    set(p_new):
        enabled = p_new
        notify_property_list_changed()
        if not slider:
            return
        slider.editable = enabled

@export var format_string: String = "%.f"

signal value_changed(value: float)


func _ready():
    label.text = name
    slider.min_value = minimum
    slider.max_value = maximum
    slider.step = (maximum - minimum) / 100.0
    self.enabled = enabled
    self.value = value


func _on_slider_value_changed(new_value: float) -> void:
    if not enabled:
        return
    value_changed.emit(new_value)
    value_readout.text = format_string % new_value
