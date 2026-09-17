if plugin "lua" then
	if not _OPTIONS["luau-dynamic"] then
		defines { "LUMIX_STATIC_LUAU" }
	end

	configuration { "vs20*" }
		libdirs { "../plugins/lua/external/luau/lib/win" }
		linkLib "Luau"

	configuration { "linux" }
		libdirs { "../plugins/lua/external/luau/lib/linux" }
		linkLib "Luau"

	configuration {}

	files {
		"src/**.h",
		"src/**.cpp",
		"genie.lua"
	}
	includedirs { "../plugins/lua/external/luau/include", "../src", "../plugins/lua/src" }
	defines { "BUILDING_LUA" }
	dynamic_link_plugin { "core", "engine" }

	if hasPlugin "renderer" then
		dynamic_link_plugin { "renderer" }
	end

	local function link_luau_to_target()
		links { "Luau" }
		configuration { "vs20*" }
			libdirs { "../plugins/lua/external/luau/lib/win" }
			files { "../plugins/lua/external/luau/lib/win/Luau.dll" }
			copy { "../plugins/lua/external/luau/lib/win/Luau.dll" }
		configuration { "linux" }
			libdirs { "../plugins/lua/external/luau/lib/linux" }
		configuration {}
	end
	build_app_callbacks[#build_app_callbacks + 1] = link_luau_to_target
	build_studio_callbacks[#build_studio_callbacks + 1] = link_luau_to_target
	if build_tests then
		build_tests_callbacks[#build_tests_callbacks + 1] = link_luau_to_target
	end

	project "meta"
		files { "src/meta_lua.cpp" }
end
