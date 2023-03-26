#include "shufflegrid.h"
#include <chrono>
#include <algorithm>

/**
 * certes le code est plus long que shuffle.gd
 * mais selon mon gestionnaire de taches, les utilisations ressources sont 'quasi?) les memes 
 * 
 */


using namespace godot;

void ShuffleGrid::_register_methods() {
    register_method("_ready", &ShuffleGrid::_ready);
    register_method("shuffle", &ShuffleGrid::shuffle);
}

ShuffleGrid::ShuffleGrid() {}

ShuffleGrid::~ShuffleGrid() {}


void ShuffleGrid::_init() {    
    auto now = std::chrono::system_clock::now();
    auto seed = std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()).count();
    rng = std::mt19937(seed);
}


//un script gdscript peut appeler shuffle grace a _register_methods
//un peu long, mais appeler un objet RandomNumberGenerator fait crasher le programme 
//(Godot ne s'attends pas à ce qu'on crée un nouvel objet en plein milieu, il doit tout connaitre a l'initialisation je suppose)
void ShuffleGrid::shuffle() {
    // Shuffle the children using the random number engine
    std::shuffle(children.begin(), children.end(), rng);
    // Remove and re-add the shuffled children in their new order
    for (const auto &n : children) {
        remove_child(n);
        add_child(n);
    }
}

void ShuffleGrid::_ready() {    

    //attention, si ce bout de code est en _init, le vecteur children sera vide !
    //le noeud gridcontainer ne connait pas ses enfants à l'initialisation!
    //c'est pour ça que en gdscript, on utilise le mot clé onready pour déclarer
    //des variables qu'on ne connait pas a l'initialisation
    //donc faire ceci est une traduction directe de shuffle.gd :
    //les variables onready sont en fait assignée dans _ready de manière internes par Godot
    Array temp = get_children();
    children.reserve(temp.size());

    for (int i = 0; i < temp.size(); i++) 
        children.push_back(Object::cast_to<Node>(temp[i]));
        //le programme marche sans cast_to<>() mais affiche des messages d'erreurs sur la console Godot

    shuffle();

    //preuve que le script est reconnu
    Godot::print("script gdnative!");
}

