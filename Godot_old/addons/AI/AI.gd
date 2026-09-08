extends Node3D

@onready var target := $"../../Target"
@onready var body := $Body

var time := 0.0

var total_rotation = Vector3.ZERO
var prev_rotation = Vector3.ZERO
var total_turns = 0

var weight := {}
var info := {}
var exit := {}
var layers := []

const H_layers = 3

var action = {
	"right": func(force): right(force),
	"left": func(force): left(force),
	"forward": func(force): forward(force),
	"backward": func(force): backward(force)
}

func right(force):
	body.apply_impulse(body.transform.basis.y * abs(force), $Body/Area3D/Collision/Right.global_position)

func left(force):
	body.apply_impulse(body.transform.basis.y * abs(force), $Body/Area3D/Collision/Left.global_position)

func forward(force):
	body.apply_impulse(body.transform.basis.y * abs(force), $Body/Area3D/Collision/Forward.global_position)

func backward(force):
	body.apply_impulse(body.transform.basis.y * abs(force), $Body/Area3D/Collision/Backward.global_position)

class Neuron:
	var name: String
	var value: float
	var weights: Dictionary
	
	func _init(title: String, val: float = 0.0):
		name = title
		value = val
		value = activate(value)
		
	func activate(x: float, alpha: float = 0.01):
		return x if x > 0 else alpha * x
	
	func add(number: float = 0.0):
		value += number
	
	func zero():
		value = 0
	
	func exit(target: String):
		return activate(value, 0.1)*weights[target]
		
class Layer:
	var number: int
	var size: int
	var neurons: Array
	var layers
	var Use: String
	var Act: Callable
	
	func _init(weight: Dictionary, layer: Array, n_amount: int = 0, num: int = 0, use: String = "hidden", act: Callable = Callable()):
		layers = layer
		Use = use
		Act = act
		
		match use:
			"info":
				var information = act.call()
				size = information.size()
				number = 0
				for i in range(size):
					neurons.append(Neuron.new(information.keys()[i], information[information.keys()[i]]))
			"hidden":
				size = n_amount
				number = num
				for i in layers[number-1].neurons:
					if weight.has(i.name):
						i.weights = weight[i.name]
					else:
						weight[i.name] = {}
						for j in range(size):
							weight[i.name][str(number) + "_" + str(j)] = randf_range(-2, 2)
						i.weights = weight[i.name]
				for i in range(size):
					neurons.append(Neuron.new(str(number) + "_" + str(i), calculate(str(number) + "_" + str(i))))
			"exit":
				size = n_amount
				number = num
				for i in layers[number-1].neurons:
					if weight.has(i.name):
						i.weights = weight[i.name]
					else:
						weight[i.name] = {}
						for j in range(size):
							weight[i.name][act.call().keys()[j]] = randf_range(-2, 2)
						i.weights = weight[i.name]
				for i in range(size):
					neurons.append(Neuron.new(act.call().keys()[i], calculate(act.call().keys()[i])))
		
		for i in neurons:
			print(i.name + ": " + str(i.value))
	
	func think():
		match Use:
			"info":
				for i in range(neurons.size()):
					var x = Act.call().keys()[i]
					neurons[i].add(Act.call()[x])
			"hidden":
				for i in neurons:
					i.zero()
					for j in layers[number-1].neurons:
						i.add(j.exit(i.name))
			"exit":
				for i in range(Act.call().size()):
					Act.call()[Act.call().keys()[i]].call(neurons[i].activate(neurons[i].value))
	
	func calculate(name: String):
		var answer := 0.0
		for i in layers[number-1].neurons:
			answer += i.exit(name)
		return answer

func H_N_amount():
	return int((info.size()+exit.size())/2)

func update_info():
	info = {
		"rotX": body.rotation.x/PI,
		"rotY": body.rotation.y/PI,
		"rotZ": body.rotation.z/PI,
		
		"distX": (max((body.position.x-target.position.x), 0.0))/80,
		"distY": (max((body.position.y-target.position.y), 0.0))/80,
		"distZ": (max((body.position.z-target.position.z), 0.0))/80,
		
		"dist-X": (max(-(body.position.x-target.position.x), 0.0))/80,
		"dist-Y": (max(-(body.position.y-target.position.y), 0.0))/80,
		"dist-Z": (max(-(body.position.z-target.position.z), 0.0))/80,

		"bias": 1.0
	}
	
	return info

func act():
	return action

func _ready() -> void:
	await get_tree().process_frame
	update_info()
	
	layers.append(Layer.new(weight, layers, 0, 0, "info", update_info))
	print("---------------------------")
	layers.append(Layer.new(weight, layers, H_N_amount(), 1))
	print("---------------------------")
	layers.append(Layer.new(weight, layers, H_N_amount(), 2))
	print("---------------------------")
	layers.append(Layer.new(weight, layers, H_N_amount(), 3))
	print("---------------------------")
	layers.append(Layer.new(weight, layers, action.size(), 4, "exit", act))


func _physics_process(delta: float) -> void:
	update_info()
	normalize_global_rotation(body)
	
	time += delta
	
	for i in layers:
		i.think()

func normalize_global_rotation(obj: Node3D):
	var diff = obj.global_rotation - prev_rotation
	
	if diff.x > PI: diff.x -= TAU
	elif diff.x < -PI: diff.x += TAU
	
	if diff.y > PI: diff.y -= TAU
	elif diff.y < -PI: diff.y += TAU
	
	if diff.z > PI: diff.z -= TAU
	elif diff.z < -PI: diff.z += TAU
	
	total_rotation += diff
	prev_rotation = obj.global_rotation
	
	if abs(total_rotation.x) >= TAU or abs(total_rotation.y) >= TAU or abs(total_rotation.z) >= TAU:
		total_rotation = Vector3.ZERO
		total_turns += 1
	
	obj.global_rotation.x = fmod(obj.global_rotation.x, TAU)
	if obj.global_rotation.x < 0: obj.global_rotation.x += TAU
	
	obj.global_rotation.y = fmod(obj.global_rotation.y, TAU)
	if obj.global_rotation.y < 0: obj.global_rotation.y += TAU
	
	obj.global_rotation.z = fmod(obj.global_rotation.z, TAU)
	if obj.global_rotation.z < 0: obj.global_rotation.z += TAU
