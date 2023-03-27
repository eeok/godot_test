#include "game.h"

void godot::Main::_register_methods()
{ 
    register_method("_ready", &Main::_ready);
    register_method("_on_button_pressed", &Main::_on_button_pressed);
}

godot::Main::Main()
{
}

godot::Main::~Main()
{
}

void godot::Main::_init()
{
}

void godot::Main::_ready()
{
    board = Object::cast_to<ShuffleGrid>(get_node("playerBoard")->get_child(1));
}

void godot::Main::_on_button_pressed()
{
    if(board != nullptr)
        board->shuffle();

}
