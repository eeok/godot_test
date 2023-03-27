//importer les bibliotheque a exporter en dll
#include "shufflegrid.h"
#include "game.h"

//telling godot initialize linking library
extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *o){
    godot::Godot::gdnative_init(o);
}

extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *o){
    godot::Godot::gdnative_terminate(o);
}

//ici, on dit a godot quoi register (class, property, ....?)
extern "C" void GDN_EXPORT godot_nativescript_init(void *handle){
    godot::Godot::nativescript_init(handle);
    godot::register_class<godot::ShuffleGrid>();
    godot::register_class<godot::Main>();
}