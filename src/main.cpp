#include "Game.h"
#include "MenuState.h"

int main(){
	Game game("Wenova - Rise of Conquerors");

	State * state =  new MenuState(false);
	game.push(state);

	game.run();

	return 0;
}

int WinMain(){
	return main();
}