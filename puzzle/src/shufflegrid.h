//important ifndef et pas pragma dans ce cas askip
#ifndef HELLO_H
#define HELLO_H

#include <Godot.hpp>
#include <GridContainer.hpp>

namespace godot {
    
    class ShuffleGrid : public GridContainer{
        GODOT_CLASS(ShuffleGrid, GridContainer)//important
    
    
    public:
        //fonction statique que Godot appellera pour savoir quelles méthodes peuvent être appelées sur 
        //notre NativeScript et quelles propriétés il expose. 
        static void _register_methods();
        ShuffleGrid();
        ~ShuffleGrid();

        void _init();
        void _ready();
    };

}

#endif