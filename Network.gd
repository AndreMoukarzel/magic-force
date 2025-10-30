extends Node

const PACKET_READ_LIMIT: int = 32

var IS_HOST: bool = false
var LOBBY_ID: int = 0
var LOBBY_MEMBERS: Array = []
var LOBBY_MEMBERS_MAX: int = 10


func _ready() -> void:
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.p2p_session_request.connect(_on_p2p_session_request)


func _process(_delta: float) -> void:
	if LOBBY_ID > 0:
		read_all_p2p_packets()


func create_lobby() -> void:
	if LOBBY_ID == 0:
		IS_HOST = true
		Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, LOBBY_MEMBERS_MAX)


func _on_lobby_created(connect_value: int, this_lobby_id: int) -> void:
	if connect_value == 1:
		LOBBY_ID = this_lobby_id
		
		Steam.setLobbyJoinable(LOBBY_ID, true)
		Steam.setLobbyData(LOBBY_ID, "name", "Lobby Name")
		
		print("CREATED LOBBY: ", LOBBY_ID)
		var _set_relay: bool = Steam.allowP2PPacketRelay(true)


func join_lobby(this_lobby_id: int) -> void:
	Steam.joinLobby(this_lobby_id)


func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		LOBBY_ID = this_lobby_id
		
		get_lobby_members()
		make_p2p_handshake()


func get_lobby_members() -> void:
	LOBBY_MEMBERS.clear()
	
	var num_members: int = Steam.getNumLobbyMembers(LOBBY_ID)
	
	for member in range(num_members):
		var member_steam_id: int = Steam.getLobbyMemberByIndex(LOBBY_ID, member)
		var member_steam_name: String = Steam.getFriendPersonaName(member_steam_id)
		
		LOBBY_MEMBERS.append({"steam_id": member_steam_id, "steam_name": member_steam_name})


func send_p2p_packet(this_target: int, packet_data: Dictionary, send_type: int = 0) -> void:
	var channel: int = 0
	var this_data: PackedByteArray
	
	this_data.append_array(var_to_bytes(packet_data))
	
	if this_target == 0: # 0 is an arbitrary code for "everyone"
		if LOBBY_MEMBERS.size() > 1:
			for member in LOBBY_MEMBERS:
				if member["steam_id"] != Global.STEAM_ID:
					Steam.sendP2PPacket(member["steam_id"], this_data, send_type, channel)
	else:
		Steam.sendP2PPacket(this_target, this_data, send_type, channel)


func _on_p2p_session_request(remote_id: int) -> void:
	var _this_requester: String = Steam.getFriendPersonaName(remote_id)
	Steam.acceptP2PSessionWithUser(remote_id)


func make_p2p_handshake() -> void:
	send_p2p_packet(0, {
		"message": "handshake", "steam_id": Global.STEAM_ID, "username": Global.STEAM_USERNAME
	})

func read_all_p2p_packets(read_count: int = 0) -> void:
	if read_count >= PACKET_READ_LIMIT:
		return
	
	if Steam.getAvailableP2PPacketSize(0) > 0:
		read_p2p_packet()
		read_all_p2p_packets(read_count + 1)


func read_p2p_packet() -> void:
	var packet_size: int = Steam.getAvailableP2PPacketSize(0)
	
	if packet_size > 0:
		var this_packet: Dictionary = Steam.readP2PPacket(packet_size, 0)
		var _packet_sender: int = this_packet["remote_steam_id"]
		var packet_code: PackedByteArray = this_packet["data"]
		var readable_data: Dictionary = bytes_to_var(packet_code)
		
		if readable_data.has("message"):
			match readable_data["message"]:
				"handshake":
					print("Player: ", readable_data["username"], " HAS JOINED!!!")
					get_lobby_members()


func leave_lobby() -> void:
	# If in a lobby, leave it
	if LOBBY_ID != 0:
		# Send leave request to Steam
		Steam.leaveLobby(LOBBY_ID)
		# Wipe the Steam lobby ID then display the default lobby ID and player list title
		LOBBY_ID = 0
		# Close session with all users
		for this_member in LOBBY_MEMBERS:
			# Make sure this isn't your Steam ID
			if this_member['steam_id'] != Global.STEAM_ID:
				# Close the P2P session using the Networking class
				Steam.closeP2PSessionWithUser(this_member['steam_id'])
		# Clear the local lobby list
		LOBBY_MEMBERS.clear()
