#include "shufflegrid.h"
#include <random>
#include <algorithm>

/**
 * @chatgpt
 * 
 * 
 */


using namespace godot;

void ShuffleGrid::_register_methods() {
    register_method("_ready", &ShuffleGrid::_ready);
}

ShuffleGrid::ShuffleGrid() {
   
}

ShuffleGrid::~ShuffleGrid() {
}


void ShuffleGrid::_init() {}

void ShuffleGrid::_ready() {
    // Get all children of the GridContainer
    Array children = get_children();
    std::vector<Node*> kids;
    
    // Convert Godot's Array to a vector of Node pointers
    for (int i = 0; i < children.size(); i++) {
        kids.push_back(Object::cast_to<Node>(children[i]));
    }
    
    // Use a random device to seed the random number generator
    std::random_device rd;
    
    // Create a random number engine and seed it
    std::mt19937 gen(rd());
    
    // Shuffle the children using the random number engine
    std::shuffle(kids.begin(), kids.end(), gen);
    
    // Remove and re-add the shuffled children in their new order
    for (const auto &n : kids) {
        remove_child(n);
        add_child(n);
    }

    Godot::print("oazifhoizfha");
}

