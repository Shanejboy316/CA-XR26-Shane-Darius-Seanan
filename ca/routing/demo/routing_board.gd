extends Panel

const SESSION = preload("res://routing/routing_session.gd")
const NETWORK = preload("res://routing/routing_network.gd")

var session := SESSION.new()
var choices: Array[String] = []


func _ready() -> void:
	%LeftChoice.pressed.connect(_choose.bind(0))
	%RightChoice.pressed.connect(_choose.bind(1))
	%Continue.pressed.connect(_continue)
	_show_packet("")


func _show_packet(feedback: String) -> void:
	var packet = session.packet
	%Round.text = "Packet 1 of 2  ·  Guided" if session.guided else "Packet 2 of 2  ·  Your turn"
	%Score.text = "Points  %d" % session.score
	%Current.text = _device_name(packet.current_device)
	%Destination.text = packet.destination_ip

	var delivered: bool = packet.is_delivered()
	%Hint.text = session.get_hint()
	%Hint.visible = not %Hint.text.is_empty()
	if delivered:
		feedback += "\nRoute: " + " → ".join(packet.route)
	%Feedback.text = feedback

	%TableSection.visible = not delivered
	%Choices.visible = not delivered
	%Continue.visible = delivered
	%Continue.text = "Play again" if session.is_finished() else "Next packet"
	if not delivered:
		_show_table(packet.current_device)


func _show_table(router: String) -> void:
	var table: Dictionary = NETWORK.TABLES[router]
	var rows := PackedStringArray()
	choices.clear()
	for ip in table:
		var next_hop: String = table[ip]
		rows.append("%s  →  %s" % [ip, _device_name(next_hop)])
		if not choices.has(next_hop):
			choices.append(next_hop)
	%Table.text = "\n".join(rows)
	%LeftChoice.text = _device_name(choices[0])
	%RightChoice.text = _device_name(choices[1])


func _choose(index: int) -> void:
	_show_packet(session.choose_next_hop(choices[index]))


func _continue() -> void:
	if session.is_finished():
		session = SESSION.new()
	else:
		session.start_next_packet()
	_show_packet("")


func _device_name(device: String) -> String:
	if device.is_valid_ip_address():
		return "PC " + device
	return device
