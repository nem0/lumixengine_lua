#include "meta/meta.h"

// Lua meta generation is currently registered here; the generator emits the
// Lua C API and type definitions for this plugin.
static void metaLua(MetaData& data) {
	(void)data;
}

META_PLUGIN(metaLua);
