#ifndef GAME_H
#define GAME_H

#include <Godot.hpp>
#include <Node2D.hpp>

#include "shufflegrid.h"

namespace godot {
    
    class Main : public Node2D{
        GODOT_CLASS(Main, Node2D)//important
    
    ShuffleGrid *board;
    public:
        //fonction statique que Godot appellera pour savoir quelles méthodes peuvent être appelées sur 
        //notre NativeScript et quelles propriétés il expose. 
        static void _register_methods();
        Main();
        ~Main();

        void _init();
        void _ready();
        void _on_button_pressed();
    };

}



#endif