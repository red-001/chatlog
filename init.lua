local modstorage = core.get_mod_storage()
if modstorage:get_string("setup") == "" then
	modstorage:set_string("timestamp","%H:%M")
	modstorage:set_string("setup","finished")
end

local function log_message(message)
	local id = modstorage:get_int("chat_message_id")
	print("Debug: current id " .. id)
	if id == -1 then id = 0 end
	
	local format = modstorage:get_string("timestamp")
	local time = os.time()
	message = os.date(format, time) .. message

	modstorage:set_string(id, message)
	modstorage:set_int("chat_message_id", id + 1)
end

core.register_on_receiving_chat_messages(function(message)
	if modstorage:get_string("disable") == "true" then
		return
	end

	log_message(message)
end)

core.register_on_sending_chat_messages(function(message)
	if modstorage:get_string("disable") == "true" then
		return
	end
	if modstorage:get_string("enable_local_log") == "true" then
		log_message(message)
	end
end)

local function read_log(param)
	param = tonumber(param)
	if not param then
		return false, "Display [number of messages]"
	end

	local current_id = modstorage:get_int("chat_message_id")
	if current_id == -1 then return end
	local id = current_id - math.floor(param)
	if id < 0 then id = 0 end

	minetest.display_chat_message("**Starting to read log**")
	for i = id, current_id, 1 do
		minetest.display_chat_message(modstorage:get_string(i))
	end

	return true, "**Finished reading log**"
end

local function display_help()
	minetest.display_chat_message("Help: show this help message")
	minetest.display_chat_message("On: Turn logging on (default)")
	minetest.display_chat_message("Off: Turn logging off")
	minetest.display_chat_message("Clear: Clear chat log")
	minetest.display_chat_message("Display: Shows logged messages")
	minetest.display_chat_message("Timestamp: Set the timestamp the mod should use (lua os.date format)")
	minetest.display_chat_message("Enable_local_log: needed to log messages sent by the local player on servers that don't use recent dev")
	minetest.display_chat_message("Disable_local_log: needed to prevent double logging of local player messages on servers with recent dev (default)")
end

minetest.register_chatcommand("chatlog", {
	func = function(param)
		paraml = param:lower()

		if paraml:sub(1,4) == "help" then
			display_help()
		elseif paraml:sub(1,2) == "on" then
			modstorage:set_string("disable", "false")
			return true, "Turned logging on"
		elseif paraml:sub(1,3) == "off" then
			modstorage:set_string("disable", "true")
			return true, "Turned logging off"
		elseif paraml:sub(1,7) == "display" then
			return read_log(paraml:sub(8))
		elseif paraml:sub(1,16) == "enable_local_log" then
			modstorage:set_string("enable_local_log", "true")
			return true, "Enabled local logging"
		elseif paraml:sub(1,17) == "disable_local_log" then
			modstorage:set_string("enable_local_log", "false")
			return true, "Disabled local logging"
		elseif paraml:sub(1,5) == "clear" then
			modstorage:set_int("chat_message_id", -1)
			return true, "Cleared log"
		elseif paraml:sub(1,9) == "timestamp" then
			modstorage:set_string("timestamp", param:sub(10))
		else
			minetest.display_chat_message("Invalid Arguments")
			display_help()
		end
		
	end,
})
