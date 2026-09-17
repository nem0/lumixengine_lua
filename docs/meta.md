# Lua Meta bindings

The Lua Meta backend turns declarations parsed by [Meta](meta.md) into:

- `src/lua/lua_capi.gen.h` - C++ wrappers and API registration
- `data/scripts/lumix.d.lua` - generated Lua type definitions

The generator is implemented in `src/meta/lua_meta.cpp` and is registered through `META_PLUGIN`, like the other Meta generators. Do not edit generated files directly; change the annotated C++ declaration or the Lua generator and run `scripts\run_meta.bat`.

## Enums

Enums marked with `//@ enum` are exposed under `LumixAPI`. Each enum is a table whose keys are enumerator names and whose values are integers:

```lua
local align = LumixAPI.TextVAlign.MIDDLE
local motion = LumixAPI.D6Motion.FREE
local cursor = LumixAPI.CursorType.HAND
```

Global enums and enums declared within modules are both registered this way.

## Functions and return values

Functions in `//@ functions` blocks and eligible component methods receive generated Lua wrappers.

- A non-`void` return value is the first Lua result.
- A returned `//@ struct` is represented by a table containing its fields.
- A pointer to a `//@ object` is wrapped with `LuaWrapper::pushObject`.
- A non-const reference parameter (`T&`, but not `const T&`) is an in/out parameter and becomes an additional result.

In/out results follow the main return value in declaration order. If the C++ function returns `void`, only the in/out values are returned.

```cpp
//@ function
virtual bool getBounds(EntityRef entity, Vec3& out_min, Vec3& out_max) = 0;
```

```lua
local ok, min, max = this.world:getModule("renderer"):getBounds(entity)
```

Aliases specified with `//@ alias` become the Lua-visible function names.

## Objects

A type marked with `//@ object` has wrappers generated for its `//@ function` methods. Objects can be obtained from module functions or installed in global tables by C++ code.

For example, an object returned by a module can be used directly:

```lua
this.world.ui:getSystem():enableCursor(true)
```

Editor objects such as `SceneView` and `AssetBrowser` can be exposed through the global `Editor` table:

```lua
Editor.scene_view:setViewportPosition(pos)
Editor.asset_browser:openEditor("models/cube.fbx")
```

### Binding an object from C++

Use `LuaWrapper::pushObject`. Its type name must match the C++ type marked with `//@ object` so that Lua receives the generated metatable:

```cpp
lua_getglobal(L, "Editor");
StudioApp::GUIPlugin* scene_view = m_app.getGUIPlugin("scene_view");
LuaWrapper::pushObject(L, scene_view, "SceneView");
lua_setfield(L, -2, "scene_view");

LuaWrapper::pushObject(L, &m_app.getAssetBrowser(), "AssetBrowser");
lua_setfield(L, -2, "asset_browser");
lua_pop(L, 1);
```

Objects hold raw C++ pointers. C++ must guarantee that an object remains alive while Lua can retain its wrapper.

## Structs

A type marked with `//@ struct` is represented as a Lua table. Generated push and argument-conversion functions copy fields between the C++ value and that table.

```lua
local ray = camera.camera:getRay(screen_pos)
local hit = this.world.renderer:castRay(ray, nil)
if hit.is_hit then
	local pos = hit.origin + hit.dir * hit.t
end
```

Pointer and handle fields, such as `Mesh*`, are represented as tables containing lightuserdata rather than as raw userdata. A null pointer may appear as `nil`; check it before passing the handle to another API:

```lua
if hit.mesh ~= nil then
	-- Use the opaque handle only with APIs that accept Mesh.
end
```

## Modules and components

Module functions are registered in `LumixModules` and are exposed through the engine's Lua world/module API. Component properties and functions are registered using the component ID parsed from `//@ component` or `//@ component_struct`.

Property labels are converted to Lua identifiers. Function aliases are used when present. Consult `data/scripts/lumix.d.lua` for the generated names and types rather than guessing them.

## Troubleshooting

- Confirm the declaration is inside the correct Meta block and that the block has `//@ end`.
- Confirm object methods intended for Lua have `//@ function`.
- Ensure the name passed to `LuaWrapper::pushObject` matches the type marked with `//@ object`.
- Regenerate Meta output after changing annotations.
- Inspect `data/scripts/lumix.d.lua` and `src/lua/lua_capi.gen.h` to verify what was generated.
