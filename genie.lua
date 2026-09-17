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


-- original genie.lua from engine repo
--[[

if build_luau then
	printf("Using Luau from external/_repos/luau (build from source code)")
	project "Luau"
		if luau_dynamic then
			kind "SharedLib"
		else
			kind "StaticLib"
		end
		files { "../external/_repos/luau/Ast/src/**.cpp"
			, "../external/_repos/luau/Ast/src/**.h"
			, "../external/_repos/luau/CodeGen/src/**.cpp"
			, "../external/_repos/luau/CodeGen/src/**.h"
			, "../external/_repos/luau/Common/src/**.cpp"
			, "../external/_repos/luau/Common/src/**.h"
			, "../external/_repos/luau/Compiler/src/**.cpp"
			, "../external/_repos/luau/Compiler/src/**.h"
			, "../external/_repos/luau/VM/src/**.cpp"
			, "../external/_repos/luau/VM/src/**.h"
		}

		if not luau_dynamic then
			files { "../external/_repos/luau/Analysis/src/**.cpp"
				, "../external/_repos/luau/Analysis/src/**.h"
				, "../external/_repos/luau/Config/src/**.cpp"
				, "../external/_repos/luau/Config/src/**.h"
			}

			includedirs { "../external/_repos/luau/Analysis/include/" 
				, "../external/_repos/luau/Config/include/"
			}
		end

		includedirs { "../external/_repos/luau/Ast/include/"
			, "../external/_repos/luau/CodeGen/include/"
			, "../external/_repos/luau/Common/include/"
			, "../external/_repos/luau/Compiler/include/"
			, "../external/_repos/luau/VM/include/"
			, "../external/_repos/luau/VM/src/"
		}

		removeflags { "NoExceptions", "NoRTTI" }
		configuration { "RelWithDebInfo" }
			flags { "OptimizeSize", "ReleaseRuntime", "Symbols" }

		configuration { "Debug" }
			flags { "OptimizeSize", "ReleaseRuntime", "Symbols" }

		configuration { "linux"}
			targetdir "../external/luau/lib/linux"

		configuration { "windows" }
			targetdir "../external/luau/lib/win"
			defines {
				"_CRT_SECURE_NO_WARNINGS",
				"LUA_API=__declspec(dllexport)",
				"LUACODE_API=__declspec(dllexport)"
			}
			buildoptions_cpp { "/wd4267" }
		configuration {}

	if not luau_dynamic then
		solution "LumixEngine"
			configuration { "vs20*" }
			defines { "LUMIX_LUAU_ANALYSIS" }
			configuration {}
	end
else	
	printf("Using Luau from external/luau (prebuilt)")
end

]]--