----- EXAMPLE EFFECT TYPES -----

playereffects.register_effect_type("high_speed", "high speed", {"speed"}, 
	function(player)
		player:set_physics_override(4,nil,nil)
	end,
	
	function(effect)
		local player = minetest.get_player_by_name(effect.playername)
		player:set_physics_override(1,nil,nil)
	end
)
playereffects.register_effect_type("low_speed", "low speed", {"speed"}, 
	function(player)
		player:set_physics_override(0.25,nil,nil)
	end,
	
	function(effect)
		local player = minetest.get_player_by_name(effect.playername)
		player:set_physics_override(1,nil,nil)
	end
)
playereffects.register_effect_type("highjump", "greater jump height", {"jump"},
	function(player)
		player:set_physics_override(nil,2,nil)
	end,
	function(effect)
		local player = minetest.get_player_by_name(effect.playername)
		player:set_physics_override(nil,1,nil)
	end
)
playereffects.register_effect_type("fly", "fly mode available", {"fly"},
	function(player)
		local playername = player:get_player_name()
		local privs = minetest.get_player_privs(playername)
		privs.fly = true
		minetest.set_player_privs(playername, privs)
	end,
	function(effect)
		local privs = minetest.get_player_privs(effect.playername)
		privs.fly = nil
		minetest.set_player_privs(effect.playername, privs)
	end
)


minetest.register_chatcommand("fast", {
	params = "",
	description = "Makes you fast for a short time.",
	privs = {},
	func = function(name, param)
		playereffects.apply_effect_type("high_speed", 10, minetest.get_player_by_name(name))
	end,
})
minetest.register_chatcommand("slow", {
	params = "",
	description = "Makes you slow for a long time.",
	privs = {},
	func = function(name, param)
		playereffects.apply_effect_type("low_speed", 120, minetest.get_player_by_name(name))
	end,
})
minetest.register_chatcommand("highjump", {
	params = "",
	description = "Makes you jump higher for a short time.",
	privs = {},
	func = function(name, param)
		playereffects.apply_effect_type("highjump", 20, minetest.get_player_by_name(name))
	end,
})

minetest.register_chatcommand("fly", {
	params = "",
	description = "Grants you the fly privilege for a short time.",
	privs = {},
	func = function(name, param)
		playereffects.apply_effect_type("fly", 20, minetest.get_player_by_name(name))
	end,
})